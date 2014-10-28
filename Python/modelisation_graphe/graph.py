from graph_tool import *
from graph_tool.draw import *
from graph_tool.flow import *
import sys, getopt, subprocess

def parse_command_line(argv):

    try:
        opts, args = getopt.getopt(argv, "hw:vM:n:a:p", \
                                   ["help","notsolve","write", "verbose", "maxvalue","size","answerfile","printanswer"])
    #raise if an option is not in the list below
    except getopt.GetoptError: 
        print("Options non reconnues. Veuillez utiliser P0.py -h pour en savoir plus")
        sys.exit(2)

    options=dict()
    options['value_max']=None
    options['size']=None
    options['verbose']=False
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
            
    return options


def getCoef():
    f=open("models/model.lp", "r")
    f.readline()
    obj_func=list()
    for line in f:
        if line.startswith("Subject"):
            break
        
        obj_func+=line.strip().split(' ')

    #WTF ???? + shouldnt be trated this way
    coef=list(map(lambda x: x.strip('+'), obj_func))
    coef=list(filter(None, coef))
    for i,x in enumerate(coef):
        try:
            coef[i]=float(x)
        except:
            coef.remove(x)

    coef=list(map(float, coef))
    return coef
#main function

def createGraph(coef,size):
    Vertices=list()
    Edges_s=list()
    Edges_t=list()
    Edges_c=list()
    g=Graph()
    s=g.add_vertex()
    t=g.add_vertex()
    for x in range(size+size):
        Vertices.append(g.add_vertex())

    for x in range(size):
        #source to person
        Edges_s.append(g.add_edge(s,Vertices[x]))
        #objects to target
        Edges_t.append(g.add_edge(Vertices[size+x],t))
        for y in range(size):
            Edges_c.append(g.add_edge(Vertices[x],Vertices[size+y]))

    G=dict()
    G["graph"]=g
    G["source"]=s
    G["target"]=t
    G["edges_source"]=Edges_s
    G["edges_target"]=Edges_t
    G["edges_central"]=Edges_c
    return G


def getCapacity(G,coef,Lambda,size):
    g=G["graph"]
    Edges_s=G["edges_source"]
    Edges_t=G["edges_target"]
    Edges_c=G["edges_central"]
    capacity=g.new_edge_property("double")
    for x in range(size):
        min_s=None
        min_t=None
        for y in range(size):
            tmp_s=coef[size*x+y]-Lambda
            tmp_t=coef[x+size*y]-Lambda
            capacity[Edges_c[size*x+y]]=tmp_s
            if min_s == None or (tmp_s>0 and tmp_s<min_s):
                min_s=tmp_s
            if min_t == None or (tmp_t>0 and tmp_t<min_t):
                min_t=tmp_t
        capacity[Edges_s[x]]=min_s
        capacity[Edges_t[x]]=min_t

    return capacity

def printResults(G, capacity, residual):
    g=G["graph"]
    Edges_s=G["edges_source"]
    Edges_t=G["edges_target"]
    Edges_c=G["edges_central"]
    for x in Edges_s:
        print("machin")
        print(capacity[x])
        print(residual[x])
        
def main(argv, current_directory):
    options=parse_command_line(argv)
    model_options=["../modelisation_P0/P0.py", "--notsolve ","-w","model"]
    if not options["size"]:
        options["size"]=10
    if not options["value_max"]:
        options["value_max"]=10

        
    model_options.extend(["-n",str(options["size"])])
    model_options.extend(["-M", str(options["value_max"])])


    #print None...
    #TO DO delte none ? not warn if nothing has been precised
    subprocess.call(["gurobi.sh"]+model_options)

    coef=getCoef()
    G=createGraph(coef,options['size'])
    Lambda=0
    g=G["graph"]
    s=G["source"]
    t=G["target"]
    capacity=getCapacity(G,coef,Lambda,options['size'])
    residual=g.new_edge_property("double")
    edmonds_karp_max_flow(g,s,t,capacity,residual)
    printResults(G,capacity,residual)
#    random_layout(graph)
    #graph_draw(G, output="test.pdf")
#    subprocess.call(["../modelisation_P0/P0.py",' '.join(model_options)])

    
#Entry point of the program
if __name__ =="__main__":
    #delete the first argument which is the path of the program
    main(sys.argv[1:], sys.argv[0])
