%Function that evalutates a given shift pattern consisting of numbers using the sleepswitch.m-file
%and writes the totalsleep, Dv-values and last info on H,C,xc,n,state
function [totalsleep, Dv, lastH, lastC, lastxc, lastn, laststate, x,xc]= evalnumberedpattern(Pattern, plotting, prevH, prevC, prevxc, prevn, prevstate,workedN,Bio)
    
    Pattern=cell2mat(Pattern);
   
    hpd = 24; % hours per day
    mph=60; % minutes per hour
    worktimes=zeros(2,1);
    shifttimes=zeros(2,1);
    getreadyhrs=0.75;  %Time in hours needed to be awake prior to starting a shift
    gettobedhrs=0.75;  %Time in hours needed to be awake after ending a shift

    for d=1:size(Pattern,2)
        if(workedN==1)
             [worktimes(1),worktimes(2)]=getnumberedshifthours(9999,getreadyhrs,gettobedhrs);
             [shifttimes(1),shifttimes(2)]=getnumberedshifthours(9999,0,0);
        end
        if(~Pattern(d)==0)
            [worktimes(size(worktimes,1)+1),worktimes(size(worktimes,1)+1)]=getnumberedshifthours(Pattern(d),getreadyhrs,gettobedhrs);
            worktimes(size(worktimes,1)-1)=(d-1)*24+worktimes(size(worktimes,1)-1);
            worktimes(size(worktimes,1))=(d-1)*24+worktimes(size(worktimes,1));
            [shifttimes(size(shifttimes,1)+1),shifttimes(size(shifttimes,1)+1)]=getnumberedshifthours(Pattern(d),0,0);
            shifttimes(size(shifttimes,1)-1)=(d-1)*24+shifttimes(size(shifttimes,1)-1);
            shifttimes(size(shifttimes,1))=(d-1)*24+shifttimes(size(shifttimes,1));
        end
    end
    
    worktimes=worktimes*mph;
    
    [totalsleep, Dv, lastH, lastC, lastxc, lastn, laststate, x, xc]=sleepswitch(worktimes, shifttimes, plotting, prevH, prevC, prevxc, prevn, prevstate,Bio,Pattern);
    %worktimes are used to decide times of forced wakefulness
    %shifttimes are used to plot activity:sleep, wake, work
    %Tfuture is the length of the pattern
    
end