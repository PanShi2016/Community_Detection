function [H,setdata] = growclusters(A,seeds,varargin)
% GROWCLUSTERS Expand seed sets into clusters based on the PPR method
%
% [H,setdata] = growclusters(A,seeds,...)
% takes a vector of seeds, or a cell array of seed sets.
% as well as options for the ppr cluster routine
% and returns the best cluster found by exploring around
% the seed.  Note that this does not neessarily contain
% the seed itself.

n = size(A,1);
if ~iscell(seeds), seeds=num2cell(seeds); end
ns = numel(seeds);

%fprintf('Computing pprgrow clustering ... for %i seeds\n', ns);
setdata.cond = zeros(ns,1);
setdata.cut = zeros(ns,1);
setdata.vol = zeros(ns,1);
setdata.size = zeros(ns,1);
setdata.seeds = seeds;
H = sparse(n,ns);
for i=1:ns
    seed = seeds{i};
    [curset,setdata.cond(i),setdata.cut(i),setdata.vol(i),setdata.expand(i)] = ...
        pprgrow(A,seed,varargin{:});
    setdata.size(i) = min(numel(curset),n-numel(curset));
    setdata.vol(i) = min(nnz(A) - setdata.vol(i),setdata.vol(i));
    H(curset,i) = 1;
end