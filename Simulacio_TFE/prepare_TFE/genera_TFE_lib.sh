#!/bin/bash

# primer, modifiquem el nom de la molècula i l'anomenem TFE
sed -i s/MOL/TFE/g TFE.pdb

# segon, generem el fitxer *prepin, el format que vol amber
antechamber -i TFE.pdb -fi pdb -o TFE.prepin -fo prepi -c bcc -s 2

# tercer, comprovem que els paràmetres existeixen i funcionen
parmchk2 -i TFE.prepin -f prepi -o TFE.frcmod

# quart, generem el fitxer *mol2, el format que vol packmol
antechamber -i TFE.pdb -fi pdb -o TFE.mol2 -fo mol2 -c bcc -s 

# ara executem tleap
# notar que carrego el frcmod, però no cal perquè no hi ha cap
# paràmetre que no estigui ja defini a GAFF
cat <<EOF >_leap_TFE.inp
source leaprc.protein.ff14SB
source leaprc.water.tip3p
source leaprc.gaff
loadamberprep TFE.prepin
loadAmberParams TFE.frcmod 
check TFE
EOF
tleap -s -f _leap_TFE.inp 