#!/bin/bash

# Directorio donde está el script y las carpetas de salida
BASE_DIR="."  # Usa la carpeta actual en lugar de RELN_mult_seq
INPUT_DIR="sequencies"
SEQ_WAT_DIR="seq_wat"
SEQ_PAR_DIR="seq_parm7_rst7"
TMP_DIR="tmp_generados"

# Crear carpeta para archivos temporales
mkdir -p "$TMP_DIR"

# Procesar cada archivo PDB en la carpeta sequencies
for pdb_file in "$INPUT_DIR"/*.pdb; do
    base_name=$(basename "$pdb_file" .pdb)

    # Eliminar hidrógenos y guardar el archivo procesado en tmp_generados
    grep -Ev " H |TER|END" "$pdb_file" > "$TMP_DIR/${base_name}_noH.pdb"


    # Verificar que el archivo _noH.pdb se ha generado
    if [[ ! -s "$TMP_DIR/${base_name}_noH.pdb" ]]; then
        echo "Error: No se generó el archivo $TMP_DIR/${base_name}_noH.pdb"
        continue  # Saltar esta iteración si hay error
    fi

    # Crear el archivo leap para la secuencia dentro de tmp_generados
    cat <<EOF > "$TMP_DIR/leap_$base_name.inp"
source leaprc.protein.ff14SB
source leaprc.water.tip3p
source leaprc.gaff
set default PBRadii mbondi3

x = loadPDB $TMP_DIR/${base_name}_noH.pdb
savepdb x $TMP_DIR/${base_name}_H.pdb
solvateBox x TIP3PBOX 10.0
addions x Na+ 0
addions x Cl- 0
savepdb x $SEQ_WAT_DIR/${base_name}_wat.pdb
saveAmberParm x $SEQ_PAR_DIR/${base_name}.parm7 $SEQ_PAR_DIR/${base_name}.rst7
quit
EOF

    # Verificar que leap.inp se generó antes de ejecutar tleap
    if [[ ! -s "$TMP_DIR/leap_$base_name.inp" ]]; then
        echo "Error: No se generó el archivo $TMP_DIR/leap_$base_name.inp"
        continue
    fi

    # Ejecutar tleap para esta secuencia y guardar la salida en tmp_generados
    tleap -s -f "$TMP_DIR/leap_$base_name.inp" > "$TMP_DIR/tleap_$base_name.log" 2>&1

    # Verificar si los archivos parm7 y rst7 se han generado correctamente
    if [[ ! -s "$SEQ_PAR_DIR/${base_name}.parm7" || ! -s "$SEQ_PAR_DIR/${base_name}.rst7" ]]; then
        echo "Error: No se generaron correctamente los archivos parm7 y rst7 para $base_name"
    fi
done
