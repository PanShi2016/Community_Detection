function ps = random_walk(A,seed,varargin)
opts = struct(varargin{:});
if ~isfield(opts,'rw_decay'),  opts.rw_decay = 0.5; end; % called alpha in pagerank-nibble paper
if ~isfield(opts,'rw_iter'),   opts.rw_iter = 10; end;
if ~isfield(opts,'rw_diag'),   opts.rw_diag = 1; end;
if ~isfield(opts,'rw_threshold'), opts.rw_threshold = 1e-8; end;
if ~isfield(opts,'rw_degree_normalize'), opts.rw_degree_normalize = 0; end;

d = full(sum(A,2)) + eps;

for i = 1 : size(seed,2);
  p = seed(:,i);
  for it = 1:opts.rw_iter
      % p = p ./ (d + opts.rw_diag);
      % p = seed + opts.rw_decay * (opts.rw_diag * p + A * p);
      % p = max(seed, opts.rw_decay * (opts.rw_diag * p + A * p));
      if nnz(p) < 1e5
          [pi,~,pv] = find(p);
          p = opts.rw_decay * seed(:,i) + (1-opts.rw_decay)*(p + A(:,pi) * (pv./d(pi)))/2;
      else
          p = opts.rw_decay * seed(:,i) + (1-opts.rw_decay)*(p + A * (p./d))/2;
      end
      % remove very small values
      if opts.rw_threshold > 0
          [pi,~,pv] = find(p);
          % p(pi(pv < opts.rw_threshold)) = 0;
          p = sparse(pi(pv >= opts.rw_threshold),1,pv(pv >= opts.rw_threshold),length(p),1);
      end
      if nnz(p) > length(p)/4
          p = full(p); % at some point dense vectors are more efficient
      end
  end
  if opts.rw_degree_normalize
      p = p ./ (d+eps);
  end
  ps(:,i) = p;
end

end
