function [] = hep_th()
% Process hep-th dataset

dataPath = '../Original_Data/hep-th/';
savePath = '../Processed_Data/';

% load hep-th.gml
edges = importdata([dataPath,'hep-th.gml'],'');

newedges = [];
w = [];
for i = 1 : length(edges)
    if true == strcmp(edges{i},'  edge')
        edges_a = split(edges{i+2});
        edges_b = split(edges{i+3});
        w = split(edges{i+4});
        newedges = [newedges;[str2num(edges_a{end}),str2num(edges_b{end}),str2num(w{end})]];
    end
end

if min(min(newedges(:,1:2))) == 0
    newedges(:,1:2) = newedges(:,1:2) + 1;
end

dlmwrite([savePath,'hep-th'],newedges,'precision',10,'delimiter','\t');

end
