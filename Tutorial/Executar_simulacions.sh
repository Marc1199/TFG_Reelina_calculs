
#Minimitzar
$AMBERHOME/bin/pmemd -O -i 01_Min.in -o 01_Min.out -p parm7 -c rst7 -r 01_Min.ncrst -inf 01_Min.mdinfo

#Heating
$AMBERHOME/bin/pmemd -O -i 02_Heat.in -o 02_Heat.out -p parm7 -c 01_Min.ncrst -r 02_Heat.ncrst -x 02_Heat.nc -inf 02_Heat.mdinfo

#Production
$AMBERHOME/bin/pmemd -O -i 03_Prod.in -o 03_Prod.out -p parm7 -c 02_Heat.ncrst -r 03_Prod.ncrst -x 03_Prod.nc -inf 03_Prod.info


#Per comprovar el proces:
#tail -f 03_Prod.out
#Per sortir del comando fer CTRL+C.

#Veure ordre de cració de fitxers: $ls -ltrsa
