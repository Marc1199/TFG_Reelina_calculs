
import pandas as pd
import matplotlib.pyplot as plt

# Llegir els fitxers CSV
df1 = pd.read_csv('./RMSD.csv')
df2 = pd.read_csv('./RMSF.csv')
df3 = pd.read_csv('./RG.csv')


# Assegurar-se que els fitxers tenen almenys dues columnes
if df1.shape[1] < 2 or df2.shape[1] < 2 or df3.shape[1] < 2 :
    raise ValueError("Cada fitxer CSV ha de tenir almenys dues columnes")

# Assignar les columnes a variables
col1_1, col1_2 = df1.columns[0], df1.columns[1]
col2_1, col2_2 = df2.columns[0], df2.columns[1]
col3_1, col3_2 = df3.columns[0], df3.columns[1]

# Crear els gràfics
fig, axs = plt.subplots(1, 3, figsize=(15, 10))

# Gràfic a
axs[0].plot(df1[col1_1], df1[col1_2], linestyle='-')
axs[0].set_title('A. RMSD')
axs[0].set_xlabel(col1_1)
axs[0].set_ylabel(col1_2)
axs[0].grid(True)

# Gràfic b
axs[1].plot(df2[col2_1], df2[col2_2], linestyle='-')
axs[1].set_title('B. RMSF')
axs[1].set_xlabel(col2_1)
axs[1].set_ylabel(col2_2)
axs[1].grid(True)

# Gràfic c
axs[2].plot(df3[col3_1], df3[col3_2], linestyle='-')
axs[2].set_title('C. RG')
axs[2].set_xlabel(col3_1)
axs[2].set_ylabel(col3_2)
axs[2].grid(True)

# Ajustar el layout
plt.tight_layout()
plt.savefig("MD_RMSD_RMSF_RG.png", dpi=300)

