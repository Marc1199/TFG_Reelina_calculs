#!/bin/bash

# Directorios
sequences_folder="sequencies"
inp_folder="inp_files"  # Carpeta para los archivos .inp
output_folder="seq_pdb_generados"  # Carpeta para los archivos .pdb
tfe_counts=(5 50 100 250 500)  # Cantidades de TFE por cada secuencia

# Crear las carpetas de salida si no existen
mkdir -p "$inp_folder"
mkdir -p "$output_folder"

rm -rf "$inp_folder"/*
rm -rf "$output_folder"/*

# Iterar sobre las 21 secuencias
for i in {0..20}; do
    sequence_file="${sequences_folder}/sequencia_${i}.pdb"

    # Generar archivos .inp para cada cantidad de TFE
    for tfe_count in "${tfe_counts[@]}"; do
        inp_filename="${inp_folder}/sequencia_${i}_TFE_${tfe_count}.inp"
        pdb_output="${output_folder}/sequencia_${i}_TFE_${tfe_count}.pdb"

        cat <<EOF > "$inp_filename"
tolerance 2.0

# The type of the files will be pdb
filetype pdb
add_amber_ter

# The name of the output file
output $pdb_output

# Molécula central fija en una posición específica
structure $sequence_file
  number 1
  fixed 0.003974832214769661 -0.12196979865771812 0.4291845637583893 0. 0. 0.
  center
end structure

# Moléculas de TFE distribuidas dentro de un cubo
structure prepare_TFE/TFE.pdb
  number $tfe_count     # Número de moléculas de TFE
  inside box -25.0 -25.0 -25.0 25.0 25.0 25.0  # Define un cubo de 40 Å de lado
end structure
EOF
    done
done

echo "✅ Archivos .inp guardados en: $inp_folder"

for file in inp_files/*.inp; do packmol < "$file"; done

