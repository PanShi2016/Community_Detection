function [final_C] = OverlapCommSSE(A, seeding, expand, k)
%% Written by Joyce Whang (joyce@cs.utexas.edu), David Gleich (dgleich@purdue.edu)

%% inputs
% A: adjacency matrix
% seeding: seed finding strategy
%  - 'graclus_centers' / 'spread_hubs'
% expand('true/false'): 
%  - if expand is true, then the seed sets are expanded via their neighborhood
% k: the number of seeds 

addpath('./matlab-bgl');
addpath('./GraclusSeeds/graclus1.2/matlab');

%% Filtering phase
[~,pdata] = graphprep(A); 
G = pdata.bicore; 

%% Seeding & PPR communities
% 'runs' should be proportional to the size of the graph
if size(A,1)>100
    runs = 13;
else
    runs = 3; 
end
if strcmp(seeding, 'graclus_centers') % graclus centers (hierarchical clustering)
    minSize=0;
    [center] = get_hrc_graclus_seeds(G,k,minSize);
    seeds=center;
    seeddata = seed_report(G,seeds,expand,'nruns',runs,'maxexpand',nnz(G)/2);
elseif strcmp(seeding, 'spread_hubs') % spread hubs
    seeds=spHubSeeds(G,k);
    fprintf('sphub seeds selected... %d seeds\n',length(seeds));
    seeddata = seed_report(G,seeds,expand,'nruns',runs,'maxexpand',nnz(G)/2);
end

%% Propagation Phase
[C_full] = propagation(A,G,seeddata,pdata);

% get communities
% final_C = getComm(C_full);

%% (optional) Flip assignment for super large clusters
if size(A,1)>100
    [final_C] = flip_C(C_full',A);
else
    final_C=C_full;
end

end
