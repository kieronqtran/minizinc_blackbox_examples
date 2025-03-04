include "model__STUB_scoring.mzn";
include "model__STUB_BASE_regular.mzn";

array[int,int] of int: nShift_WS_DATA_2D;
array[int,int] of int: nScore_DATA_2D;

                    
%%%%%%%%%%%%% LNS
include "restart.mzn";
include "globals.mzn";

int: nDiff;
set of int: testWNURSES;
set of int: randNURSES;
 NURSES: nurID1;
 DAYS: d1; 
int: fObjMinimiseSum;
int: SwitchNeighborhood;
int: Iteration;
array[NURSES] of int: worseDays;
set of int: WORDAYS={worseDays[i]| i in index_set(worseDays)};
int: prevObj;
int: objDiff=0;
set of int: WNURSES = { n | n in index_set_1of2(nScore_DATA_2D), d in index_set_2of2(nScore_DATA_2D) where nScore_DATA_2D[n,d] >= prevObj-objDiff};
set of int: WDAYS = { d | n in index_set_1of2(nScore_DATA_2D), d in index_set_2of2(nScore_DATA_2D) where nScore_DATA_2D[n,d] >= prevObj-objDiff};


% The user-defined LNS strategy
constraint status() == START ->  forall(n in NURSES, d in DAYS 
                                          where n <= card(index_set_1of2(nShift_WS_DATA_2D)) 
                                                          /\ not ( n in {nurID1} /* /\ d in {d1-3,d2-2,d1-1,d1}  /\ fAvoidPattern==1 */ ) 
                                                          )
                                       ( nShift[n,d] = nShift_WS_DATA_2D[n,d] );
constraint 



%if fLNS==1 then true %If no prev sol, relax all, else use LNS
%else
  forall( n in NURSES, d in DAYS where
    (fObjMinimiseSum==0 /\ SwitchNeighborhood==0 /\Iteration>0    %If max min, not stuck in local optima
    /\ n <= card(index_set_1of2(nShift_WS_DATA_2D))     %n not larger than #n in prev sol (I think)
    /\ ( not ( (n in testWNURSES union randNURSES) ))      %n not in specified collection of NURSES  {nurID1}    union {nurID2} union {nurID3}
    /\ not (nShift_WS_DATA_2D[n,d] == 0)) %Not if off-day in prev sol
  )
 (nShift[n,d] = nShift_WS_DATA_2D[n,d] ) %Fix sol to prev sol
%endif;
;

constraint 
%if fLNS==1 then true %If no prev sol, relax all, else use LNS
%else
  forall( n in NURSES, d in DAYS where
    (fObjMinimiseSum==0 /\ SwitchNeighborhood==1/\Iteration>0  %If max min is stuck in local optima
    /\ n <= card(index_set_1of2(nShift_WS_DATA_2D))
    /\ (not (n in testWNURSES union randNURSES ))                   
    /\ (not (nShift_WS_DATA_2D[n,d] == 0))
  ))
 (nShift[n,d] = nShift_WS_DATA_2D[n,d] )
%endif;
;

constraint 
%if fLNS==1 then true 
%else
  forall( n in NURSES, d in DAYS where
    (fObjMinimiseSum==1/\Iteration>0 
    /\ not ( n in randNURSES)%{nurID1} union {nurID2} union {nurID3} union {nurID4} union {nurID5} union {nurID6} union {nurID7}
    %/\ (d in max(1,d1-nDiff)..min(d1+nDiff,max(DAYS)) )
    /\ not (nShift_WS_DATA_2D[n,d] == 0)
    )
  )
 (nShift[n,d] = nShift_WS_DATA_2D[n,d] )
%endif;
;

constraint 
%if fLNS==1 then true 
%else
  forall( n in NURSES, d in DAYS where
    (Iteration==0 
    )
  )
 (nShift[n,d] = nShift_WS_DATA_2D[n,d] )
;

var int: obj;

constraint if (fObjMinimiseSum==0 /\ SwitchNeighborhood==1/\Iteration>0 ) then forall(n in NURSES, d in DAYS)(score[n,d] <=prevObj) else true endif; %Set hard constr depending on fObjMinimiseSum
constraint obj = if (fObjMinimiseSum==1) then sum(n in NURSES)( max(d in DAYS)(score[n,d]) ) elseif (SwitchNeighborhood==1) then sum([1| n in NURSES, d in DAYS where (score[n,d]>=prevObj)])  else max( score ) endif; % Set obj depending on fObjMinimizeSum





solve 
%::on_restart("my_lns")
%::restart_constant(10000)
::seq_search( [
%       if card(WORDAYS)>0 then 
%        int_search(
%            [ nShift[n,d] | n in NURSES, d in WORDAYS ],
%            input_order, indomain_min, complete
%        ) else constraint_name("dummy") endif,
       int_search(
            [ nShift[n,d] | n in {nurID1}, d in { d1, max(1,d1-1), max(1,d1-2), max(1,d1-3) } ],
            input_order, indomain_min, complete
        ),
       int_search(
            [ nShift[n,d] | n in {nurID1}, d in DAYS diff { d1, max(1,d1-1), max(1,d1-2), max(1,d1-3) } ],
            input_order, indomain_min, complete
        ),
if card(WNURSES) > 0 then int_search(
            [ nShift[n,d] | n in WNURSES, d in WDAYS ],
            input_order, indomain_min, complete
        ) else constraint_name("dummy") endif,
if card(WNURSES) > 0 then int_search(
            [ nShift[n,d] | n in WNURSES, d in DAYS diff WDAYS ],
            input_order, indomain_min, complete
        ) else constraint_name("dummy") endif,
       int_search(
            [ nShift[n,d] | n in { n1 | n1 in NURSES where nShift_WS_DATA_2D[n1,d1] == 0 }, d in { d1, max(1,d1-1), max(1,d1-2), max(1,d1-3) } ],
            input_order, indomain_min, complete
        ),
       int_search(
            [ nShift[n,d] | n in { n1 | n1 in NURSES where nShift_WS_DATA_2D[n1,d1] == 0 }, d in DAYS diff { d1, max(1,d1-1), max(1,d1-2), max(1,d1-3) } ],
            input_order, indomain_min, complete
        ),
       int_search(
            [ nShift[n,d] | n in NURSES diff ({nurID1} union { n1 | n1 in NURSES where nShift_WS_DATA_2D[n1,d1] == 0 }), d in { d1, max(1,d1-1), max(1,d1-2), max(1,d1-3) } ],
            input_order, indomain_min, complete
        ),
       int_search(
            [ nShift[n,d] | n in NURSES diff ({nurID1} union { n1 | n1 in NURSES where nShift_WS_DATA_2D[n1,d1] == 0 }), d in DAYS diff { d1, max(1,d1-1), max(1,d1-2), max(1,d1-3) } ],
            input_order, indomain_min, complete
        ),
])

  minimize
    obj
    ;