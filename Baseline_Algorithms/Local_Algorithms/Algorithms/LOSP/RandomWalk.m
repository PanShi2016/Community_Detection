function p = RandomWalk(graph,p,steps)
% p is initial probability vector and steps is the number of random walk steps

if nargin < 1
    % two overlapping cliques of size 5
    graph = [
        %    1     2     3     4     5     6     7     8
        0     1     1     1     1     0     0     0  ;%1
        1     0     1     1     1     0     0     0  ;%2
        1     1     0     1     1     0     0     0  ;%3
        1     1     1     0     1     1     1     1  ;%4
        1     1     1     1     0     1     1     1  ;%5
        0     0     0     1     1     0     1     1  ;%6
        0     0     0     1     1     1     0     1  ;%7
        0     0     0     1     1     1     1     0  ];%8
    
    % start from vertex 1
    p = [ 1     0     0     0     0     0     0     0 ];   
    steps = 2;
end

n = length(graph);
graph = NormalizeGraph(graph); % aij = aij/di such that aij = pij

% random walk step by step
for i = 1 : steps
    p = p*graph;
end

end
