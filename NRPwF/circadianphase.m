ev_hor=7;
NrSims=30;
Shifts={'O','D','E','N'}; %All shifts
ShiftsNumbered=[1:4];
BioTypes=[1:1];

load('realrosters.mat'); %get real rosters in "Insert"

% Rosters=Insert(:,1:7);
% for s=1:NrSims
%     for t =1:ev_hor
%         if(strcmp(Rosters(s,t),'N'))
%             NightOrNotRosters(s,t)=1;
%         else
%             NightOrNotRosters(s,t)=0;
%         end
%         NumberedRosters(s,t)=find(strcmp(Rosters(s,t),Shifts))-1;
%     end
% end

DrawShifts=zeros(NrSims,ev_hor);
for s=1:NrSims
    DrawShifts(s,1:ev_hor)=DrawShifts(s,(randi(1,0,ev_hor)));
end








Weights=ones(BioTypes,7);
ThePredictor=zeros(BioTypes,NrSims,ev_hor);
Error=zeros(BioTypes,NrSims,ev_hor);
phase_at_end=zeros(1,NrSims);

for b=BioTypes
    for s=NrSims
        [~, Dv, ~, lastx, lastxc, ~, x,xc]=evalnumberedpattern({NumberedRosters(s,:)}, 0, 9999, 9999, 9999, 9999, 9999,0,b);
        phase_at_end(b,s)=atan2(lastxc,lastx);
        
        %A=Weights(b,:)
        %B=NightOrNotRosters(s,:)
        ThePredictor(b,s,:)=Weights(b,:).*NightOrNotRosters(s,:);
        
        Error(b,s,ev_hor)=phase_at_end(b,s)-ThePredictor(b,s,ev_hor);
        
        %ThePredictor(b,s)=dot(Weights(b,:),NightOrNotRosters(s,:));
       % phase_at_end=
    end
end

LastDayErrors=squeeze(Error(:,:,ev_hor))











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
            [DvData(b,1,i,:,:),xData(b,1,i,:,:)]=DvSingle(A, ev_hor, 0, b);
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
    save('NewDvData1109.mat','DvData','xData','RosterData','ev_hor','RosterLength', '-v7.3');
end
toc
