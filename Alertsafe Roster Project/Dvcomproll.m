clear all
ModelType=1;%If=1, Andrew's model.
%Runs DvSingle for a number of different evluation horizons and rosters.
%Writes an array to file that contains the sleep drive at all times
%for each roster for Full Roster Evaluation and tRHE.
%Explicitpattern={};
Explicitpattern={'D','D','N','O','D','E','E'};
tic
UseExistingDrawShifts=0;
plotting=0;
ev_hor=[7];
NrSims=30;
if(isempty(Explicitpattern))
    RosterLength=7*6;
else
    RosterLength=size(Explicitpattern,2);
end
colssize=RosterLength;
Shifts={'D','E','N','O'}; %All shifts
DrawShifts={};
%DrawShifts(size(DrawShifts,1)+1,1:25)={'D'};DrawShifts(size(DrawShifts,1),26:50)={'E'};DrawShifts(size(DrawShifts,1),51:75)={'N'};DrawShifts(size(DrawShifts,1),76:100)={'O'};%Equal
%DrawShifts(size(DrawShifts,1)+1,1:43)={'D'};DrawShifts(size(DrawShifts,1),44:57)={'E'};DrawShifts(size(DrawShifts,1),58:71)={'N'};DrawShifts(size(DrawShifts,1),72:100)={'O'};%Normal:3/7 D, 1/7 E, 1/7N, 2/7 O
%DrawShifts(size(DrawShifts,1)+1,1:43)={'E'};DrawShifts(size(DrawShifts,1),44:57)={'D'};DrawShifts(size(DrawShifts,1),58:71)={'N'};DrawShifts(size(DrawShifts,1),72:100)={'O'};%Evening: 1/7 D, 3/7 E, 1/7N, 2/7 O
%DrawShifts(size(DrawShifts,1)+1,1:43)={'N'};DrawShifts(size(DrawShifts,1),44:57)={'D'};DrawShifts(size(DrawShifts,1),58:71)={'E'};DrawShifts(size(DrawShifts,1),72:100)={'O'};%Night:1/7 D, 1/7 E, 3/7N, 2/7 O
%DrawShifts(size(DrawShifts,1)+1,1:71)={'N'};DrawShifts(size(DrawShifts,1),72:100)={'O'};%Only nightwork: 5/7 N, 2/7 O
%DrawShifts(size(DrawShifts,1)+1,1:57)={'N'};DrawShifts(size(DrawShifts,1),58:100)={'O'};%Only nigths reduced: 4/7 N, 3/7 O
%DrawShifts(size(DrawShifts,1)+1,1:50)={'N'};DrawShifts(size(DrawShifts,1),51:100)={'D'};%Unrealisitc worst case for oscillator 50/50 N and D

BioTypes=[1:9];
 

NrShifts=size(Shifts,2);
%excludedays=3*7;

load('realrosters.mat'); %get real rosters in "Insert"

if(ModelType==1)
    if(~isempty(DrawShifts))
        if UseExistingDrawShifts==1
           load('drawnrosters.mat'); %get DrawnShifts from separate file.
        else
            %Save DrawShifts
            for draw=1:size(DrawShifts,1)
                for i=1:NrSims
                    DrawnShifts(i,draw,1:RosterLength)=DrawShifts(draw,(randi(100,1,RosterLength)));
                end
            end
            save('drawnrosters.mat','DrawnShifts');%save DrawnShifts
        end
    end

    for b =BioTypes
        if(~isempty(DrawShifts))
            for draw=1:size(DrawnShifts,2)
                for i=1:NrSims
                    %Get drawshifts
                    D=DrawnShifts(i,draw,:);
                    A=D(1,1,:);
                    A=squeeze(A);
                    A=transpose(A);
                    A=string(A);
                    %Rosterline(min(NrSims,size(Insert,1))+i,1:RosterLength)=A;
                    [DvData(b,1,1,1,:),xData(b,1,1,1,:)]=DvSingle(A, 0, 0, b);

                end
            end
        end
        if(NrSims<size(Insert,1)) %If we are not simulating as many cases as there are real rosters, choose random subset
            k=randperm(size(Insert,1));
            RealRosters=Insert(k(1:NrSims),:);
        else
            RealRosters=Insert;
        end
        for i=1:min(NrSims,size(Insert,1))
            A= RealRosters(i,:);
            [DvData(b,1,i,:,:),xData(b,1,i,:,:),xcData(b,1,i,:,:)]=DvSingle(A, ev_hor, 0, b);
            RosterData(1,i,:)=A;
        end    
    end
elseif(ModelType==2)
    
    if(NrSims<size(Insert,1)) %If we are not simulating as many cases as there are real rosters, choose random subset
        k=randperm(size(Insert,1));
        RealRosters=Insert(k(1:NrSims),:);
    else
        RealRosters=Insert;
    end
    
    
    for i=1:NrSims
        for d=1:size(Insert,2)
            if(~strcmp(RealRosters(i,d),{'O'}))
                RostersFRE(i,d)=strcat(RealRosters(i,d),'/M');
            end
        end
        %for e = ev_hor
            for d=ev_hor:size(Insert,2)
                B=RealRosters(i,d-ev_hor+1:d);
                for tau=1:size(B,2)
                    if(~strcmp(B(tau),{'O'}))
                       RostersRHE(i,d-ev_hor+1,tau)=strcat(B(tau),'/M');
                    end
                end
            end
        %end
        
        %Write to excel
    end
end
    
    
    
    
    
if(ModelType==1)
    save('NewDvData1709.mat','DvData','xData','xcData','RosterData','ev_hor','RosterLength', '-v7.3');
end
toc
