function [] = process_data(mu)
% Process LFR data

dataPath = './LFR_Model/binary_networks/';

% load network.dat
edges = load([dataPath,'network.dat']);
graph = sparse(edges(:,1),edges(:,2),1);

% save network 
[rowId,colId,w] = find(tril(graph) > 0); % rowId, columnId, and weight of edges in graph

dlmwrite(['LFR_',num2str(mu)],[colId,rowId],'precision',10,'delimiter','\t');

% load community.dat
comm = dlmread([dataPath,'community.dat']);
comm_num = max(max(comm(:,2:end)));

for i = 1 : comm_num
    [row,col] = find(comm(:,2:end)==i);
    comm_i = row';
    % save communities
    if i == 1
        dlmwrite(['LFR_',num2str(mu),'.txt'],comm_i,'precision',10,'delimiter','\t');
    else
        dlmwrite(['LFR_',num2str(mu),'.txt'],comm_i,'precision',10,'-append','delimiter','\t');        
    end
end

end    
