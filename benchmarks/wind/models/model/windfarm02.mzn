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
% This model is an extension of windfarm_base02.mzn where we apply a different
% heuristic, called relax-and-reconstruct, to solve the problem.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

include "windfarm_base02.mzn";

%%%%

int: relax_percentage = 95;

solve
  ::int_search([ if j == 1 then xvariant[i] else yvariant[i] endif | i in TURB, j in 1..2 ], input_order, indomain_random)
  ::relax_and_reconstruct(xvariant_div5 ++ yvariant_div5, relax_percentage)
minimize -obj;
