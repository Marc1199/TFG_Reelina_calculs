#!/bin/bash

# Archivo de entrada
INPUT_FILE="pdb_wt/sequencia_0_TFE_5_wat.pdb"
# Archivo de salida
OUTPUT_FILE="conformacio_0_TFE_5_wat_mut.pdb"

# 1. Eliminar las líneas de los átomos N, H, CA, HA y CB de ARG 18
# 1. Mantener solo los átomos N, H, CA, HA y CB del residuo ARG 18 y eliminar el resto de sus átomos
grep -vE "ATOM\s+[0-9]+\s+(CG|HG2|HG3|CD|HD2|HD3|NE|HE|CZ|NH1|HH11|HH12|NH2|HH21|HH22|C|O)\s+ARG\s+18" "$INPUT_FILE" > temp.pdb

# 2. Reemplazar ARG por HIS en los átomos restantes del residuo 18
sed 's/\bARG\b/HIS/g' temp.pdb 

#############################################
#elimina hidrogens
grep -Ev " H |TER|END" temp.pdb > "$OUTPUT_FILE"
#############################################


rm temp.pdb

cat <<EOF > "test.inp"
source leaprc.protein.ff14SB
source leaprc.water.tip3p 
source leaprc.gaff

# Cargar parámetros de TFE
loadamberprep /home/marct/TFG_Reelina_calculs/Simulacio_TFE/prepare_TFE/TFE.prepin
loadAmberParams /home/marct/TFG_Reelina_calculs/Simulacio_TFE/prepare_TFE/TFE.frcmod
TFE = loadMol2 /home/marct/TFG_Reelina_calculs/Simulacio_TFE/prepare_TFE/TFE.mol2

# Cargar el PDB original
mol = loadPdb /home/marct/TFG_Reelina_calculs/Simulacio_TFE_mut/conformacio_0_TFE_5_wat_mut.pdb

# Guardar los archivos de parámetros y coordenadas finales
saveAmberParm mol test.parm7 test.srt7

# Salir de LEaP
quit
EOF


tleap -s -f test.inp | tee test.log
