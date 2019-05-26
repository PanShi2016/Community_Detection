function [out,l] = optimize_cluster(A,c0,varargin)
  % Use gradient ascend to find an optimal cluster
  
  % Options
  if length(varargin) == 1 && isstruct(varargin{1})
    opts = varargin{1};
  else
    opts = struct(varargin{:});
  end
  if ~isfield(opts,'verbose'), opts.verbose = 0; end;
  if ~isfield(opts,'score'), opts.score = 'conductance'; end;
  if ~isfield(opts,'method'), opts.method = 'gradient'; end
  if ~isfield(opts,'max_iter'), opts.max_iter = 100 + isequal(opts.method,'discrete')*1000; end;
  if ~isfield(opts,'min_step'), opts.min_step = 1/32; end;
  if ~isfield(opts,'max_step'), opts.max_step = 1e9; end;
  if ~isfield(opts,'max_size'), opts.max_size = -1; end;
  if ~isfield(opts,'line_search_step'), opts.line_search_step = 2; end;
  if ~isfield(opts,'positive_first'), opts.positive_first = 0; end;
  if ~isfield(opts,'negative_first'), opts.negative_first = 0; end;
  if ~isfield(opts,'positive_only'), opts.positive_only = 0; end;
  if ~isfield(opts,'stop_on_negative'), opts.stop_on_negative = 0; end;
  if ~isfield(opts,'try_infinite_step'), opts.try_infinite_step = 0; end;
  if ~isfield(opts,'normalize_cluster'), opts.normalize_cluster = 0; end;
  if ~isfield(opts,'keep_initial'), opts.keep_initial = 1; end;
  %if ~isfield(opts,'target_size') opts.target_size = full(sum(c0,1)); end
  if ~isfield(opts,'parallel'), opts.parallel = (exist('OCTAVE_VERSION','builtin') && size(c0,2)>100) * 3; end;
  if opts.negative_first, opts.positive_first = 0; end
  if ~isfield(opts,'min_rw_score'), opts.min_rw_score = 0; end;
  if ~isfield(opts,'output_summary'), opts.output_summary = 0; end;
  if ~isfield(opts,'subset_size'), opts.subset_size = 0; end;
  if ~isfield(opts,'subset_path_length'), opts.subset_path_length = 2; end;
  if ~isfield(opts,'subset_method')
    if opts.subset_size>0
      opts.subset_method = 'pagerank';
    elseif isequal(opts.method,'lemon')
      opts.subset_method = 'nonzero_degree';
    else
      opts.subset_method = 'none';
    end
  end;
  if ~isfield(opts,'order'), opts.order = 'pagerank'; end
  
  % Seed vs initialization
  if isfield(opts,'initial')
    cSeed = c0;
    c0 = opts.initial;
  elseif isfield(opts,'target')
    cSeed = opts.target;
  else
    cSeed = c0;
  end
  assert(isequal(size(cSeed), size(c0)));
  
  % Ground truth (for comparison)
  if isfield(opts,'truth')
    cTruth = opts.truth;
  else
    cTruth = c0; % dummy
  end
  
  % Global method? In that case run it only once
  if isequal(opts.method,'lso') && isequal(opts.subset_method,'none')
    if ~isfield(opts,'lso_arguments'), opts.lso_arguments = {}; end
    opts.global_clusters = lso_cluster(A, opts.lso_arguments{:});
  end
  
  % Multiple clusters at once
  out = cell(1,size(c0,2));
  if opts.parallel
    if exist('OCTAVE_VERSION','builtin')
      out = pararrayfun(opts.parallel,@(i)optimize_cluster_one(A,cSeed(:,i),c0(:,i),cTruth(:,i),opts), 1:columns(c0), 'UniformOutput',false);
      if length(out) ~= columns(c0) || ~isstruct(out{1})
        warning('Parallel computation failed')
        for i=1:size(c0,2)
          out{i} = optimize_cluster_one(A,cSeed(:,i),c0(:,i),cTruth(:,i),opts);
        end
      end
    else
      parfor i=1:size(c0,2)
        out{i} = optimize_cluster_one(A,cSeed(:,i),c0(:,i),cTruth(:,i),opts);
      end
    end
  else
    for i=1:size(c0,2)
      out{i} = optimize_cluster_one(A,cSeed(:,i),c0(:,i),cTruth(:,i),opts);
    end
  end
  
  if opts.output_summary
    out = transpose_struct(out);
    out.opts = rmfield(opts,'truth');
  else
    c = cellfun(@(x)x.c,out,'UniformOutput',false);
    c = [c{:}];
    l = cellfun(@(x)x.score,out,'UniformOutput',true);
    out = c;
  end
end

