#!/bin/bash
#SBATCH --job-name=Tutorial_amber       # Nom del job
#SBATCH --output=sortida.txt            # Fitxer de sortida
#SBATCH --error=error.txt               # Fitxer d’errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1               # Nombre de CPUs per tasca
#SBATCH --mem=2GB                       # Memòria assignada
#SBATCH --partition=highmem             # Tipus de partició  

# Directorio donde están los archivos
DIRECTORIO="/ruta/a/tu/carpeta"

# Iterar sobre los archivos en el directorio
for parm_file in $DIRECTORIO/*.parm7; do
    # Obtener el nombre base del archivo sin la extensión
    base_name=$(basename $parm_file .parm7)
    rst_file="$DIRECTORIO/$base_name.rst7"
    
    # Ejecutar el comando con los archivos actuales
    $AMBERHOME/bin/pmemd -O -i 01_Min.in -o 01_Min_$base_name.out -p $parm_file -c $rst_file -r 01_Min_$base_name.ncrst -inf 01_Min_$base_name.mdinfo
done
