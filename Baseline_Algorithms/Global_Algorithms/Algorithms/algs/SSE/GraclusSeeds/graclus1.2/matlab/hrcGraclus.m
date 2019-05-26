function [prt,prtsz] = hrcGraclus_Joyce(A,ncs,lvl)
%--------------------------------------------------------------------------
% Hierarchical graph partitioning using graclus
% 
% [prt,prtsz] = hrcGraclus(A,ncs,lvl)
%
% INPUT:: 
%   A     - Adjacency matrix of a graph
%   ncs   - Number of clusters at each level. Can be a single number, if
%       you wnat same number of clusters for all levels.
%   lvl	- Number of levels. Must be the case that lvl==length(ncs),
%       if length(ncs)>=2.
% OUTPUT:
%   prt   - Vector indicating cluster belonging for each vertex.
%   prtsz - Vector indicating the size of each cluster.
%--------------------------------------------------------------------------
% Joyce modified the code... 7/25/2012
%--------------------------------------------------------------------------

tic

prt = cell(lvl,1);
prtsz = cell(lvl,1);

if length(ncs) == 1
    ncs = ones(lvl,1)*ncs;
end

[ci, obj] = graclus_mex(A,nnz(A),ncs(1),0,0,0);
prt{1} = ci;

csz = zeros(1,ncs(1));
for i=1:ncs(1)
	csz(i) = sum(ci == i);
end
prtsz{1} = csz;

for l=2:lvl
    
    fprintf('================= Level %d =================\n',l);
    cnum = 0;
    nprt = zeros(size(A,1),1);
    
    for i=1:max(prt{l-1}) % no. of clusters in the previous level
        ind = find(prt{l-1} == i); % extract one cluster
        % if the cluster size is big enough, recursively partition it
        if length(ind)>20 % adjust threshold
            % partition the extracted cluster into ncs(l) clusters
            [ci, obj] = graclus_mex(A(ind,ind),nnz(A(ind,ind)),ncs(l),0,0,0);
            sci=ci;
            for j=1:ncs(l)
                ci(sci==j) = cnum + j; % re-indexing the partition number
            end
            cnum = max(ci);
            nprt(ind) = ci;
            %unique(nprt(ind))
        else
            nprt(ind) = cnum + 1;
            cnum = max(nprt(ind));
            %unique(nprt(ind))
        end
    end
    prt{l} = nprt; % clustering result
    
    csz = zeros(1,max(nprt));
    for i=1:numel(csz)
        csz(i) = sum(nprt==i);
    end
    prtsz{l} = csz; % cluster size
    toc
end

