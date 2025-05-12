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
warnings.filterwarnings('ignore')

# Load your trajectory and topology files
import os
u = mda.Universe(
    os.path.expanduser("~/TFG_reelina_calculs/Simulacio_TFE/seq_parm7_rst7/sequencia_0.parm7"),
    os.path.expanduser("~/sortides_TFE/sequencia_0/03_Prod.nc"),
    topology_format="PARM7"
)


# Select the atoms you want to analyze
selection = u.select_atoms('protein')

# Perform RMSF calculation
rmsf = RMSF(selection).run()


# Convert the data to a pandas DataFrame
rmsf_df = pd.DataFrame({
        'Residue ID': selection.resids,
        'RMSF (A)': rmsf.rmsf
            })

# Save the DataFrame to a CSV file
rmsf_df.to_csv("RMSF.csv", index=False)


