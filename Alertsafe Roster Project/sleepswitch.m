%% Code for simulating the sleep/wake model in Phillips et al. (2013)

function [totalsleep, Dv, lastH, lastC, lastxc, lastn, laststate, x, xc, shiftstate,state] = sleepswitch(worktimes, shifttimes, plotting, prevH, prevC, prevxc, prevn, prevstate, Bio, roster)
%
%global waketimes worktimes state sleeptimes Tfuture plotting awakestate workstate
global state %waketimes  %sleeptimes 

Tfuture=size(roster,2);

%tic

%% Settings for simulation
% Conversion factors
hpd = 24; % hours per day
mph=60; % minutes per hour


%% Initial Conditions (Declare V and C)
% Initialise everything. If dummy values are given, default values are
% used. If real values for V are given, they are used.
V = zeros(4,1);
load defaultvalues;
% Set up the base initial conditions
if prevH==9999
    %V(1) = 16;          % H (excluded later if ramp) %Original defaultval
    V(1)=defaultvals(Bio,1);
else
    V(1)=prevH;
end
if prevC==9999
    %V(2) = -.7;           % x %Original defaultval
    V(2) = defaultvals(Bio,2);
else
    V(2) = prevC;
end
if prevxc==9999
    %V(3) = 0;           % xc %Original defaultval
    V(3) = defaultvals(Bio,3);
else
    V(3) = prevxc;
end
if prevn==9999
    %V(4) = .03;        % n %Original defaultval
    V(4) = defaultvals(Bio,4);
else
    V(4)=prevn;
end
if prevstate==9999
    state=0;        %state. All biotypes gives sleep at midnight if normal day off
else    
    state = prevstate;
end

V = V(:,end);
[totalsleep,linth,H,x,n, Dv, shiftstate, xc] = runmodel(worktimes, shifttimes, Tfuture, V, Bio);
%nextstartstate
lastH=H(2401);
lastC=x(2401);
lastxc=xc(2401);
lastn=n(2401);
laststate=round(state(2401));


%Consider changing above when changing day

%To find default-values
% lastH=H(end);
% lastC=x(end);
% lastxc=xc(end);
% lastn=n(end);
% laststate=round(state(end));


%% Plot results
if plotting==0
else
    figure(plotting)
%     subplot(4,1,1)
%     plot(linth,H,'r')
%     xlabel('Time (h)')
%     ylabel('H-Drive')
%     title('H-Drive')
% %    set(gca, 'xtick', [0:24:xlim([0 size(roster,2)*24])]);
%     xlim([0 size(roster,2)*24])
%     
%     subplot(4,1,2)
%     plot(linth,x,'b')
%     xlabel('Time (h)')
%     ylabel('C-drive')
%     title('C-Drive')
%     set(gca, 'xtick', [0:24:size(roster,2)*24]);
%     xlim([0 size(roster,2)*24])
    
    %Plot alertness
    subplot(2,1,1)
    %plot(linth,Dv)
    plot(linth,Dv)
    title('Sleep drive')
    %ylim([-0.2 1.2])
    xlabel('Time (h)')
    ylabel('Fatigue')
    set(gca, 'xtick', [0:24:size(roster,2)*24]);
    xlim([0 size(roster,2)*24])
    
   %xlim([0 96])
    %set(gca, 'xtick', [24,48,72,96]);
    xt = [0,2.75+1*24,24,48, 50.75,72, 74.75,96];
   % set(gca, 'XTickLabel', []);
    
    
    
    nrxt = size(xt,2);
    latvct = linspace(71.59, 24.06, nrxt);
    lat_txt = {'','D','','','N','','N',''};%cellstr(strsplit(num2str(latvct,'%.2f '),' '));
    text([(xt(1)-xt(2))*0.5 xt], ones(1,nrxt+1)*2.13-0.05*1, [' ' lat_txt],'HorizontalAlignment','center')
    lngvct = linspace(100.71, 75.54, nrxt);

    
    subplot(2,1,2)
    %Plot time awake
    names = {'Sleeping';'Awake'; 'Working'; };
    plot(linth,shiftstate+state)
    set(gca,'ytick',[0:2],'yticklabel',names)
    title('Activity')
    ylim([-0.2 2.2])
    xlabel('Roster')
    set(gca, 'xtick', [12:24:size(roster,2)*24]);
    set(gca,'xticklabel',roster(1:end).')
    xlim([0 size(roster,2)*24])
    set(gca,'TickLength',[0,0])
end
%% Average wake clock time
% 
% activeangle = mod(linth, 24)*pi/12;
% vecsum = sum(awakestate.*exp(sqrt(-1)*activeangle));
% cob = 12/pi*angle(vecsum);
% mag = abs(vecsum)/length(linth);

end