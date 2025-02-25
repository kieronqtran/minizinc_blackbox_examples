include "model__STUB_scoring.mzn";
include "model__STUB_BASE.mzn";

array[int,int] of int: nShift_WS_DATA_2D;

constraint
forall(n in NURSES, d in DAYS)
   ( nShift[n,d] = nShift_WS_DATA_2D[n,d] )
   ;
  

solve 
satisfy