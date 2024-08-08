var -4 .. 4: x;
var -4 .. 4: y;

constraint abs(x) != abs(y);

% t[x,y] = 5*sin(x)*cos(y)
array[-4..4,-4..4] of float: t::output = array2d(-4..4,-4..4,[ 5 * sin(xi) * cos(yi) | xi, yi in -4..4]);

var -100.0 .. 100.0: obj;
constraint obj = t[x,y] + abs(x) + abs(y);
solve minimize obj;
