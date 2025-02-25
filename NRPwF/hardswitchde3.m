function [dVdt] = hardswitchde3(t,V,pars,worktimes) 
global state%waketimes %sleeptimes 

%consts
hpd = 24; % hours per day
mph=60;
tauv = 10/mph;              % (min) time constant
taum = 10/mph;               % (min) time constant
kappainv = 2*pi/(hpd*mph);       % 1/kappa (min^{-1})

%% Define light level and photic drives
dawn = 6;
dusk = 18;
Imax = 1000;

I = state*(40+Imax*(mod(t/60,24)>dawn).*(mod(t/60,24)<=dusk));
alpha = pars(25)* I^(pars(27)+1)./(I+pars(28));
Bhat = (pars(26).* (1-V(4)) .* alpha);
B = Bhat .* (1-pars(29).*V(2)) .* (1-pars(29).*V(3));

%% Determining drive values

Dm =(pars(6) + pars(9)*(pars(10)*pars(11)*(V(2) + pars(12)) + pars(13)));
Dv=(pars(4)*V(1) + pars(3) + pars(2)*(pars(10)*pars(11)*(V(2) + pars(12)) + pars(13)) + pars(14)*Bhat);

%% Determining sleep/wake state

if t<0 % If in the past, use prior sleep history
    ;%state = 1-mod(sum(t>sleeptimes),2);

    %Check if t==0
else % If in the future, use applied sleep time constraints
    work = mod(sum(t>worktimes),2); % Determine whether currently at work
end

if work==1 % If currently forced to be awake
    state=1;
else % If not currently forced to be awake, model will solve to decide
    mstate = 0.5*(1+consciousness(Dm,Dv)); % Model state as function of Dm, Dv. 1=wake; 0.5=bistable; 0=sleep
    if state==0 % If currently asleep
        if mstate==1 % If in wake-only region, wake model up
            state=1;
        else
        end
    else % If currently awake
        if mstate==0 % If in sleep-only region, put model to sleep
            state=0;
        else
        end
    end
end


%% Define differential equations to solve (assuming hard switching between sleep/wake states)
dVdt = [...
(pars(7)*4.8*60*(state==1) - V(1))/pars(8);... % H
kappainv*((V(3) + B +  pars(24)*((state==1)+0.333)*(1-tanh(V(2)))+ pars(15)*(pars(16)*V(2) + pars(17)*V(2)^3 + pars(18)*V(2)^5) + pars(19)*V(2)^7)); ... % x  (circadian drive
kappainv*(B*(pars(20)*V(3) - pars(21)*V(2)) - V(2)*pars(22)); ... % xc
(alpha*(1-V(4)) - pars(23)*V(4))]; % n

end