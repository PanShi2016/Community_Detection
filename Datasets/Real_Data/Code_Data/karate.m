function [] = karate()
% Process karate dataset

dataPath = '../Original_Data/karate/';
savePath = '../Processed_Data/';

% load karate.gml
edges = importdata([dataPath,'karate.gml'],'');

newedges = [];
for i = 1 : length(edges)
    if true == strcmp(edges{i},'  edge')
        edges_a = split(edges{i+2});
        edges_b = split(edges{i+3});
        newedges = [newedges;[str2num(edges_a{end}),str2num(edges_b{end})]];
    end
end

dlmwrite([savePath,'karate'],newedges,'precision',10,'delimiter','\t');

end
