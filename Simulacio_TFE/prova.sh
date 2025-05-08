#!/bin/bash

cat <<EOF > tleap.inp
source leaprc.protein.ff14SB
source leaprc.gaff
loadAmberParams TFE.frcmod
TFE = loadMol2 TFE.mol2
set default PBRadii mbondi3
x = loadPDB tmp_generados/sequencia_0_noH.pdb
solvateBox x TFE 10.0 iso
setBox x centers
desc x
check x
addIons2 x Na+ 1 Cl- 1 iso
saveAmberParm x seq_parm7_rst7/sequencia_0.parm7 seq_parm7_rst7/sequencia_0.rst7
quit
EOF

tleap -f tleap.inp