function [] = PPI_function()
% Process PPI_function dataset

dataPath = '../Original_Data/PPI_function/';
savePath = '../Processed_Data/';

% load PPI_Cell_Comm.txt
edges = importdata([dataPath,'PPI_Cell_Comm.txt'],'');
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

dlmwrite([savePath,'PPI_function'],newedges,'delimiter','\t');

% load ICSC_indicator.txt
Id_label = load([dataPath,'ICSC_indicator.txt']);
Id_min = min(Id_label);
Id_max = max(Id_label);

for j =  Id_min : Id_max
    label = find(Id_label==j);
    if j == Id_min
        dlmwrite([savePath,'PPI_function.txt'],label','delimiter','\t');
    else
        dlmwrite([savePath,'PPI_function.txt'],label','-append','delimiter','\t');
    end
end

end
