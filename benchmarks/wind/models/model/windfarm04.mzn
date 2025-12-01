include "experimental/on_restart.mzn";
include "windfarm_base02.mzn";
include "all_different.mzn";
% adding the relax_or_reconstruct

TURB: n = 1;

function var int: euclidean_dist_pow_2(var int: x_i, var int: y_i, var int: x_j, var int: y_j) =           
  pow(x_i - x_j, 2) + pow(y_i - y_j, 2);


function int: euclidean_dist_pow_2(int: x_i, int: y_i, int: x_j, int: y_j) =           
  pow(x_i - x_j, 2) + pow(y_i - y_j, 2);

% predicate free_nearest_neighbour() = let {
%     var TURB: i = uniform_on_restart(TURB);
% %     array[TURB] of var int: turbine_indexes::output = arg_sort([euclidean_dist_pow_2(
% %                       init_x[i] + sol(xvariant[i]),
% %                       init_y[i] + sol(yvariant[i]),
% %                       init_x[j] + sol(xvariant[j]),
% %                       init_y[j] + sol(yvariant[j])) | j in TURB]);
% %     array[TURB] of var TURB: turbine_indexes::output;
% %     constraint arg_sort(s, turbine_indexes);
%     array[TURB] of var int: dis::output = [euclidean_dist_pow_2(
%                       init_x[i] + sol(xvariant[i]),
%                       init_y[i] + sol(yvariant[i]),
%                       init_x[j] + sol(xvariant[j]),
%                       init_y[j] + sol(yvariant[j])) | j in TURB];
%     array[TURB] of var TURB: turbine_indexes::output;
%     constraint all_different(turbine_indexes);
% %     constraint all_different(turbine_indexes) /\ forall (j in 1..length(dis) - 1) (
% %       dis[turbine_indexes[j]] <= dis[turbine_indexes[j + 1]] /\ 
% %       (dis[turbine_indexes[j]] == dis[turbine_indexes[j + 1]] -> turbine_indexes[j] < turbine_indexes[j + 1])
% %     );
%   } in forall(k in TURB where k != i /\ k != turbine_indexes[2])
%       (xvariant[k] = sol(xvariant[k]) /\ yvariant[k] = sol(yvariant[k]));

% var TURB: ni = uniform_on_restart(TURB);
% array[TURB] of var TURB: turbine_indexes::output;

% set of int: irs = 0..euclidean_dist_pow_2(0, 0, ceil(w + min_dist), ceil(h + min_dist));

% set of int: ir = 0..(pow(ceil(w + min_dist), 2) + pow(ceil(h + min_dist), 2));

% array[TURB] of var ir: dis::output = [euclidean_dist_pow_2(
%                   init_x[ni] + sol(xvariant[ni]),
%                   init_y[ni] + sol(yvariant[ni]),
%                   init_x[j] + sol(xvariant[j]),
%                   init_y[j] + sol(yvariant[j])) | j in TURB];
% constraint all_different(turbine_indexes);
% constraint forall (j in 1..length(dis) - 1) (
%     dis[turbine_indexes[j]] <= dis[turbine_indexes[j + 1]] /\ 
%     (dis[turbine_indexes[j]] == dis[turbine_indexes[j + 1]] -> turbine_indexes[j] < turbine_indexes[j + 1])
%   );
% constraint all_different(turbine_indexes) /\ forall (j in 1..length(dis) - 1) (
%     dis[turbine_indexes[j]] <= dis[turbine_indexes[j + 1]] /\ 
%     (dis[turbine_indexes[j]] == dis[turbine_indexes[j + 1]] -> turbine_indexes[j] < turbine_indexes[j + 1])
%   );

var TURB: ni = uniform_on_restart(TURB union { nturb + 1 });
array[TURB,1..3] of set of TURB: nearest_neighbour ::output = [ (ti,i): array2set(
  arg_sort(tj in TURB)(euclidean_dist_pow_2(init_x[ti], init_y[ti],init_x[tj], init_y[tj]))[1..i]) 
    | ti in TURB, i in 1..3 ];

var 1..3: nbh_size ::output = uniform_on_restart(1..4);
any: neighbourhood = nearest_neighbour[ni, nbh_size];

constraint status() != START -> forall(k in TURB where not (k in neighbourhood))
      (xvariant[k] = sol(xvariant[k]) /\ yvariant[k] = sol(yvariant[k]));

include "gecode.mzn";

solve
%   ::on_restart("random_pick_turbine") % not working due to there is a bug in MiniZinc compiler.
  ::int_search([ if j == 1 then xvariant_div5[i] else yvariant_div5[i] endif | i in TURB, j in 1..2 ], random, indomain_random)
minimize -obj;
