function [cond cut vol] = cut_cond(A,set)
% function [cond cut vol] = cut_cond(A,set)
%
% INPUTS
%  A    -- adjacency matrix, must be symmetric and {0,1}-valued
%  set  -- set of nodes
%
% OUTPUTS
%   cond  -- conductance of `set`
%   cut   -- number of cut edges of `set`
%   vol   -- edge volume of `set`
%
%

  inds = set;

  totvol = nnz(A);
  n = size(A,1);
  e_S = sparse( inds, 1, 1, n, 1);
  Ae_S = A*e_S;
  vol = full( sum( Ae_S ) );
  cut = vol - full( e_S'*Ae_S );
  temp_vol = min(vol, totvol-vol);
  if temp_vol == 0,
      cond = 1;
      return;
  end
  cond = cut/temp_vol;
