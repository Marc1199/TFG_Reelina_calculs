# Codi per a executar el tutorial de LEaP
#Cridar la terminal de linux
#wsl

#Exportar les variables d'entorn
export AMBERHOME=/mnt/d/Marc/TFG/Simulacions_amber/software/amber24
export PATH=$AMBERHOME/bin:$PATH

#Comprovar que s'ha exportat correctament
echo $AMBERHOME
echo $PATH

#Obrir LEaP
tleap -I /mnt/d/Marc/TFG/Simulacions_amber/software/amber24/dat/leap/prep

#Carregar el force field
source leaprc.protein.ff19SB

#Carregar la seqüència
diala = sequence { ACE ALA NME }

#Crear la topologia
source leaprc.water.opc
solvateoct diala OPCBOX  10.0

#Guardar la topologia i les coordenades
saveamberparm diala parm7 rst7

#Sortir de LEaP
quit

############################################################################################################
#Aqui s'ahn de crear els documents corresponents a les simulacions de dinàmica molecular
#01_Min.in
#02_Heat.in
#03_Prod.in
############################################################################################################
