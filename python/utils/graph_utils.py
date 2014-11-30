# -*- coding: utf-8 -*-

from pygraph.classes.digraph import digraph
from pygraph.algorithms.minmax import maximum_flow

def createGraph(size):
    g=digraph()
    s=g.add_node("s")
    t=g.add_node("t")
    for i in range(size):
        g.add_node("a_"+str(i))
        g.add_node("o_"+str(i))
            
    for i in range(size):
        #source to person
        g.add_edge(("s","a_"+str(i)))
        g.add_edge(("o_"+str(i),"t"))
        for j in range(size):
            g.add_edge(("a_"+str(i),"o_"+str(j)))

    return g


def log2(x):
    log=0
    x=x>>1
    while x>0:
        log+=1
        x=x>>1 
    return log


def isValid(size,flow):
    for i in range(size):
        if flow[('s','a_'+str(i))]==0:
            return False
    else:
        return True

