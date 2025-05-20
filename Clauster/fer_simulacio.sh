#!/usr/bin/bash
# Directorio donde están los archivos de entrada (.parm7 y .rst7)
DIRECTORIO=~/conformacions
# Directorio donde se guardarán las salidas
SALIDAS_DIR=~/sortides_MD_reelina
# Directorio que contiene los archivos .in (Min.in, Heat.in y Prod.in)
DIRECTORIO_IN=/home/10033944/TFG_Reelina_calculs/Clauster

# Crear el directorio de salidas si no existe y limpiar su contenido
mkdir -p "$SALIDAS_DIR"
rm -rf "$SALIDAS_DIR"/*

# Para cada número del 0 al 20, se creará un script de grupo
for num in {0..20}; do
    # Nombre del script de envío para el grupo
    grupo_script="$SALIDAS_DIR/submit_group_${num}.sh"
    echo "Creando lista de espera para secuencias que comienzan con $num ..."

    # Escribir la cabecera del script utilizando un here document sin expansión
    cat << 'EOF' > "$grupo_script"
#!/usr/bin/bash
#SBATCH --job-name=Grupo_SEQS
#SBATCH --output=grupo_seqs.txt
#SBATCH --error=grupo_seqs.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2GB
#SBATCH --partition=highmem

export SALIDAS_DIR=~/sortides_MD_reelina

EOF

    # Agregar los comandos de simulación para cada secuencia cuyo nombre contenga exactamente "sequencia_<num>_"
    for parm_file in "$DIRECTORIO"/sequencia_"${num}"_*parm7; do
        # Obtener el nombre base del archivo sin extensión
        base_name=$(basename "$parm_file" .parm7)
        rst_file="$DIRECTORIO/$base_name.rst7"

        # Verificar que el archivo .rst7 correspondiente existe
        if [[ -f "$rst_file" ]]; then
            echo "  Agregando simulación para $base_name al grupo $num..."
            cat << EOF >> "$grupo_script"
mkdir -p "\$SALIDAS_DIR/$base_name"
\$AMBERHOME/bin/pmemd -O -i $DIRECTORIO_IN/Min.in -o "\$SALIDAS_DIR/$base_name/Min.out" -p "$parm_file" -c "$rst_file" -r "\$SALIDAS_DIR/$base_name/Min.ncrst" -inf "\$SALIDAS_DIR/$base_name/Min.mdinfo"
\$AMBERHOME/bin/pmemd -O -i $DIRECTORIO_IN/Heat.in -o "\$SALIDAS_DIR/$base_name/Heat.out" -p "$parm_file" -c "\$SALIDAS_DIR/$base_name/Min.ncrst" -r "\$SALIDAS_DIR/$base_name/Heat.ncrst" -x "\$SALIDAS_DIR/$base_name/Heat.nc" -inf "\$SALIDAS_DIR/$base_name/Heat.mdinfo"
\$AMBERHOME/bin/pmemd -O -i $DIRECTORIO_IN/Prod.in -o "\$SALIDAS_DIR/$base_name/Prod.out" -p "$parm_file" -c "\$SALIDAS_DIR/$base_name/Heat.ncrst" -r "\$SALIDAS_DIR/$base_name/Prod.ncrst" -x "\$SALIDAS_DIR/$base_name/Prod.nc" -inf "\$SALIDAS_DIR/$base_name/Prod.mdinfo"

EOF
        else
            echo "  ⚠️ Archivo .rst7 no encontrado para $base_name. Se omite."
        fi
    done
    echo "✅ Lista de espera creada para grupo $num: $grupo_script"
    # Enviar el script de grupo a la cola del clúster
    sbatch "$grupo_script"
done
