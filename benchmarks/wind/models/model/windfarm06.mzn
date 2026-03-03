include "experimental/on_restart.mzn";
include "windfarm_base02.mzn";


opt int: percentage;

ann: search_int = if occurs(percentage) /\ percentage > -1 then 
    seq_search([
             int_search([ if j == 1 then xvariant_div5[i] else yvariant_div5[i] endif | i in TURB, j in 1..2 ], input_order, indomain_random),
             relax_and_reconstruct(xvariant_div5 ++ yvariant_div5, deopt(percentage))
             ])
  else 
    int_search([ if j == 1 then xvariant_div5[i] else yvariant_div5[i] endif | i in TURB, j in 1..2 ], input_order, indomain_random)
  endif;

predicate hill_climbing() =
  if status()=START then true
  else obj > sol(obj) endif;

constraint hill_climbing();

solve
%   ::on_restart("hill_climbing") % not working due to there is a bug in MiniZinc compiler.
   ::search_int
satisfy;
% maximize obj;
