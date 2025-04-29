import os

# separar_seq.py

def separar_secuencias(input_file, output_prefix):
    with open(input_file, 'r') as pdb_file:
        lines = pdb_file.readlines()

    seq_count = 0
    current_seq = []

    for line in lines:
        if line.startswith("MODEL"):  # Marca el inicio de una nueva secuencia
            if current_seq:
                # Guardar la secuencia anterior en un archivo
                output_file = f"{output_prefix}_{seq_count}.pdb"
                with open(output_file, 'w') as out_file:
                    out_file.writelines(current_seq)
                seq_count += 1
                current_seq = []
        current_seq.append(line)

    # Guardar la última secuencia
    if current_seq:
        output_file = f"{output_prefix}_{seq_count}.pdb"
        with open(output_file, 'w') as out_file:
            out_file.writelines(current_seq)

    print(f"Se han separado {seq_count + 1} secuencias en archivos individuales.")

# Configuración
input_pdb = "reelina_mult_seq.pdb"
output_prefix = "secuencia"

# Ejecutar la función
output_dir = "sequencies"

# Actualizar el prefijo de salida para incluir la carpeta
output_prefix = os.path.join(output_dir, "sequencia")

# Ejecutar la función
separar_secuencias(input_pdb, output_prefix)
