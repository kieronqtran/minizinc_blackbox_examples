%% Function for calling the model to obtain value for objective function, give a vector of forced wake times
% totalsleep = runmodel(trans,Tfuture,p)
% Function returns the objective function total sleep time.
% Required arguments are:
% - trans = list of transitions times we are adding (in addition to the work
% schedule)
% - Tfuture = number of days into future to solve
% - Vi = Initial values for variables
% - p = parameter values


function [totalsleep, linth, H, x, n,Dv, shiftstate, xc] = runmodel(worktimes, shifttimes, Tfuture, Vi, Bio)

mph=60;
hpd=24;
%oldparams
%;


if(Bio==0)
    oldparams
else
    oldparamswithoutbio
    if Bio<4
        pars(22) = (hpd/(0.99729*24.15))^2;% period of x, tauc is intrinsic period for DD conditions %tau default=24.15
    elseif Bio<7
        pars(22) = (hpd/(0.99729*(24.15-0.45)))^2;
    else
        pars(22) = (hpd/(0.99729*(24.15+0.45)))^2;
    end
    if mod(Bio,3)==1
         pars(3) = -4.70;         % D0/tauv  %default=-4.8
    elseif mod(Bio,3)==2
        pars(3) = -6.8;
    else
        pars(3) = -2.59;
    end
end
p = pars;

global state %waketimes %sleeptimes 

%waketimes = [worktimes];

%options=odeset;
options = odeset('RelTol',1e-9,'AbsTol',1e-9);%,'InitialSlope',prevdV
[t,V]=ode23(@hardswitchde3,[0;24*Tfuture*60],Vi,options,p,worktimes);
%We get Dv ------------------------------

%consts
hpd = 24; % hours per day
mph=60;
tauv = 10/mph;              % (min) time constant
taum = 10/mph;               % (min) time constant
kappainv = 2*pi/(hpd*mph);       % 1/kappa (min^{-1})
 
% % Define light level and photic drives
dawn = 6;
dusk = 18;
Imax = 1000;
state=[state,transpose(sign(diff(V(:,1)))>0.5)];
I = state.*transpose(40+Imax*(mod(t./60,24)>dawn).*(mod(t./60,24)<=dusk));
alpha = pars(25).* I.^(pars(27)+1)./(I+pars(28));
Bhat = (pars(26).* (1-V(:,4)) .* transpose(alpha));
B = Bhat .* (1-pars(29).*V(:,2)) .* (1-pars(29).*V(:,3));
Dv = (pars(4)*V(:,1) + pars(3) + pars(2)*(pars(10)*pars(11)*(V(:,2) + pars(12)) + pars(13)) + pars(14)*Bhat);

% We got Dv -----------------------------------

% Define the model variables
H = V(:,1); %homeostatic sleep drive (concentration of substance)
x = V(:,2); %SCN activity (dimensionless)
xc = V(:,3); %y (complementary variable) (dimensionless)
n = V(:,4); %fraction of activated photoreceptors (dimensionless)
th = t/60;% Time in hours


%% Interpolating
ts = 0.01;
linth = min(th):ts:max(th);
H = interp1(th,H,linth);
x = interp1(th,x,linth);
xc = interp1(th,xc,linth);
n = interp1(th,n,linth);
Dv = interp1(th,Dv,linth);
state = interp1(th,state,linth,'nearest');

%Determine if currently working a shift for plotting
B= (num2cell(linth));
shiftstate=cellfun(@(x) myfunction(shifttimes,x),B);


awakestate = 0.5*sign(diff(H))+0.5;
awakestate(end+1)=awakestate(end);

%output linth
totalsleep=sum(awakestate(2400*21:end)==0)*ts/21;

end

