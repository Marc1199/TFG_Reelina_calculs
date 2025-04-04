#!/bin/bash
#SBATCH --job-name=Tutorial_amber       # Nom del job
#SBATCH --output=sortida.txt      # Fitxer de sortida
#SBATCH --error=error.txt         # Fitxer d’errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1        # Nombre de CPUs per tasca
#SBATCH --mem=2GB                 # Memòria assignada
#SBATCH --partition=highmem     # Tipus de partició  
$AMBERHOME/bin/pmemd -O -i 02_Heat.in -o 02_Heat.out -p parm7 -c 01_Min.ncrst -r 02_Heat.ncrst -x 02_Heat.nc -inf 02_Heat.mdinfo
