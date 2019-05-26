function [center] = ComputeCenterNodes(A, partition)

sigma=1.0;

if min(partition)==0
    partition=partition+1;
end

m=max(partition);

degree = sum(A,2);
links_Vc = zeros(m,1);
w_Vc = zeros(m,1);
for k=1:m
    ind = find(partition==k);
    select = A(ind,ind);
    links_Vc(k) = sum(sum(select));
    w_Vc(k) = sum(degree(ind));
end

% compute center nodes
center = zeros(m,1);
for k=1:m
    nodes = find(partition==k);
    n=length(nodes);
    distance = zeros(n,1);
    for i=1:n
        friends = find(A(:,nodes(i)));
        links=sum(partition(friends)==k);
        wi = degree(nodes(i));
        distance(i) = -(2*links/(wi*w_Vc(k))) + links_Vc(k)/((w_Vc(k))^2) + sigma/wi - sigma/w_Vc(k);
        fprintf('cluster: %d, node: %d, distance: %f \n',k,nodes(i),distance(i));
    end
    %distance
    if nnz(distance==min(distance))>1
        fprintf('min distance tie nodes...\n');
        ties=nodes(distance==min(distance))
        center(k)=ties(1);
    else 
       center(k)=nodes(distance==min(distance)); 
    end
    fprintf('cluster: %d, cluster size: %d, center: %d, distance: %f\n',k, n,center(k),min(distance));
end

end

