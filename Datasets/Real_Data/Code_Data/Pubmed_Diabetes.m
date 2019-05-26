function [] = Pubmed_Diabetes()
% Process Pubmed-Diabetes dataset

dataPath = '../Original_Data/Pubmed-Diabetes/';
savePath = '../Processed_Data/';

% load Pubmed-Diabetes.NODE.paper.tab
attributes = importdata([dataPath,'Pubmed-Diabetes.NODE.paper.tab'],'');
num_attributes = length(attributes);

% get unique words
words = split(attributes{2});
num_words = length(words);
word_vector = [];

for i = 2 : (num_words - 1)
    words_a = split(words{i},':');
    word_vector = union(word_vector,{words_a{2}},'stable');
end

classes = {'label=1';'label=2';'label=3'};
num_classes = length(classes);
num_words_vector = length(word_vector);
prob_vector = zeros(1,num_words_vector);
prob_matrix = [];
paperId = [];
commId = [];
temp_vector = [];
temp_vector2 = [];

for j = 3 : num_attributes
    attributes_a = split(attributes{j});
    paperId = union(paperId,{attributes_a{1}},'stable');
    commId = [commId,find(ismember(classes,attributes_a{2}))];
    num_attributes_a = length(attributes_a);
    for k = 3 : (num_attributes_a - 1)
        attributes_b = split(attributes_a{k},'=');
        temp_vector = [temp_vector,find(ismember(word_vector,attributes_b{1}))];
        temp_vector2 = [temp_vector2,str2num(attributes_b{2})];
    end
    prob_vector(temp_vector) = temp_vector2;
    prob_matrix = [prob_matrix;sparse(prob_vector)];
end

save([savePath,'Pubmed-Diabetes_attributes.mat'],'prob_matrix','-v7.3');

for l = 1 : num_classes
    comm = find(commId == l);
    if l == 1
        dlmwrite([savePath,'Pubmed-Diabetes.txt'],comm,'precision',10,'delimiter','\t');
    else
        dlmwrite([savePath,'Pubmed-Diabetes.txt'],comm,'precision',10,'-append','delimiter','\t');
    end
end

% load Pubmed-Diabetes.DIRECTED.cites.tab
cites = importdata([dataPath,'Pubmed-Diabetes.DIRECTED.cites.tab'],'');
num_cites = length(cites);

newcites = [];
for m = 3 : num_cites
    cites_a = split(cites{m});
    Lia = ismember(paperId,cites_a{2}(7:end));
    Lib = ismember(paperId,cites_a{4}(7:end));
    a = find(Lia);
    b = find(Lib);
    if (~isempty(a) & ~isempty(b)) && (a ~= b) 
        newcites = [newcites;[a,b]];
    end
end

% remove multiple edges
graph = sparse([newcites(:,1);newcites(:,2)],[newcites(:,2);newcites(:,1)],1);

[rowId,colId,w] = find(tril(graph) > 0); % rowId, columnId, and weight of edges in graph

dlmwrite([savePath,'Pubmed-Diabetes'],[colId,rowId],'precision',10,'delimiter','\t');

end
