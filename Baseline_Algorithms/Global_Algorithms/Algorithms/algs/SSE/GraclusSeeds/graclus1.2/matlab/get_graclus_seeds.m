function [center] = get_graclus_seeds(A,k,minSize)

[partition, ~] = graclus(A,k,0,0,0);
[center] = ComputeCenterNodes2(A, partition, minSize);
%[center] = ComputeCenterNodes(A, partition);

end

