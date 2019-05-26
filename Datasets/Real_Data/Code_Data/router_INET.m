function [] = router_INET()
% Process router_INET dataset

dataPath = '../Original_Data/router_INET/';
savePath = '../Processed_Data/';

% load router_INET.txt
edges = load([dataPath,'router_INET.txt']);
minIdx = min(min(edges));

if minIdx == 0
    edges = edges + 1;
end

dlmwrite([savePath,'router_INET'],edges,'precision',10,'delimiter','\t');

end
