function [center] = get_hrc_graclus_seeds(A,k,minSize)

%[prt,prtsz,NoCC] = hrcGraclus_Joyce(A,ncs,lvl);
ncs=2;
lvl=round(log2(k));
[prt,prtsz] = hrcGraclus(A,ncs,lvl);
partition=prt{end};
[center] = ComputeCenterNodes2(A, partition, minSize);

end

