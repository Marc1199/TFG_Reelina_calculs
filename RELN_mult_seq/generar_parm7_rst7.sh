#Eliminar hidrogens del pdb
grep -v '        H' Reelina_individual.pdb > Reelina_individual_noH.pdb





#Reduim el pdb
#pdb4amber -i Reelina_individual.pdb -o gfp.pdb --dry --reduce

#Arreglar càrregues
#antechamber -fi ccif -i CRO.cif -bk CRO -fo ac -o cro.ac -c bcc -at amber

#Generar el fitxer de càrregues
#prepgen -i cro.ac -o cro.prepin -m cro.mc -rn CRO


# parmchk2 -i cro.prepin -f prepi -o frcmod.cro -a Y \
#          -p $AMBERHOME/dat/leap/parm/parm10.dat

# grep -v "ATTN" frcmod.cro > frcmod1.cro # Strip out ATTN lines
# parmchk2 -i cro.prepin -f prepi -o frcmod2.cro

#generar fiter per al leap
cat <<EOF > leap.inp
source leaprc.protein.ff14SB
source leaprc.water.tip3p
source leaprc.gaff
set default PBRadii mbondi3
x = loadPDB Reelina_individual_noH.pdb
savepdb x Reelina_individual_H.pdb
solvateBox x TIP3PBOX 10.0
addions x Na+ 0
addions x Cl- 0
savepdb x Reelina_individual_wat.pdb
saveAmberParm x Reelina_individual_noH.parm7 Reelina_individual_noH.rst7
quit
EOF

tleap -f leap.inp