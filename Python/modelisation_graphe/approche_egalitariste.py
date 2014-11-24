# -*- coding: utf-8 -*-

from pygraph.classes.digraph import digraph
from pygraph.algorithms.minmax import maximum_flow
import sys, subprocess
sys.path.insert(0,'../utils')
from command_line import *
from graph_utils import *

def createModel(options):
    #clean main
    model_options=["../modelisation_P0/P0.py", "--notsolve","-w","model"]
    if not options["size"]:
        options["size"]=10
    if not options["value_max"]:
        options["value_max"]=10

    model_options.extend(["-n",str(options["size"])])
    model_options.extend(["-M", str(options["value_max"])])
    
    #print model_options
    subprocess.call(["python2.7"]+model_options)

#parse the model generated to find the capacities for the graph
#the capacities are the coefficients of the objective function
def getCoef(size):
    f=open("models/model.lp", "r")
    f.readline() #useless line
    obj_func=list()
    for line in f:
        #all the line 'till subject contains the coefficients
        if line.startswith("Subject"):
            break
        obj_func+=line.strip().split(' ')
    #get only the numbers
    coef=list()
    for x in obj_func:
        try:
            coef.append(size*float(x))
        except:
            pass

    return coef

def get_sat_max(size,coef,mu):
    new_mu=max(coef)
    for i in range(size):
        for j in range(size):
            if coef[size*i+j]-mu>0 and new_mu>coef[size*i+j]:
                new_mu=coef[size*i+j]
    return new_mu

def getCapacity(size,coef,mu):
    caps=dict()
    for i in range(size):
        caps[('s','a_'+str(i))]=1
        caps[('o_'+str(i),"t")]=1
        for j in range(size):
            if coef[size*i+j]-mu>0:
                caps[("a_"+str(i),"o_"+str(j))]=1
            else:
                caps[("a_"+str(i),"o_"+str(j))]=0
    return caps

def main(argv, current_directory):
    options=parse_command_line(argv)
    size=options['size']
    createModel(options)
    coef=getCoef(size)
    g=createGraph(size)
    #mu is the thresold
    mu=0
    sat_max=0
    (borne_inf,borne_sup)=(0,options['value_max'])
    count=0
    iteration_number=2*log2(size*size)+1
    while count<iteration_number:
        sat_max=mu
        #print("satisfaction_max", mu)
        caps=getCapacity(size,coef,mu)
        (flow,cut)=maximum_flow(g,"s","t",caps)
        if isValid(size,flow):
            borne_inf=mu
            mu=(borne_sup+borne_inf)/2.
        else:
            borne_sup=mu
            mu=(borne_sup+borne_inf)/2.
        count+=1
    print(sat_max)
#Entry point of the program
if __name__ =="__main__":
    #delete the first argument which is the path of the program
    main(sys.argv[1:], sys.argv[0])
