function walk_vec = sparse_k_walk( A, seed_set, walk_k )
% walk_vec = sparse_k_walk( A, seed_set, walk_k )
%
% INPUTS
%   A         -- sparse input matrix
%   seed_set  -- array of seed nodes where the walk starts
%   walk_k    -- length of walk performed, default=2
%
%
% Note: this outputs walk_vec = (A_bar)^walk_k * sparse( seed_set, 1, 1, n, 1)
%

if nargin < 3, walk_k = 2; end
n = size(A,1);
walk_vec = sparse( seed_set, 1, 1, n, 1);
for j=1:walk_k,
    temp_vec = sparse_degpower_mex(A, walk_vec, -0.5);
    temp_vec2 = sparse( temp_vec(:,1), 1, temp_vec(:,2), n, 1 ) ;
    temp_vec3 = temp_vec2 + A*temp_vec2;
    temp_vec4 = sparse_degpower_mex(A, temp_vec3, -0.5);
    walk_vec = sparse( temp_vec4(:,1), 1, temp_vec4(:,2), n, 1 ) ;
end
