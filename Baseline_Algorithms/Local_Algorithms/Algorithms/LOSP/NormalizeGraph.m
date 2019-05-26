function graph = NormalizeGraph(graph, mode)
% compute Nrw = D^(-1)A or Nsym = D^(-1/2)AD^(-1/2)
% mode: 1: Nrw, 2: Nsym

rw = 1;
sym = 2;

if nargin < 2
    mode = 1; % Nrw
end

s = sum(graph);
n = length(graph);

% compute Nrw = D^(-1)A
if(mode == rw)
    Nrw = graph./(s'*ones(1,n));
    graph = Nrw;
end

% compute Nsym = D^(-1/2)AD^(-1/2)
if(mode == sym)
    sqrtS = sqrt(s);
    ss = sqrtS'*ones(1,n); 
    Nsys = graph./ss;
    Nsys = Nsys./ss';
    graph = Nsys;
end

end

