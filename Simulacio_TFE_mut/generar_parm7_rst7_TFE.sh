#!/bin/bash

# Directorios
BASE_DIR="."
INPUT_DIR="seq_pdb_generados"  # Carpeta con los PDB generados previamente
SEQ_PAR_DIR="seq_parm7_rst7"
TMP_DIR="tmp_generados"

# Crear carpetas si no existen
mkdir -p "$SEQ_PAR_DIR"
mkdir -p "$TMP_DIR"

rm -rf seq_parm7_rst7/*
rm -rf tmp_generados/*

# Procesar cada archivo PDB en la carpeta de estructuras generadas
for pdb_file in "$INPUT_DIR"/*.pdb; do
    base_name=$(basename "$pdb_file" .pdb | tr -d ' ')
    
    echo "Procesando archivo: $pdb_file -> Nombre base: $base_name"

    # Eliminar hidrógenos y guardar el archivo procesado
    grep -Ev " H |TER|END" "$pdb_file" > "$TMP_DIR/${base_name}_noH.pdb"
    # Eliminar OXT
    sed -i '/OXT/d' "$TMP_DIR/${base_name}_noH.pdb"

    if [[ ! -s "$TMP_DIR/${base_name}_noH.pdb" ]]; then
        echo "Error: No se generó el archivo $TMP_DIR/${base_name}_noH.pdb"
        continue
    fi

    # Crear el archivo leap para la simulación
    cat <<EOF > "$TMP_DIR/leap_${base_name}_agua.inp"
source leaprc.protein.ff14SB
source leaprc.water.tip3p
source leaprc.gaff
loadamberprep prepare_TFE/TFE.prepin
loadAmberParams prepare_TFE/TFE.frcmod
TFE = loadMol2 prepare_TFE/TFE.mol2
set default PBRadii mbondi3
x = loadPDB $TMP_DIR/${base_name}_noH.pdb

# Solvatar con agua TIP3P
solvateBox x TIP3PBOX 10.0 iso

# Neutralizar el sistema con Cl-
addions x Cl- 11
savePDB x $TMP_DIR/${base_name}_wat.pdb
saveAmberParm x $SEQ_PAR_DIR/${base_name}_wat.parm7 $SEQ_PAR_DIR/${base_name}_wat.rst7
quit
EOF

    # Ejecutar tleap con salida en pantalla y log
    tleap -s -f "$TMP_DIR/leap_${base_name}_agua.inp" | tee "$TMP_DIR/tleap_${base_name}_agua.log"

    if [[ ! -s "$SEQ_PAR_DIR/${base_name}_wat.parm7" || ! -s "$SEQ_PAR_DIR/${base_name}_wat.rst7" ]]; then
        echo "Error: No se generaron correctamente los archivos parm7 y rst7 para $base_name con agua"
        cat "$TMP_DIR/tleap_${base_name}_agua.log"
        continue
    fi

    echo "✅ Proceso completado con éxito para $base_name con agua"
    sleep 1
done

