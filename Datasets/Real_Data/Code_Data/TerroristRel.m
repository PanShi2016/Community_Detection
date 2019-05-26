function [] = TerroristRel()
% Process TerroristRel dataset

dataPath = '../Original_Data/TerroristRel/';
savePath = '../Processed_Data/';

% load TerroristRel.labels
labels = importdata([dataPath,'TerroristRel.labels'],'');
num_labels = length(labels);

% load TerroristRel_Contact.nodes
Contact = importdata([dataPath,'TerroristRel_Contact.nodes'],'');
num_Contact = length(Contact);

Contact_nodes = [];
Contact_vector = [];
Contact_commId = [];

for i = 1 : num_Contact
    Contact_a = split(Contact{i});
    Contact_nodes = union(Contact_nodes,{Contact_a{1}},'stable');
    temp = str2num(char(Contact_a{2:end-1}))';
    Contact_vector = [Contact_vector;sparse(temp)];
    labelsId = find(ismember(labels,Contact_a{end}));
    if ~isempty(labelsId)
        Contact_commId = [Contact_commId,i];
    end
end

save([savePath,'TerroristRel_Contact_attributes.mat'],'Contact_vector','-v7.3');

% load TerroristRel_Family.nodes
Family = importdata([dataPath,'TerroristRel_Family.nodes'],'');

% load TerroristRel_Colleague.nodes
Colleague = importdata([dataPath,'TerroristRel_Colleague.nodes'],'');

% load TerroristRel_Congregate.nodes
Congregate = importdata([dataPath,'TerroristRel_Congregate.nodes'],'');

Family_vector = cell(num_Contact,1);
Colleague_vector = cell(num_Contact,1);
Congregate_vector = cell(num_Contact,1);
Family_commId = [];
Colleague_commId = [];
Congregate_commId = [];

for j = 1 : num_Contact
    Family_a = split(Family{j});
    Colleague_a = split(Colleague{j});
    Congregate_a = split(Congregate{j});
    Family_nodeId = find(ismember(Contact_nodes,Family_a{1}));
    Colleague_nodeId = find(ismember(Contact_nodes,Colleague_a{1}));
    Congregate_nodeId = find(ismember(Contact_nodes,Congregate_a{1}));
    Family_vector{Family_nodeId} = sparse(str2num(char(Family_a{2:end-1}))');
    Colleague_vector{Colleague_nodeId} = sparse(str2num(char(Colleague_a{2:end-1}))');
    Congregate_vector{Congregate_nodeId} = sparse(str2num(char(Congregate_a{2:end-1}))');
    FamilyId = find(ismember(labels,Family_a{end}));
    ColleagueId = find(ismember(labels,Colleague_a{end}));
    CongregateId = find(ismember(labels,Congregate_a{end}));
    if ~isempty(FamilyId)
        Family_commId = [Family_commId,Family_nodeId];
    end
    if ~isempty(ColleagueId)
        Colleague_commId = [Colleague_commId,Colleague_nodeId];
    end
    if ~isempty(CongregateId)
        Congregate_commId = [Congregate_commId,Congregate_nodeId];
    end
end

Family_vector = cell2mat(Family_vector);
Colleague_vector = cell2mat(Colleague_vector);
Congregate_vector = cell2mat(Congregate_vector);
save([savePath,'TerroristRel_Family_attributes.mat'],'Family_vector','-v7.3');
save([savePath,'TerroristRel_Colleague_attributes.mat'],'Colleague_vector','-v7.3');
save([savePath,'TerroristRel_Congregate_attributes.mat'],'Congregate_vector','-v7.3');

dlmwrite([savePath,'TerroristRel.txt'],Contact_commId,'precision',10,'delimiter','\t');
dlmwrite([savePath,'TerroristRel.txt'],Family_commId,'precision',10,'-append','delimiter','\t');
dlmwrite([savePath,'TerroristRel.txt'],Colleague_commId,'precision',10,'-append','delimiter','\t');
dlmwrite([savePath,'TerroristRel.txt'],Congregate_commId,'precision',10,'-append','delimiter','\t');

% load TerroristRel.edges
edges = importdata([dataPath,'TerroristRel.edges'],'');
num_edges = length(edges);

newedges = [];
for k = 1 : num_edges
    edges_a = split(edges{k});
    Lia = ismember(Contact_nodes,edges_a{1});
    Lib = ismember(Contact_nodes,edges_a{2});
    a = find(Lia);
    b = find(Lib);
    if (~isempty(a) & ~isempty(b)) && (a ~= b) 
        newedges = [newedges;[a,b]];
    end
end

% remove multiple edges
graph = sparse([newedges(:,1);newedges(:,2)],[newedges(:,2);newedges(:,1)],1);

[rowId,colId,w] = find(tril(graph) > 0); % rowId, columnId, and weight of edges in graph

dlmwrite([savePath,'TerroristRel'],[colId,rowId],'precision',10,'delimiter','\t');

end
