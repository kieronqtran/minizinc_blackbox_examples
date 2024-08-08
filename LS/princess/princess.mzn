include "experimental/blackbox.mzn";

var -4..4: X;
var -4..4: Y;

var -3..68: obj;

constraint blackbox([X,Y], [], [obj], []) ::blackbox_dll("./libbb_pricess.so");
% constraint blackbox([X,Y], [], [obj], []) ::blackbox_exec("./libbb_pricess.so");

constraint obj = X*X;
% constraint obj = X*X + X*Y + Y*Y - 3*X - 2*Y;

solve minimize obj;
