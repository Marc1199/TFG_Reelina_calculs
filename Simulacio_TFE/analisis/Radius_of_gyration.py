import sys
sys.path.append("/home/10033944/paquets")
import MDAnalysis as mda
import pandas as pd
from matplotlib import pyplot as plt
import warnings
warnings.filterwarnings('ignore')

# Load your trajectory and topology files
import os
u = mda.Universe(
    os.path.expanduser("~/TFG_reelina_calculs/Simulacio_TFE/seq_parm7_rst7/sequencia_0.parm7"),
    os.path.expanduser("~/sortides_TFE/sequencia_0/03_Prod.nc"),
    topology_format="PARM7"
)


# Select the protein atoms
protein = u.select_atoms("protein")

# Calculate the radius of gyration
time=[]
rgyr=[]

for frame in u.trajectory:
    time.append(u.trajectory.time)
    rgyr.append(protein.radius_of_gyration())


#Crear un csv amb els resultats
rgyr_df = pd.DataFrame(list(zip(time, rgyr)),
            columns =['Time (ps)', 'Radius of gyration (A)'],
            index=None)
rgyr_df.to_csv('RG.csv',index=False)


