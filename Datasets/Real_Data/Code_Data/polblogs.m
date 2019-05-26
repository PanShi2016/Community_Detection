function [] = polblogs()
% Process polblogs dataset

dataPath = '../Original_Data/polblogs/';
savePath = '../Processed_Data/';

% load polblogs.gml
edges = importdata([dataPath,'polblogs.gml'],'');

nodelabel = [];
newedges = [];
for i = 1 : length(edges)
    if true == strcmp(edges{i},'  node [')
        node = split(edges{i+1});
        label = split(edges{i+3});
        nodelabel = [nodelabel;[str2num(node{end}),str2num(label{end})]];
    end
    
    if true == strcmp(edges{i},'  edge [')
        edges_a = split(edges{i+1});
        edges_b = split(edges{i+2});
        newedges = [newedges;[str2num(edges_a{end}),str2num(edges_b{end})]];
    end
end

graph = sparse([newedges(:,1);newedges(:,2)],[newedges(:,2);newedges(:,1)],1);
graph = graph - diag(diag(graph));    % remove self-loop

% remove multiple edges

[rowId,colId,w] = find(tril(graph) > 0); % rowId, columnId, and weight of edges in graph

dlmwrite([savePath,'polblogs'],[colId,rowId],'precision',10,'delimiter','\t');

% compute nodes in each group
comm = cell(2,1);

for j = 1 : 2
    comm{j} = nodelabel(find(nodelabel(:,2)==(j-1)),1)';
    if j == 1
        dlmwrite([savePath,'polblogs.txt'],comm{j},'precision',10,'delimiter','\t');
    else
        dlmwrite([savePath,'polblogs.txt'],comm{j},'precision',10,'-append','delimiter','\t');        
    end
end

end
