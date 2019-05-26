function [] = SBM_benchmark(n,N,p,q)
% generate N diagonal blocks with probability p
% add additional background noise with probability q

if nargin < 4
    n = 200;
    N = 10;
    p = 0.6;
    q = 0.4;
end

% generate N diagonal blocks with probability p
graph = zeros(n);
s = floor(n/N); % block size
% I = [1 : n];
I = randperm(n);

fid = fopen('SBM.txt','w');
for i = 1 : N 
    graph(I(s*(i-1)+1:s*i),I(s*(i-1)+1:s*i)) = genBlock(s,p);
    fprintf(fid,'%d\t',I(s*(i-1)+1:s*i));
    fprintf(fid,'\n');
end
fclose(fid);

% generate background noise with probability q
noise = genBlock(n,q);

% generate synthetic graph with N Erdos-Renyi blocks and background noise
graph = graph | noise;
graph = sparse(graph);

% save synthetic graph
[rowId,colId,w] = find(tril(graph) > 0); % rowId, columnId, and weight of edges in graph

dlmwrite('SBM',[colId,rowId],'precision',10,'delimiter','\t');

end

function block = genBlock(s,p)
% generate an s by s subgraph with edge probability p

block = rand(s) < p;
block = triu(block) + triu(block,1)';
block = block - diag(diag(block));
    
end
