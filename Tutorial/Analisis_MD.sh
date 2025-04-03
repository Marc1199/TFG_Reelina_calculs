#Creació de la carpeta d'analisis i Sel·lecció de la carpeta d'analisi
mkdir Analysis
cd Analysis

#processar el fitxer de sortida de la simulació
$AMBERHOME/bin/process_mdout.perl ../02_Heat.out ../03_Prod.out

#Borrar les peimeres lines del fitxer de densitat ja que es la densitat durant el període d'escalfament.
#Aquest codi ens permet eliminar manualment les lines que es desitgin.
#gedit summary.DENSITY


#1. MD simulation temperature
#2. MD simulation density
#3. MD simulation total, potential, and kinetic energies.
xmgrace summary.TEMP
xmgrace summary.DENSITY
xmgrace summary.ETOT summary.EPTOT summary.EKTOT

#per crear l'arxiu 
gedit rmsd.cpptraj

##El que hem de ficar dintre l'arxiu es el següent:
#trajin 02_Heat.nc
#trajin 03_Prod.nc
#reference 01_Min.ncrst
#autoimage
#rms reference mass out 02_03.rms time 2.0 :2

#Tornal al directori per així poder trobar els scripts nombrats a la seguent línea.
cd ..
$AMBERHOME/bin/cpptraj -p parm7 -i rmsd.cpptraj &> cpptraj.log

#Per veure el plot del RMSD
xmgrace 02_03.rms