function [r,dr] = score_conductance(A,c,d,dividemax)
  % [r,dr] = score_conductance(A,c,d)
  %
  % Input:
  %   A = adjacency matrix
  %   c = cluster membership degrees (sparse column vector)
  %   d = (optional) node degrees, d = sum(A)
  % Output:
  %   r = w/v/max(c):  the within cluster fraction
  %   dr = ∂s/∂c
  %
  % Calculate the within fraction of a cluster (higher is better).
  % Note: conductance = 1-s
  % Normalizes cluster memberships between 0 and 1, or equivalently calculates.
  % Second output is the gradient.

  if nargin<3 || isempty(d)
    d = full(sum(A));
  end
  if nargin<4
    dividemax = 2; % do set to 0 gradients that point outside contraints
  end
  
  if size(c,2)~=1
    %w = full(diag( c'*(A*c) ))';
    %w = full(sum(c .* (A*c),1));
    w = cluster_within(A,c);
  else
    % significantly faster to do the sparse multiplication manually
    [i,j,k] = find(c);
    if length(k)<10000
        w = full(diag( c'*(A(:,i)*k) ))';
        % w = spdiags((c'*(A(:,i)*k))',0,length(k),length(k));
    else
        w = full(diag( k'*(A(i,i)*k) ))';
    end
  end
  v = full(d*c);
  r = w./(v+eps);
  if dividemax
    r = r ./(max(c)+eps);
  end
  
  if nargout>=2
    n = length(A);
    if size(c,2)~=1
      dw = 2*A*c;
    else
      dw = 2*A(:,i)*k; % faster multiplication
    end
    dv = d';
    if dividemax
      if size(c,2)~=1
        dr = sparse(dr);
        dr = dr .* (dr>0 | c~=0); % don't remove nodes that aren't there
        dr(find(c==max(c) & dr>0)) = 0; % don't increase membership that is already 1
      elseif 1
        % faster code path
        relevant = union(find(dw),find(c)); % = find(dw|c) % union is faster
        v = v + eps;
        dr_r = dw(relevant)/v - dv(relevant)*(w/v^2);
        c_r = full(c(relevant));
        active_r = c_r > 0 & dr_r < 0 | c_r < 1 & dr_r > 0;
        dr = sparse(zeros(length(A),1));
        dr(relevant) = dr_r .* active_r;
      end
      if dividemax == 1
        dr = dr / (max(c) + eps);
      end
    else
      dr = dw/v - dv*(w/v^2);
    end
  end
end
