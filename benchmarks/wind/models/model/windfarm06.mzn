
include "experimental/on_restart.mzn";
include "windfarm_base02.mzn";

int: MAX_INT = 2147483646;  % safe sentinel under 32-bit signed limit

float: initTemp = 10000;
float: coolingRate = 0.0005;

predicate simulated_annealing(float: initTemp, float: coolingRate) = 
  let { var 0.0..initTemp: temp::output; } in
  if status()=START then temp = initTemp
  else
    temp = last_val(temp)*(1-coolingRate) /\ % cool down
    % _objective < sol(_objective) - ceil(ln(uniform(0.0,1.0)) * temp)
    % _objective < sol(_objective) - ceil(ln_uniform_on_restart(0.0,1.0) * temp)
    _objective < sol(_objective) - ceil(uniform_on_restart(-(100), 0) * temp)
  endif;

constraint simulated_annealing(initTemp, coolingRate);

solve
%   ::on_restart("random_pick_turbine") % not working due to there is a bug in MiniZinc compiler.
  ::int_search([ if j == 1 then xvariant_div5[i] else yvariant_div5[i] endif | i in TURB, j in 1..2 ], input_order, indomain_random)
maximize obj;
