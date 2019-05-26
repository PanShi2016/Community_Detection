function [] = BlogCatalog()
% Process BlogCatalog data

dataPath = '../Original_Data/BlogCatalog/';
savePath = '../Processed_Data/';

% load edges.csv
edges = csvread([dataPath,'edges.csv']);
dlmwrite([savePath,'BlogCatalog'],edges,'precision',10,'delimiter','\t');

% load group-edges.csv
group = csvread([dataPath,'group-edges.csv']);

% compute nodes in each group
group_max = max(group(:,2));
comm = cell(group_max,1);

for i = 1 : group_max
    comm{i} = group(find(group(:,2)==i),1)';
    if i == 1
        dlmwrite([savePath,'BlogCatalog.txt'],comm{i},'precision',10,'delimiter','\t');
    else
        dlmwrite([savePath,'BlogCatalog.txt'],comm{i},'precision',10,'-append','delimiter','\t');        
    end
end

end
