function c = optimize_cluster_kmeans(A,d,cSeed,c0,opts)
  if ~isfield(opts,'kernel') opts.kernel = 'normalized_assoc'; end
  if ~isfield(opts,'sigma')  opts.sigma = full(max(sum(A))); end
  if ~isfield(opts,'delta') opts.delta = 0.0; end
  if ~isfield(opts,'lambda') opts.lambda = opts.sigma - opts.delta; end
  
  % Kernel is sparse, so that's fine
  if isequal(opts.kernel,'ratio_assoc')
    K = opts.sigma * eye(length(A)) + A;
    w = ones(size(c0));
  elseif isequal(opts.kernel,'normalized_assoc')
    w = d' + eps;
    % K = opts.sigma * diag(w.^-1) + diag(w.^-1) * A * diag(w.^-1);
    sparse_w = spdiags(w.^-1,0,length(w),length(w));
    K = opts.sigma * sparse_w + sparse_w * A * sparse_w;
    lambda = opts.lambda * (w.^-1);
  else
    error('Unknown kernel: %s',opts.kernel);
  end
  
  c = c0;
  
  for it = 1:opts.max_iter
    % calculate distances to centroid
    % ⟨μ,xi⟩ = w*c*K(-,xi) / sum(w*c) = w*ci*K(ck,i) / sum(w*c)
    [ci,~,ck] = find(w.*c);
    ck = ck / (sum(ck)+eps);
    K_xx = diag(K);
    K_xm = K(:,ci) * ck;
    K_mm = full(ck' * K(ci,ci) * ck);
    dist = K_xx + K_mm - 2*K_xm;
    if opts.verbose
      loss1 = c'*dist
      loss2 = sum(1-c)*opts.lambda
      loss3 = loss1 + loss2 - (length(c)-1)*opts.sigma + length(c)*opts.delta
      loss3b = length(c)*opts.delta
      d = dist(1:3)
    end
    % Points with distance < lambda go into cluster
    cNew = dist < lambda;
    cNew = cNew | cSeed;
    if opts.verbose
      nnzC = nnz(cNew)
    end
    if ~any(cNew ~= c)
      break;
    end
    c = cNew;
  end
end
