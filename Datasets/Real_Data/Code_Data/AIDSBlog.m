function [] = AIDSBlog()
% Process AIDSBlog dataset

dataPath = '../Original_Data/AIDSBlog/';
savePath = '../Processed_Data/';

% load AIDSBlog.txt
edges = load([dataPath,'AIDSBlog.txt']);

dlmwrite([savePath,'AIDSBlog'],edges,'precision',10,'delimiter','\t');

end
