function [] = Email_Eu()
% Process Email-Eu dataset

dataPath = '../Original_Data/Email-Eu/';
savePath = '../Processed_Data/';

% load email-Eu-core.txt
edges = load([dataPath,'email-Eu-core.txt']);

minIdx = min(min(edges));

if minIdx == 0
    edges = edges + 1;
end

graph = sparse([edges(:,1);edges(:,2)],[edges(:,2);edges(:,1)],1);
graph = graph - diag(diag(graph));    % remove self-loop
[rowId,colId,w] = find(tril(graph) > 0);  % rowId, columnId, and the weight of edge in graph

dlmwrite([savePath,'Email-Eu'],[colId,rowId],'precision',10,'delimiter','\t');

% load email-Eu-core-department-labels.txt
group = load([dataPath,'email-Eu-core-department-labels.txt']);

% compute nodes in each group
if minIdx == 0
    group(:,1) = group(:,1) + 1;
end

group_max = max(group(:,2));
comm = cell(group_max,1);

for i = 0 : group_max
    comm{i+1} = group(find(group(:,2)==i),1)';
    if i == 0
        dlmwrite([savePath,'Email-Eu.txt'],comm{i+1},'precision',10,'delimiter','\t');
    else
        dlmwrite([savePath,'Email-Eu.txt'],comm{i+1},'precision',10,'-append','delimiter','\t');        
    end
end

end
