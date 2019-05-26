function [] = cond_mat()
% Process cond-mat dataset

dataPath = '../Original_Data/cond-mat/';
savePath = '../Processed_Data/';

% load cond-mat.gml
edges = importdata([dataPath,'cond-mat.gml'],'');

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

dlmwrite([savePath,'cond-mat'],newedges,'precision',10,'delimiter','\t');

end
