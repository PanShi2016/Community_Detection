function [] = ppi()
% Process ppi dataset 

dataPath = '../Original_Data/ppi/';
savePath = '../Processed_Data/';

% load ppi.txt
edges = importdata([dataPath,'ppi.txt'],'');
num_edges = length(edges);

nodes = [];
newedges = [];
for i = 1 : num_edges
    edges_a = split(edges{i});
    nodes = union(nodes,edges_a,'stable');
    Lia = ismember(nodes,edges_a{1});
    Lib = ismember(nodes,edges_a{2});
    a = find(Lia);
    b = find(Lib);
    newedges = [newedges;[a,b]];
end

dlmwrite([savePath,'ppi'],newedges,'delimiter','\t');

end
