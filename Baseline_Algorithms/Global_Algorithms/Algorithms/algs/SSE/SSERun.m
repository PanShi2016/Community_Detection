function community_pair = SSERun(filename, seeds, k)
graph1 = load(filename);
graph2 = [graph1(:,2),graph1(:,1)];
graph3 = [graph1;graph2];
sparse_comm = sparse(graph3(:,1),graph3(:,2),1);
result = OverlapCommSSE(sparse_comm, seeds,true,k);
[m,n] = size(result);
fid = fopen('SSE.gen', 'wt');
for i = 1:n
    I = find(result(:,i)>0);
    str = num2str(I');
    fprintf(fid,'%s\n',str);
end
fclose(fid);
