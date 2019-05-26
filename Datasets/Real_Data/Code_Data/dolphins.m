function [] = dolphins()
% Process dolphins dataset

dataPath = '../Original_Data/dolphins/';
savePath = '../Processed_Data/';

% load dolphins.gml
edges = importdata([dataPath,'dolphins.gml'],'');

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

dlmwrite([savePath,'dolphins'],newedges,'precision',10,'delimiter','\t');

end
