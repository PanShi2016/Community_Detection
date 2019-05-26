Greedy Clique Expansion Community Finder
Community finder. Requires edge list of nodes. Processes graph in undirected, unweighted form. Edgelist must be two values separated with non digit character.

Use with either full (if specify all 5) or default (specify just graph file) parameters:
Full parameters are:
The name of the file to load
The minimum size of cliques to use as seeds. Recommend 4 as default, unless particularly small communities are required (in which case use 3).
The minimum value for one seed to overlap with another seed before it is considered sufficiently overlapping to be discarded (eta). 1 is complete overlap. However smaller values may be used to prune seeds more aggressively. A value of 0.6 is recommended.
The alpha value to use in the fitness function greedily expanding the seeds. 1.0 is recommended default. Values between .8 and 1.5 may be useful. As the density of edges increases, alpha may need to be increased to stop communities expanding to engulf the whole graph. If this occurs, a warning message advising that a higher value of alpha be used, will be printed.
The proportion of nodes (phi) within a core clique that must have already been covered by other cliques, for the clique to be 'sufficiently covered' in the Clique Coveage Heuristic

Usage: ./algs/GCECommunityFinder/build/GCECommunityFinder graphfilename minimumCliqueSizeK overlapToDiscardEta fitnessExponentAlpha CCHthresholdPhi

Usage (with defaults): ./algs/GCECommunityFinder/build/GCECommunityFinder graphfilename
This will run with the default values of: minimumCliqueSizeK 4, overlapToDiscardEta 0.6, fitnessExponentAlpha 1.0, CCHthresholdPhi .75
Communities will be output, one community per line, with the same numbering as the original nodes were provided.