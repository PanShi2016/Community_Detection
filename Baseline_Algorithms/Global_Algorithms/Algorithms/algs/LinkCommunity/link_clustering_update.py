#!/usr/bin/env python
# encoding: utf-8

# link_clustering.py
# Jim Bagrow, Yong-Yeol Ahn
# Last Modified: 2010-02-16


# Copyright 2008,2009,2010 James Bagrow, Yong-Yeol Ahn
# 
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


import sys, os, time
from copy import copy
from operator import itemgetter
from heapq import heappush, heappop
from collections import defaultdict
from itertools import combinations # requires python 2.6+
from optparse import OptionParser

def swap(a,b):
    if a > b:
        return b,a
    return a,b


def Dc(m,n):
    """partition density"""
    try:
        return m*(m-n+1.0)/(n-2.0)/(n-1.0)
    except ZeroDivisionError: # numerator is "strongly zero"
        return 0.0


class HLC:
    def __init__(self,adj,edges):
        self.adj   = adj
        self.edges = edges
        self.Mfactor  = 2.0 / len(edges)
        self.edge2cid = {}
        self.cid2nodes,self.cid2edges = {},{}
        self.initialize_edges() # every edge in its own comm
        self.D = 0.0 # partition density
    
    def initialize_edges(self):
        for cid,edge in enumerate(self.edges):
            edge = swap(*edge) # just in case
            self.edge2cid[edge] = cid
            self.cid2edges[cid] = set([edge])
            self.cid2nodes[cid] = set( edge )
    
    def merge_comms(self,edge1,edge2):
        cid1,cid2 = self.edge2cid[edge1],self.edge2cid[edge2]
        if cid1 == cid2: # already merged!
            return
        m1,m2 = len(self.cid2edges[cid1]),len(self.cid2edges[cid2])
        n1,n2 = len(self.cid2nodes[cid1]),len(self.cid2nodes[cid2])
        Dc1, Dc2 = Dc(m1,n1), Dc(m2,n2)
        if m2 > m1: # merge smaller into larger
            cid1,cid2 = cid2,cid1
        
        self.cid2edges[cid1] |= self.cid2edges[cid2]
        for e in self.cid2edges[cid2]: # move edges,nodes from cid2 to cid1
            self.cid2nodes[cid1] |= set( e )
            self.edge2cid[e] = cid1
        del self.cid2edges[cid2], self.cid2nodes[cid2]
        
        m,n = len(self.cid2edges[cid1]),len(self.cid2nodes[cid1]) 
        Dc12 = Dc(m,n)
        self.D = self.D + ( Dc12 -Dc1 - Dc2) * self.Mfactor # update partition density
    
    def single_linkage(self,threshold=None):
        """docstring goes here..."""
        print "clustering..."
        self.list_D = [(1.0,0.0)] # list of (S_i,D_i) tuples...
        self.best_D = 0.0
        self.best_S = 1.0 # similarity threshold at best_D
        self.best_P = None # best partition, dict: edge -> cid
        
        H = similarities( self.adj ) # min-heap ordered by 1-s
        S_prev = -1
        for oms,eij_eik in H:
            S = 1-oms # remember, H is a min-heap
            if S < threshold:
                break
                
            if S != S_prev: # update list
                if self.D >= self.best_D: # check PREVIOUS merger, because that's
                    self.best_D = self.D  # the end of the tie
                    self.best_S = S
                    self.best_P = copy(self.edge2cid) # slow...
                self.list_D.append( (S,self.D) )
                S_prev = S
            self.merge_comms( *eij_eik )
        
        self.list_D.append( (0.0,self.list_D[-1][1]) ) # add final val
        if threshold != None:
            return self.edge2cid, self.D
        return self.best_P, self.best_S, self.best_D, self.list_D
    


def similarities(adj):
    """Get all the edge similarities. Input dict maps nodes to sets of neighbors.
    Output is a list of decorated edge-pairs, (1-sim,eij,eik), ordered by similarity.
    """
    print "computing similarities..."
    i_adj = dict( (n,adj[n] | set([n])) for n in adj)  # node -> inclusive neighbors
    min_heap = [] # elements are (1-sim,eij,eik)
    for n in adj: # n is the shared node
        if len(adj[n]) > 1:
            for i,j in combinations(adj[n],2): # all unordered pairs of neighbors
                edge_pair = swap( swap(i,n),swap(j,n) )
                inc_ns_i,inc_ns_j = i_adj[i],i_adj[j] # inclusive neighbors
                S = 1.0 * len(inc_ns_i&inc_ns_j) / len(inc_ns_i|inc_ns_j) # Jacc similarity...
                heappush( min_heap, (1-S,edge_pair) )
    return [ heappop(min_heap) for i in xrange(len(min_heap)) ] # return ordered edge pairs


def read_edgelist(filename,delimiter=None,nodetype=str):
    adj = defaultdict(set)
    edges = set()
    print delimiter
    for line in open(filename):
        L = line.strip().split(delimiter)
        ni,nj = nodetype(L[0]),nodetype(L[1]) # other columns ignored
        if ni != nj: # skip any self-loops...
            edges.add( swap(ni,nj) )
            adj[ni].add(nj)
            adj[nj].add(ni) # since undirected
    return dict(adj), edges


def write_edge2cid(e2c,filename,delimiter="\t"):
    # write edge2cid three-column file
    
    
    cid2edges,cid2nodes = defaultdict(set),defaultdict(set) # faster to recreate here than
    for edge,cid in e2c.iteritems():                        # to keep copying all dicts
        cid2edges[cid].add( edge )                          # during the linkage...
        cid2nodes[cid] |= set(edge)
    cid2edges,cid2nodes = dict(cid2edges),dict(cid2nodes)
    
    # write list of edges for each comm, each comm on its own line
    g = open( 'LC.gen', 'w')
    for cid in sorted(cid2edges.keys()):
        nodes = map(str,cid2nodes[cid])
        #f.write( "\t".join(edges) ); f.write("\n")
        g.write( "\t".join(nodes) ); g.write("\n")
    g.close(); #g.close()


if __name__ == '__main__':
    usage = "usage: python %prog [options] filename"
    parser = OptionParser(usage)
    parser.add_option("-d", "--delimiter", dest="delimiter", default="\t",
                      help="delimiter of input & output files [default: tab]")
    parser.add_option("-t", "--threshold", dest="threshold", type="float", default=None,
                      help="threshold to cut the dendrogram (optional)")
    starttime = time.clock()
    (options, args) = parser.parse_args()
    if len(args) != 1:
        parser.error("incorrect number of arguments")
    delimiter = options.delimiter
	# delimiter = ' '
    if delimiter == '\\t':
        delimiter = '\t'
    threshold = options.threshold
    
    print "# loading input..."
    print delimiter
    basename = os.path.splitext(args[0])[0]
    adj,edges = read_edgelist(args[0], delimiter=delimiter) # load network from edgelist
    
    
    if threshold:
        edge2cid,D_thr = HLC( adj,edges ).single_linkage( threshold )
        print "# D_thr = %f" % D_thr
        write_edge2cid( edge2cid,"%s_thrS%f_thrD%f" % (basename,threshold,D_thr), delimiter=delimiter )
    else:
        edge2cid,S_max,D_max,list_D = HLC( adj,edges ).single_linkage()
        f = open( "LC.D",'w')
        f.write( "D_max = " )
        f.write( str(D_max) ); f.write("\n")
        f.write( "S_max = " )
        f.write( str(S_max) ); f.write("\n")
        f.close()
        print "# D_max = %f\n# S_max = %f" % (D_max,S_max)
        write_edge2cid( edge2cid,"%s_maxS%f_maxD%f" % (basename,S_max,D_max), delimiter=delimiter )

	#time saving
	endtime = time.clock()
	h = open( "LC.timelength",'w')
	h.write( str(endtime-starttime) )
	h.write("\n")
	h.close()

