function [bestJaccardindex,bestF05score,bestF1score,bestF2score,bestprecision,bestrecall,bestsize,bestcond,detectedComm] = IterativeWorkConduct(graph,subgraph,initialStartSeeds,sample,groundTruthComm,dist,dim,step)
% use conductance to decide the community size

% Start from initialStartSeeds
% do random walk, then use min 1-norm to get a vector v that contains the 3 start nodes

% use pos1norm2: the summation of indicators of the start nodes  >= 1, each contributes weight W1
% or
% use pos1norm3: the summation of indicators of initial start nodes  >= 1, each contributes weight W1
%                the summation of indicators of the start nodes  >= 1, later seeds contributes weight 0.5W1

% at each iteration, use the accumulated nodes to be the start seeds
% or
% at each iteration, just use the current top nodes to be the start seeds

if nargin < 6
    dist = 4; % length of the shortest path
end

if nargin < 7
    dim = 3;  % dimension of subspace
end

if nargin < 8
    step = 3; % random walk steps
end

n = length(subgraph);
delta = 5;
minCommSize = 3;
maxCommSize = 500;
originalGraph = subgraph;

% add selfloop
subgraph = sparse(eye(n) + subgraph); % its iteration curve is more stable
subgraph = NormalizeGraph(subgraph); % D^(-1)A 
sampleSize = length(sample);

% begin with random walk
startPoints = getInitialSeeds(initialStartSeeds,originalGraph,dist);
startNums = length(startPoints); % number of start nodes
initialPoints = startPoints;
totalStartNum = startNums;

oldv = zeros(1,n);
oldv(startPoints) = 1/totalStartNum;

iter = 1;
while(iter <= 3 || conductances(iter-1) <= conductances(iter-2) && iter < 10)
    p = zeros(1,n);
    p(startPoints) = 1/totalStartNum; % startNums
    V = Walk(subgraph,p,dim,step);

    % find minimum one norm vector
    v = pos1norm(V,startPoints,initialPoints);

    [w,I] = sort(v,'descend');
    walkSize = length(w);
    maxCommSize = min(walkSize,maxCommSize);

    if(isempty(I) == 0) % work well by minimal 1-norm
        [findCommSizes(iter),conductances(iter),~] = getConduct(originalGraph,w,I,minCommSize, maxCommSize); % get the community size having minimal conductance
        [bestJaccard(iter),bestF05(iter),bestF1(iter),bestF2(iter),bestprecision(iter),bestrecall(iter)] = testsubgraph(sample(I(1:findCommSizes(iter))),groundTruthComm);
        globalcond(iter) = getConductance(graph,sample(I(1:findCommSizes(iter))));
        if(totalStartNum <= sampleSize - delta)
            startNums = startNums + delta;
            I = I(1:startNums); % top start number of nodes
            startPoints = union(startPoints,I); % at each iteration, use the accumulate nodes be the start seeds, 5% higher
        end
        totalStartNum = length(startPoints);
        iter = iter + 1;
    else
        % if I is empty, return the older result
        v = oldv;
        [w,I] = sort(v,'descend');
        if iter > 1
            [bestJaccard(iter),bestF05(iter),bestF1(iter),bestF2(iter),bestprecision(iter),bestrecall(iter)] = testsubgraph(sample(I(1:findCommSizes(iter-1))),groundTruthComm);
        else
            [bestJaccard(iter),bestF05(iter),bestF1(iter),bestF2(iter),bestprecision(iter),bestrecall(iter)] = testsubgraph(sample(I(1:3)),groundTruthComm);
            bestsize = 3;
            bestcond = getConductance(graph,sample(I(1:3)));
        end
        break;
    end
    oldv = v;
end

% get the best F1 based on the minimal conductance
if iter > 1
    [bestJaccardindex,bestF05score,bestF1score,bestF2score,bestprecision,bestrecall,bestsize,bestcond] = getMinResult(conductances,bestJaccard,bestF05,bestF1,bestF2,bestprecision,bestrecall,findCommSizes);
    [~,ind] = min(conductances);
    bestcond = globalcond(ind);
    detectedComm = sample(I(1:bestsize));
else
    bestJaccardindex = bestJaccard;
    bestF05score = bestF05;
    bestF1score = bestF1;
    bestF2score = bestF2;
    detectedComm = sample(I(1:3));
end

end

% compute the shortest path between each pair of initial seeds and add nodes on the path to the seed set if path length <= dist 
function newStartPoints = getInitialSeeds(startPoints,subgraph,dist)
m = length(startPoints);
newStartPoints = startPoints;
for j = 1 : (m - 1)
    for k = (j + 1) : m
        [dist,path] = graphshortestpath(subgraph,startPoints(j),startPoints(k),'Directed',false); % Dijkstra O(log(n)*e)
        if(dist <= dist)
            deltaS = setdiff(path,newStartPoints);
            newStartPoints = union(newStartPoints,path);
        end
    end
end
end

% compute the conductance of clusters from I(1:minSize) to I(1:maxsize),
% return the size with the minimal conductance
function [findCommSize,minConduct,conductances] = getConduct(subgraph,w,I,minCommSize, maxCommSize)
conductances = zeros(1,maxCommSize);
for i = 1 : min(length(I),maxCommSize)
    conductances(1,i) = getConductance(subgraph, I(1:i));
end
[minConduct,findCommSize] = getLocalMinResult(conductances,minCommSize,maxCommSize,w);
end
