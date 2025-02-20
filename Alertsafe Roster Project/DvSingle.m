%function taking a roster, a set of evaluation horizons (int), binary plotting
%and biological type (int) as inputs and providing Dv-valuesfor time period
%of roster. Uses rolling horizon approach if ev_hor is >0.
%Full roster evaluation if ev_hor=0. Plots development in Dv if plotting=1.
%Dv-values for all times periods are collected in Dv_all, and Dv_all(1,:)
%is the full roster evaluation. For Dv_all(i,:) where i>=2, some evaluation
%horizon is used for a rolling horizon approximation.
function [Dv_all,x,xc] = DvSingle(roster, ev_hor, plotting, Bio)
tic
r_length=size(roster,2);

prevH=9999;
prevC=9999;
prevxc=9999;
prevn=9999;
prevstate=9999;
workedN=0;

[~,Dv_all(1,:),~, ~, ~, ~, ~,x(1,:),xc(1,:), FREshiftstate,FREstate]=evalpatternwh(roster,0,prevH, prevC, prevxc, prevn, prevstate,workedN,Bio);

for e=ev_hor
   for t=1:r_length
        if t<e            
        elseif t==e
            %Get values for approximation the first e days
            pattern=roster(1:t);
            E=[];
            F=[];
            [totalsleep,E,prevH, prevC, prevxc, prevn, prevstate,F,G, shiftstate,state]=evalpatternwh(pattern,0,prevH, prevC, prevxc, prevn, prevstate,workedN,Bio);
            Dv_all(find(ev_hor==e)+1,1:1+(t*2400))=E(1:end);
            x(find(ev_hor==e)+1,1:1+(t*2400))=F(1:end);
            xc(find(ev_hor==e)+1,1:1+(t*2400))=G(1:end);
            RHEshiftstate(find(ev_hor==e)+1,1:1+(t*2400))=shiftstate(1:end);
            RHEstate(find(ev_hor==e)+1,1:1+(t*2400))=state(1:end);
        elseif t>e
            %Get values for the rest of the planning period, one day at the
            %time
            pattern=roster(t-e+1:t);
            E=[];            
            F=[]; 
            G=[]; 
            if(strcmp(roster(t-e),{'N'}))
                workedN=1;
            else
                workedN=0;
            end
            %Choose version below            
            %[totalsleep,E,prevH, prevC, prevxc, prevn, prevstate]=evalpatternwh(pattern,0,prevH, prevC, prevxc, prevn, prevstate,workedN,Bio);%Should be identical
            [totalsleep,E,prevH, prevC, prevxc, prevn, prevstate,F,G, shiftstate,state]=evalpatternwh(pattern,0,9999, 9999, 9999, 9999, 9999,workedN,Bio);
            Dv_all(find(ev_hor==e)+1,1+((t-1)*2400):1+(t*2400))=E(end-2400:end);
            x(find(ev_hor==e)+1,1+((t-1)*2400):1+(t*2400))=F(end-2400:end);
            xc(find(ev_hor==e)+1,1+((t-1)*2400):1+(t*2400))=G(end-2400:end);
            RHEshiftstate(find(ev_hor==e)+1,1+((t-1)*2400):1+(t*2400))=shiftstate(end-2400:end);
            RHEstate(find(ev_hor==e)+1,1+((t-1)*2400):1+(t*2400))=state(end-2400:end);
        end
    end
end



toc

if(plotting==1)
%Dv(1,:)=Dv_all(1,2401:2400:end);
% Shifts={'D','E','N','O'}; %All shifts
% NrShifts=size(Shifts,2);
% getreadyhrs=0.75;  %Time in hours needed to be awake prior to starting a shift
% gettobedhrs=0.75;  %Time in hours needed to be awake after ending a shift
% ShiftWorstDv=zeros(size(Dv_all));
% 
% for t=1:r_length
%     [ShiftStrt, ShiftEnd]=getshifthours(roster(t),getreadyhrs,gettobedhrs);
%     if ShiftStrt==0&&ShiftEnd==0 %If off-shift, no hours are given
%         %Do not register value for ShiftWorstDv that day
%     else
%         ShiftStrt=ShiftStrt*100;
%         ShiftEnd=ShiftEnd*100;
%         ShiftWorstDv(1,1+(t-1)*2400:1+t*2400)=max(Dv_all(1,1+(t-1)*2400+ShiftStrt:min(1+(t-1)*2400+ShiftEnd,1+2400*r_length)));
%         for e=ev_hor
%             ShiftWorstDv(find(ev_hor==e)+1,1+(t-1)*2400:1+t*2400)=max(Dv_all(find(ev_hor==e)+1,1+(t-1)*2400+ShiftStrt:min(1+(t-1)*2400+ShiftEnd,1+2400*r_length)));
%         end
%     end
% end
% 
%     
%     
% for t=1:r_length
%     DaysWorstDv(1,1+(t-1)*2400:1+t*2400)=max(Dv_all(1,1+(t-1)*2400:1+t*2400));
%    
%     
%     for e=ev_hor
%         DaysWorstDv(find(ev_hor==e)+1,1+(t-1)*2400:1+t*2400)=max(Dv_all(find(ev_hor==e)+1,1+(t-1)*2400:1+t*2400));
%     end
% end
% 
% for t=1:r_length
%     MeanDv(1,1+(t-1)*2400:1+t*2400)=mean(Dv_all(1,1+(t-1)*2400:1+t*2400));
%     for e=ev_hor
%         MeanDv(find(ev_hor==e)+1,1+(t-1)*2400:1+t*2400)=mean(Dv_all(find(ev_hor==e)+1,1+(t-1)*2400:1+t*2400));
%     end
% end

%Dv(1:find(ev_hor==max(ev_hor))+1,:)=Dv_all(1:find(ev_hor==max(ev_hor))+1,2401:2400:end);
    
        figure(plotting);
        resizefactor=1;
        x=1:resizefactor:(r_length*2400)+1;
        
        yFRE=Dv_all(1,x);
        yRHE=Dv_all(find(ev_hor==e)+1,x);
        yDIFF=yFRE-yRHE;
                         
%         yFRE=DaysWorstDv(1,x);
%         yMIN=DaysWorstDv(find(ev_hor==min(ev_hor))+1,x);
%         yMAX=DaysWorstDv(find(ev_hor==max(ev_hor))+1,x);
%         yDIFFMIN=DaysWorstDv(1,x)-DaysWorstDv(find(ev_hor==min(ev_hor))+1,x);
%         yDIFFMAX=DaysWorstDv(1,x)-DaysWorstDv(find(ev_hor==max(ev_hor))+1,x);
        
%         yFRE=ShiftWorstDv(1,x);
%         yMIN=ShiftWorstDv(find(ev_hor==min(ev_hor))+1,x);
%         yMAX=ShiftWorstDv(find(ev_hor==max(ev_hor))+1,x);
%         yDIFFMIN=ShiftWorstDv(1,x)-ShiftWorstDv(find(ev_hor==min(ev_hor))+1,x);
%         yDIFFMAX=ShiftWorstDv(1,x)-ShiftWorstDv(find(ev_hor==max(ev_hor))+1,x);
                                                   
%         yFRE=MeanDv(1,x);
%         yMIN=MeanDv(find(ev_hor==min(ev_hor))+1,x);
%         yMAX=MeanDv(find(ev_hor==max(ev_hor))+1,x);
%         yDIFFMIN=MeanDv(1,x)-MeanDv(find(ev_hor==min(ev_hor))+1,x);
%         yDIFFMAX=MeanDv(1,x)-MeanDv(find(ev_hor==max(ev_hor))+1,x);
%         
%         subplot(4,1,1)
%         title('Sleep drive FRE')
%         xlabel('Time (h)')
%         ylabel('Fatigue')
%         
%         plot(x,yFRE);
%         set(gca, 'xlim', [1 r_length*2400]);
%          
%         set(gca, 'xtick', [1201:2400:r_length*2400]);
%         set(gca,'xticklabel',roster(1:end).')
%         set(gca,'TickLength',[0 0])
%         lgd = legend('Location','northwest');
%         lgd.Title.String = 'Full Roster Evaluation';
%        lgd.NumColumns = 1;
%         hold on
%         set(groot,'defaultLegendAutoUpdate','off')
%         for i=1:r_length
%            s=xline(1+2400*i,'--');
%            s.Annotation.LegendInformation.IconDisplayStyle = 'off';
%         end
%         yline(0,'--');
%         set(groot,'defaultLegendAutoUpdate','off')
%         hold off
        
%         subplot(4,1,2)
%         title('Sleep drive diff.')
%         xlabel('Time (h)')
%         ylabel('Fatigue')
%         resizefactor=1;
%         x=1:resizefactor:(r_length*2400)+1;
%         y=Dv_all(min(ev_hor+1),x);
%         plot(x,y,'DisplayName',strcat(num2str(min(ev_hor)),'-RHE'));
%         set(gca, 'xlim', [1 r_length*2400]);
%         set(gca, 'xtick', [1201:2400:r_length*2400]);
%         set(gca,'xticklabel',roster(min(ev_hor):end).')
%         set(gca,'TickLength',[0 0])
%         lgd = legend('Location','northwest');
%         lgd.Title.String =strcat(num2str(min(ev_hor)),' Rolling Horizon Evaluation');
%         lgd.NumColumns = 1;
%         hold on
%         hold on
%         set(groot,'defaultLegendAutoUpdate','off')
%         for i=1:r_length
%             s=xline(1+2400*i,'--');
%             s.Annotation.LegendInformation.IconDisplayStyle = 'off';
%         end
%         yline(0,'--');
%         set(groot,'defaultLegendAutoUpdate','off')
%         hold off
%         
%         subplot(4,1,2)
%         title('Sleep drive diff.')
%         xlabel('Time (h)')
%         ylabel('Fatigue')
%         plot(x,yRHE,'DisplayName',strcat(num2str(max(ev_hor)),'-RHE'));
%         
         
%         set(gca, 'xlim', [1 r_length*2400]);
%         set(gca, 'xtick', [1201:2400:r_length*2400]);
%         set(gca,'xticklabel',roster(1:end).')
%         set(gca,'TickLength',[0 0])
%         lgd = legend('Location','northwest');
%         lgd.Title.String = strcat(num2str(max(ev_hor)),' Rolling Horizon Evaluation');
%        lgd.NumColumns = 1;
%         hold on
%         set(groot,'defaultLegendAutoUpdate','off')
%         for i=1:r_length
%             s=xline(1+2400*i,'--');
%             s.Annotation.LegendInformation.IconDisplayStyle = 'off';
%         end
%         yline(0,'--');
%         set(groot,'defaultLegendAutoUpdate','off')
%         hold off
        %xperiod=[1 r_length*2400]
        xperiod=[(12-1)*2400 16*2400]
        
        %subplot(1,1,1);
        subplot(2,1,1);
        alldatacursors = findall(gcf,'type','hggroup');
        set(alldatacursors,'FontSize',46);
        set(alldatacursors,'FontName','Times');
        set(alldatacursors, 'FontWeight', 'bold');
        title('Sleep drive diff.');
        xlabel('Time (h)');
        ylabel('Fatigue');
        a1=plot(x,yFRE,'b-');%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PLOTPLOTPLOTPLOTPLOT
        ylim([-1.1 6.2]);
        set(gca, 'xlim', [xperiod]);
        xlabel('Time [days]');
        ylabel('Fatigue [mV]');
        for i = 1: length(roster)
          Numbers(i)={num2str(i)};
        end
        
        
        set(gca, 'xtick', [1201:2400:r_length*2400]);
        set(gca,'xticklabel',Numbers(1:end).');
        set(gca,'TickLength',[0 0])
        lgd = legend('Location','northwest');
        lgd.Title.String = 'Comparison';
        lgd.NumColumns = 1;
        hold on
        a2=plot(x,yRHE,'Red--','LineWidth',1.5);%%%%%%%%%%%%PLOTPLOTPLOTPLOT
        legend([a1,a2],{'FRE',strcat(num2str(max(ev_hor)),'-RHE')});
        set(groot,'defaultLegendAutoUpdate','off');
        for i=1:r_length
            s=xline(1+2400*i,'--');
            s.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        %yline(0,'--');
        set(groot,'defaultLegendAutoUpdate','off')
        hold off
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot(2,1,2)
        %Plot time awake
        names = {'Sleeping';'Awake'; 'Working'; };
        b1=plot(x,FREshiftstate+FREstate,'b-');%%%%PLOTPLOTPLOTPLOT
        set(gca, 'xtick', []);
        xlabel('Time [days]');
        
        str_roster=roster;
        for i =1:length(roster)
            if strcmp(roster(i),'O')
                str_roster(i)={' '};
                xt(i)=(i-1)*2400+1200;
            elseif strcmp(roster(i),'D')
                str_roster(i)={'D'};
                xt(i)=(i-1)*2400+1100;
            elseif strcmp(roster(i),'E')
                str_roster(i)={'E'};
                xt(i)=(i-1)*2400+1850;
            elseif strcmp(roster(i),'N')
                str_roster(i)={'N'};
                xt(i)=(i-1)*2400+2675;
            end
        end
       
        nrxt = size(xt,2);
        latvct = linspace(71.59, 24.06, nrxt);
        lat_txt = str_roster;%cellstr(strsplit(num2str(latvct,'%.2f '),' '));
        text([(xt(1)-xt(2))*0.5 xt], ones(1,nrxt+1)*2.13-0.05*1, [' ' lat_txt],'HorizontalAlignment','center');
        lngvct = linspace(100.71, 75.54, nrxt);
        
              
        set(gca,'ytick',[0:2],'yticklabel',names);
        title('Activity');
        ylim([-0.2 2.2]);
        %xlabel('Roster')
        %set(gca, 'xtick', [12:24:size(roster,2)*24]);
        %set(gca,'xticklabel',roster(1:end).')
        %xlim([0 size(roster,2)*24])
        set(gca, 'xlim', xperiod);
        set(gca,'TickLength',[0,0])
        %set(groot,'defaultLegendAutoUpdate','off')
%         for i=1:r_length
%             s=xline(1+2400*i,'--');
%             s.Annotation.LegendInformation.IconDisplayStyle = 'off';
%         end
%         %yline(0,'--');
%         set(groot,'defaultLegendAutoUpdate','off')%%%%%%%%%%END PLOT 2
        
        hold on
        %a2=plot(x,yRHE,'Red');%%%%%%%%%%%%PLOTPLOTPLOTPLOT
        b2=plot(x,RHEshiftstate(2,:)+RHEstate(2,:),'Red--','LineWidth',1.5); %%%%%%%%%%%PLOTPLOTPLOTPLOTPLOTPLOT
        %b2=plot(x,0.05+RHEshiftstate(2,:)*0.95+RHEstate(2,:)*0.95,'--','Red'); %%%%%%%%%%%PLOTPLOTPLOTPLOTPLOTPLOT
        
        %%%%%%%%%%%%%%%%%%%%%%%
        %subplot(3,1,3)
        names = {'Sleeping';'Awake'; 'Working'; };
        %plot(x,RHEshiftstate+RHEstate,'Red') %%%%%%%%%%%PLOTPLOTPLOTPLOTPLOTPLOT
        %set(gca, 'xtick', []);
        %xt = [2675,5075,7475,9875,10800,13100,15600,19475,21875,24275,25200,27600,30000,32400,36275,38675,41075,43475,44400,46800,49200,53075,55475,57875,60275,61200,63600,66000,69875,72275,74675,75600];
      
        %nrxt = size(xt,2);
        %latvct = linspace(71.59, 24.06, nrxt);
        %lat_txt = str_roster;%cellstr(strsplit(num2str(latvct,'%.2f '),' '));
        %text([(xt(1)-xt(2))*0.5 xt], ones(1,nrxt+1)*2.13-0.05*1, [' ' lat_txt],'HorizontalAlignment','center')
        %lngvct = linspace(100.71, 75.54, nrxt);

        %set(gca,'ytick',[0:2],'yticklabel',names)
        %title('Activity')
        %ylim([-0.2 2.2])
        %xlabel('Roster')
        %set(gca, 'xtick', [12:24:size(roster,2)*24]);
        %set(gca,'xticklabel',roster(1:end).')
        %xlim([0 size(roster,2)*24])
        %set(gca, 'xlim', [1 r_length*2400]);
        %set(gca,'TickLength',[0,0])
        %set(groot,'defaultLegendAutoUpdate','off')
        for i=1:r_length
            s=xline(1+2400*i,'--');
            s.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
        %yline(0,'--');
        set(groot,'defaultLegendAutoUpdate','off');
        
        hold off
        
%         subplot(4,1,4)
%         title('Sleep drive diff.') 
%         xlabel('Time (h)')
%         ylabel('Fatigue')
%         a1=plot(x,yDIFF);
%         set(gca, 'xlim', [1 r_length*2400]);
%         set(gca, 'xtick', [1201:2400:r_length*2400]);
%         set(gca,'xticklabel',roster(1:end).')
%         set(gca,'TickLength',[0 0])
%         lgd = legend('Location','northwest');
%         lgd.Title.String = 'Diff. from FRE';
%         lgd.NumColumns = 1;
%        
%         %legend([a1],{'FRE minus',strcat(num2str(max(ev_hor)),'-RHE')});
%         hold on
%         %set(groot,'defaultLegendAutoUpdate','off')
%         for i=1:r_length
%             s=xline(1+2400*i,'--');
%             s.Annotation.LegendInformation.IconDisplayStyle = 'off';
%         end
%         yline(0,'--');
%         set(groot,'defaultLegendAutoUpdate','off')
%         hold off
%     end
%     

    

end





