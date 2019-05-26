function [c,l] = optimize_cluster_gradient(p,score,cSeed,c0,opts)
  c = c0;
  
  if opts.positive_first
    phase = 'pos';
  elseif opts.negative_first
    phase = 'neg';
  elseif opts.positive_only
    phase = 'pos';
  else
    phase = 'both';
  end
  
  if opts.verbose
    fprintf('Iteration %d. %s, size: %d, wsize: %f, score: %f\n',0,'ini',nnz(c),full(sum(c)),score(c));
  end
  
  if opts.min_rw_score > 0
    allowed_nodes = sparse(p >= opts.min_rw_score);
  end
  
  % Timing
  if ~exist('OCTAVE_VERSION','builtin')
    time = @cputime;
  end
  time_gradient   = 0; count_gradient   = 0;
  time_score      = 0; count_score      = 0;
  time_linesearch = 0; count_linesearch = 0;
  time_phase      = 0; count_phase      = 0; % phase restriction stuff
  time_stopping   = 0; count_stopping   = 0; % checking stopping condition
  time_constraint = 0; count_constraint = 0;
  timer_total = time();
  
  % Iterations
  for it=1:opts.max_iter
    % Find gradient
    timer_gradient = time();
    [l,dC] = score(c);
    time_gradient = time_gradient + time() - timer_gradient; count_gradient = count_gradient + 1;
    
    timer_phase = time();
    % stop on negative gradient?
    if opts.stop_on_negative && any((dC<0) & (c>0))
      if opts.verbose
        fprintf('Negative gradient, stopping.\n');
      end
      break
    end
    % stop on large clusters?
    if opts.max_size > 0 && sum(c) >= opts.max_size
      if opts.verbose
        fprintf('Cluster too large, stopping.\n');
      end
      break;
    end
    % Is there any point?
    if ~any(dC)
      if opts.verbose
        fprintf('Iteration %d, no gradient, done.\n', it);
      end
      break
    elseif opts.positive_first && isequal(phase,'pos') && ~any(dC>0)
      if opts.verbose >= 2
        fprintf('Iteration %d, all negative\n', it);
      end
      phase = 'neg'; % there is no point to a positive iteration
    elseif opts.negative_first && isequal(phase,'neg') && ~any(dC<0)
      if opts.verbose >= 2
        fprintf('Iteration %d, all positive\n', it);
      end
      phase = 'pos'; % there is no point to a positive iteration
    elseif opts.positive_only && ~any(dC>0)
      break;
    end
    
    % Restrict gradient to positive/negative
    if isequal(phase,'pos')
      dC = max(0,dC);
    elseif isequal(phase,'neg')
      dC = min(0,dC);
    end
    time_phase = time_phase + time() - timer_phase; count_phase = count_phase + 1;
    
    if isequal(opts.method,'discrete')
      % discrete optimization
      [~,i] = max(dC);
      newC = c; newC(i) = 1;
      newL = score(newC);
      bestL = l;
      bestC = c;
      bestAmount = 0;
      if newL > l
        bestC = newC;
        bestL = newL;
        bestAmount = 1;
      end
      
    else
      % Line search
      timer_linesearch = time();
      %dC = dC / (max(abs(dC)) + eps);
      dC = dC / (sum(abs(dC)) + eps);
      amount = 1;%full(1./(sum(abs(dC)) + eps));
      amount = amount * opts.min_step;
      bestL = l;
      bestC = c;
      bestAmount = 0;
      maxAmount = opts.max_step(min(length(opts.max_step), it));
      if opts.try_infinite_step
        inf_steps = [0,1];
      else
        inf_steps = [0];
      end
      for inf_step = inf_steps
        while inf_step || amount <= maxAmount
          % new cluster
          if inf_step
            amount = inf;
            newC = c;
            newC(dC>0) = 1;
            newC(dC<0) = 0;
          else
            newC = max(0,min(1, c + amount * dC));
          end
          if opts.keep_initial
            newC = max(newC, cSeed);
          end
          if opts.min_rw_score > 0
            newC = min(newC, allowed_nodes);
          end
          if isequal(opts.score,'conductance_size')
            % try to ensure both size and 0<=c<=1 constraints are satisfied simultaniously
            timer_constraint = time();
            for constraint_it=1:10
              newC = newC * (opts.target_size / (sum(newC)+eps));
              %if all(newC>=0 & newC<=1) % this check is slower than running more iterations!
              if ~any(newC < 0) && ~any(newC > 1)
                break;
              end
              newC = max(0,min(1, newC));
            end
            time_constraint = time_constraint + time() - timer_constraint; count_constraint = count_constraint + constraint_it;
          end
          % Score of newC
          timer_score = time();
          newL = score(newC);
          time_score = time_score + time() - timer_score; count_score = count_score + 1;
          
          if opts.verbose >= 2
            fprintf('Iteration %d. %s, size: %d, wsize: %f, score: %f, step: %f\n',it,phase,nnz(newC),full(sum(newC)),newL,amount);
          end
          if newL > bestL || (l == bestL && newL == bestL)
            bestL = newL;
            bestC = newC;
            bestAmount = amount;
          else
            if newL == bestL
              bestC = newC; % Prefer the larger amount to prevent 0.99999
              bestAmount = amount;
            end
            break;
          end
          if opts.max_size > 0 && sum(newC) >= opts.max_size
            break;
          end
          if inf_step
            break;
          end
          amount = amount * opts.line_search_step;
        end
      end
      time_linesearch = time_linesearch + time() - timer_linesearch; count_linesearch = count_linesearch + 1;
    end
    
    % Progress report
    if opts.verbose
      fprintf('Iteration %d. %s, size: %d, wsize: %f, score: %f, step: %f, *, overlap = %f\n',it,phase,nnz(bestC),full(sum(bestC)),bestL,bestAmount,cluster_overlap(bestC,c0));
    end
    
    % next iteration
    timer_stopping = time();
    if bestAmount == 0 || l == bestL % || all(c == bestC) % this check is slow and unneeded
      % no progress
      if isequal(phase,'pos') && opts.positive_first
        if opts.verbose >= 2
          fprintf('Iteration %d, no positive progress, switching to negative\n', it);
        end
        phase = 'neg';
      elseif isequal(phase,'neg') && opts.negative_first
        if opts.verbose >= 2
          fprintf('Iteration %d, no negative progress, switching to positive\n', it);
        end
        phase = 'pos';
      else
        break;
      end
    elseif isequal(phase,'neg') && opts.positive_first
      phase = 'pos';
    elseif isequal(phase,'pos') && opts.negative_first
      phase = 'neg';
    end
    time_stopping = time_stopping + time() - timer_stopping; count_stopping = count_stopping + 1;
    
    c = bestC;
    l = bestL;
  end
  
  if opts.verbose
    fprintf('Time total:               %f\n', time() - timer_total);
    fprintf('Time for gradient:        %f / %d = %f\n', time_gradient, count_gradient, time_gradient/(count_gradient+eps));
    fprintf('Time for line search:     %f / %d = %f\n', time_linesearch, count_linesearch, time_linesearch/(count_linesearch+eps));
    fprintf('Time for score eval:      %f / %d = %f\n', time_score, count_score, time_score/(count_score+eps));
    fprintf('Time for phase restrict:  %f / %d = %f\n', time_phase, count_phase, time_phase/(count_phase+eps));
    fprintf('Time for constraint:      %f / %d = %f\n', time_constraint, count_constraint, time_constraint/(count_constraint+eps));
    fprintf('Time for stopping cond.:  %f / %d = %f\n', time_stopping, count_stopping, time_stopping/(count_stopping+eps));
  end
end
