#!/usr/bin/bash

#SBATCH --job-name=transferir_noms       # Nombre del job
#SBATCH --output=sortida.txt          # Archivo de salida
#SBATCH --error=error.txt             # Archivo de errores
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4             # Número de CPUs por tarea
#SBATCH --mem=5GB                     # Memoria asignada
#SBATCH --partition=highmem           # Tipo de partición

python RMSF.py

python Radius_of_gyration.py