
%%%%%%%%%%%% Roster Score %%%%%%%%%%%%%%  ++++++++++++++++++++++++++++++++++++++++++++++++++++
int: maxFatigue = max([max(nShiftScore__DATA_1D),max(nShiftScoreAfterNight__DATA_1D)]); % f^{Max}
int: minFatigue = min([min(nShiftScore__DATA_1D),min(nShiftScoreAfterNight__DATA_1D)]);
array[NURSES, DAYS] of var minFatigue..maxFatigue: score;
constraint forall( n in NURSES, d in DAYS)( 
%%%constraint if extFatigue==1 then forall( n in NURSES, d in DAYS)(       
%                     score[ n, d] == if d-1 > 0 /\ nShift[n,d-1]==3 then
%                           nShiftScoreAfterNight__DATA_1D[(pow(4,nPatternLength)*(nNurseBioType[n]-1) + (   
%                                                   (nShift[n,d]+1) + 
%                                                    nShift[n,d+1]*nPatternLength + 
%                                                    nShift[n,d+2]*pow(nPatternLength,2)+ 
%                                                    nShift[n,d+3]*pow(nPatternLength,3)) 
%                                                    ) ]
%                           else
%                           nShiftScore__DATA_1D[(pow(4,nPatternLength)*(nNurseBioType[n]-1) + (   
%                                                   (nShift[n,d]+1) + 
%                                                    nShift[n,d+1]*nPatternLength + 
%                                                    nShift[n,d+2]*pow(nPatternLength,2)+ 
%                                                    nShift[n,d+3]*pow(nPatternLength,3)) 
%                                                    ) ]
%                           endif

                    score[ n, d] ==    (if d==1 then 
                                                nShiftScore__DATA_1D[(pow(4,nPatternLength)*(nNurseBioType[n]-1) + (   
                                                  1+nShift[n,d]*pow(nPatternLength,3))  ) ]
                                        elseif d==2 then
                                                nShiftScore__DATA_1D[(pow(4,nPatternLength)*(nNurseBioType[n]-1) + (   
                                                  (1) + 
                                                   nShift[n,d-1]*pow(nPatternLength,2)+ 
                                                   nShift[n,d]*pow(nPatternLength,3)) 
                                                   ) ]
                                        elseif d==3 then
                                                nShiftScore__DATA_1D[(pow(4,nPatternLength)*(nNurseBioType[n]-1) + (   
                                                  (1) + 
                                                   nShift[n,d-2]*nPatternLength + 
                                                   nShift[n,d-1]*pow(nPatternLength,2)+ 
                                                   nShift[n,d]*pow(nPatternLength,3)) 
                                                   ) ]   
                                        else           
                                            if d > 4 /\ nShift[n,d-4]==3 then
                                                  nShiftScoreAfterNight__DATA_1D[(pow(4,nPatternLength)*(nNurseBioType[n]-1) + (   
                                                  (nShift[n,d-3]+1) + 
                                                   nShift[n,d-2]*nPatternLength + 
                                                   nShift[n,d-1]*pow(nPatternLength,2)+ 
                                                   nShift[n,d]*pow(nPatternLength,3)) 
                                                   ) ]
                                            else                                             
                                                  nShiftScore__DATA_1D[(pow(4,nPatternLength)*(nNurseBioType[n]-1) + (   
                                                  (nShift[n,d-3]+1) + 
                                                   nShift[n,d-2]*nPatternLength + 
                                                   nShift[n,d-1]*pow(nPatternLength,2)+ 
                                                   nShift[n,d]*pow(nPatternLength,3)) 
                                                   ) ]
                                            endif
                                         endif)
                    ) %else true endif;
                    
