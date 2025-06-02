#El RMSF (Root Mean Square Fluctuation) és una mesura de la 
#flexibilitat d'una proteïna, que calcula les fluctuacions 
#mitjanes de les posicions dels àtoms al llarg del temps. 
#Això et permet identificar quines parts de la proteïna són 
#més flexibles o rígides durant una simulació de dinàmica molecular.


import sys
sys.path.append("/home/10033944/paquets")
import MDAnalysis as mda
from MDAnalysis.analysis.rms import RMSF
import matplotlib.pyplot as plt
import warnings
import pandas as pd
import os
import glob

warnings.filterwarnings('ignore')

# Directorios de entrada para los archivos de trayectoria (.nc) y topología (.parm7)
INPUT_NC = "/home/10033944/sortides_MD_reelina/alo"
INPUT_PARM7 = "/home/10033944/TFG_Reelina_calculs/Analisis_Reelina/seq_parm7"

# Carpeta donde se guardarán los CSV
CSV_DIR = "csv"
os.makedirs(CSV_DIR, exist_ok=True)

# Lista de archivos .nc
fitxers_nc = [f for f in os.listdir(INPUT_NC) if f.endswith(".nc")]

# Generar los nombres de los archivos .parm7 correspondientes
fitxers_parm7 = [f.replace(".nc", ".parm7") for f in fitxers_nc]

# Procesamos cada pareja .nc y .parm7 y generamos CSV con los resultados de RMSF
for conf_nc, conf_parm7 in zip(fitxers_nc, fitxers_parm7):
    u = mda.Universe(
        os.path.expanduser(f"{INPUT_PARM7}/{conf_parm7}"),
        os.path.expanduser(f"{INPUT_NC}/{conf_nc}"),
        topology_format="PARM7"
    )

    # Seleccionar los átomos de la proteína
    selection = u.select_atoms("protein")

    # Calcular RMSF
    rmsf = RMSF(selection).run()

    # Convertir los datos a un DataFrame de pandas
    rmsf_df = pd.DataFrame({
        "Residue ID": selection.resids,
        "RMSF (A)": rmsf.rmsf
    })

    # Guardar el DataFrame en un CSV dentro de la carpeta 'csv'
    output_csv = os.path.join(CSV_DIR, f"RMSF_{conf_nc.replace('.nc', '')}.csv")
    rmsf_df.to_csv(output_csv, index=False)

# ------------------------------------------------------------------------------------
# Una vez generados los CSV, a continuación agrupamos los datos para crear
# dos figuras PNG conforme a lo que solicitas.
# ------------------------------------------------------------------------------------

# Estructuras para agrupar por mutante y por concentración de TFE.
groups_by_mutant = {}
groups_by_tfe = {}

# Lista de archivos CSV generados
csv_files = glob.glob(os.path.join(CSV_DIR, "RMSF_*.csv"))

for csv_file in csv_files:
    # Ejemplo de filename: RMSF_sequencia_0_ARG_TFE_0_wat.csv
    filename = os.path.basename(csv_file)
    sim_name = filename.replace("RMSF_", "").replace(".csv", "")
    tokens = sim_name.split('_')
    
    # Si el tercer token es "TFE" se trata de la WT; en caso contrario, el tercer token es el mutante.
    if tokens[2] == "TFE":
        mutant = "WT"
        tfe = tokens[3]  # Por ejemplo, "0"
    else:
        mutant = tokens[2]
        tfe = tokens[4]
    
    df = pd.read_csv(csv_file)
    
    # Agrupar por mutante
    if mutant not in groups_by_mutant:
        groups_by_mutant[mutant] = {}
    groups_by_mutant[mutant][tfe] = df
    
    # Agrupar por concentración de TFE
    if tfe not in groups_by_tfe:
        groups_by_tfe[tfe] = {}
    groups_by_tfe[tfe][mutant] = df

# ------------------------------------------------------------------------------------
# Primera figura: 5 subgráficos (uno por cada mutante/WT).
# En cada gráfico se dibujan 3 líneas correspondientes a las concentraciones de TFE (0, 20 y 500)
# ------------------------------------------------------------------------------------

# Orden esperado de las concentraciones
tfe_orders = ["0", "20", "500"]
# Ordenamos los mutantes (por ejemplo, dará: ARG, ASP, HIS, LYS, WT)
mutants = sorted(groups_by_mutant.keys())

fig1, axs1 = plt.subplots(len(mutants), 1, figsize=(12, 5 * len(mutants)))
# Aseguramos que axs1 sea una lista, aunque haya un solo subplot.
if len(mutants) == 1:
    axs1 = [axs1]

for i, mutant in enumerate(mutants):
    for tfe in tfe_orders:
        if tfe in groups_by_mutant[mutant]:
            df = groups_by_mutant[mutant][tfe]
            axs1[i].plot(df["Residue ID"], df["RMSF (A)"], label=f"TFE {tfe}")
    axs1[i].set_title(f"Mutant/WT: {mutant}")
    axs1[i].set_xlabel("Residue ID")
    axs1[i].set_ylabel("RMSF (Å)")
    axs1[i].legend()

fig1.tight_layout()
plt.savefig("RMSF_por_mutante.png", dpi=300)
plt.show()

# ------------------------------------------------------------------------------------
# Segunda figura: 3 subgráficos (uno por cada concentración de TFE).
# En cada gráfico se dibujan 5 líneas correspondientes a los 4 mutantes y la WT.
# ------------------------------------------------------------------------------------

# Ordenamos las concentraciones de TFE (convertimos a entero para asegurar el orden 0, 20, 500)
tfe_concentrations = sorted(groups_by_tfe.keys(), key=lambda x: int(x))
# Definimos un orden consistente para los mutantes
mutant_order = ["ARG", "ASP", "HIS", "LYS", "WT"]

fig2, axs2 = plt.subplots(len(tfe_concentrations), 1, figsize=(12, 5 * len(tfe_concentrations)))
if len(tfe_concentrations) == 1:
    axs2 = [axs2]

for i, tfe in enumerate(tfe_concentrations):
    for mutant in mutant_order:
        if mutant in groups_by_tfe[tfe]:
            df = groups_by_tfe[tfe][mutant]
            axs2[i].plot(df["Residue ID"], df["RMSF (A)"], label=mutant)
    axs2[i].set_title(f"Concentració TFE: {tfe}")
    axs2[i].set_xlabel("Residue ID")
    axs2[i].set_ylabel("RMSF (Å)")
    axs2[i].legend()

fig2.tight_layout()
plt.savefig("RMSF_por_concentracio.png", dpi=300)
plt.show()


import pandas as pd
import matplotlib.pyplot as plt
import glob
import os

# Carpeta donde están los CSV
CSV_DIR = "csv"

# Estructuras para agrupar por mutante y por concentración de TFE.
groups_by_mutant = {}
groups_by_tfe = {}

# Lista de archivos CSV generados
csv_files = glob.glob(os.path.join(CSV_DIR, "RMSF_*.csv"))

for csv_file in csv_files:
    filename = os.path.basename(csv_file)
    sim_name = filename.replace("RMSF_", "").replace(".csv", "")
    tokens = sim_name.split('_')
    
    # Si el tercer token es "TFE" se trata de la WT; en caso contrario, el tercer token es el mutante.
    if tokens[2] == "TFE":
        mutant = "WT"
        tfe = tokens[3]
    else:
        mutant = tokens[2]
        tfe = tokens[4]
    
    df = pd.read_csv(csv_file)
    
    # Agrupar por mutante
    if mutant not in groups_by_mutant:
        groups_by_mutant[mutant] = {}
    groups_by_mutant[mutant][tfe] = df
    
    # Agrupar por concentración de TFE
    if tfe not in groups_by_tfe:
        groups_by_tfe[tfe] = {}
    groups_by_tfe[tfe][mutant] = df

# Orden esperado de las concentraciones
tfe_orders = ["0", "20", "500"]
# Ordenamos los mutantes
mutants = sorted(groups_by_mutant.keys())

# Creación de la primera figura con distribución en 2 columnas (3 gráficos en la primera, 2 en la segunda)
fig1, axs1 = plt.subplots(nrows=3, ncols=2, figsize=(12, 10))
axs1 = axs1.flatten()

for i, mutant in enumerate(mutants):
    for tfe in tfe_orders:
        if tfe in groups_by_mutant[mutant]:
            df = groups_by_mutant[mutant][tfe]
            axs1[i].hist(df["Residue ID"], bins=30, weights=df["RMSF (A)"], alpha=0.6, label=f"TFE {tfe}")
    axs1[i].set_title(f"Mutant/WT: {mutant}")
    axs1[i].set_xlabel("Residue ID")
    axs1[i].set_ylabel("RMSF (Å)")
    axs1[i].legend()

fig1.tight_layout()
plt.savefig("RMSF_por_mutante_distribuido_hist.png", dpi=300)
plt.show()

# Ordenamos las concentraciones de TFE
tfe_concentrations = sorted(groups_by_tfe.keys(), key=lambda x: int(x))
mutant_order = ["ARG", "ASP", "HIS", "LYS", "WT"]

# Creación de la segunda figura
fig2, axs2 = plt.subplots(len(tfe_concentrations), 1, figsize=(12, 5 * len(tfe_concentrations)))
if len(tfe_concentrations) == 1:
    axs2 = [axs2]

for i, tfe in enumerate(tfe_concentrations):
    for mutant in mutant_order:
        if mutant in groups_by_tfe[tfe]:
            df = groups_by_tfe[tfe][mutant]
            axs2[i].hist(df["Residue ID"], bins=30, weights=df["RMSF (A)"], alpha=0.6, label=mutant)
    axs2[i].set_title(f"Concentració TFE: {tfe}")
    axs2[i].set_xlabel("Residue ID")
    axs2[i].set_ylabel("RMSF (Å)")
    axs2[i].legend()

fig2.tight_layout()
plt.savefig("RMSF_por_concentracio_hist.png", dpi=300)
plt.show()
