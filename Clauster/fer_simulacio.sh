#!/usr/bin/bash
# Directorio donde están los archivos de entrada (.parm7 y .rst7)
DIRECTORIO=/users/home/adrian/research/ms_marc/2025.05.21/003/Simulacio_reelina_Adria/conformacions
# Directorio donde se guardarán las salidas
SALIDAS_DIR=/users/home/adrian/research/ms_marc/2025.05.21/003/Simulacio_reelina_Adria/output_alo
# Directorio que contiene los archivos .in (Min.in, Heat.in y Prod.in)
DIRECTORIO_IN=/users/home/adrian/research/ms_marc/2025.05.21/003/Simulacio_reelina_Adria/Clauster
# Crear el directorio de salidas si no existe y limpiar su contenido
mkdir -p “$SALIDAS_DIR”
rm -rf “$SALIDAS_DIR”/*
amber=“/hpcapps/source/a/Amber/test/amber24/bin/pmemd.cuda_SPFP”
# Iterar sobre todos los archivos .parm7 que empiecen por “sequencia_0”
for parm_file in “$DIRECTORIO”/sequencia_0*.parm7; do
    # Obtener el nombre base del archivo sin la extensión
    base_name=$(basename “$parm_file” .parm7)
    rst_file=“$DIRECTORIO/$base_name.rst7”
    # Verificar que el archivo .rst7 correspondiente existe
    if [[ -f “$rst_file” ]]; then
        echo “Procesando $base_name...”
        cat << EOF > “$SALIDAS_DIR/submit_$base_name.sh”
#!/usr/bin/bash
#SBATCH -J $base_name
#SBATCH -o messages_sortida_$base_name.txt
#SBATCH -e messages_error_$base_name.txt
#SBATCH -p gpu-1xA100
#SBATCH --hint=nomultithread
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
ml use /hpcapps/lib-bio/modules/all
ml load Amber
pmemd --version
/hpcapps/source/a/Amber/test/amber24/bin/pmemd.cuda_SPFP --version
date
pwd
echo $PATH
echo “about to start working”
# Crear un subdirectorio para cada archivo
mkdir -p “$SALIDAS_DIR/$base_name”
# Ejecutar los pasos de simulación
${amber} -O -i $DIRECTORIO_IN/Min.in -o “$SALIDAS_DIR/$base_name/Min.out” -p “$parm_file” -c “$rst_file” -r “$SALIDAS_DIR/$base_name/Min.ncrst” -inf “$SALIDAS_DIR/$base_name/Min.mdinfo”
${amber} -O -i $DIRECTORIO_IN/Heat.in -o “$SALIDAS_DIR/$base_name/Heat.out” -p “$parm_file” -c “$SALIDAS_DIR/$base_name/Min.ncrst” -r “$SALIDAS_DIR/$base_name/Heat.ncrst” -x “$SALIDAS_DIR/$base_name/Heat.nc” -inf “$SALIDAS_DIR/$base_name/Heat.mdinfo”
${amber} -O -i $DIRECTORIO_IN/Prod.in -o “$SALIDAS_DIR/$base_name/Prod.out” -p “$parm_file” -c “$SALIDAS_DIR/$base_name/Heat.ncrst” -r “$SALIDAS_DIR/$base_name/Prod.ncrst” -x “$SALIDAS_DIR/$base_name/Prod.nc” -inf “$SALIDAS_DIR/$base_name/Prod.mdinfo”
echo “all done”
date
EOF
        # Enviar el script al clúster
        sbatch “$SALIDAS_DIR/submit_$base_name.sh”
        echo “submitted $base_name.”
    else
        echo “file .rst7 not found $base_name”
    fi
done