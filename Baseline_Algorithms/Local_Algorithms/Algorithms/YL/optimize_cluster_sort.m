function [c,lBest] = optimize_cluster_sort(p,score,cSeed,c0,opts)

if ~isfield(opts,'optimum_hump') opts.optimum_hump = -1.2; end;

% sort by rw-score
[p,pos] = sort(p,'descend');

% find local maxima of score
cBest = c0;
c = cBest;
lBest = score(c);

for i=1:length(pos)
    if opts.max_size > 0 && sum(c) >= opts.max_size
        if opts.verbose
            fprintf('Cluster too large, stopping.\n');
        end
        break;
    end

    c(pos(i)) = 1;
    l = score(c);
    if l >= lBest
        lBest = l;
        cBest = c;
    else
        % stopping condition
        if opts.optimum_hump == 0
            break;
        elseif opts.optimum_hump < 0 && 1-l > (1-lBest)*(-opts.optimum_hump) % from Yang&Leskovec paper
            break;
        elseif l < lBest - opts.optimum_hump*lBest
            break;
        end
    end
end

l = lBest; 
c = cBest;

end
