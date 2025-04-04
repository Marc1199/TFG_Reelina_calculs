#!/bin/bash
#SBATCH --job-name=Tutorial_amber       # Nom del job
#SBATCH --output=sortida.txt      # Fitxer de sortida
#SBATCH --error=error.txt         # Fitxer d’errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1        # Nombre de CPUs per tasca
#SBATCH --mem=2GB                 # Memòria assignada
#SBATCH --partition=highmem     # Tipus de partició 
$AMBERHOME/bin/pmemd -O -i 03_Prod.in -o 03_Prod.out -p parm7 -c 02_Heat.ncrst -r 03_Prod.ncrst -x 03_Prod.nc -inf 03_Prod.info
