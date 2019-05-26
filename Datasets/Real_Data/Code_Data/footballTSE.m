function [] = footballTSE()
% Process footballTSE dataset

dataPath = '../Original_Data/footballTSE/';
savePath = '../Processed_Data/';

% load footballTSE.gml
edges = importdata([dataPath,'footballTSE.gml'],'');

nodelabel = [];
newedges = [];
for i = 1 : length(edges)
    if true == strcmp(edges{i},'  node')
        node = split(edges{i+2});
        label = split(edges{i+4});
        nodelabel = [nodelabel;[str2num(node{end}),str2num(label{end})]];
    end
    
    if true == strcmp(edges{i},'  edge')
        edges_a = split(edges{i+2});
        edges_b = split(edges{i+3});
        newedges = [newedges;[str2num(edges_a{end}),str2num(edges_b{end})]];
    end
end

if min(nodelabel(:,1)) == 0
    nodelabel = nodelabel + 1;
    newedges = newedges + 1;
end

dlmwrite([savePath,'footballTSE'],newedges,'precision',10,'delimiter','\t');

% compute nodes in each group
label_max = max(nodelabel(:,2));
comm = cell(label_max,1);

for j = 1 : label_max
    comm{j} = nodelabel(find(nodelabel(:,2)==j),1)';
    if j == 1
        dlmwrite([savePath,'footballTSE.txt'],comm{j},'precision',10,'delimiter','\t');
    else
        dlmwrite([savePath,'footballTSE.txt'],comm{j},'precision',10,'-append','delimiter','\t');        
    end
end

end
