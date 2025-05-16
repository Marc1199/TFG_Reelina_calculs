#!/bin/bash

# Directorios
sequences_folder="conformacions_mut"
inp_folder="inp_files"           # Carpeta para los archivos .inp
output_folder="seq_pdb_generados_mut"  # Carpeta para los archivos .pdb
tfe_counts=(0 20 500)            # Cantidades de TFE

# Mutaciones disponibles en el nombre de archivo
mutants=("ARG" "ASP" "HIS" "LYS")

# Crear las carpetas de salida si no existen
mkdir -p "$inp_folder"
mkdir -p "$output_folder"

# Limpiar directorios de salida
rm -rf "$inp_folder"/*
rm -rf "$output_folder"/*

# Iterar sobre las secuencias (0 a 20) y cada tipo de mutante
for i in {0..20}; do
  for mut in "${mutants[@]}"; do
    sequence_file="${sequences_folder}/sequencia_${i}_${mut}.pdb"
    if [ -f "$sequence_file" ]; then
      # Para cada cantidad de TFE se genera un archivo .inp
      for tfe_count in "${tfe_counts[@]}"; do
        inp_filename="${inp_folder}/sequencia_${i}_${mut}_TFE_${tfe_count}.inp"
        pdb_output="${output_folder}/sequencia_${i}_${mut}_TFE_${tfe_count}.pdb"

        cat <<EOF > "$inp_filename"
tolerance 2.0

# Tipo de archivo: pdb
filetype pdb
add_amber_ter

# Nombre del archivo de salida
output $pdb_output

# Molécula central con posición fija
structure $sequence_file
  number 1
  fixed 0.003974832214769661 -0.12196979865771812 0.4291845637583893 0. 0. 0.
  center
end structure

# Moléculas de TFE distribuidas en un cubo
structure prepare_TFE/TFE.pdb
  number $tfe_count     # Número de moléculas de TFE
  inside box -25.0 -25.0 -25.0 25.0 25.0 25.0
end structure
EOF

      done
    else
      echo "WARNING: El archivo $sequence_file no existe, se omite."
    fi
  done
done

echo "✅ Archivos .inp guardados en: $inp_folder"

# Ejecutar packmol para cada archivo .inp
for file in "$inp_folder"/*.inp; do
  packmol < "$file"
  # Aquí podrías añadir instrucciones adicionales para la mutación, si fuese necesario.
done
