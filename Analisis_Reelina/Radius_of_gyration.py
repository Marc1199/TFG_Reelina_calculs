#!/usr/bin/env python3
import sys
sys.path.append("/home/10033944/paquets")

import MDAnalysis as mda
import pandas as pd
import matplotlib.pyplot as plt
import warnings
import os
import glob

warnings.filterwarnings('ignore')

# ================================
# PARTE 1: Calcular Radius of gyration y generar CSV
# ================================

# Directorios de entrada (rutas actualizadas)
INPUT_NC = "/home/10033944/sortides_MD_reelina/alo"
INPUT_PARM7 = "/home/10033944/TFG_Reelina_calculs/Analisis_Reelina/seq_parm7"

# Directorio destino para guardar los CSV de radio de giración
CSV_RG = "csv_RG"
os.makedirs(CSV_RG, exist_ok=True)

# Lista de archivos .nc en INPUT_NC
fitxers_nc = [f for f in os.listdir(INPUT_NC) if f.endswith(".nc")]

# Generar los nombres correspondientes de .parm7
fitxers_parm7 = [f.replace(".nc", ".parm7") for f in fitxers_nc]

# Iterar sobre cada par de archivos .nc y .parm7
for conf_nc, conf_parm7 in zip(fitxers_nc, fitxers_parm7):
    try:
        print("Procesando:", conf_nc, conf_parm7)
        u = mda.Universe(
            os.path.expanduser(f"{INPUT_PARM7}/{conf_parm7}"),
            os.path.expanduser(f"{INPUT_NC}/{conf_nc}"),
            topology_format="PARM7"
        )
        # Seleccionar los átomos de la proteína
        protein = u.select_atoms("protein")
        # Calcular el radio de giración a lo largo de la trayectoria
        time_list = []
        rgyr_list = []
        for frame in u.trajectory:
            time_list.append(u.trajectory.time)
            rgyr_list.append(protein.radius_of_gyration())
        # Crear un DataFrame con los resultados
        rgyr_df = pd.DataFrame(list(zip(time_list, rgyr_list)),
                               columns=['Time (ps)', 'Radius of gyration (A)'])
        # Guardar el CSV en la carpeta csv_RG
        output_csv = os.path.join(CSV_RG, f"RG_{conf_nc.replace('.nc', '')}.csv")
        rgyr_df.to_csv(output_csv, index=False)
        print("CSV generado:", output_csv)
    except Exception as e:
        print(f"Error procesando {conf_nc}: {e}")

# ================================
# PARTE 2: Agrupar los CSV y generar los gráficos
# ================================

groups_by_mutant = {}
groups_by_tfe = {}

csv_files = glob.glob(os.path.join(CSV_RG, "RG_*.csv"))

for csv_file in csv_files:
    filename = os.path.basename(csv_file)  # Ejemplo: RG_sequencia_0_ARG_TFE_0_wat.csv 
    sim_name = filename.replace("RG_", "").replace(".csv", "")
    tokens = sim_name.split('_')
    
    # Aquí esperamos dos formatos:
    # a) WT: ["sequencia", "0", "TFE", "<conc>", "wat"]  → 5 tokens  
    # b) Mutante: ["sequencia", "0", "<mutant>", "TFE", "<conc>", "wat"]  → 6 tokens
    if len(tokens) == 5:
        if tokens[2].upper() == "TFE":
            mutant = "WT"
            tfe = tokens[3]
        elif tokens[2].upper() == "ATFE":
            # Si por error se lee "ATFE", se considera mutant ARG
            mutant = "ARG"
            tfe = tokens[3]
        else:
            print("Warning: archivo con 5 tokens pero inesperado:", filename, tokens)
            continue
    elif len(tokens) == 6:
        mutant = tokens[2].upper()
        # Si en archivos de 6 tokens el token aparece como "ATFE", lo corregimos a "ARG"
        if mutant == "ATFE":
            mutant = "ARG"
        tfe = tokens[4]
    else:
        print("Warning: estructura inesperada en", filename, tokens)
        continue

    # Para depuración:
    print("Asignado -> Mutante:", mutant, ", TFE:", tfe)
    
    df = pd.read_csv(csv_file)
    
    # Agrupamos por mutante
    if mutant not in groups_by_mutant:
        groups_by_mutant[mutant] = {}
    groups_by_mutant[mutant][tfe] = df
    
    # Agrupamos por concentración de TFE
    if tfe not in groups_by_tfe:
        groups_by_tfe[tfe] = {}
    groups_by_tfe[tfe][mutant] = df

print("Grupos por mutante:", groups_by_mutant.keys())
print("Grupos por TFE:", groups_by_tfe.keys())

# ---------------------------------------
# Grupo 1: Figura con subgráficos por mutante (cada uno con 3 líneas: TFE 0, 20 y 500)
# ---------------------------------------
tfe_levels = ["0", "20", "500"]
mutants_sorted = sorted(groups_by_mutant.keys())

fig1, axs1 = plt.subplots(len(mutants_sorted), 1, figsize=(12, 5 * len(mutants_sorted)))
if len(mutants_sorted) == 1:
    axs1 = [axs1]

for i, mutant in enumerate(mutants_sorted):
    for tfe in tfe_levels:
        if tfe in groups_by_mutant[mutant]:
            df = groups_by_mutant[mutant][tfe]
            axs1[i].plot(df["Time (ps)"], df["Radius of gyration (A)"], label=f"TFE {tfe}")
    axs1[i].set_title(f"Mutant/WT: {mutant}")
    axs1[i].set_xlabel("Time (ps)")
    axs1[i].set_ylabel("Radius of gyration (A)")
    axs1[i].legend()

fig1.tight_layout()
plt.savefig("RG_por_mutante.png", dpi=300)
plt.show()

# ---------------------------------------
# Grupo 2: Figura con subgráficos por concentración de TFE (cada uno con 5 líneas: 4 mutantes + WT)
# ---------------------------------------
def sort_key(x):
    try:
        return int(x)
    except ValueError:
        return 10000

tfe_concentrations = sorted(groups_by_tfe.keys(), key=lambda x: int(x))
mutant_order = ["ARG", "ASP", "HIS", "LYS", "WT"]

fig2, axs2 = plt.subplots(len(tfe_concentrations), 1, figsize=(12, 5 * len(tfe_concentrations)))
if len(tfe_concentrations) == 1:
    axs2 = [axs2]

for i, tfe in enumerate(tfe_concentrations):
    for mutant in mutant_order:
        if mutant in groups_by_tfe[tfe]:
            df = groups_by_tfe[tfe][mutant]
            axs2[i].plot(df["Time (ps)"], df["Radius of gyration (A)"], label=mutant)
    axs2[i].set_title(f"Concentració TFE: {tfe}")
    axs2[i].set_xlabel("Time (ps)")
    axs2[i].set_ylabel("Radius of gyration (A)")
    axs2[i].legend()

fig2.tight_layout()
plt.savefig("RG_por_concentracio.png", dpi=300)
plt.show()

