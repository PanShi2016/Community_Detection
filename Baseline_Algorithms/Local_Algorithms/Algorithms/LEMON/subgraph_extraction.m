function [output_subgraph, extracted_size] = subgraph_extraction(A, seed_set, varargin)
% [output_subgraph, extracted_size] = subgraph_extraction(A, seed_set, varargin)
  % INPUTS
  %   A                   - adjacency matrix
  %   seed_set            - small set of nodes
  %
  % varargin:
  %   'set_limit'   -- max size of output, default value min(3000, (size of A)/5 )
  %   'method'      -- input an integer k>=1 to use a k-walk.
  %
  % OUTPUTS
  %   output_subgraph     - set of nodes surrounding seed_set
  %   extracted_size      - size of subgraph extracted, before altering
  %
  % Kyle Kloster and Yixuan Li, 2016


  n = size(A,1);

  % PARAMETERS
  p = inputParser;
  p.addOptional('set_limit', min(3000, ceil(n/5) ) );
  p.addOptional('method', 2);
  p.parse(varargin{:});

  method_name = p.Results.method;
  set_limit = p.Results.set_limit;

  walk_k = p.Results.method ;
  assert( isnumeric(walk_k), 'Input method_name not valid\n' );
  iter_vec = sparse_k_walk( A, seed_set, walk_k );
  [inds, ~, vals] = find(iter_vec);

  [~, permut] = sort(vals,'descend');
  sorted_inds = inds(permut);
  sorted_inds = union(seed_set, sorted_inds, 'stable');
  output_subgraph = sorted_inds(1:min(set_limit, length(sorted_inds)));
  extracted_size = length(permut);

end
