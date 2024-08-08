include "globals.mzn";
include "experimental/blackbox.mzn";

var -4..4: X;
var -4..4: Y;

var -3..68: obj;

constraint blackbox(BBDLL, "./libbb_pricess.so", [X,Y], [], [obj], []);

% constraint obj = X*X + X*Y + Y*Y - 3*X - 2*Y;

solve minimize obj;
