import os

def separar_secuencias(input_file, output_prefix, output_dir="sequencies"):
    with open(input_file, 'r') as pdb_file:
        lines = pdb_file.readlines()

    seq_count = 0
    current_seq = []
    has_atoms = False  # Para verificar si la secuencia contiene átomos

    for line in lines:
        if line.startswith("MODEL"):  # Marca el inicio de una nueva secuencia
            if current_seq and has_atoms:
                output_file = os.path.join(output_dir, f"{output_prefix}_{seq_count}.pdb")
                with open(output_file, 'w') as out_file:
                    out_file.writelines(current_seq)
                seq_count += 1
            current_seq = [line]  # Reinicia la secuencia actual
            has_atoms = False  # Restablecer el indicador de átomos

        elif line.startswith("ENDMDL"):
            current_seq.append(line)
            if has_atoms:  # Solo guardar si hay átomos en la estructura
                output_file = os.path.join(output_dir, f"{output_prefix}_{seq_count}.pdb")
                with open(output_file, 'w') as out_file:
                    out_file.writelines(current_seq)
                seq_count += 1
            current_seq = []  # Reinicia la secuencia después de ENDMDL
            has_atoms = False

        else:
            current_seq.append(line)
            if line.startswith(("ATOM", "HETATM")):  # Verifica si hay coordenadas atómicas
                has_atoms = True

    print(f"Se han separado {seq_count} secuencias con átomos en archivos individuales.")

# Configuración
input_pdb = "reelina_mult_seq.pdb"
output_dir = "sequencies"
output_prefix = "sequencia"

# Crear carpeta si no existe
os.makedirs(output_dir, exist_ok=True)

# Ejecutar la función
separar_secuencias(input_pdb, output_prefix, output_dir)
