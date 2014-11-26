# -*- coding: utf-8 -*-

import getopt
import sys
from math import isnan, isinf
def clean_string(filename):
    return "".join([c for c in filename if c.isalpha() or c.isdigit() or c=='_']).rstrip()

def parse_command_line(argv):

    try:
        opts, args = getopt.getopt(argv, "hdw:vM:n:a:p", \
                                   ["help","notsolve","write", "verbose", "maxvalue","size","answerfile","printanswer"])
    #raise if an option is not in the list below
    except getopt.GetoptError: 
        print("Options non reconnues. Veuillez utiliser P0.py -h pour en savoir plus")
        sys.exit(2)

    options=dict()
    options['value_max']=None
    options['size']=None
    options['verbose']=False
    options['write']=False
    options['filename']=None
    options['answerfile']=None
    options['printanswer']=False
    options['solve']=True
    #value_max = None
    #size = None
    #verbose=False
    #write the model in a file
    #write=False
    #filename=None
    
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print("gurobi.sh P0.py -M <value max for the coef. matrix> -n <size of the problem> [-v]")
            print("Options :")
            print("\t-n (--size) <entier> : Spécifier la taille du problème")
            print("\t-M (--maxvalue) <float> : Spécifier la valeur maximale pour les coefficients d'utilité")
            print("\t-v (--verbose) : affiche des informations supplémentaires à l'écran")
            print("\t-w (--write) <nom fichier>: écrire le modèle dans un fichier ")
            print("\t-a (--answerfile) <nom fichier>: redirige la sortie standard dans un fichier")
            print("\t-p (--printanswer) : écrit la solution sur la sortie standard")
            print("\t--notsolve) : ne résoud pas le modèle généré")
            sys.exit(0)
            
        elif opt in ("-M", "--maxvalue"):
            try:
                options["value_max"]=float(arg)
                if isnan(options["value_max"]) or \
                    isinf(options["value_max"]) or \
                    options["value_max"]<=0:
                    raise ValueError
            except ValueError:
                print("Erreur: la valeur maximum doit être un floattant strictement positif valide")
                sys.exit(3)
        elif opt in ("-n", "--size"):
            try:
                options["size"]=int(arg)
                if options["size"]<=0:
                    raise ValueError
            except ValueError:
                print("Erreur: la taille doit être un entier strictement positif")
        elif opt in("-v", "--verbose"):
            options["verbose"]=True
        elif opt in("-w", "--write"):
            options["write"]=True
            options["filename"]=clean_string(arg)
        elif opt in("-a", "--answerfile"):
            options["answerfile"]=clean_string(arg)
        elif opt in("-p", "--printanswer"):
            options["printanswer"]=True
        elif opt in("-d", "--notsolve"):
            options["solve"]=False
            
    #if the user has not specified some parameters
    if options["size"] == None:
        print("Attention, pas de taille spécifiée pour le problème.")
        print("Par défault, la taille vaudra 10")
        options["size"]=10

    if options["value_max"] == None:
        print("Attention, pas de taille spécifiée pour le problème.")
        print("Par défault, la valeur maximale sera 10")
        options["value_max"]=10
    
    return options
