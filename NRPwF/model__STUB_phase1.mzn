include "model__STUB_BASE.mzn";

array[int,int] of int: nShift_WS_DATA_2D;
array[int] of int: nShift_WS_DATA = [nShift_WS_DATA_2D[n,d] | n in NURSES, d in DAYS];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%%%%%%%%%%% Roster Score %%%%%%%%%%%%%%  ++++++++++++++++++++++++++++++++++++++++++++++++++++
include "model__STUB_scoring.mzn";
                    
                    
%%%%%%%%%%%%% LNS
include "restart.mzn";
include "globals.mzn";
% The user-defined LNS strategy
constraint status() == START -> let {
    array[int] of var int: x = [nShift[n,d]|n in NURSES, d in DAYS]
} in forall(i in index_set(x))( x[i] = nShift_WS_DATA[i] );

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% var int: sum_bDiff2Data;
% constraint sum_bDiff2Data = sum( bDiff2Data );
var int: sum_score;
% constraint sum_score = sum( score ); % Minimise total score
constraint sum_score = max( score ); % Minimise max score in the entire roster
var int: obj;
% var min(nShiftScore__DATA_1D)..max(nShiftScore__DATA_1D): obj; %% for minimising maximum score in a roster set the bounds
constraint obj == 
 %%% Diff to the example schedule
      sum_score
%    5 * sum_bDiff2Data
% + 10 * sum_viol2N
;
  
solve 
  minimize
    obj
    ;
    
% output
% ["Roster = \n"] ++ [show([nShift[i,j] | i in NURSES, j in DAYS])] ++
% ["\nObj = \(obj), \(bObj)\n"];