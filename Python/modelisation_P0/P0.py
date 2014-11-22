# -*- coding: utf-8 -*-

from gurobipy import *
from random import triangular
#parse command line
import sys, os, getopt
#check the value float
from math import isnan, isinf

## #pick random coefficient for the matrix u_{i,j} using triangular law
## def picking_random_coefficient_uij(n,value_max):
##     #by default the third argument of triangular is (high+low)/2
##     return [[triangular(0,value_max) for j in range(n)] for i in range(n)]

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

#insert variables in the model
def createVariables(m, options):

    size=options["size"]
    if options["verbose"]:
        print("Add the variables to the model")

    
    #the name of the variable is "x:i:j"
    #the variable is a binary
    #there are size*size variables    
    return [[m.addVar(vtype=GRB.BINARY, name=":".join(["x",str(i),str(j)])) \
             for j in range(size)] for i in range(size)]

#set the objective function
def setObjectiveFunction(m, options, Variables):
    size=options['size']
    value_max=options['value_max']
    
    if options["verbose"]:
        print("Set the objective function")
    
    for i in range(size):
        for j in range(size):
            #for each variable, we add its coefficient in the objective function
            #the coefficient is a random value following a triangular law of parameter [0;M] center in M/2
            Variables[i][j].setAttr("Obj", triangular(0,value_max))

    
    m.setAttr("ModelSense", GRB.MAXIMIZE)

#add the constraints to the model
def addConstraints(m,options, Variables):
    size=options["size"]
    
    if options["verbose"]:
        print("Add the constraints to the model")
    
    for i in range(size):
        l=LinExpr() #one object per person
        c=LinExpr() #one person per object
        for j in range(size):
            l.add(Variables[i][j],"1.")
            c.add(Variables[j][i],"1.")
        
        m.addConstr(l,GRB.EQUAL,1., "l"+str(i))
        m.addConstr(c,GRB.EQUAL,1., "c"+str(i))
        

#create the model P0
def createModel(options):
    if options["verbose"]:
        print("Creating the model...")
    m= Model("P0")
    Variables=createVariables(m, options)
    m.update()
    setObjectiveFunction(m, options, Variables)
    m.update()
    addConstraints(m, options, Variables)
    m.update()
    return m

#main function
def main(argv, current_directory):
    options=parse_command_line(argv)
    m=createModel(options)

    #write the model in a file
    if options["write"]:
        #check if the sub directory "models" exists and create it otherwise
        if not os.path.isdir("models"):
            os.mkdir("models")
        m.write("models/"+options["filename"]+".lp")

    if options["solve"]:
        if options["verbose"]:
            print("Solving...")
    #solve the linear problem
        m.optimize()

    #obj=m.getObjective()
    #print(obj)
    #print(m.getConstrs())
    #print(system("pwd"))
    if options["solve"] and options["answerfile"]!=None:

        #check the existence of the solutions directory
        print("solutions/"+options["answerfile"])
        if not os.path.isdir("solutions"):
            os.mkdir("solutions")
        answerfile=open("solutions/"+options["answerfile"]+".sol","w")
        #If the user has specified a model file
        if options["write"]:
            answerfile.write("Answers for model"+options["filename"])
        
        for v in m.getVars():
            #python2 syntax
            print >> answerfile, v.varName, v.x, v.getAttr("Obj")

        answerfile.close()
    if options["printanswer"]:
        for v in m.getVars():
            print(v.varName, v.x, v.getAttr("Obj"))

    
    #print 'Obj:', m.objVal

#Entry point of the program
if __name__ =="__main__":
    #delete the first argument which is the path of the program
    main(sys.argv[1:], sys.argv[0])


