function [subgraph,I] = BFS(graph,startNodes,distance)
% start from a node or a set of nodes and get a subgraph by BFS <= distance
% return the subgraph and the oldIdx in the original graph

tempGraph = graph;
newI = startNodes;
I = startNodes;

% get neighbors with distance
for i = 1 : distance
    oldI = newI; % nodes in old layer
    newI = [];    
    for j = 1 : length(oldI)
        newI = union(newI,find(tempGraph(oldI(j),:)>0),'stable');
    end
    I = union(I,newI,'stable');
    tempGraph(I,I) = 0; % remove vertices already in the subgraph
end

subgraph = graph(I,I);

end
