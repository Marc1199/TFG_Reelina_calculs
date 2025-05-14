from pymol import cmd

def modificar_aminoacid(pdb_file, residu_original, residu_nou, posicio):
    """
    Modifica un aminoàcid en una estructura PDB utilitzant PyMOL.
    
    :param pdb_file: Fitxer PDB de la proteïna.
    :param residu_original: Codi de tres lletres de l'aminoàcid original.
    :param residu_nou: Codi de tres lletres de l'aminoàcid nou.
    :param posicio: Número de residu a modificar.
    """
    cmd.load(pdb_file, "proteina")
    seleccio = f"resi {posicio} and resn {residu_original}"
    cmd.wizard("mutagenesis")
    cmd.do(f"select {seleccio}")
    cmd.get_wizard().set_mode(residu_nou)
    cmd.get_wizard().apply()
    cmd.save("/conformacions_mut/conformació_0_mut.pdb")
    cmd.quit()

# Exemple d'ús
modificar_aminoacid("/home/marct/TFG_Reelina_calculs/Simulacio_TFE/sequencies/sequencia_0.pdb", "ARG", "HIS", 16)
