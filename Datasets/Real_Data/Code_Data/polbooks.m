function [] = polbooks()
% Process polbooks dataset

dataPath = '../Original_Data/polbooks/';
savePath = '../Processed_Data/';

% load polbooks.gml
edges = importdata([dataPath,'polbooks.gml'],'');

nodes = [];
labels = {};
newedges = [];
for i = 1 : length(edges)
    if true == strcmp(edges{i},'  node')
        node = split(edges{i+2});
        label = split(edges{i+4});
        nodes = [nodes,str2num(node{end})];
        labels = [labels,label{end}];
    end
    
    if true == strcmp(edges{i},'  edge')
        edges_a = split(edges{i+2});
        edges_b = split(edges{i+3});
        newedges = [newedges;[str2num(edges_a{end}),str2num(edges_b{end})]];
    end
end

if min(nodes) == 0
    nodes = nodes + 1;
    newedges = newedges + 1;
end

dlmwrite([savePath,'polbooks'],newedges,'precision',10,'delimiter','\t');

% compute nodes in each group
value = {'"l"','"n"','"c"'};
comm = cell(3,1);

for j = 1 : length(value)
    Lia = ismember(labels,value{j});
    ind = find(Lia);
    comm{j} = nodes(ind);
    if j == 1
        dlmwrite([savePath,'polbooks.txt'],comm{j},'precision',10,'delimiter','\t');
    else
        dlmwrite([savePath,'polbooks.txt'],comm{j},'precision',10,'-append','delimiter','\t');        
    end
end

end
