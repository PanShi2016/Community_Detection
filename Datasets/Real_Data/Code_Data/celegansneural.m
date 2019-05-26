function [] = celegansneural()
% Process celegansneural dataset

dataPath = '../Original_Data/celegansneural/';
savePath = '../Processed_Data/';

% load celegansneural.gml
edges = importdata([dataPath,'celegansneural.gml'],'');

newedges = [];
for i = 1 : length(edges)
    if true == strcmp(edges{i},'  edge')
        edges_a = split(edges{i+2});
        edges_b = split(edges{i+3});
        weight = split(edges{i+4});
        newedges = [newedges;[str2num(edges_a{end}),str2num(edges_b{end}),str2num(weight{end})]];
    end
end

if min(min(newedges(:,1:2))) == 0
    newedges(:,1:2) = newedges(:,1:2) + 1;
end

dlmwrite([savePath,'celegansneural'],newedges,'precision',10,'delimiter','\t');

end
