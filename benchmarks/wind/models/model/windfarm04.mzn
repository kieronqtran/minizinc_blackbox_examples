include "experimental/on_restart.mzn";
include "windfarm_base02.mzn";
include "all_different.mzn";
% adding the relax_or_reconstruct

TURB: n = 1;

predicate random_pick_turbine() = 
  let {
    array[1..n] of TURB: n_random_turbine = [ uniform(1, nturb) | i in 1..n];
    constraint alldifferent(n_random_turbine);
  } in 
   forall(i in TURB diff array2set(n_random_turbine))
      (xvariant[i] = sol(xvariant[i]) /\ yvariant[i] = sol(yvariant[i]));

constraint status() != START -> random_pick_turbine();

solve
%   ::on_restart("random_pick_turbine") % not working due to there is a bug in MiniZinc compiler.
  ::int_search([ if j == 1 then xvariant_div5[i] else yvariant_div5[i] endif | i in TURB, j in 1..2 ], input_order, indomain_random)
minimize -obj;
