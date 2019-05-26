function [H,setdata] = egonet_seeded_communities(A,expand,varargin)
% EGONET_SEEDED_COMMUNITIES Find locally minimal egonets and seed communities
%
% [H,setdata] = egonet_seeded_communities(A,...)
% takes an undirected graph A and returns a set of communities by first
% finding locally minimal egonet seeds, and then growing the seed vertices,
% and the seed egonets to produce clusters, the final set of clusters can
% be thresholded by a maximal conductance score.
%

p = inputParser;
p.addOptional('mindegree',5,@isnumeric);
p.addOptional('maxcond',1,@isnumeric);
%p.addOptional('expand',true,@islogical); %% this part is commented
p.parse(varargin{:});


n = size(A,1);
fprintf('Computing neighborhood clusters ... ');
data.d = full(sum(A,2));
d = data.d;
t0 = tic;
[data.cond data.cut data.vol data.cc data.t] = triangleclusters(A);
data.time.neighborhood = toc(t0);
fprintf('%.1f sec\n', data.time.neighborhood);

t0 = tic;
minverts = neighborhoodmin(A,data.cond);
minverts = minverts(data.d(minverts)>=p.Results.mindegree);
setdata.neighborhoods = data;
%[H1 setdata.singletons] = growclusters(A,minverts,'maxexpand',nnz(A)/3,'nruns',15);
%if p.Results.expand
if expand
    %fprintf('expand=true\n');
    egonetseeds = cell(numel(minverts),1);
    for i=1:numel(minverts)
        nset = unique([minverts(i); find(A(:,minverts(i)))]);
        egonetseeds{i} = nset;
    end
    [H setdata] = growclusters(A,egonetseeds,'maxexpand',nnz(A)/2,'nruns',13);
%     [H,msetdata] = merge_community_data(H1,setdata.singletons,H2,setdata.egonets);
%     msetdata.egonets = setdata.egonets;
else %% this part is added
    %fprintf('expand=false\n');
    egonetseeds = cell(numel(minverts),1);
    for i=1:numel(minverts)
        nset = minverts(i); % just take the seed
        egonetseeds{i} = nset;
    end
    [H setdata] = growclusters(A,egonetseeds,'maxexpand',nnz(A)/2,'nruns',13);
    %msetdata = setdata;
end
% [H,msetdata] = filter_community_conductance(H,msetdata,p.Results.maxcond);
% msetdata.minverts = minverts;
% msetdata = add_extra_community_data(H,msetdata);
% msetdata.neighborhoods = setdata.neighborhoods;
% msetdata.singletons = setdata.singletons;
% setdata = msetdata;