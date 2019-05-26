function [] = TerrorAttack()
% Process TerrorAttack dataset

dataPath = '../Original_Data/TerrorAttack/';
savePath = '../Processed_Data/';

% load terrorist_attack.labels
labels = importdata([dataPath,'terrorist_attack.labels'],'');
num_labels = length(labels);

% load terrorist_attack.nodes
nodes = importdata([dataPath,'terrorist_attack.nodes'],'');
num_nodes = length(nodes);

nodes_set = [];
word_vector = [];
commId = [];

for i = 1 : num_nodes
    nodes_a = split(nodes{i});
    nodes_set = union(nodes_set,{nodes_a{1}},'stable');
    temp = str2num(char(nodes_a{2:end-1}))';
    word_vector = [word_vector;sparse(temp)];
    commId = [commId,find(ismember(labels,nodes_a{end}))];
end

save([savePath,'TerrorAttack_attributes.mat'],'word_vector','-v7.3');

for j = 1 : num_labels
    comm = find(commId == j);
    if j == 1
        dlmwrite([savePath,'TerrorAttack.txt'],comm,'precision',10,'delimiter','\t');
    else
        dlmwrite([savePath,'TerrorAttack.txt'],comm,'precision',10,'-append','delimiter','\t');
    end
end

% load terrorist_attack_loc.edges
edges = importdata([dataPath,'terrorist_attack_loc.edges'],'');
num_edges = length(edges);

newedges = [];
for k = 1 : num_edges
    edges_a = split(edges{k});
    Lia = ismember(nodes_set,edges_a{1});
    Lib = ismember(nodes_set,edges_a{2});
    a = find(Lia);
    b = find(Lib);
    if (~isempty(a) & ~isempty(b)) && (a ~= b) 
        newedges = [newedges;[a,b]];
    end
end

% remove multiple edges
graph = sparse([newedges(:,1);newedges(:,2)],[newedges(:,2);newedges(:,1)],1);

[rowId,colId,w] = find(tril(graph) > 0); % rowId, columnId, and weight of edges in graph

dlmwrite([savePath,'TerrorAttack'],[colId,rowId],'precision',10,'delimiter','\t');

% load terrorist_attack_loc_org.edges
org_edges = importdata([dataPath,'terrorist_attack_loc_org.edges'],'');
num_org_edges = length(org_edges);

neworg_edges = [];
for l = 1 : num_org_edges
    org_edges_a = split(org_edges{l});
    Lic = ismember(nodes_set,org_edges_a{1});
    Lid = ismember(nodes_set,org_edges_a{2});
    c = find(Lic);
    d = find(Lid);
    if (~isempty(c) & ~isempty(d)) && (c ~= d) 
        neworg_edges = [neworg_edges;[c,d]];
    end
end

% remove multiple edges
org_graph = sparse([neworg_edges(:,1);neworg_edges(:,2)],[neworg_edges(:,2);neworg_edges(:,1)],1);
I = find(org_graph > 1);
org_graph(I) = 1; % remove multiple edges

[rowId,colId,w] = find(tril(org_graph) > 0); % rowId, columnId, and weight of edges in graph

dlmwrite([savePath,'TerrorAttack_org'],[colId,rowId],'precision',10,'delimiter','\t');

end
