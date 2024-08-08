int: w; % number of Wukongs

int: n; % number of spot fires
set of int: FIRE = 1..n;
array[FIRE] of int: d;    % duration
array[FIRE] of int: reqW; % #Wukongs required
array[FIRE] of int: best; % best time

int: m; % number of precedence pairs
set of int: PREC = 1..m;
array[PREC] of FIRE: pre;  % put out this
array[PREC] of FIRE: post; % before this

int: maxt = sum(f in FIRE)(d[f]); % max time

array[FIRE] of var 0..maxt: s; % start time
array[FIRE] of var 0..maxt: e = [s[f] + d[f] | f in FIRE]; % end time

constraint forall(i in PREC)
    (e[pre[i]] <= s[post[i]]);

% include "cumulative.mzn";
% constraint cumulative(s, d, reqW, w);

include "experimental/blackbox.mzn";
% this is not working since it's never complete
constraint blackbox(BBExec, "/opt/anaconda3/bin/python ../bb_lns_py/bb_lns_py.py", [w, n] ++ s ++ d ++ reqW, [], s, []);

var int: obj = sum(f in FIRE)(abs(s[f] - best[f]));
solve :: relax_and_reconstruct(s, 70)
      minimize obj;

annotation relax_and_reconstruct(array[int] of var int: x, int:c);

output["Start = \(s)\n" ++
       "End   = \(e)\n" ++
       "Obj   = \(obj)\n"];