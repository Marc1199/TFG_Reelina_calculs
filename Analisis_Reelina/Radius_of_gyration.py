import sys
sys.path.append("/home/10033944/paquets")
import os
import MDAnalysis as mda
import pandas as pd

# Definir variables como si fueran "$algo"
DIRECTORIO = os.path.expanduser("~/Sortides_MD_reelina")
OUTPUT_DIR = os.path.expanduser("~/resultats_rgyr")
NC_DIR = os.path.expanduser("~/conformacions")

# Asegurar que la carpeta de resultats existeix
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Iterar sobre els fitxers .parm7
for parm_file in os.listdir(DIRECTORIO):
    if parm_file.endswith(".parm7"):
        BASE_NAME = os.path.splitext(parm_file)[0]  # Simulant $base_name

        PARM7_FILE = f"$DIRECTORIO/{BASE_NAME}.parm7"
        NC_FILE = f"$NC_DIR/{BASE_NAME}/03_Prod.nc"

        # Expandir les variables (com en Bash)
        PARM7_FILE = os.path.expanduser(PARM7_FILE.replace("$DIRECTORIO", DIRECTORIO))
        NC_FILE = os.path.expanduser(NC_FILE.replace("$NC_DIR", NC_DIR))

        if not os.path.exists(PARM7_FILE) or not os.path.exists(NC_FILE):
            print(f"Fitxers no trobats per: {BASE_NAME}")
            continue

        # Carregar trajectòria
        u = mda.Universe(PARM7_FILE, NC_FILE, topology_format="PARM7")

        # Seleccionar àtoms de la proteïna
        protein = u.select_atoms("protein")

        # Calcular el radi de gir
        time = []
        rgyr = []

        for frame in u.trajectory:
            time.append(u.trajectory.time)
            rgyr.append(protein.radius_of_gyration())

        # Crear un CSV amb els resultats
        OUTPUT_CSV = f"$OUTPUT_DIR/{BASE_NAME}_RG.csv"
        OUTPUT_CSV = os.path.expanduser(OUTPUT_CSV.replace("$OUTPUT_DIR", OUTPUT_DIR))

        rgyr_df = pd.DataFrame(list(zip(time, rgyr)), columns=['Time (ps)', 'Radius of gyration (A)'])
        rgyr_df.to_csv(OUTPUT_CSV, index=False)

        print(f"Resultats guardats en: {OUTPUT_CSV}")
