%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Wind Farm Layout Optimisation in MiniZinc
% Based on: Wagner, Day, Neumann (2012/2013):
% "A fast and effective local search algorithm for optimizing the placement of wind turbines"
% Renewable Energy 51 (2013) 64–70; arXiv:1204.4560
%
include "globals.mzn";
include "experimental/blackbox.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
int: M = 8;                     
0.0..infinity: R;                 % Rotor radius
float: PI = 3.141;

0..infinity: w; % width
0..infinity: h; % height

set of int: WIDTH = 0..w;
set of int: HEIGHT = 0..h;

int: nzones;                      % number of infeasible zones
set of int: ZONES = 1..nzones;

array[ZONES] of WIDTH: zx;        %       
array[ZONES] of HEIGHT: zy;
array[ZONES] of WIDTH: zwidth;    % width of each infeasible zones
array[ZONES] of HEIGHT: zheight;  % height of each infeasible zones

int: nturb;
set of int: TURB = 1..nturb;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
array[TURB] of var WIDTH: tx;     % x axis of each turbine 
array[TURB] of var HEIGHT: ty;    % y axis of each turbine

constraint forall(z in ZONES)
    (assert(zx[z] + zwidth[z] <= w /\ zy[z] + zheight[z] <= h, "invalid zones \(z): zw = \(zx[z] + zwidth[z]) zh = \(zy[z] + zheight[z]) w = \(w) h = \(h)"));
 
function var bool: outside_zone(var int: x, var int: y, int: z) =
  let {
    int: x1 = zx[z],
    int: y1 = zy[z],
    int: x2 = zx[z] + zwidth[z] - 1,
    int: y2 = zy[z] + zheight[z] - 1
  } in x1 > x \/ x >= x2 \/ y1 > y \/ y >= y2;

% x1 <= x /\ x <= x2 /\ y1 <= y /\ y <= y2

% constraint 1: no overlaped
% NOTES: there is no given areas of each turb's space taken in the paper
%        so that using packing constraint (diffn) is not making sense here.
constraint forall(t in TURB, z in ZONES)(outside_zone(tx[t], ty[t], z));

% constraint 2: maintaining the minimal distance between 2 turbines
% constraint forall(i, j in TURB where i < j)
% %       (round(sqrt(pow(tx[i] - tx[j], 2) + pow(ty[i] - ty[j], 2))) >= M * R);
%         (trace("\(pow(tx[i] - tx[j], 2) + pow(ty[i] - ty[j], 2)) >= \(pow(M * R, 2)) \(pow(tx[i] - tx[j], 2) + pow(ty[i] - ty[j], 2) >= pow(M * R, 2))\n", ));
        
constraint forall(i, j in TURB where i < j)
        (pow(tx[i] - tx[j], 2) + pow(ty[i] - ty[j], 2) >= ceil(pow(M * R, 2)));

constraint lex2_strict([ (i,j): if j == 1 then tx[i] else ty[i] endif | i in index_set(tx), j in 1..2]);

% solve
%   ::int_search([ if j == 1 then tx[i] else ty[i] endif | i in index_set(tx), j in 1..2], input_order, indomain_min)
% satisfy;

var int: obj;

% 
constraint blackbox([
  trace_exp(if j == 1 then tx[i] else ty[i] endif) | i in TURB, j in 1..2
], [], [obj], [])::blackbox_exec("/opt/homebrew/Caskroom/miniconda/base/envs/turbine_distribution/bin/java -cp /Users/kieronqtran/Projects/turbine_distribution/dist/windWithTDAandCMAESandOPENWIND.jar directSpread.WindTurbineBlackBoxMain");

solve
  ::int_search([ if j == 1 then tx[i] else ty[i] endif | i in TURB, j in 1..2 ], input_order, indomain_min)
maximize obj;
