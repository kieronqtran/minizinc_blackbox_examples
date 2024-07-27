include "globals.mzn";
include "experimental/blackbox.mzn";

int: n = 10; % number of bin

int: gni = 550; % Gross National Income

set of int: BIN = 1..n;

array[BIN] of var 0..infinity: incomes;

% array[BIN] of var 0..infinity: incomes = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

% array[BIN] of var 0..infinity: incomes = [0, 0, 0, 0, 0, 0, 0, 0, 0, 550];

var float: res;

constraint sum(incomes) = gni;

constraint forall(b in BIN diff { max(BIN) })(incomes[b] <= incomes[b + 1]);

% constraint blackbox(BBExec, "python3 ../bb_gini_py/bb_gini.py", incomes, [], [], [res]);

constraint blackbox(BBDLL, "libbb_gini.so", incomes, [], [], [res]);

constraint incomes[5] = incomes[4] + 10;

solve
  ::int_search(incomes, input_order, indomain_max)
  minimize res;
