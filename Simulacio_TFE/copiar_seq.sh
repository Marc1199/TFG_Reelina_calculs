#!/bin/bash

# Definir las carpetas origen y destino
origen="sequencies"
destino="seq_pdb_generados"

# Iterar sobre los archivos en la carpeta origen
for archivo in "$origen"/sequencia_*.pdb; do
    # Obtener el número de la secuencia
    nombre_base=$(basename "$archivo" .pdb)
    
    # Generar el nuevo nombre con el sufijo _TFE_0
    nuevo_nombre="${nombre_base}_TFE_0.pdb"
    
    # Copiar el archivo al destino con el nuevo nombre
    cp "$archivo" "$destino/$nuevo_nombre"
done

echo "Archivos copiados y renombrados correctamente."
