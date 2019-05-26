function [] = GN_benchmark(k_out)
% generate GN benchmark
% k_out: external degrees of a node

if nargin < 1
    k_out = 0;
end

n = 128; % number of nodes
c = 4; % number of communities
n1 = n/c; % community size

p_out = k_out/(n1*(c-1)); % edge probability between different communities
p_in = 0.5 - 3*p_out; % edge probability in the same community

if p_in < 0
    fprintf('input error!\n');
end

% generate edges in the same community with probability p_in
comm1 = rand(n1) < p_in;
comm2 = rand(n1) < p_in;
comm3 = rand(n1) < p_in;
comm4 = rand(n1) < p_in;

% generate edges between different communities with probability p_out
noise = rand(n) < p_out;
noise = noise + 2*blkdiag(ones(n1),ones(n1),ones(n1),ones(n1));
noise(noise > 1) = 0;

A = blkdiag(comm1,comm2,comm3,comm4) + noise;
A = A - diag(diag(A));
A = triu(A) + triu(A,1)';
A = sparse(A);

% save GN benchmark 
[rowId,colId,w] = find(tril(A) > 0); % rowId, columnId, and weight of edges in graph

dlmwrite(['GN_kout_',num2str(k_out)],[colId,rowId],'precision',10,'delimiter','\t');

dlmwrite(['GN_kout_',num2str(k_out),'.txt'],[1 : n1],'precision',10,'delimiter','\t');
dlmwrite(['GN_kout_',num2str(k_out),'.txt'],[n1 + 1 : 2*n1],'-append','precision',10,'delimiter','\t');
dlmwrite(['GN_kout_',num2str(k_out),'.txt'],[2*n1 + 1 : 3*n1],'-append','precision',10,'delimiter','\t');
dlmwrite(['GN_kout_',num2str(k_out),'.txt'],[3*n1 + 1 : 4*n1],'-append','precision',10,'delimiter','\t');

end
