%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Wind Farm Layout Problem (Approach 2)
%
% The WFLP and solves described in https://doi.org/10.1016/j.renene.2012.09.008
% Based on: Wagner, Day, Neumann (2012/2013)
% Renewable Energy 51 (2013) 64–70; arXiv:1204.4560
% 
% There are a map of windfarm as well as there are infeasiable zones that cannot
% place the turbines in. We plan to place a number of turbines in the zones that 
% produce the maximum number of output energy, where the objective value is 
% calculated by external program through the java programs as a blackbox function
%
% This scenarios solve will finding the solutions by dividing the farm into grid
% each grid we will place one turbine into it and we start to place each turbine 
% in each grid and moving 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

float: min_dist::output = M * R;       % minimal distance between two turbine
% int: ngridx::output = 1 + floor(w / min_dist); % number of rows in the grid
% int: ngridy::output = 1 + floor(h / min_dist); % number of cols in the grid

% set of int: GRIDX = 1..ngridx;
% set of int: GRIDY = 1..ngridy;

% array[GRIDX] of WIDTH: gridx::output = [   % x axis of each initial grid
%    if i = ngridx then round(w - min_dist) else round(min_dist / 2 + (i-1) * min_dist) endif | i in GRIDX
% ];

% array[GRIDY] of HEIGHT: gridy::output = [  % y axis of each initial grid
%    if i = ngridy then round(h - min_dist) else round(min_dist / 2 + (i-1) * min_dist) endif  | i in GRIDY
% ];

% array[GRIDX] of WIDTH: gridx::output = [   % x axis of each initial grid
%    ceil((i-1) * min_dist) | i in GRIDX
% ];

% array[GRIDY] of HEIGHT: gridy::output = [  % y axis of each initial grid
%    ceil((i-1) * min_dist)  | i in GRIDY
% ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% array[GRIDX, GRIDY] of var bool: choosen;

% int: half_min_dist = ceil(min_dist / 2);
% array[TURB] of var -half_min_dist..half_min_dist: xvariant; %
% array[TURB] of var -half_min_dist..half_min_dist: yvariant; %

% array[TURB] of WIDTH: init_x = [
%   0, 0, 308, 308
% ];

% array[TURB] of WIDTH: init_y = [
%   0, 308, 0, 308
% ];


array[TURB] of WIDTH: init_x::output = [
  620,
  620,
  1240,
  1240,
  1240,
  1240,
  1240,
  1240,
  1240,
  1240,
  1860,
  1860,
  1860,
  1860,
  1860,
  1860,
  1860,
  1860,
  1860,
  1860,
  1860,
  2480,
  2480,
  2480,
  2480,
  2480,
  2480,
  2480,
  2480,
  2480,
  2480,
  2480,
  3100,
  3100,
  3100,
  3100,
  3100
];

array[TURB] of HEIGHT: init_y::output = [
  3709,
  4945,
  1236,
  1855,
  2473,
  3091,
  3709,
  4327,
  4945,
  5564,
  618,
  1236,
  1855,
  2473,
  3091,
  3709,
  4327,
  4945,
  5564,
  6182,
  6800,
  618,
  1236,
  1855,
  2473,
  3091,
  3709,
  4327,
  4945,
  5564,
  6182,
  6800,
  0,
  618,
  1236,
  1855,
  2473
];

int: half_mdist = ceil(min_dist / 2);

array[TURB] of var -half_mdist..half_mdist: xvariant; %
array[TURB] of var -half_mdist..half_mdist: yvariant; %

% making sure the placement of turbine is not out of the windfarm layout
constraint forall(t in TURB)(
  let {
    var int: x = init_x[t] + xvariant[t];
    var int: y = init_y[t] + yvariant[t];
  } in 0 <= x /\ x <= w /\ 0 <= y /\ y <= h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN CONSTRAINTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
include "globals.mzn";
include "experimental/blackbox.mzn";

% each turbines must be outside of infeasiable zones and within the windfarm layout
constraint forall(t in TURB, z in ZONES)(
  let {
    var WIDTH: x   = init_x[t] + xvariant[t],
    var HEIGHT: y  = init_y[t] + yvariant[t],
    WIDTH: x1      = zx[z],
    HEIGHT: y1     = zy[z],
    WIDTH: x2      = zx[z] + zwidth[z] - 1,
    HEIGHT: y2     = zy[z] + zheight[z] - 1
  } in x1 > x \/ x >= x2 \/ y1 > y \/ y >= y2);

% maintaining the minimal distance between 2 turbines
constraint forall(i, j in TURB where i < j)(
  let {
    var WIDTH: x_i   = init_x[i] + xvariant[i],
    var HEIGHT: y_i  = init_y[i] + yvariant[i],
    var WIDTH: x_j   = init_x[j] + xvariant[j],
    var HEIGHT: y_j  = init_y[j] + yvariant[j]
  } in pow(x_i - x_j, 2) + pow(y_i - y_j, 2) >= ceil(pow(M * R, 2)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OBJECTIVE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
var int: obj;

array[int] of var int: coords::output = [
  if j == 1 then init_x[t] + xvariant[t] else init_y[t] + yvariant[t] endif | t in TURB, j in 1..2 
];

% the required input coordinates for the blackbox is [x_1, y_1, x_2, y_2,...]
constraint blackbox(coords, [], [obj], [])
  ::blackbox_exec("java -cp ../blackbox_exec/windWithTDAandCMAESandOPENWIND.jar directSpread.WindTurbineBlackBoxMain");

solve
  ::int_search([ if j == 1 then xvariant[i] else yvariant[i] endif | i in TURB, j in 1..2 ], input_order, indomain_median)
minimize -obj;
