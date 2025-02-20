function EvaluateData(Rosterchoice,bchoice,ev_horchoice)
clearvars('-except','Rosterchoice','bchoice','ev_horchoice')
%clear all
%Load data from simulations
load('NewDvData1709.mat');
load defaultvalues
%load('defaultcircadianmax.mat');
%DvData=(BioTypes,Rosterprofile,NrSims,FRE:tRHE,Timestamps);
%RosterData(Real:DrawShifts,NrSims,Days);

%If we only want to look at subset of data, DvData can be adjusted here.
%E.g., if we only want a subset of simulations (to see how many are needed)
%we can choose the n first by doing DvData=DvData(:,:,1:n,:,:). Similarly,
%we can choose a subset of biotypes of rosterprofiles. It can all be
%evaluated in light of solution methods (i.e. evaluation horizon).

%Rosterchoice=1:30;%Choose roster
%bchoice=1:6;%Choose bio
%ev_horchoice=[3];%Choose evaluation horizon to look at
Rostertype=1;%Choose rostertype
HrsAcceptedUnphasing=2;%Number of hours unphasing we accept

PreRosterData=RosterData(Rostertype,Rosterchoice,1:max(ev_horchoice));
%DvData=DvData(bchoice,Rostertype,Rosterchoice,:,1+2400*10:size(DvData,5));
DvData=DvData(bchoice,Rostertype,Rosterchoice,[1 find(ev_hor==ev_horchoice)+1],1+2400*max(ev_horchoice):size(DvData,5)); %Keep only relevant data
xData=xData(bchoice,Rostertype,Rosterchoice,[1 find(ev_hor==ev_horchoice)+1],1+2400*max(ev_horchoice):size(xData,5)); %Keep only relevant data
xcData=xcData(bchoice,Rostertype,Rosterchoice,[1 find(ev_hor==ev_horchoice)+1],1+2400*max(ev_horchoice):size(xcData,5)); %Keep only relevant data

RosterData=RosterData(:,:,max(ev_horchoice)+1:RosterLength); %Remove data where rFRE=RHE from rosters

CheckRosters=squeeze(RosterData);



%Decide how to evaluate data
EvaluateError=1;%Evaluate the error of using Rolling Horizon Approximation without any variable-values igven from day to day
if EvaluateError==1
   
   EvaluateDailyMaxVals=1;  %Compare the maximum fatigue values each day
   EvaluateShiftMaxVals=0;  %Compare the maximum fatigue values observed during each shift worked
   EvaluateDailyAvgVals=0;  %Compare the average values each day
   EvaluateTimeStampVals=0; %Compare the values of each timestamp
   
   Plotting=1;
end

BioEval=0;%Plot data for the different biotypes
if(BioEval==1)
    BioCompare=[1,4,7]; %Choose 3 BioCompares to compare
    ProvideRoster=0;%If BioEval=1, ProvideRoster=1 looks at mean of all rosters over rosterprofiles (Draw) and simulations (NrSims). If ProvideRoster>0, it determines which roster is evaluated.
    if ProvideRoster>0
        DrawChoice=2; %1 is realrosters, >1 types of random draws
        SimChoice=1;
    end
end

%Define useful variables
getreadyhrs=0.75;
gettobedhrs=0.75;
BioTypes=[1:size(DvData,1)];
RosterProfiles=[1:size(DvData,2)];
Sims=[1:size(DvData,3)];
SolMethods=[1:size(DvData,4)];
TimeStamps=[1:size(DvData,5)];
r_length=size(RosterData,3);
SolMethodNames=[{'FRE'}];

XError=[];
YFatigue=[];
YCirc=[];
for i=1:size(ev_hor,2)
    SolMethodNames=[SolMethodNames, strcat(num2str(ev_hor(i)),'RHE')];
end
count=0;
if EvaluateError==1    
    if EvaluateDailyMaxVals==1
        DaysWorstDvDiff=[];
        for b = BioTypes
            DefaultPhase(b)=atan2(defaultvals(b,3),defaultvals(b,2));
            for s=SolMethods                                
                for draw=RosterProfiles %1 is realrosters, rest are draws
                    for i=Sims %1:NrSims
                        flag=0;
                        for t=1:r_length %1:the number of days in a roster
                           if(flag==0)
                                normaltimestamps=1+(t-1)*2400:t*2400;                            
                                Phase=atan2(xcData(b,draw,i,1,normaltimestamps(end)),xData(b,draw,i,1,normaltimestamps(end)));
                                CircDiff=abs(Phase-DefaultPhase(b));
                                if(abs(Phase-DefaultPhase(b))<(3.14159/12)*HrsAcceptedUnphasing)                                
                                    DaysWorstDv(b,draw,i,1,t)=max(DvData(b,draw,i,1,normaltimestamps),[],[5]);
                                    DaysWorstDv(b,draw,i,s,t)=max(DvData(b,draw,i,s,normaltimestamps),[],[5]);
                                    DaysWorstDvDiff(b,draw,i,s,t)=DaysWorstDv(b,draw,i,1,t)-DaysWorstDv(b,draw,i,s,t);
                                    XError=[XError, abs(DaysWorstDvDiff(b,draw,i,s,t))];
                                    YFatigue=[YFatigue, DaysWorstDv(b,draw,i,s,t)];
                                    YCirc=[YCirc, CircDiff];
                                else
                                    flag=1;
                                    count=count+1;
                                end
                           end                            
                        end
                        
                    end
                end

            end
        end
        PercentilesDiff=[min(DaysWorstDvDiff,[],'all'),prctile(DaysWorstDvDiff,1,'all'), prctile(DaysWorstDvDiff,3,'all'), prctile(DaysWorstDvDiff,5,'all'), prctile(DaysWorstDvDiff,10,'all'), prctile(DaysWorstDvDiff,90,'all'), prctile(DaysWorstDvDiff,95,'all'), prctile(DaysWorstDvDiff,97,'all'), prctile(DaysWorstDvDiff,99,'all'),max(DaysWorstDvDiff,[],'all')];
        formatSpec = strcat(num2str(ev_horchoice),'& %5.4f & %5.4f & %5.4f & %5.4f & %5.4f & %5.4f & %5.4f & %5.4f & %5.4f & %5.4f & %5.4f & %5.4f');
        fprintf(formatSpec,PercentilesDiff);
        count

        scatter(XError,YCirc)
        
        
        
    end
        
    if EvaluateDailyAvgVals==1
        for t=1:r_length
            MeanDv(1,1+(t-1)*2400:1+t*2400)=mean(Dv_all(1,1+(t-1)*2400:1+t*2400));
            for e=ev_hor
                MeanDv(find(ev_hor==e)+1,1+(t-1)*2400:1+t*2400)=mean(Dv_all(find(ev_hor==e)+1,1+(t-1)*2400:1+t*2400));
            end
        end
    end

    if EvaluateShiftMaxVals==1
        %for b = BioTypes
            for draw=RosterProfiles %1 is realrosters, rest are draws
                for i=Sims %1:NrSims
                    %for s=SolMethods
                        for t=1:r_length %1:the number of days in a roster

                            [ShiftStrt, ShiftEnd]=getshifthours(RosterData(draw,i,t),getreadyhrs,gettobedhrs);

                            if ShiftStrt==0&&ShiftEnd==0 %If off-shift, no hours are given
                                %Do not register value for ShiftWorstDv that day
                            else
                                ShiftStrt=ShiftStrt*100;
                                ShiftEnd=ShiftEnd*100;

                                %ShiftWorstDv(draw,i,1+(t-1)*2400:1+t*2400


                                ShiftWorstDv(BioTypes,draw,i,SolMethods,1+(t-1)*2400:1+t*2400)=max(DvData(BioTypes,draw,i,SolMethods,1+(t-1)*2400+ShiftStrt:min(1+(t-1)*2400+ShiftEnd,1+2400*r_length)));

                                %ShiftWorstDv(1,1+(t-1)*2400:1+t*2400)=max(Dv_all(1,1+(t-1)*2400:1+t*2400));
                                %for e=ev_hor
                                %    ShiftWorstDv(find(ev_hor==e)+1,1+(t-1)*2400:1+t*2400)=max(Dv_all(find(ev_hor==e)+1,1+(t-1)*2400+ShiftStrt:min(1+(t-1)*2400+ShiftEnd,1+2400*r_length)));
                                %end
                            end
                        end
                    %end
                end
            end
        %end
    end
end

       
       
       
      
if(BioEval==1)
    if(ProvideRoster>0)
        %Plot Dv for chosen BioCompares on provided roster. Use only FRE-values.
        B=squeeze(DvData(:,DrawChoice,SimChoice,1,:));
        roster=squeeze(RosterData(DrawChoice,SimChoice,:));
    else
        %Plot Dv for chosen BioCompares on mean over all Rosterprofiles and
        %Sims. Use only FRE-values.
        B=squeeze(mean(DvData(:,:,:,1,:),[2 3]));
        roster=[1:r_length];
    end
        x=1:size(B,2);

        xlabel('Time (h)')
        ylabel('Fatigue')
        y=B(BioCompare(1),:);
        a1=plot(x,y);
        lgd = legend('Location','northwest');
        lgd.Title.String = 'Default bio';
        lgd.NumColumns = 1;

        set(gca, 'xlim', [1 r_length*2400+1]);
        set(gca, 'xtick', [1201:2400:r_length*2400]);
        Days=[1:r_length];
        set(gca,'xticklabel',roster(1:end).')
        set(gca,'TickLength',[0 0])

        hold on

        a2=plot(x,B(BioCompare(2),:));
        a3=plot(x,B(BioCompare(3),:));
        legend([a1,a2,a3],{strcat('Bio ',num2str(BioCompare(1))),strcat('Bio ',num2str(BioCompare(2))),strcat('Bio ',num2str(BioCompare(3)))});

        set(groot,'defaultLegendAutoUpdate','off')
        for i=1:r_length
           s=xline(1+2400*i,'--');
           s.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        yline(0,'--');
        set(groot,'defaultLegendAutoUpdate','off')
        hold off    
end
end