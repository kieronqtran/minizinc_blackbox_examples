%Runs for three weeks without any work to stabilize default values.
Pattern={'O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O','O'};
worktimes=zeros(2,1);
%defaultvalues=zeros(9,4)
r_length=size(Pattern,2);
Bio=1:9;

for b=1:size(Bio,2)
    prevH=9999;
    prevC=9999;
    prevxc=9999;
    prevn=9999;
    prevstate=9999;
    workedN=0;

    [totalsleep, Dv, lastH, lastC, lastxc, lastn, laststate]=evalpatternwh(Pattern,0,prevH, prevC, prevxc, prevn, prevstate,workedN,b);

    defaultvals(b,:)=[lastH, lastC, lastxc, lastn];
    totalsleeps(b)=totalsleep;
    %[~,Dv_all(1,:),prevH, prevC, prevxc, prevn, prevstate,x_all(1,:)]=evalpatternwh(Pattern,0,0,0,0,9999,9999,9999,9999, b,0);
    
%     for t=1
%        timestamps=1+(t-1)*2400:t*2400;
%        [DaysWorstC(b,1,1,1,t),A]=max(x_all(1,timestamps),[],[2]);
%        logdefaultcircadianmax(b,t)=A;
%     end
    %defaultcircadianmax(b)=mean(logdefaultcircadianmax(b,22:49),2);
end
defaultvals