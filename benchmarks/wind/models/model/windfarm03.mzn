include "experimental/on_restart.mzn";
include "windfarm_base02.mzn";
include "all_different.mzn";

TURB: n;

var int: evaluation::output;

constraint if status() == START then evaluation = 0 else evaluation = last_val(evaluation) + 1 endif;

predicate random_pick_turbine() = 
  let {
    any: random_turbines_set = { uniform_on_restart(TURB) | i in 1..n };
    constraint card(random_turbines_set) = n;
  } in forall(i in TURB)
      (i in random_turbines_set \/ (xvariant[i] = sol(xvariant[i]) /\ yvariant[i] = sol(yvariant[i])));

constraint status() != START -> random_pick_turbine();

solve
%   ::on_restart("random_pick_turbine") % not working due to there is a bug in MiniZinc compiler.
  ::int_search([ if j == 1 then xvariant_div5[i] else yvariant_div5[i] endif | i in TURB, j in 1..2 ], input_order, indomain_random)
minimize -obj;
