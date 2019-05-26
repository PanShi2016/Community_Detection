function V = Walk(graph,p,k,steps,randomWalkMode )
% p is initial probability vector and steps is the number of random walk steps, 
% k is the dimension of the probability space
% return the k vectors in volumes

if nargin < 1,
    % two overlapping cliques of size 5
    A = zeros(8,8);
    A(1:6,1:6)=1;
    A(5:8,5:8)=1;
    graph = A - diag(diag(A))
    % start from vertex 1
    p =[ 1     0     0     0     0     0     0     0 ];
    k = 2;%dimension of the subspace    
    steps = 3;
end
if nargin <5
    randomWalkMode = 1; 
end
alpha = 0.15;
initP = p;

n = length(graph);
         
% randomWalkMode  1: standard, 2: light lazy, 3:lazy, 4: personalized 
% 1 standard, do nothing
%2: add selfloop, light lazy, save one/(d+1) prob at the current node
if(randomWalkMode ==2)
    graph = sparse(eye(n) + graph); % its iteration curve is more stable
else if(randomWalkMode == 3) % lazy random walk, save one half prob at the current node
        graph = diag(sum(graph)) + graph;
    end
end

graph = NormalizeGraph(graph); % aij=aij/di such that aij=pij
n = length(graph);
V = zeros(k,n);
V(1,:) = p;
if (randomWalkMode == 4) % pernonalized random walk, with alpha = 0.15 probability to restart from the inital seeds
    for i = 1:k-1 
        V(i+1,:) = (1-alpha)*V(i,:)*graph + alpha * initP;
    end
else
    for i = 1:k-1
        V(i+1,:) = V(i,:)*graph; 
    end
end

V=(orth(V'))';
initPK = repmat(initP,k,1);
for i=1:steps
    if (randomWalkMode == 4) % pernonalized random walk, with alpha = 0.15 probability to restart from the inital seeds
        V=(1-alpha)*V*graph + alpha * initPK;
    else
        V=V*graph;
    end
    V=(orth(V'))';
end

V = V';

end

% standard 
%          0    0.1771
%     0.2000    0.1371
%     0.2000    0.1371
%     0.2000    0.1371
%     0.2000    0.1486
%     0.2000    0.1486
%          0    0.0571
%          0    0.0571
% light lazy
%     0.1667    0.1528
%     0.1667    0.1528
%     0.1667    0.1528
%     0.1667    0.1528
%     0.1667    0.1528
%     0.1667    0.1528
%          0    0.0417
%          0    0.0417

% lazy 
%     0.5000    0.2943
%     0.1000    0.1343
%     0.1000    0.1343
%     0.1000    0.1343
%     0.1000    0.1371
%     0.1000    0.1371
%          0    0.0143
%          0    0.0143
% personal
%     0.1500    0.2780
%     0.1700    0.1246
%     0.1700    0.1246
%     0.1700    0.1246
%     0.1700    0.1328
%     0.1700    0.1328
%          0    0.0413
%          0    0.0413
