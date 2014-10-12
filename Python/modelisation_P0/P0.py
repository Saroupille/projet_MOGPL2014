# -*- coding: utf-8 -*-

from gurobipy import *
from random import triangular
#parse command line
import sys, getopt
#check the value float
from math import isnan, isinf

#pick random coefficient for the matrix u_{i,j} using triangular law
def picking_random_coefficient_uij(n,m,value_max):
    return [[triangular(0,value_max) for i in range(n)] for j in range(m)]


def parse_command_line(argv):

    try:
        opts, args = getopt.getopt(argv, "hM:n:",["help","maxvalue","size"])
    #raise if an option is not in the list below
    except getopt.GetoptError: 
        print("Options non reconnues. Veuillez utiliser P0.py -h pour en savoir plus")
        sys.exit(2)


    value_max = None
    size = None
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print("P0.py -M <value max for the coef. matrix> -n <size of the problem>")
            print("Options :")
            print("-n <entier> : Spécifier la taille du problème")
            print("-M <float>: Spécifier la valeur maximale pour les coefficients d'utilité")
            print("--size : voir -n") 
            print("--maxvalue : voir -M")
            
        elif opt in ("-M", "--maxvalue"):
            try:
                value_max=float(arg)
                if isnan(value_max) or isinf(value_max) or value_max<=0:
                    raise ValueError
            except ValueError:
                print("Erreur: la valeur maximum doit être un floattant strictement positif valide")
                sys.exit(3)
        elif opt in ("-n", "--size"):
            try:
                size=int(arg)
                if size<=0:
                    raise ValueError
            except ValueError:
                print("Erreur: la taille doit être un entier strictement positif")

    if size == None:
        print("Attention, pas de taille spécifiée pour le problème.")
        print("Par défault, la taille vaudra 10")
        size=10

    if value_max == None:
        print("Attention, pas de taille spécifiée pour le problème.")
        print("Par défault, la valeur maximale sera 10")
        value_max=10

    return (value_max,size)
        
def main(argv):
    (value_max,size)=parse_command_line(argv)


#Entry point of the program
if __name__ =="__main__":
    #delete the first argument which is the path of the program
    main(sys.argv[1:])


