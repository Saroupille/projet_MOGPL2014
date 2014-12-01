# -*- coding: utf-8 -*-

from gurobipy import *
from random import triangular
#parse command line
import sys, os, getopt
import sys, os, getopt
file_path = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(1,file_path+'/../utils')
from command_line import *

#pull the utilities from a triangular law
def utilites(size,value_max):
    return [[triangular(0,value_max) for i in range(size)] for j in range(size)]


#insert variables in the model
def createVariables(m, options):

    size=options["size"]
    if options["verbose"]:
        print("Add the variables to the model")

        #the name of the variable is "x:i:j"
    #the variable is a binary
    #there are size*size variables
    #Variables is a tuple. The first component is the same as P0, the second is the variable in the
    #objective function
    return [[m.addVar(vtype=GRB.BINARY, name="_".join(["x",str(i),str(j)])) \
             for j in range(size)] for i in range(size)],m.addVar(vtype=GRB.SEMICONT , name="zmin")

def setObjectiveFunction(m, options, zmin):
    
    if options["verbose"]:
        print("Set the objective function")

    zmin.setAttr("Obj", 1)
    m.setAttr("ModelSense", GRB.MAXIMIZE)

#add the constraints to the model
def addConstraints(m,options, Variables,utils,zmin):
    size=options["size"]
    value_max=options["value_max"]
    if options["verbose"]:
        print("Add the constraints to the model")

    #same constraints as P0
    for i in range(size):
        l=LinExpr() #one object per person
        c=LinExpr() #one person per object
        for j in range(size):
            l.add(Variables[i][j],"1.")
            c.add(Variables[j][i],"1.")
        
        m.addConstr(l,GRB.EQUAL,1., "l"+str(i))
        m.addConstr(c,GRB.EQUAL,1., "c"+str(i))


    #we add the constraint that zmin must be less than any other satisfaction
    for i in range(size):
        z=LinExpr()
        for j in range(size):
            z.add(Variables[i][j], utils[i][j])

        z.add(zmin, -1)
        m.addConstr(z, GRB.GREATER_EQUAL,0., "z"+str(i))
        

#create the model P1
def createModel(options,utils):
    if options["verbose"]:
        print("Creating the model...")
    m= Model("P1")
    Variables,zmin=createVariables(m, options)
    m.update()
    setObjectiveFunction(m, options, zmin)
    m.update()
    addConstraints(m, options, Variables,utils,zmin)
    m.update()
    return m

#main function
def main(argv, current_directory):
    options=parse_command_line(argv)
    size=options["size"]
    value_max=options["value_max"]
    utils=utilites(size,value_max)
    m=createModel(options,utils)
    
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
        
        constraints=[m.getConstrByName("z"+str(i)) for i in range(options["size"])]
        for v in m.getVars():
            if v.varName!="zmin":
                for c in constraints:
                    if m.getCoeff(c,v)!=0:
                        answerfile.write(" ".join([str(v.varName),str(v.x),str(m.getCoeff(c,v))+"\n"]))
          
        answerfile.close()

        
    #TO DO : change this stuff
    if options["printanswer"]:
        constraints=[m.getConstrByName("z"+str(i)) for i in range(options["size"])]
        for v in m.getVars():
            if v.varName!="zmin":
                for c in constraints:
                    if m.getCoeff(c,v)!=0:
                        print(v.varName,v.x,m.getCoeff(c,v))
            else:
                print(v.varName,v.x,m.getCoeff(c,v))

    
    #print 'Obj:', m.objVal

#Entry point of the program
if __name__ =="__main__":
    #delete the first argument which is the path of the program
    main(sys.argv[1:], sys.argv[0])


