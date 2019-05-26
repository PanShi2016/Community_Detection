function [] = Isobase(dataName)
% Process Isobase datasets, including hs, mm, dm, ce and sc

dataPath = '../Original_Data/Isobase/';
savePath = '../Processed_Data/';

% load *.tab
edges = importdata([dataPath,dataName,'.tab'],'');
edges = edges(2:end);
nodes = split(edges);

% convert to a matrix
[nodes_uni,unused,nodesid] = unique(nodes,'stable');
col1 = nodesid(1:length(nodes));
col2 = nodesid(length(nodes)+1:end);

A = sparse(col1,col2,1,length(nodes_uni),length(nodes_uni));
A = A | A';
A = A - diag(diag(A)); % remove self loops
[rowId,colId,w] = find(tril(A) > 0);  % rowId, columnId, and the weight of edge in matrix A

dlmwrite([savePath,'Isobase_',dataName],[colId,rowId],'precision',10,'delimiter','\t');

% load pid.go.goevid.goaspect.txt
go = importdata([dataPath,'pid.go.goevid.goaspect.txt'],'');
comm = split(go);

idx = regexp(comm(:,1),dataName);
id = find(cellfun(@(x)~isempty(x),idx));

cid = [];
index = [];
for i = 1 : length(id)
    Lia = ismember(nodes_uni,comm(id(i),1));
    ind = find(Lia);
    if ~isempty(ind)
        cid = [cid,id(i)];
    end
    index = [index,ind];
end

commnodes = [];
for j = 1 : length(cid)
    goid = split(comm(cid(j),2),'|');
    commnodes = [commnodes;index(j)*ones(length(goid),1)];
end

[go_uni,unused,goidx] = unique(comm(cid,2),'stable');

t = 0;
for k = 1 : length(go_uni)
    id = find(goidx==k);
    nodesgo = commnodes(id)';
    nodesgo = unique(nodesgo,'stable');
    if length(nodesgo) >= 3
        t = t + 1;
       if t == 1
           dlmwrite([savePath,'Isobase_',dataName,'.txt'],nodesgo,'precision',10,'delimiter','\t');
       else
           dlmwrite([savePath,'Isobase_',dataName,'.txt'],nodesgo,'-append','precision',10,'delimiter','\t');
       end
   end
end

end
