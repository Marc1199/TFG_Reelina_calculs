ssh -l marc.tomas@uvic.cat lavandula.uvic.local

#COPYING FILES TO CLUSTER
scp -r head.sh  marc.tomas@uvic.cat@lavandula.uvic.local:~/Tutorial 

#COPYING FILES FROM CLUSTER
scp -r nsekhar@192.168.133.2:PATH OF THE CLUSTER/FOLDER .
sbatch


#!/bin/bash
#SBATCH --job-name=Tutorial_amber       # Nom del job
#SBATCH --output=sortida.txt      # Fitxer de sortida
#SBATCH --error=error.txt         # Fitxer d’errors
#SBATCH --cpus-per-task=1        # Nombre de CPUs per tasca
#SBATCH --mem=2GB                 # Memòria assignada
#SBATCH --partition=highmem     # Tipus de partició
