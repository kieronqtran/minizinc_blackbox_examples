int: n;
set of int: JOB = 1..n;
int: m;
set of int: MACH = 1..m;
set of int: TASK = 1..m;
array[JOB,TASK] of int:  ed; % estimate length of task
array[JOB,TASK] of MACH: mc; % which machine

int: maxt::output = sum(j in JOB, t in TASK)(ed[j,t]) * 2;

array[JOB,TASK] of var int: d; % length of task
array[JOB,TASK] of var 0..maxt: s; % start time

array[JOB,TASK] of var 0..maxt: s2; % start time

% performs tasks in a job in order
constraint forall(j in JOB, t in 1..m-1)
                 (s[j,t] + ed[j,t] <= s[j,t+1]);

constraint forall(j in JOB, t in 1..m-1)
                 (s2[j,t] + ed[j,t] + d[j,t] <= s2[j,t+1]);

include "disjunctive.mzn";
include "experimental/blackbox.mzn";

constraint blackbox(array1d(s), [], array1d(d), []) ::blackbox_exec("python3 ../bb_jobshop_py/bb_jobshop_simulator.py");

% constraint blackbox(array1d(s), [], array1d(d), []) ::blackbox_exec("/opt/anaconda3/bin/python /Users/kieronqtran/Projects/Deeker1/blackbox/bb_jobshop_py/bb_jobshop_simulator.py");

% constraint forall(ma in MACH)
%                  ( let { array[int] of var int: ss = [ s2[j,t] | j in JOB, t in TASK where mc[j,t] = ma ];
%                          array[int] of var int: dd = [ ed[j,t] + d[j,t] | j in JOB, t in TASK where mc[j,t] = ma ]; } in
%                    disjunctive(ss,dd));

var int: violation = sum(ma in MACH)(
                   let { array[int] of var int: ss = [ s2[j,t] | j in JOB, t in TASK where mc[j,t] = ma ];
                         array[int] of var int: dd = [ ed[j,t] + d[j,t] | j in JOB, t in TASK where mc[j,t] = ma ]; } in
                    count(t1, t2 in index_set(ss) where t1 < t2)(
                      occurs(ss[t1]) /\ occurs(ss[t2]) /\ ss[t1] + dd[t1] > ss[t2] /\ ss[t2] + dd[t2] > ss[t1])
);

% constraint forall(ma in MACH)
%                  ( let { array[int] of var int: ss = [ s2[j,t] | j in JOB, t in TASK where mc[j,t] = ma ];
%                          array[int] of var int: dd = [ ed[j,t] + d[j,t] | j in JOB, t in TASK where mc[j,t] = ma ]; } in
%                    disjunctive(ss,dd));

var 0..maxt: makespan = max(j in JOB)(s2[j,m] + ed[j,m] + d[j,m]);

solve  
     ::
     seq_search([ int_search([s[i,j]| i in JOB, j in TASK],
                            smallest, indomain_min, complete),
                 int_search([makespan], input_order, indomain_min, complete)])
%      seq_search([ int_search([makespan], input_order, indomain_min, complete),
%                   int_search([s[i,j]| i in JOB, j in TASK],
%                             smallest, indomain_min, complete)])
         minimize makespan + sum(j in JOB, t in TASK)(abs(s[j, t] - s2[j,t])) * 10 + violation * 100;

output [ "maxt = \(maxt) \n" ] ++
       [ "makespan = ", show(makespan), "\n"] ++
       [ show_int(3,s[j,t]) ++ if t = m  then "\n" else " " endif
       | j in JOB, t in TASK];

output [ "maxt = \(maxt) \n" ] ++
       [ "makespan = ", show(makespan), "\n"] ++
       [ show_int(3,s2[j,t]) ++ if t = m  then "\n" else " " endif
       | j in JOB, t in TASK] ++
       [ "violation = \(violation)\n"];
