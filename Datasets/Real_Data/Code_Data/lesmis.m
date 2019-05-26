function [] = lesmis()
% Process lesmis dataset

dataPath = '../Original_Data/lesmis/';
savePath = '../Processed_Data/';

% load lesmis.gml
edges = importdata([dataPath,'lesmis.gml'],'');

weightedges = [];
for i = 1 : length(edges)
    if true == strcmp(edges{i},'  edge')
        edges_a = split(edges{i+2});
        edges_b = split(edges{i+3});
        weight = split(edges{i+4});
        weightedges = [weightedges;[str2num(edges_a{end}),str2num(edges_b{end}),str2num(weight{end})]];
    end
end

if min(min(weightedges(:,1:2))) == 0
    weightedges(:,1:2) = weightedges(:,1:2) + 1;
end

dlmwrite([savePath,'lesmis'],weightedges,'precision',10,'delimiter','\t');

end
