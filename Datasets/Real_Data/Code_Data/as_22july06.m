function [] = as_22july06()
% Process as-22july06 dataset

dataPath = '../Original_Data/as-22july06/';
savePath = '../Processed_Data/';

% load as-22july06.gml
edges = importdata([dataPath,'as-22july06.gml'],'');

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

dlmwrite([savePath,'as-22july06'],newedges,'precision',10,'delimiter','\t');

end
