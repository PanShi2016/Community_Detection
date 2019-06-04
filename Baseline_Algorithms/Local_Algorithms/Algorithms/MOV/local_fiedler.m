function [x, approx_kappa, gamma, v] = local_fiedler(A, S, varargin)
% [x, approx_kappa, gamma, v] = local_fiedler(A, S, varargin)
%
% Constructs the "MOV" vector, i.e. a locally-biased version of the Fiedler vector.
%
% INPUTS:
%   A       -  adjacency matrix
%   S       -  seed set,
%
% VARARGIN:
%   degrees -  vector of degrees (if not passed as an input,
%              then this function computes them automatically)
%   kappa   -  correlation parameter, 0 < kappa < 1, controls extent to which
%               MOV vector correlates with seed set (1 is maximal).
%               default: 0.5
%   verbose -  set to 1 to output gamma and x'*L*x at each step.
%   lambda2 -  the smallest positive generalized eigenvalue of the Laplacian
%               (This is the Fiedler eigenvalue)
%              If lambda2 is omitted, this function will compute it automatically via
%              MATLAB's built in eigs command. If this function is going to be called
%              multiple times, some cost can be saved by pre-computing lambda2 a
%              single time and passing it in as a parameter. Compute via
%                [lams] = eigs(A, spdiags(d, 0, n, n), 2, 'LA');
%                lambda2 = 1-lams(2);
%                where L = D-A, n = size(L,1).
%
% OUTPUTS:
%   x       - MOV vector
%
% Kyle Kloster, Purdue University 2015
%
% Algorithm first presented in
% Mahoney, Orecchia, Vishnoi "A local spectral method for graphs" JMLR 2012

% SETUP PARAMETERS
p = inputParser;
p.addOptional('degrees',[0]);
p.addOptional('kappa',0.5);
p.addOptional('verbose',false, @islogical);
p.addOptional('lambda2',0);
p.parse(varargin{:});

n = size(A,2);
d = p.Results.degrees;
if length(d) ~= n, d = full(sum(A,2)); end
kappa = p.Results.kappa;
verbose = p.Results.verbose;
lambda2 = p.Results.lambda2;
if lambda2 == 0,
  [lams] = eigs(A, spdiags(d, 0, n, n), 2, 'LA');
  lambda2 = 1 - lams(2);
end

volG = sum(d);
volS = sum(d(S));
volSbar = volG - volS;
temp_scalar = sqrt( volS*volSbar/volG );
v = -(temp_scalar/volSbar).*ones(n,1);
v(S) = temp_scalar/volS;
% dsq = d.^(1/2);
Dsq = spdiags( d.^(1/2), 0, n, n) ;

vd = v.*d;
sqkappa = sqrt(kappa);

gamma_left = -volG;
gamma_right = lambda2;
gamma_cur = (gamma_left + gamma_right)/2;
gamma = [];
kappa_tol = 1e-2;
approx_kappa = -1;

% BINARY SEARCH FOR GAMMA
iter_max = 200;
cur_iter = 0;
while ( abs(approx_kappa - sqkappa) > kappa_tol || approx_kappa < sqkappa ),
    cur_iter = cur_iter + 1;
    gamma = gamma_cur;
    x = MOV_for_gamma(A, gamma, d, vd);

    approx_kappa = x'*vd;
    if approx_kappa > sqkappa,
        gamma_left = gamma_cur;
    else
        gamma_right = gamma_cur;
    end
    gamma_cur = (gamma_left + gamma_right)/2;
    if verbose==1, fprintf('\ngamma_cur=%f   x^TLx=%f',gamma_cur, x'*L*x); end
    if cur_iter >= iter_max, break; end
end
end

function y = MOV_for_gamma(A, gamma, d, vd)
  n = size(A,1);
  y = -(A + spdiags( (1-gamma).*d, 0, n, n) )\vd;
  y = y/sqrt((d'*(y.*y))); % normalize
end
