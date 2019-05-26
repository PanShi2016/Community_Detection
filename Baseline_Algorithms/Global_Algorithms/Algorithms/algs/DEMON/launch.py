import networkx as nx
import Demon as D
import sys, time

starttime = time.clock()
G = nx.Graph()
file = open(sys.argv[1], "r")
for row in file:
    part = row.strip().split()
    G.add_edge(int(part[0]), int(part[1]))

# Example use of DEMON. Parameter discussed in the paper.
CD = D.Demon()
CD.execute(G)
endtime = time.clock()
h = open("Demon_time.txt",'w')
h.write( str(endtime-starttime) )
h.write("\n")
h.close()
