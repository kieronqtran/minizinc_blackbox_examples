include "model__STUB_scoring.mzn";
include "model__STUB_BASE_regular.mzn";

array[int,int] of int: nShift_WS_DATA_2D;
array[int] of int: nShift_WS_DATA = [nShift_WS_DATA_2D[n,d] | n in NURSES, d in DAYS];

%Try adding constraints
%constraint forall( n in NURSES, d in DAYS where not (n in NurseID) \/ not (d in DayID))       
%                    ( nShift[n,d] = nShift_WS_DATA_2D[n,d]);
set of int: NurseID;
set of int: DayID;
int: fObjMinimiseSum;
constraint trace("\(NurseID), \(DayID)\n");
constraint let {
      set of int: D2 = {d2| d1 in DayID, d2 in max(1,d1-1)..d1}
} 
  in forall( n in NURSES diff NurseID, d in DAYS diff D2 where not (nShift_WS_DATA_2D[n,d] == 0) ) 
( nShift[n,d] = nShift_WS_DATA_2D[n,d]);

constraint exists( n in NurseID, d in DayID) 
( nShift[n,max(1,d-1)] = 0 );        %Fix to off-shift the day before the worst fatigue value

%constraint forall( n in NurseID and d in DayID)       
%                    ( nShift[n,d] = 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
%%%%%%%%%%%% Roster Score %%%%%%%%%%%%%%  ++++++++++++++++++++++++++++++++++++++++++++++++++++
%include "model__STUB_scoring.mzn";
                    

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++



var int: obj;
%constraint if true \/ fObjMinimiseSum==1 then forall(n in NURSES, d in DAYS)(score[n,d] <=maxObj) else true endif;%
constraint obj = if fObjMinimiseSum==1 then sum(n in NURSES)( max(d in DAYS)(score[n,d]) ) else max( score ) endif; % Minimise max score in the entire roster

%constraint if true \/ fObjMinimiseSum==0 then obj == max( score ); %Minimize worst case if ObjMinimiseSum==0



solve 
% ::on_restart("my_lns")
% ::seq_search( [
%        int_search(
%             [ nShift[n,d] | n in {NurseID}, d in DayID ],
%             input_order, indomain_min, complete
%         ),
%        int_search(
%             [ nShift[n,d] | n in {NurseID}, d in DAYS diff DayID ],
%             input_order, indomain_min, complete
%         ),
%        int_search(
%             [ nShift[n,d] | n in { n1 | n1 in NURSES }, d in DayID where nShift_WS_DATA_2D[n,d] == 0],
%             input_order, indomain_min, complete
%         ),
%        int_search(
%             [ nShift[n,d] | n in { n1 | n1 in NURSES}, d in DAYS diff DayID where nShift_WS_DATA_2D[n,d] == 0 ],
%             input_order, indomain_min, complete
%         ),
%        int_search(
%             [ nShift[n,d] | n in NURSES diff ({NurseID} union { n1 | n1 in NURSES }), d in DayID where nShift_WS_DATA_2D[n,d] == 0],
%             input_order, indomain_min, complete
%         ),
%        int_search(
%             [ nShift[n,d] | n in NURSES diff ({NurseID} union { n1 | n1 in NURSES }), d in DAYS diff NurseID where nShift_WS_DATA_2D[n,d] == 0],
%             input_order, indomain_min, complete
%         ),
% ])
  minimize
    obj
    ;
    
% output
% ["Roster = \n"] ++ [show([nShift[i,j] | i in NURSES, j in DAYS])] ++
% ["\nObj = \(obj), \(bObj)\n"];
