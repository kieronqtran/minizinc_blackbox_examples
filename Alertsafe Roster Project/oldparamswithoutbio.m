%old params
	%% Sleep/wake switch parameters
	% ----- Parameters used by sleepde.m are stored in a vector -----
	

	pars(1)  = -2.1/(mph);  % connection strength/tau (mV/min) to VLPO from MA
    pars(2) = -.17/(mph);  % connection strength/tau (mV/min) to VLPO from DMH
   
	pars(4)  = 1.0;         % mu_vh (mV nM^{-1} min^{-1})
	pars(5)  = -1.8/(mph);  % connection strength/tau (mV/m) to MA from VLPO
	pars(6) = 1.3;      % average effect from cholinergic and other sources to MA(mV/min)
	pars(7) = 4.4/mph;            % mu (nM min)
	pars(8) = 45*mph;         % chi (min)
    pars(9) = .01/(mph);    % mu_md (mV s)
    pars(10) = 1;                % a
    pars(11) = 17*mph;           % k (min^{-1})
    pars(12) = 2.8;             % delta
    pars(13) = 4.8*mph;          % b (min^{-1})
    pars(14) = -0*880/(mph);  % muvb (masking effect of light on VLPO)          
 

%% Circadian parameter values

	% Parameters used by sleepde.m are stored in a vector. Parameter values
	% are from St. Hilaire et al. Addition of a non-photic component to a
	% light-based mathematical model the human circadian pacemaker, J.
	% Theor. Biol. (2007).

	pars(15) = 0.13;                 % oscillator stiffness
	pars(16) = 1/3;                  % c1
    pars(17) = 4/3;                  % c2
    pars(18) = 0;                    % c3
    pars(19) = -256/105;             % c4
    pars(20) = 1/3;                  % q
    pars(21) = -0.2;                 % h
    
	pars(23) = 0.007;                % beta (min^{-1})
    pars(24) = 1*0.032;              % rho
    
    %% Idrive parameter values
       pars(25) = 0.1/9500^0.5; %'C' constant in alpha, alpha0/(I0)^p
       pars(26) = 37; %'G' constant in Bhat
       pars(27) = 0.5; %'p' 
       pars(28) = 10; % I_1 (lux)
       pars(29) = 0.4; %modulation 'r' in paper
