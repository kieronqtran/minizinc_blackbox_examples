% enum MONKEY;

array[MONKEY,MONKEY] of int: coop;
set of int: MONKEY = 1..n;
int: n;
set of int: POS = 1..n;
array[POS] of var MONKEY: monkey;
include "alldifferent.mzn";
constraint alldifferent(monkey);

include "experimental/blackbox.mzn";

var int: obj;

constraint blackbox(monkey, [], [obj], []) ::blackbox_dll("./libbb_monkey.so");

solve maximize obj;

% solve maximize
%   sum(i in 1..n-1)(coop[monkey[i],monkey[i+1]]);
