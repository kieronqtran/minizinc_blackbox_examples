include "globals.mzn";
include "experimental/blackbox.mzn";

int: n = 10; % number of bin

int: gni = 550; % Gross National Income

set of int: BIN = 1..n;

array[BIN] of var 0..infinity: incomes;

% array[BIN] of var 0..infinity: incomes = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

% array[BIN] of var 0..infinity: incomes = [0, 0, 0, 0, 0, 0, 0, 0, 0, 550];

var 0..100: res;
var 0..10000: total;

constraint sum(incomes) = gni;

constraint forall(b in BIN diff { max(BIN) })(incomes[b] <= incomes[b + 1]);

% constraint blackbox(BBExec, "/opt/anaconda3/bin/python ../bb_gini_py/bb_gini.py", incomes, [], [res], []);

constraint blackbox([100] ++ incomes, [], [], [res, total]) ::blackbox_dll("libbb_gini.so");

% incomes = [49, 49, 49, 49, 59, 59, 59, 59, 59, 59];

% predicate gini ( array [ BIN ] of var 0..infinity :X , var int :M , var int :g , int : s ) =
%   let { int : n = length ( X ) ;
% %         int : range_size = ub( X ) - lb( X );
%         array [ int ] of var 0.. infinity : diffs = [ abs ( X [ i ] - X [ j ]) | i , j in index_set ( X ) where i < j ];
%         var 0.. s *( n div 2 + 1) *( n div 2) *( 1000 ) : tot_diff = sum ( diffs ) * s ;
%         var 0.. ub ( tot_diff ) div n : result_ = tot_diff div n ;
%         var 0.. ub ( result_ ) : result = result_ div M }
%         in g = result /\ M = sum ( X );

% var 0..infinity: total;
% constraint gini(incomes, total, res, 100);

constraint incomes[5] = incomes[4] + 10;

solve
  ::int_search(incomes, input_order, indomain_max)
  minimize res;
