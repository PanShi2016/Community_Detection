function [output_cluster, cond] = lemon_original( A, S, varargin)
% [output_cluster, subg_size] = lemon_original( A, S, varargin)
%
% INPUTS
%   A    - adjacency matrix
%   S       - seed set
%
%   varargin:
%   krylov_dimension  - default 3, determines dim l of krylov subspace
%   krylov_shift       - default 3, determines shift k of krylov subspace
%               K(k,l) = [ A_sub^(k)*v, ..., A_sub^(k+l-1)*v ]
%   seed_augment_size - default 6, determines size of increase of seed set
%   num_augment_steps - default 10, determines num of seed set increases
%   subgraph_size     - default 3000, size of initial subgraph extracted
%   sweep_range       - default [1,subgraph_size],  determines interval of
%                       lemon vector indices swept over
%
% OUPUTS
%   output_cluster        - cluster identified by LEMON
%   subg_size             - size off subgraph extracted before LEMON computed
%
% This method first described in
% "Uncovering small structure in large networks"
% [Li, He, Bindel, Hopcroft 2015]

  % [0] PARAMETERS
  %   settings recommended in Li et al. paper
    p = inputParser;
    p.addOptional('num_augment_steps',10);
    p.addOptional('seed_augment_size',6);
    p.addOptional('krylov_dimension',3);
    p.addOptional('krylov_shift',3);
    p.addOptional('subgraph_size',3000);
    p.addOptional('sweep_range',[1,0]);
    p.parse(varargin{:});
    krylov_shift = p.Results.krylov_shift;
    krylov_dimension = p.Results.krylov_dimension;
    num_augment_steps = p.Results.num_augment_steps;
    seed_augment_size = p.Results.seed_augment_size;
    set_limit = p.Results.subgraph_size;
    sweep_range = [1,set_limit];
    input_sweep_range = p.Results.sweep_range;
    sweep_range(1) = max( sweep_range(1), input_sweep_range(1) );
    if input_sweep_range(2) > 0,
      sweep_range(2) = max( sweep_range(1), min( input_sweep_range(2), set_limit ) );
    end

  % [1] SUBGRAPH EXTRACTION ("sub-sampling")
    [subgraph_indices, subg_size] = subgraph_extraction(A, S, 'set_limit', set_limit, ...
        'method', 2 );
    A_sub = A(subgraph_indices, subgraph_indices);
    n_sub = size(A_sub,1);

    degs_sub = full(sum(A_sub,2));
    Dsub_sqinv = spdiags( degs_sub.^-0.5, 0, n_sub, n_sub);
    Abar_sub = Dsub_sqinv*(A_sub + speye(n_sub))*Dsub_sqinv;

    S_sub = [];
    for j=1:length(S),
      S_sub = [S_sub; find( subgraph_indices == S(j) )];
    end

% [2] SEED AUGMENTATION
    S_current = S_sub;
    conductances = ones(num_augment_steps+2,1);
    conductances(1) = 0.0;
    conductances(2) = cut_cond(A_sub, S_current);
    for which_step = 1:num_augment_steps,

        % get LEMON vector
        lemon_vec = construct_lemon_vector(Abar_sub, S_current, krylov_shift, krylov_dimension);
        if length(lemon_vec) == 0
            continue;
        end

        % get current conductance
        [~,sort_inds] = sort(lemon_vec,'descend');
        [node_set, cond_current] = sweepcut(A_sub,sort_inds,'inputnodes',true,'sweeprange',sweep_range);
        conductances(which_step+2) = cond_current;

        % check termination criterion:
        if ( (conductances(which_step+1) < cond_current) ...
        && (conductances(which_step+1) < conductances(which_step)) ),
          break;
        end

        % augment current seed set
        augment_size = min(seed_augment_size*which_step, length(sort_inds));
        S_current = union( S_current, sort_inds(1:augment_size) );
    end

    output_cluster = subgraph_indices( S_current );
    cond = cut_cond(A_sub,S_current);

end



%%%%%%%%%%%%%%%%%%%%

%%%
%%%   FUNCTION DEFS
%%%

function [lemon_iter] = construct_lemon_vector(Abar_sub, S_sub, krylov_shift, krylov_dimension)
  % Construct local spectral subspace
  n_sub = size(Abar_sub,1);
  P = zeros(n_sub,krylov_dimension);
  P(S_sub,1) = 1/length(S_sub);
  for j=2:krylov_dimension,
      P(:,j) = Abar_sub*P(:,j-1);
  end

  [V0,R] = qr(P, 0); % V_0,l in the paper
  V = V0;
  for j=1:krylov_shift,
      V0 = Abar_sub*V;
      [V,~] = qr( V0, 0 ); % reduced qr
  end

  % Compute LEMON
  lemon_iter = pos1norm(V,S_sub);

  % len_x = size(V,2);
  % V_S = V(S_sub,:);

  % cvx_begin quiet
  %     cvx_precision high
  %     variable x(len_x);
  %     minimize sum( V*x )
  %     subject to
  %         V*x >= 0;   % check y >= 0
  %         V_S*x >= 1; % check y(S_sub) >= 1
  % cvx_end

  % lemon_iter = V*x;
end
