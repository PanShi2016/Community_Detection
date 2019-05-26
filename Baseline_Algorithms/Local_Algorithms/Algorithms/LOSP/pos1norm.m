function v = pos1norm(V,startPoints, initialPoints )
% Find minimum 1-norm vector lies in the column space of V
% V: k column vectors got by random walk
% i: seed vertice that must be in the cluster

if nargin < 1
    % two cliques of size 5, overlap at v4 and v5
    V = [  -0.2772   -0.2774   -0.2774   -0.5032   -0.5032   -0.2960   -0.2960   -0.2960
    -0.4371   -0.4311   -0.4311    0.0216    0.0216    0.3814    0.3814    0.3814]';
    initialPoints = [1]; 
    startPoints = [1 4];  
end
   
[n,k] = size(V); % n rows, k colums

f = [zeros(k,1); ones(n,1)];
y = zeros(1,n);
y(startPoints) = 1;
y2 = zeros(1,n); % indicator especially for initial seeds
y2(initialPoints) = 1;
a1 = [zeros(1,k),y]; % seedRow for current seeds
a2 = [zeros(1,k),y2]; % seedRow for initial seeds
a = [a1;a2];
N1 = length(initialPoints);
W1 = 1/N1;
N2 = length(startPoints)-N1;
W2 = 0.5*W1;
b = [N2*W2+1;1];

Aeq = [V,-eye(n)];  % [V, -I]
beq = [zeros(n,1)];  % create constant column vector with a 1 in top component
lb = [-Inf * ones(1,k),zeros(1,1*n)]'; % yi >= 0

v = linprog(f,[-a],[-b],Aeq,beq,lb,[]);

if(isempty(v) == 0)
    v = v(k+1:k+n); % y1 to yn
end

end
