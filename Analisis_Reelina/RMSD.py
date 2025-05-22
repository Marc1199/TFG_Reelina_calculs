#comparar diferents conformacions d'aquesta proteïna al llarg del 
#temps durant una simulació de dinàmica molecular. Pots veure com 
#canvien les conformacions de la proteïna i quant es desviïen de 
# la conformació inicial o de referència.
import sys
sys.path.append("/home/10033944/paquets")
import MDAnalysis as mda
from MDAnalysis.analysis.hydrogenbonds.hbond_analysis import HydrogenBondAnalysis as HBA
import matplotlib.pyplot as plt
import pandas as pd
import warnings
from MDAnalysis.analysis import rms
# suppress some MDAnalysis warnings
warnings.filterwarnings('ignore')

# Cargar el archivo de topología y trayectoria

import os

for conf in os.listdir("~/Sortides_MD_reelina/sequencia_0*.nc"):
    u = mda.Universe(
        os.path.expanduser("~/TFG_reelina_calculs/Simulacio_TFE/seq_parm7_rst7/sequencia_0.parm7"),
        os.path.expanduser(conf),
        topology_format="PARM7"
    )


sel = u.select_atoms('protein')

# Calculate RMSD
R = rms.RMSD(u, u, select='protein and name CA')
R.run()

rmsd_df = pd.DataFrame(R.results.rmsd,
                    columns=['Frame', 'Time (ps)', 'Backbone'])
rmsd_df = rmsd_df[['Time (ps)', 'Backbone']]
rmsd_df.to_csv('RMSD.csv',index=False)
