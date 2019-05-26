function [] = citeseer()
% Process citeseer data

dataPath = '../Original_Data/citeseer/';
savePath = '../Processed_Data/';

% load citeseer.content
content = importdata([dataPath,'citeseer.content'],'');
num_content = length(content);

classes = {'Agents';'AI';'DB';'IR';'ML';'HCI'};
num_classes = length(classes);

content_nodes = [];
word_vector = [];
commId = [];

for i = 1 : num_content
    content_a = split(content{i});
    content_nodes = union(content_nodes,{content_a{1}},'stable');
    temp = str2num(char(content_a{2:end-1}))';
    word_vector = [word_vector;sparse(temp)];
    commId = [commId,find(ismember(classes,content_a{end}))];
end

save([savePath,'citeseer_attributes.mat'],'word_vector','-v7.3');

for j = 1 : num_classes
    comm = find(commId == j);
    if j == 1
        dlmwrite([savePath,'citeseer.txt'],comm,'precision',10,'delimiter','\t');
    else
        dlmwrite([savePath,'citeseer.txt'],comm,'precision',10,'-append','delimiter','\t');
    end
end

% load citeseer.cites
cites = importdata([dataPath,'citeseer.cites'],'');
num_cites = length(cites);

newcites = [];
for k = 1 : num_cites
    cites_a = split(cites{k});
    Lia = ismember(content_nodes,cites_a{1});
    Lib = ismember(content_nodes,cites_a{2});
    a = find(Lia);
    b = find(Lib);
    if (~isempty(a) & ~isempty(b)) && (a ~= b) 
        newcites = [newcites;[a,b]];
    end
end

% remove multiple edges
graph = sparse([newcites(:,1);newcites(:,2)],[newcites(:,2);newcites(:,1)],1);

[rowId,colId,w] = find(tril(graph) > 0); % rowId, columnId, and weight of edges in graph

dlmwrite([savePath,'citeseer'],[colId,rowId],'precision',10,'delimiter','\t');

end
