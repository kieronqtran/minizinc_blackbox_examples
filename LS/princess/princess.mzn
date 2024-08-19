include "experimental/blackbox.mzn";

var -400..400: X;
var -400..400: Y;

var -3..68: obj;

constraint blackbox([X, Y], [], [obj], []) ::blackbox_dll("./libbb_pricess.so");
% constraint blackbox([X,Y], [], [obj], []) ::blackbox_exec("./libbb_pricess.so");

% constraint obj = X*X + X*Y + Y*Y - 3*X - 2*Y;

solve minimize obj;
