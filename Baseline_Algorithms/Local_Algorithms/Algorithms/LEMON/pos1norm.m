function v = pos1norm( V,startPoints )
% Find minimum 1-norm vector lies in the column spaces of V.
% V: k column vectors got by random walk or Lanczos iteration
% i: seed vertice that must be in the cluster

if nargin < 1
    % two cliques of size 5, overlap at v4 and v5
    V = [  -0.2772   -0.2774   -0.2774   -0.5032   -0.5032   -0.2960   -0.2960   -0.2960
           -0.4371   -0.4311   -0.4311    0.0216    0.0216    0.3814    0.3814    0.3814]';
    startPoints = [1 4];  
end
   
[n,k]=size(V); % n rows, k colums
y = zeros(1,n);
y(startPoints) = 1;

f = [zeros(k,1); ones(n,1)];
Aeq = [V,-eye(n)];   % Aeq = [V,-I]
beq = [zeros(n,1)];  % beq = 0
lb = [-Inf * ones(1,k),y]'; 

% min sum y_i, s.t. y is in the span space of {v_1, v_k}; y_i >= 0; y_seed >= 1
v = linprog(f,[],[],Aeq,beq,lb,[]); 

if(isempty(v)==0)
    v = v(k+1:k+n); % y1 to y_n
end

end
