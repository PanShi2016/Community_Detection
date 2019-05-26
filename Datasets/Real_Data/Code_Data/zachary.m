function [] = zachary()
% Process zachary dataset

dataPath = '../Original_Data/zachary/';
savePath = '../Processed_Data/';

% load zachary.txt
edges = load ([dataPath,'zachary.txt']);

dlmwrite([savePath,'zachary'],edges(:,1:2),'precision',10,'delimiter','\t');

end
