function community_pair = NISERun(filename, seeds, k)
graph1 = load(filename);
graph2 = [graph1(:,2),graph1(:,1)];
graph3 = [graph1;graph2];
sparse_comm = sparse(graph3(:,1),graph3(:,2),1);
result = nise(sparse_comm, k,seeds,true);
[m,n] = size(result);
fid = fopen('NISE.gen', 'wt');
for i = 1:n
    I = find(result(:,i)>0);
    str = num2str(I');
    fprintf(fid,'%s\n', str);
end
fclose(fid);
