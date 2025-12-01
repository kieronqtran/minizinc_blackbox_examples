
% Heuristic overview:
%  - Builds on windfarm_base02 and introduces a random restart strategy for LNS.
%  - On every restart we sample a set of turbines and keep the remainder fixed,
%    ensuring diversification without discarding high quality structure.

include "experimental/on_restart.mzn";
include "windfarm_base02.mzn";

0.0..1.0: initialDestrRate;

predicate adaptiveUniform(float: initialDestrRate) = 
  let { var 0.0..1.0: rate::output; } in
  if     status() = START then rate = initialDestrRate
  elseif status() = UNSAT then rate = min(last_val(rate)-0.02,0.6)
  else                         rate = max(last_val(rate)+0.02,0.95)
  endif /\
  forall(i in TURB)
    (if uniform_on_restart(0.0, 1.0) > rate then (xvariant[i] = sol(xvariant[i]) /\ yvariant[i] = sol(yvariant[i])) else true endif);

constraint adaptiveUniform(initialDestrRate);

solve
%   ::on_restart("random_pick_turbine") % not working due to there is a bug in MiniZinc compiler.
  ::int_search([ if j == 1 then xvariant_div5[i] else yvariant_div5[i] endif | i in TURB, j in 1..2 ], input_order, indomain_random)
minimize -obj;
