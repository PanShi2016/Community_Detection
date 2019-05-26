function graph = loadGraph(dataPathandName)
% load graph

network = load(dataPathandName);
graph = sparse(network(:,1),network(:,2),1);
[row,col] = size(graph);

if row ~= col
    graph = sparse([network(:,1);network(:,2)],[network(:,2);network(:,1)],1);
end

end
