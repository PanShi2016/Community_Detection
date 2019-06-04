function [output_cluster, bestcond, x, approx_kappa, gamma, v] = MOVgrow(A, S, varargin)
% [output_cluster, x, approx_kappa, gamma, v] = MOVgrow(A, S, varargin)
%
% Constructs the "MOV" vector, i.e. a locally-biased version of the Fiedler vector,
% and uses it to identify a local cut near the input seeds S.
%
% INPUTS:
%   A       -  adjacency matrix
%   S       -  seed set
%
% VARARGIN:
%   degrees -  vector of degrees (if not passed as an input,
%              then this function computes them automatically)
%   kappa   -  correlation parameter, 0 < kappa < 1, controls extent to which
%               MOV vector correlates with seed set (1 is maximal).
%               default: 0.75
%   verbose -  set to true to output gamma and x'*L*x at each step.
%   lambda2 -  the smallest positive generalized eigenvalue of the Laplacian
%               (This is the Fiedler eigenvalue)
%              If lambda2 is omitted, this function will compute it automatically via
%              MATLAB's built in eigs command. If this function is going to be called
%              multiple times, some cost can be saved by pre-computing lambda2 a
%              single time and passing it in as a parameter. Compute via
%                [lams] = eigs(A, spdiags(d, 0, n, n), 2, 'LA');
%                lambda2 = 1-lams(2);
%
% OUTPUTS:
%   output_cluster       - good conductance cut identified by sweepcut over MOV vector
%   x                    - locally biased fiedler vector (MOV vector)
%   approx_kappa         - sqrt(x' D v)
%   gamma                - optimal value found to make the solution of y = (L - gamma*D) vd; the desired MOV vector
%   v                    - seed vector normalized in special manner as per MOV paper.
%
% Kyle Kloster, Purdue University 2015
%
% Algorithm first presented in
% Mahoney, Orecchia, Vishnoi "A local spectral method for graphs" JMLR 2012

  p = inputParser;
  p.addOptional('degrees',[0]);
  p.addOptional('kappa',0.5);
  p.addOptional('verbose',false, @islogical);
  p.addOptional('lambda2',0);
  p.parse(varargin{:});


  if p.Results.verbose, fprintf('About to compute local fiedler.\n'); end

  [x, approx_kappa, gamma, v] = local_fiedler(A, S, varargin{:} );

  if p.Results.verbose, fprintf('Done computing MOV vector.\n'); end

  sw_range = [length(S), min(size(A,1), 3000)];
  [output_cluster,bestcond,bestcut,bestvol,noderank] = sweepcut(A,x,'halfvol',true,'sweeprange', sw_range);

end
