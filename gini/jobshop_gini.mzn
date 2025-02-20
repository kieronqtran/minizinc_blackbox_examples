% === Meta Parameters ============================================= %

int: mode; %%  -2  decomposition
           %%  -1  blackbox


enum CASES = { MinDis % Minimise dispersion (bound on efficiency)
             , MaxEff % Maximise efficiency (bound on dispersion)
             , Mkspan % Minimise makespan for each agent (no
                      % constraints across agents). Used to find
                      % limited horizon size
             , MkspanPeter % Same as above but include constraints
                           % across agents
             , FndBnd % Maximise efficiency (no bound on dispersion).
                      % Used to find bound to use for MinDis/MaEff      
             , MedianPeter % Objective is the minimal of mean all agents  
             };

CASES: Case;


% === Parameters ================================================== %

int: n_jobs;
int: n_machs;
int: n_agents;

set of int: A = 1..n_agents;
set of int: J = 1..n_jobs;
set of int: M = 1..n_machs;
set of int: T = M;

opt int: end;

opt int: bnd;

array [J,T] of int: dur;
array [J,T] of M: mac;
array [J] of A: alloc;

% === Variables =================================================== %

array [J,T] of var opt 0..infinity: start;
array [J] of var opt 0..infinity: done;

% GT: this optimisation is wrong, MiniZinc will fix deopt(start[j,t]) to
%     zero when it is absent. So this needs to be disabled.
% `var opt' optimisation
% constraint forall (j in J, t in T)
% ( if absent(start[j,t]) 
%     then deopt(start[j,t]) = end+1
%     else deopt(start[j,t]) <= end endif );

% === Meta Constraints ============================================ %

constraint if Case in {Mkspan, MkspanPeter, } then
             forall (j in J)
              ( occurs(done[j]) )
           endif;

% === Scheduling Constraints ====================================== %
include "globals.mzn";

% Tasks are processed in the correct order
% GT: checked, this still works correctly in the newer MiniZinc versions.
%     When start[j,t] is absent, its deopt value may be fixed to 0, 
%     which would result in 0 + 0 * dur[j,t] <= deopt(start[j, enum_next(t)])
%     which will always be satisfied.
constraint forall (j in J, t in T diff {max(T)})
 ( deopt(start[j,t]) + occurs(start[j,t]) * dur[j,t] <= deopt(start[j, enum_next(T, t)]) );

% GT: This symmetry breaking constraint is definitely wrong and needs to be disabled
% constraint forall (j in J, t in T)
%  ( absent(start[j,t]) <-> deopt(start[j,t]) = end+1 ); % symmetry-breaking constraint

% Tasks do not overlap on a machine

% GT: I think I now understand the Mkspan case. It computes the minimum makespan
%     for each agent! The forall ranges over all agents a, which means that only
%     tasks that belong to the same agent are forced to not overlap. This means
%     that overall, we get the minimum makespan in which we could fulfill
%     all the tasks for each agent.
constraint forall (m in M)
 ( cumulative( [ deopt(start[j,t])           | j in J, t in T where mac[j,t]=m ],
               [ occurs(start[j,t])*dur[j,t] | j in J, t in T where mac[j,t]=m ],
               [ 1                           | j in J, t in T where mac[j,t]=m ],
                 1 ) 
 ) endif;

% start-done channelling
% GT: Looks correct
constraint forall (j in J)
 ( occurs(done[j]) -> deopt(start[j,max(T)]) + dur[j,max(T)] = deopt(done[j]) );
% GT: Looks correct
constraint forall (j in J)
 ( done[j] <= end );
% GT: Looks correct
constraint forall (j in J, t in T)
 ( occurs(done[j]) <-> occurs(start[j,t]) );

% === Utilities =================================================== %

array [A] of var 0..500000000: util::output;
var 0..500000000: UTIL::output;
var 0..500000000: disp::output;

function var int: max(array[int] of var opt int: x) = max([if occurs(xi) then deopt(xi) else 0 endif | xi in x]);

var int: max_done::output = max(done);

constraint UTIL = sum(util);

% GT: Looks correct
constraint forall (a in A)
 ( util[a] = sum (j in J, t in T where alloc[j] = a)
    ( if occurs(done[j]) then dur[j,t] else 0 endif) );

% Bound on efficiency
constraint (Case = MinDis) ->
 ( UTIL >= bnd );

% Bound on dispersion
constraint (Case = MaxEff) ->
 ( disp <= bnd*1 ); % already scaled 

% === Objective =================================================== %
include "experimental/blackbox.mzn";

var int: obj;

constraint if Case in {MinDis, MaxEff} then
             gini(disp, util, UTIL, 10000)
             /\ max_done > 0 % a bit hacking to remove the non-job done
           else
             disp = 1
           endif;

constraint if Case = MinDis then
             obj = disp % TODO
           elseif Case in {MaxEff, FndBnd} then
             obj = -UTIL % TODO
           elseif Case = MedianPeter then
             % GT: This was median(util), which means that the median utility
             %     was being minimized. Obviously that would result in very
             %     similar solutions all the time.
             obj = -median(util)
           elseif Case in {Mkspan, MkspanPeter} then
              max(done) <= obj
           else assert(false, "Invalid Case value")
           endif;

ann: searchann = seq_search([int_search([if occurs(start[i,j]) then deopt(start[i,j]) else -1 endif | i in J, j in T],
                                          smallest, indomain_min, complete ),
                               int_search([obj], input_order, indomain_min, complete)
                              ]);

% GT: minimising the median really doesn't make much sense, it needs to be maximised
% solve :: searchann minimize median(util);
solve ::searchann minimize obj;

% === Predicates ================================================== %
%%% GINI
%% Modes: -2 = Decomposition as in paper.
%%        -1 = The Blackbox function.

predicate gini(var int: v, array [int] of var int: X, var int: S, int: scale) =
  if mode = -2 then
    gini_decomp(X, S, v, scale)
  elseif mode = -1 then
    blackbox([scale] ++ X, [], [v], [])::blackbox_dll("./libbb_gini.so")
  else assert(mode in {-2, -1}, "mode is not neither decomp or blackbox") endif;
  
predicate gini_decomp(array[int] of var int: X, var int: M, var int: v, int: s) =
  let { int: n=length(X);
        array[int] of var 0..500000000: diffs = [ abs(X[i]-X[j]) | i,j in index_set(X) where i<j];
        var 0..500000000: tot_diff = sum(diffs) * s;
        var 0..500000000: result_ = tot_diff div n;
        var 0..500000000: result = result_ div M}
  in v = result;

%%% Median
%% Modes: -2 = Decomposition as in paper.
%%        -1 = The Blackbox function.
include "sort.mzn";

var int: median(array[int] of var int: x) = 
  if mode = -2 then
    median_decomp(x)
  elseif mode = -1 then
    let {
      var lb_array(x)..ub_array(x): result;
      constraint blackbox(x, [], [result], [])::blackbox_dll("./libbb_median.so");
    } in result
  else abort("mode is not neither decomp or blackbox") endif;

var int: median_decomp(array[int] of var int: x) = 
         let { int: l = length(x);
               array[1..l] of var int: xs = sort(x);
               int: median = l div 2;
               } in 
          xs[median];
