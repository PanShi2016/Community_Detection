function seeddata = seed_report(A,seeds,expand,varargin)
% only egonets are given to PPR
% SEED_REPORT Prepare a report on seeding communities
%
% seeddata = seed_report(A,seeds,expand,varargin);
%   if expand is true, then the seed sets are expanded via their
%     neighborhood
%   if seeds is not 'egonets', then varargin is passed to growclusters
%

if ~exist('expand','var') || isempty(expand), expand = true; end

if ischar(seeds) && strcmp(seeds,'egonets')
    %[H,setdata] = egonet_seeded_communities_Joyce_expand(A,'maxcond',1,'expand',expand);
    [H,setdata] = egonet_seeded_communities(A,expand,'maxcond',1);
else
    % expand the seeds
    if ~iscell(seeds), seeds=num2cell(seeds); end
    eseeds = cell(numel(seeds),1);
    for i=1:numel(seeds)
        si = seeds{i};
        %eseeds{end+1} = si;
        %if numel(si) == 1 && expand
        if expand
            %fprintf('expand=true\n');
            eseeds{i} = unique([si; find(A(:,si))]); % egonet
        else
            %fprintf('expand=false\n');
            eseeds{i} = si; % only seed
        end 
    end
    %fprintf('seed_report... growclusters... start.. no. of egonets passed: %d\n',length(eseeds));
    [H,setdata] = growclusters(A,eseeds,varargin{:});
    fprintf('growclusters done...\n');
end
[~,uc] = unique(H','rows','first'); % unique communities
H = H(:,uc);
setdata.cond = setdata.cond(uc);
setdata.size = setdata.size(uc);
setdata.vol = setdata.vol(uc);
setdata.cut = setdata.cut(uc);
setdata.seeds = setdata.seeds(uc);
setdata.expand = setdata.expand(uc);
setdata = add_extra_community_data(H,setdata);
seeddata = setdata;
fprintf('seed report done...\n');
seeddata.C = H;