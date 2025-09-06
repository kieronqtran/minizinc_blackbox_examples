%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Wind Farm Layout Problem (Approach 1)
%
% The WFLP and solves described in https://doi.org/10.1016/j.renene.2012.09.008
% Based on: Wagner, Day, Neumann (2012/2013)
% Renewable Energy 51 (2013) 64–70; arXiv:1204.4560

% There are a map of windfarm as well as there are infeasiable zones that cannot 
% place the turbines in. We plan to place a number of turbines in the zones that 
% produce the maximum number of output energy, where the objective value is 
% calculated by external program through the java programs as a blackbox function
%
% This approach is using the search by providing the initial solutions 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
int: M = 8;                       % a proximity factor
float: PI = 3.141;                % the constant PI
0.0..infinity: R;                 % Each windfarm's rotor radius

0..infinity: w;                   % width of the windfarm
0..infinity: h;                   % height of the windfarm

set of int: WIDTH = 0..w;         % domains of windfarm's width
set of int: HEIGHT = 0..h;        % domains of windfarm's height

int: nzones;                      % number of infeasible zones
set of int: ZONES = 1..nzones;    % domains of infeasiable zones

array[ZONES] of WIDTH: zx;        % x coordinates of infeasiable zones
array[ZONES] of HEIGHT: zy;       % y coordinates of infeasiable zones
array[ZONES] of WIDTH: zwidth;    % width of each infeasible zones
array[ZONES] of HEIGHT: zheight;  % height of each infeasible zones

% checking if all the infeasiable zones are within the windfarm
constraint forall(z in ZONES)
    (assert(zx[z] + zwidth[z] <= w /\ zy[z] + zheight[z] <= h, 
    "invalid zones \(z): zw = \(zx[z] + zwidth[z]) zh = \(zy[z] + zheight[z]) w = \(w) h = \(h)"));
 
int: nturb;                       % number of wind turbines
set of int: TURB = 1..nturb;      % domain of wind turbines

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
array[TURB] of var WIDTH: tx;     % x axis of each turbine 
array[TURB] of var HEIGHT: ty;    % y axis of each turbine

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN CONSTRAINTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
include "globals.mzn";
include "experimental/blackbox.mzn";

% each turbines must be outside of infeasiable zones and within the windfarm layout
constraint forall(t in TURB, z in ZONES)(
  let {
    var WIDTH: x   = tx[t],
    var HEIGHT: y  = ty[t],
    WIDTH: x1      = zx[z],
    HEIGHT: y1     = zy[z],
    WIDTH: x2      = zx[z] + zwidth[z] - 1,
    HEIGHT: y2     = zy[z] + zheight[z] - 1
  } in x1 > x \/ x >= x2 \/ y1 > y \/ y >= y2);

% maintaining the minimal distance between 2 turbines
constraint forall(i, j in TURB where i < j)
        (pow(tx[i] - tx[j], 2) + pow(ty[i] - ty[j], 2) >= ceil(pow(M * R, 2)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OBJECTIVE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
var int: obj;

% the required input coordinates for the blackbox is [x_1, y_1, x_2, y_2,...]
constraint blackbox(
[ if j == 1 then tx[i] else ty[i] endif | i in TURB, j in 1..2 ], [], [obj], []
)::blackbox_exec("java -cp ../blackbox_exec/windWithTDAandCMAESandOPENWIND.jar directSpread.WindTurbineBlackBoxMain");

solve
  ::int_search([ if j == 1 then tx[i] else ty[i] endif | i in TURB, j in 1..2 ], input_order, indomain_min)
minimize -obj;

constraint lex2_strict([ (i,j): if j == 1 then tx[i] else ty[i] endif | i in index_set(tx), j in 1..2]);
