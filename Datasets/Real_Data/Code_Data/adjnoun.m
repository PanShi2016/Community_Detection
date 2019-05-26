function [] = adjnoun()
% Process adjnoun dataset

dataPath = '../Original_Data/adjnoun/';
savePath = '../Processed_Data/';

% load adjnoun.gml
edges = importdata([dataPath,'adjnoun.gml'],'');

newedges = [];
for i = 1 : length(edges)
    if true == strcmp(edges{i},'  edge')
        edges_a = split(edges{i+2});
        edges_b = split(edges{i+3});
        newedges = [newedges;[str2num(edges_a{end}),str2num(edges_b{end})]];
    end
end

if min(min(newedges)) == 0
    newedges = newedges + 1;
end

dlmwrite([savePath,'adjnoun'],newedges,'precision',10,'delimiter','\t');

end
