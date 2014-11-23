# -*- coding: utf-8 -*-

from math import isnan, isinf
from pygraph.classes.digraph import digraph
from pygraph.algorithms.minmax import maximum_flow
from functools import reduce
import sys, subprocess
sys.path.insert(0,'../utils')
from command_line import *
from graph_utils import *
from debug_utils import *



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
def getCoef():
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
            coef.append(10*float(x))
        except:
            pass

    return coef
            
#main function

def satisfactions_max(size, coef):
    satisfactions_max=list()
    for i in range(size):
        satisfactions_max.append(max(coef[size*i:size*(i+1)]))

    return satisfactions_max

def get_current_satisfaction(size, coef, flow):
    current_satisfaction=[None]*size
    for x,y in flow:
        if x.startswith("a_") and flow[(x,y)]==1:
            a=int(x[2:len(x)])
            o=int(y[2:len(x)])
            current_satisfaction[a]=coef[size*a+o]
    return current_satisfaction
            
def regret_max(size, coef, flow):
    sat_max=satisfactions_max(size,coef)
    current_sat=get_current_satisfaction(size,coef,flow)
    diff = lambda (x,y): x-y
    regret_max=max(map(diff, zip(sat_max,current_sat)))
    return regret_max

#TO DO: optimize sat max
def getCapacity(size, coef,mu):
    caps=dict()
    sat_max=satisfactions_max(size,coef)
    for i in range(size):
        caps[('s','a_'+str(i))]=1
        caps[('o_'+str(i),"t")]=1
        for j in range(size):
            if sat_max[i]-coef[size*i+j]<mu:
                caps[("a_"+str(i),"o_"+str(j))]=1
            else:
                caps[("a_"+str(i),"o_"+str(j))]=0
    return caps

def main(argv, current_directory):
    options=parse_command_line(argv)
    size=options['size']
    createModel(options)
    coef=getCoef()
    g=createGraph(size)
    #mu is the thresold
    mu=options['value_max']
    regret_min=mu
    valid=True
    #caps=getCapacity(size,coef,mu)
    #(flow,cut)=maximum_flow(g,"s","t",caps)
    #mu=regret_max(size,coef,flow)
    #valid=isValid(size,flow)
    
    while valid:
        regret_min=mu
        print("regret_min :", mu)
        caps=getCapacity(size,coef,mu)
        (flow,cut)=maximum_flow(g,"s","t",caps)
        valid=isValid(size,flow)
        if valid:
            mu=regret_max(size,coef,flow)

    print(regret_min)
#Entry point of the program
if __name__ =="__main__":
    #delete the first argument which is the path of the program
    main(sys.argv[1:], sys.argv[0])
