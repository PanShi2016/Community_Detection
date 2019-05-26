function [] = Amazon()
% Process Amazon dataset

dataPath = '../Original_Data/Amazon/';
savePath = '../Processed_Data/';

% load com-amazon.ungraph.txt
ungraph = importdata([dataPath,'com-amazon.ungraph.txt']);
edges = ungraph.data;

minIdx = min(min(edges));

if minIdx == 0
    graph = sparse(edges(:,1)+1,edges(:,2)+1,1);
    edges = edges + 1;
else
    graph = sparse(edges(:,1),edges(:,2),1);
end

[row, col]= size(graph);

if row ~= col
    graph = sparse([edges(:,1);edges(:,2)],[edges(:,2);edges(:,1)],1);
end

graph = graph - diag(diag(graph));    % remove self-loop
nonZeroIdx = find(sum(graph) > 0);    % nonZeroIdx(i) is the original nodeIdx in the file for node i
graph = graph(nonZeroIdx,nonZeroIdx);

[rowId,colId,w] = find(tril(graph) > 0);  % rowId, columnId, and the weight of edge in graph

dlmwrite([savePath,'Amazon'],[colId,rowId],'precision',10,'delimiter','\t');

% load com-amazon.top5000.cmty.txt
fid1 = fopen([dataPath,'com-amazon.top5000.cmty.txt'],'r');
cid1 = 1;

while 1
    s = fgets(fid1);  % get each community from top5000 truth communities
    if s == -1
        break;
    end
    id = sscanf(s,'%f');
    if minIdx == 0
        id = id + 1;
    end
    [~,newid,~] = intersect(nonZeroIdx,id);  % remove isolated vertices in each community
    if cid1 == 1
        dlmwrite([savePath,'Amazon5000.txt'],newid','precision',10,'delimiter','\t');
    else
        dlmwrite([savePath,'Amazon5000.txt'],newid','precision',10,'-append','delimiter','\t');
    end
    cid1 = cid1 + 1;
end

fclose(fid1);

% load com-amazon.all.cmty.txt
fid2 = fopen([dataPath,'com-amazon.all.cmty.txt'],'r');
cid2 = 1;

while 1
    s = fgets(fid2);  % get each community from all truth communities
    if s == -1
        break;
    end
    id = sscanf(s,'%f');
    if minIdx == 0
        id = id + 1;
    end
    [~,newid,~] = intersect(nonZeroIdx,id);  % remove isolated vertices in each community
    if cid2 == 1
        dlmwrite([savePath,'AmazonAll.txt'],newid','precision',10,'delimiter','\t');
    else
        dlmwrite([savePath,'AmazonAll.txt'],newid','precision',10,'-append','delimiter','\t');
    end
    cid2 = cid2 + 1;
end

fclose(fid2);

end
