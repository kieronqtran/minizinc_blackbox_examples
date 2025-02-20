function [state] = consciousness(Dm,Dv)
%inputs are Dm and Dv
%state = 1 is awake, state = 0 is bistable, state = -1 is sleep

% col1 is Dm, col2 is upper branch of Dv and col3 is lower branch of Dv

highDv = 0.4758 + 0.8526*Dm + 0.4720*Dm^2 + 0.0394*Dm^3;
lowDv = 0.5520 + 0.8430*Dm - 0.1342*Dm^2 + 0.0113*Dm^3;
state = -1*(Dv>highDv) + 1*(lowDv>Dv) ;

%  if Dv>highDv
%      state = 0;
%  elseif (Dv>lowDv && Dv<highDv)
%          state = 0.5;
%  else 
%      state = 1;
%  end
end
