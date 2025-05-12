#!/usr/bin/bash
#SBATCH --job-name=Tutorial_amber       # Nom del job
#SBATCH --output=sortida.txt            # Fitxer de sortida
#SBATCH --error=error.txt               # Fitxer d’errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1               # Nombre de CPUs per tasca
#SBATCH --mem=2GB                       # Memòria assignada
#SBATCH --partition=highmem             # Tipus de partició 

export AMBERHOME=~/Software/amber24
export PATH=$AMBERHOME/bin:$PATH

# Directorio donde están los archivos
DIRECTORIO=~/TFG_reelina_calculs/Simulacio_TFE/seq_parm7_rst7
# Directorio donde se guardarán las salidas
SALIDAS_DIR=~/sortides_TFE

# Crear el directorio de salidas si no existe
mkdir -p $SALIDAS_DIR

# Iterar sobre los archivos en el directorio
for parm_file in $DIRECTORIO/*.parm7; do
    # Obtener el nombre base del archivo sin la extensión
    base_name=$(basename $parm_file .parm7)
    rst_file="$DIRECTORIO/$base_name.rst7"
   
    # Crear un subdirectorio para cada archivo
    mkdir -p $SALIDAS_DIR/$base_name
   
    # Ejecutar el comando con los archivos actuales y guardar las salidas en el subdirectorio correspondiente  
    $AMBERHOME/bin/pmemd -O -i 01_Min.in -o $SALIDAS_DIR/$base_name/01_Min.out -p $parm_file -c $rst_file -r $SALIDAS_DIR/$base_name/01_Min.ncrst -inf $SALIDAS_DIR/$base_name/01_Min.mdinfo
    $AMBERHOME/bin/pmemd -O -i 02_Heat.in -o $SALIDAS_DIR/$base_name/02_Heat.out -p $parm_file -c $SALIDAS_DIR/$base_name/01_Min.ncrst -r $SALIDAS_DIR/$base_name/02_Heat.ncrst -x $SALIDAS_DIR/$base_name/02_Heat.nc -inf $SALIDAS_DIR/$base_name/02_Heat.mdinfo
    $AMBERHOME/bin/pmemd -O -i 03_Prod.in -o $SALIDAS_DIR/$base_name/03_Prod.out -p $parm_file -c $SALIDAS_DIR/$base_name/02_Heat.ncrst -r $SALIDAS_DIR/$base_name/03_Prod.ncrst -x $SALIDAS_DIR/$base_name/03_Prod.nc -inf $SALIDAS_DIR/$base_name/03_Prod.info
done

