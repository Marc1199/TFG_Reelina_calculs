#!/bin/bash

# Directorios
BASE_DIR="."
INPUT_DIR="seq_pdb_generados_mut"  # Carpeta con los PDB generados previamente (formato: sequencia_{n}_{mut}_TFE_{cantidad}.pdb)
SEQ_PAR_DIR="seq_parm7_rst7"       # Carpeta donde se almacenarán los archivos parm7 y rst7
TMP_DIR="tmp_generados"           # Carpeta temporal para archivos intermedios

# Crear las carpetas de salida si no existen y limpiar su contenido
mkdir -p "$SEQ_PAR_DIR"
mkdir -p "$TMP_DIR"

rm -rf "$SEQ_PAR_DIR"/*
rm -rf "$TMP_DIR"/*

# Procesar cada archivo PDB en la carpeta de estructuras generadas
for pdb_file in "$INPUT_DIR"/*.pdb; do
    # Obtiene el nombre base (sin extensión) del archivo
    base_name=$(basename "$pdb_file" .pdb | tr -d ' ')
    
    echo "Procesando archivo: $pdb_file -> Nombre base: $base_name"

    # Eliminar las líneas de hidrógenos y las etiquetas TER/END, guardando el resultado en archivo temporal
    grep -Ev " H |TER|END" "$pdb_file" > "$TMP_DIR/${base_name}_noH.pdb"
    # Eliminar las líneas que contienen OXT
    sed -i '/OXT/d' "$TMP_DIR/${base_name}_noH.pdb"

    if [[ ! -s "$TMP_DIR/${base_name}_noH.pdb" ]]; then
        echo "Error: No se generó el archivo $TMP_DIR/${base_name}_noH.pdb"
        continue
    fi

    # Crear el archivo leap de entrada para la simulación con agua TIP3P
    cat <<EOF > "$TMP_DIR/leap_${base_name}_agua.inp"
source leaprc.protein.ff14SB
source leaprc.water.tip3p
source leaprc.gaff
loadamberprep prepare_TFE/TFE.prepin
loadAmberParams prepare_TFE/TFE.frcmod
TFE = loadMol2 prepare_TFE/TFE.mol2
set default PBRadii mbondi3
x = loadPDB $TMP_DIR/${base_name}_noH.pdb

# Solvatar con agua TIP3P (se crea una caja de 10 Å alrededor del sistema)
solvateBox x TIP3PBOX 10.0 iso

# Neutralizar el sistema con Cl-
addions x Cl- 11
savePDB x $TMP_DIR/${base_name}_wat.pdb
saveAmberParm x $SEQ_PAR_DIR/${base_name}_wat.parm7 $SEQ_PAR_DIR/${base_name}_wat.rst7
quit
EOF

    # Ejecutar tleap, mostrando la salida en pantalla y registrándola en un log
    tleap -s -f "$TMP_DIR/leap_${base_name}_agua.inp" | tee "$TMP_DIR/tleap_${base_name}_agua.log"

    if [[ ! -s "$SEQ_PAR_DIR/${base_name}_wat.parm7" || ! -s "$SEQ_PAR_DIR/${base_name}_wat.rst7" ]]; then
        echo "Error: No se generaron correctamente los archivos parm7 y rst7 para $base_name con agua"
        cat "$TMP_DIR/tleap_${base_name}_agua.log"
        continue
    fi

    echo "✅ Proceso completado con éxito para $base_name con agua"
    sleep 1
done
