function out = optimize_cluster_one(A,cSeed,c0,cTruth,opts)
  % Use gradient ascend to find an optimal cluster
  %
  % Do not call directly, use optimize_cluster instead
  
  % Initial/constant
  d = full(sum(A));
  if opts.normalize_cluster
    c0 = c0 / max(c0);
    cSeed = cSeed / max(cSeed);
  else
    c0 = min(1,max(0, c0));
    cSeed = min(1,max(0, cSeed));
  end
  
  % Timing
  time_start = cputime();
  
  % calculate random walk weights
  if isequal(opts.method,'sort') || (isequal(opts.method,'addrem') && isequal(opts.order,'pagerank')) || ...
     isequal(opts.method,'pagerank-threshold') || isequal(opts.method,'pagerank-top') || ...
     isequal(opts.method,'pagerank-optimal') || ...
     opts.min_rw_score > 0 || ...
     isequal(opts.score,'plus_random_walk') || isequal(opts.score,'rw') || ...
     isequal(opts.score,'times_random_walk') || isequal(opts.score,'trw') || ...
     isequal(opts.subset_method,'pagerank') || isequal(opts.subset_method,'positive_pagerank')
    p = random_walk(A,cSeed, opts);
    maxp = max(p);
  else
    p = {};
  end
  time_after_rw = cputime();
  
  if ~isequal(opts.subset_method,'none')
    % keep only the nodes with p>0
    % or: keep only the top N results
    n = size(c0,1);
    if isequal(opts.subset_method,'pagerank')
      th = quantile(p, 1 - opts.subset_size/n);
      th = max(th,eps);
      kept = find(p>=th);
    elseif isequal(opts.subset_method,'positive_pagerank')
      kept = find(p>0);
    elseif isequal(opts.subset_method,'nonzero_degree')
      kept = find(d>0);
    elseif isequal(opts.subset_method,'neighbors')
      c = cSeed;
      for i = 1:opts.subset_path_length
        c = c | (A*c) > 0;
      end
      kept = find(c);
      clear c;
    elseif isequal(opts.subset_method,'neighbors_size')
      if ~isfield(opts,'subset_size') || opts.subset_size == 0, opts.subset_size = 1000; end;
      c = cSeed;
      while nnz(c) < opts.subset_size
        n = nnz(c);
        c = c | (A*c) > 0;
      nnz(c)
        if n == nnz(c), break; end
      end
      kept = find(c);
      clear c;
    elseif isequal(opts.subset_method,'bfs')
      % From the paper: Detecting Overlapping Communities from Local Spectral Subspaces
      if ~isfield(opts,'subset_size') || opts.subset_size == 0, opts.subset_size = 1000; end;
      if ~isfield(opts,'subset_max_outdegree'), opts.subset_max_outdegree = 1000; end;
      c = cSeed;
      for i = 1:opts.subset_path_length % 2 or 3
        c = c | (A*c) > 0;
      end
      w = full(sum(A(c,c)));
      remove = d(c)-w > opts.subset_max_outdegree;
      ci = find(c);
      ci(remove) = []; % "remove vertices whose outdegree is greater than 1000"
      w(remove) = [];
      [r,i]=sort(w ./ (d(ci)+eps),'descend');
      ci = ci(i(1:min(opts.subset_size,length(i))));
      kept = union(ci,find(cSeed));
      clear c;
    elseif isequal(opts.subset_method,'bfss')
      % simplified version of the above
      if ~isfield(opts,'subset_size') || opts.subset_size == 0, opts.subset_size = 1000; end;
      c = cSeed;
      for i = 1:opts.subset_path_length % 2 or 3
        c = c | (A*c) > 0;
      end
      w = full(sum(A(c,c)));
      ci = find(c);
      [r,i] = sort(w ./ (d(ci)+eps),'descend');
      ci = ci(i(1:min(opts.subset_size,length(i))));
      kept = union(ci,find(cSeed));
      clear c;
    elseif isequal(opts.subset_method,'neighbors_strict_size')
      % automatically run the right number of iterations
      kept = find(cSeed);
      while length(kept)>0
        neighbors = find(any(A(:,kept),2));
        next = union(kept,neighbors);
        if length(next) == length(kept)
          break; % no more neighbors
        elseif length(next) >= opts.subset_size
          neighbors = setdiff(neighbors,kept);
          score = sum(A(kept,neighbors),1) ./ (d(neighbors) + eps);
          [~,which] = sort(score, 'descend');
          %neighbors = neighbors( ranks(-score) <= (opts.subset_size - length(kept)) );
          neighbors = neighbors(which(1:opts.subset_size - length(kept)));
          assert(length(neighbors) == (opts.subset_size - length(kept)));
          kept = union(kept, neighbors);
          break;
        else
          kept = next;
        end
      end
    elseif isequal(opts.subset_method,'greedy')
      if ~isfield(opts,'subset_size') || opts.subset_size == 0, opts.subset_size = 1000; end;
      kept = optimize_conductance_greedy(A,find(cSeed),opts.subset_size,0,0,0);
    else
      error('Unknown subset_method',opts.subset_method);
    end
    A_orig = A;
    d_orig = d;
    cSeed_orig = cSeed;
    cTruth_orig = cTruth;
    c0_orig = c0;
    
    A = A(kept,kept);
    d = d(kept);
    if ~isempty(p), p = p(kept); end
    c0 = c0(kept);
    cSeed = cSeed(kept);
    cTruth = cTruth(kept);
  end

  if isequal(opts.score,'conductance')
    score = @(c)score_conductance(A,c,d);
  %elseif isequal(opts.score,'conductance_size') || isequal(opts.score,'size')
  %  score = @(c)score_conductance_size(A,c,opts.target_size,d);
  elseif isequal(opts.score,'conductance_close') || isequal(opts.score,'close')
    if ~isfield(opts,'close_weight') opts.close_weight = 1; end
    score = @(c)score_conductance_close(A,c,cSeed,opts.close_weight,d);
  elseif isequal(opts.score,'conductance_double')
    score = @(c)score_conductance_double(A,c,d);
  elseif isequal(opts.score,'conductance_power') || isequal(opts.score,'power')
    if ~isfield(opts,'power'), opts.power = 1; end;
    score = @(c)score_conductance_pow(A,c,opts.power,d);
  elseif isequal(opts.score,'conductance_times_local') || isequal(opts.score,'local')
    score = @(c)score_conductance_times_local(A,c,d);
  elseif isequal(opts.score,'conductance_weighted') || isequal(opts.score,'weighted')
    score = @(c)score_conductance_weighted(A,c,d);
  elseif isequal(opts.score,'conductance_degree_hack') || isequal(opts.score,'degree_hack') || isequal(opts.score,'size_denominator')
    if ~isfield(opts,'degree_hack'), opts.degree_hack = 2; end;
    if ~isfield(opts,'size_amount'), opts.size_amount = opts.degree_hack; end;
    score = @(c)score_conductance_degree_hack(A,c,opts.size_amount,d);
  elseif isequal(opts.score,'conductance_plus') || isequal(opts.score,'plus')
    if ~isfield(opts,'plus'), opts.plus = 1; end;
    if ~isfield(opts,'plus2'), opts.plus2 = opts.plus; end;
    score = @(c)score_conductance_plus(A,c,opts.plus,opts.plus2,d);
  elseif isequal(opts.score,'conductance_posdef') || isequal(opts.score,'sigma')
    if ~isfield(opts,'sigma'), opts.sigma = 1; end;
    % A2 = A + opts.sigma * diag(d);
    A2 = A + opts.sigma * spdiags(d',0,length(d),length(d));
    score = @(c)score_conductance(A2,c,d);
    %score = @(c)score_conductance_plus(A2,c,0,eps,d);
  elseif isequal(opts.score,'sigma_lambda')
    if ~isfield(opts,'sigma'), opts.sigma = 1; end;
    if ~isfield(opts,'lambda1'), opts.lambda1 = 0; end;
    if ~isfield(opts,'lambda2'), opts.lambda2 = 0; end;
    score = @(c)score_conductance_sigma_lambda(A,c,d,opts.sigma,opts.lambda1,opts.lambda2);
  elseif isequal(opts.score,'plus_random_walk') || isequal(opts.score,'rw')
    if ~isfield(opts,'rw_weight'), opts.rw_weight = 0.5; end;
    score = @(c)score_conductance_plus_rw(A,c,p/maxp,opts.rw_weight,d);
  elseif isequal(opts.score,'times_random_walk') || isequal(opts.score,'trw')
    if ~isfield(opts,'rw_weight'), opts.rw_weight = 0.5; end;
    score = @(c)score_conductance_times_rw(A,c,p/maxp,opts.rw_weight,d);
  elseif is_function_handle(opts.score)
    score = opts.score;
  else
    error('Not a valid score function: %s',opts.score);
  end
  
  if isequal(opts.method,'gradient')
    [c,l] = optimize_cluster_gradient(p,score,cSeed,c0,opts);
  elseif isequal(opts.method,'discrete')
    [c,l] = optimize_cluster_gradient(p,score,cSeed,c0,opts);
  elseif isequal(opts.method,'sort')
    [c,l] = optimize_cluster_sort(p,score,cSeed,c0,opts);
  elseif isequal(opts.method,'addrem')
    [c,l] = optimize_cluster_addrem(A,p,c0,opts);
  elseif isequal(opts.method,'em') || isequal(opts.method,'kmeans')
    c = optimize_cluster_kmeans(A,d,cSeed,c0,opts);
    l = 0;
  elseif isequal(opts.method,'mh')
    [c,l] = optimize_cluster_mh(A,d,cSeed,c0,opts);
  elseif isequal(opts.method,'pagerank-threshold')
    if ~isfield(opts,'threshold'), opts.threshold = 0.01; end;
    c = p >= opts.threshold;
    l = opts.threshold;
  elseif isequal(opts.method,'pagerank-top')
    if ~isfield(opts,'top'), opts.top = 10; end;
    if opts.top <= length(p)
      th = -nth_element(-p,opts.top);
    else
      th = 0;
    end
    c = p >= th;
    l = th;
  elseif isequal(opts.method,'pagerank-optimal')
    % Assume that pagerank gives probabilities, and seeds are certain
    % pick cluster that maximizes expected F1 score
    if ~isfield(opts,'num_walks'), opts.num_walks = 1; end;
    if ~isfield(opts,'optimal_size'), opts.optimal_size = 10; end;
    p = 1 - (1-p).^opts.num_walks;
    p = min(1, p + cSeed);
    if opts.optimal_size > 0
      l = opts.optimal_size;
      for it=1:5
        % try to get sum(p) to equal l
        sum_p1 = sum(p>=1); % already at 1
        sum_p = sum(p);
        mul = (l - sum_p1) / (sum_p - sum_p1 + eps);
        %p = min(1, p * mul);
        p = 1 - (1-p).^mul;
      end
    else
      l = sum(p);
    end
    [ps,pos] = sort(p,'descend');
    zs = cumsum(ps) ./ ((1:length(p))' + l + eps);
    [z,zi] = max(zs);
    c = sparse(pos(1:zi),1,1,length(p),1);
  elseif isequal(opts.method,'neighbors')
    c = cSeed;
    for i = 1:opts.path_length
      c = c | (A*c) > 0;
    end
    l = opts.path_length;
  elseif isequal(opts.method,'lemon')
    addpath([pwd '/../LEMON/LEMON']);
    c = optimize_cluster_lemon(A,cSeed, 'parallel',0, 'verbose',opts.verbose);
    l = 0;
  elseif isequal(opts.method,'hkgrow')
    addpath([pwd '/../hkgrow']);
    [c,l] = hkgrow(A,find(cSeed));
    c = sparse(c,1,1,length(A),1);
  elseif isequal(opts.method,'hkgrow_union_seed')
    addpath([pwd '/../hkgrow']);
    [c,l] = hkgrow(A,find(cSeed));
    c = sparse(c,1,1,length(A),1) | cSeed;
  elseif isequal(opts.method,'hkgrow_fixed')
    addpath([pwd '/../hkgrow']);
    t = 15.;
    epsilon = 0.0001;
    [c,l] = hkgrow_mex(A, find(cSeed), t, epsilon, opts.verbose>0);
    c = sparse(c,1,1,length(A),1);
  elseif isequal(opts.method,'hkgrow_neighbors')
    [c,l] = optimize_cluster_hkgrow_neighbors(A,cSeed);
  elseif isequal(opts.method,'pprgrow')
    addpath([pwd '/../hkgrow/ppr']);
    [c,l] = pprgrow(A,find(cSeed));
    c = sparse(c,1,1,length(A),1);
  elseif isequal(opts.method,'heat_kernel')
    [c,l] = optimize_cluster_heat_kernel(A,cSeed);
  elseif isequal(opts.method,'greedy')
    if ~isfield(opts,'remove'), opts.remove = 0; end;
    if ~isfield(opts,'below_best'), opts.below_best = 1.0; end;
    if opts.max_size < 0, opts.max_size = 0; end
    [c,l] = optimize_conductance_greedy(A,find(cSeed),opts.max_size,opts.remove,0,opts.below_best);
    c = sparse(c,1,1,length(A),1);
  elseif isequal(opts.method,'lso')
    % find the global clusters containing the seed(s)
    if ~isequal(opts.subset_method,'none')
      opts.global_clusters = lso_cluster(A, opts.lso_arguments{:});
    end
    s = find(cSeed);
    c = 0;
    for i=1:length(s)
      c = c | (opts.global_clusters == opts.global_clusters(s(i)));
    end
    l = 0;
  elseif isequal(opts.method,'all')
    c = ones(length(A),1); % just put all nodes in the cluster
    l = 0;
  else
    error('Unknown method: %s',opts.method);
  end
  time_after_method = cputime();
  
  if ~isequal(opts.subset_method,'none')
    [i,~,v] = find(c);
    c = sparse(kept(i),1,v,n,1);
    A = A_orig;
    cSeed = cSeed_orig;
    cTruth = cTruth_orig;
    c0 = c0_orig;
  end
  if opts.output_summary
    out = compare_cluster_summary(A,c,cSeed,c0,cTruth);
    out.score = l;
    out.cputime = time_after_method - time_start;
    out.cputime_method = time_after_method - time_after_rw;
    out.cputime_rw = time_after_rw - time_start;
    if ~isequal(opts.subset_method,'none')
      out.subset_size = length(kept);
    end
  else
    out.c     = c;
    out.score = l;
  end
end

