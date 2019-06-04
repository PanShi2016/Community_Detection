function  conductance = getConductance(graph, commIdx)
% compute the conductance of a community
% Let S be a cluster which contains no more than half of all the nodes.
% conductance = number of edges outgoing from S / sum of degrees of nodes in S
%             = N(outgoing edges) / 2*N(inside edges)+ N(outgoing edges)
% the smaller, the better. bias to larger community.
% http://en.wikipedia.org/wiki/Conductance_(graph)

if nargin <1 , 
    graph = [
        %1 2 3 4 5 6 7 8 9 10
         0 1 1 0 0 0 0 0 0 0; %1
         1 0 1 0 0 0 0 0 0 0; %2
         1 1 0 1 0 0 0 0 0 0; %3
         0 0 1 0 1 0 0 1 0 0; %4
         0 0 0 1 0 1 1 0 0 0; %5
         0 0 0 0 1 0 1 0 0 0; %6
         0 0 0 0 1 1 0 0 0 0; %7
         0 0 0 1 0 0 0 0 1 1; %8
         0 0 0 0 0 0 0 1 0 1; %9
         0 0 0 0 0 0 0 1 1 0];%10  
     commIdx = [1 2 3 4]; % conductance = 0.2
end

if length(graph) == length(commIdx)
    conductance = 1;
else
    totalDegree = sum( sum(graph(:,commIdx)) );
    outDegree = sum(sum(graph)) - totalDegree;
    insideDegree = sum( sum(graph(commIdx,commIdx)) );
    outgoingEdges = totalDegree - insideDegree;
    conductance = outgoingEdges / min(totalDegree,outDegree);
end

end
