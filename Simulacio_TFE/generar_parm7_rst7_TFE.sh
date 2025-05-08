#!/bin/bash

# Directorios
BASE_DIR="."
INPUT_DIR="sequencies"
SEQ_TFE_DIR="seq_tfe"
SEQ_PAR_DIR="seq_parm7_rst7"
TMP_DIR="tmp_generados"
SEQ_PDB_DIR="seq_pdb_generados"

# Crear carpetas si no existen
mkdir -p "$SEQ_PAR_DIR"
mkdir -p "$TMP_DIR"
mkdir -p "$SEQ_PDB_DIR"

rm -rf seq_parm7_rst7/*
rm -rf tmp_generados/*
rm -rf seq_pdb_generados/*

# Número de moléculas de TFE a agregar
TFE_MOLECULES=(5 25 100 250 500)

# Procesar cada archivo PDB en la carpeta de secuencias
for pdb_file in "$INPUT_DIR"/*.pdb; do
    base_name=$(basename "$pdb_file" .pdb | tr -d ' ')
    
    echo "Procesando archivo: $pdb_file -> Nombre base: $base_name"

    # Eliminar hidrógenos y guardar el archivo procesado
    grep -Ev " H |TER|END" "$pdb_file" > "$TMP_DIR/${base_name}_noH.pdb"

    if [[ ! -s "$TMP_DIR/${base_name}_noH.pdb" ]]; then
        echo "Error: No se generó el archivo $TMP_DIR/${base_name}_noH.pdb"
        continue
    fi

    # Iterar sobre diferentes cantidades de TFE
    for num_tfe in "${TFE_MOLECULES[@]}"; do
        echo "Generando sistema con ${num_tfe} moléculas de TFE"

        # Crear el archivo leap para la simulación
        cat <<EOF > "$TMP_DIR/leap_${base_name}_TFE${num_tfe}.inp"
source leaprc.protein.ff14SB
source leaprc.water.opc
source leaprc.gaff
loadAmberParams TFE.frcmod
TFE = loadMol2 TFE.mol2
set default PBRadii mbondi3
x = loadPDB $TMP_DIR/${base_name}_noH.pdb

# Solvatizar primero con agua OPC
solvateBox x OPCBOX 10.0 iso

# Agregar un número fijo de moléculas de TFE distribuidas uniformemente
add x TFE ${num_tfe}

setBox x centers

savePDB x $SEQ_PDB_DIR/${base_name}_TFE${num_tfe}.pdb
saveAmberParm x $SEQ_PAR_DIR/${base_name}_TFE${num_tfe}.parm7 $SEQ_PAR_DIR/${base_name}_TFE${num_tfe}.rst7
quit
EOF

        # Ejecutar tleap con salida en pantalla y log
        tleap -s -f "$TMP_DIR/leap_${base_name}_TFE${num_tfe}.inp" | tee "$TMP_DIR/tleap_${base_name}_TFE${num_tfe}.log"

        if [[ ! -s "$SEQ_PAR_DIR/${base_name}_TFE${num_tfe}.parm7" || ! -s "$SEQ_PAR_DIR/${base_name}_TFE${num_tfe}.rst7" ]]; then
            echo "Error: No se generaron correctamente los archivos parm7 y rst7 para $base_name con ${num_tfe} moléculas de TFE"
            cat "$TMP_DIR/tleap_${base_name}_TFE${num_tfe}.log"
            continue
        fi

        echo "✅ Proceso completado con éxito para $base_name con ${num_tfe} moléculas de TFE"
        sleep 1
    done
done
