#!/usr/bin/bash
#SBATCH --job-name=Tutorial_amber
#SBATCH --output=sortida.txt
#SBATCH --error=error.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2GB
#SBATCH --partition=highmem

# Directorio donde están los archivos
DIRECTORIO=~/TFG_reelina_calculs/Clauster/conformacions
# Directorio donde se guardarán las salidas
SALIDAS_DIR=~/sortides_MD_reelina

# Crear el directorio de salidas si no existe
mkdir -p $SALIDAS_DIR

# Iterar sobre todos los archivos .parm7 que empiecen por "sequencia_"
for parm_file in $DIRECTORIO/sequencia_*.parm7; do
    # Obtener el nombre base del archivo sin la extensión
    base_name=$(basename "$parm_file" .parm7)
    rst_file="$DIRECTORIO/$base_name.rst7"

    # Verificar que el archivo .rst7 correspondiente existe
    if [[ -f "$rst_file" ]]; then
        echo "Procesando $base_name..."

        # Crear un subdirectorio para cada archivo
        mkdir -p "$SALIDAS_DIR/$base_name"

        # Ejecutar los pasos de simulación
        $AMBERHOME/bin/pmemd -O -i Min.in -o "$SALIDAS_DIR/$base_name/Min.out" -p "$parm_file" -c "$rst_file" -r "$SALIDAS_DIR/$base_name/Min.ncrst" -inf "$SALIDAS_DIR/$base_name/Min.mdinfo"
        $AMBERHOME/bin/pmemd -O -i Heat.in -o "$SALIDAS_DIR/$base_name/Heat.out" -p "$parm_file" -c "$SALIDAS_DIR/$base_name/Min.ncrst" -r "$SALIDAS_DIR/$base_name/Heat.ncrst" -x "$SALIDAS_DIR/$base_name/Heat.nc" -inf "$SALIDAS_DIR/$base_name/Heat.mdinfo"
        $AMBERHOME/bin/pmemd -O -i Prod.in -o "$SALIDAS_DIR/$base_name/Prod.out" -p "$parm_file" -c "$SALIDAS_DIR/$base_name/Heat.ncrst" -r "$SALIDAS_DIR/$base_name/Prod.ncrst" -x "$SALIDAS_DIR/$base_name/Prod.nc" -inf "$SALIDAS_DIR/$base_name/Prod.mdinfo"
    else
        echo "⚠️ Archivo .rst7 no encontrado para $base_name, se omite."
    fi
done
