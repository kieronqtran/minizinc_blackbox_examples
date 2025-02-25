function [Strt, End] = getnumberedshifthours(daystring,getreadyhrs,gettobedhrs)
    if(daystring==1)
        Strt=7-getreadyhrs;
        End=15+gettobedhrs;
    elseif(daystring==2)
        Strt=14.5-getreadyhrs;
        End=22.5+gettobedhrs;
    elseif(daystring==3)
        Strt=22-getreadyhrs;
        End=24+7.5+gettobedhrs;
    elseif(daystring==0)
        Strt=0;
        End=0;
    elseif (daystring==9999)
        Strt=-.0001;
        End=7.5+gettobedhrs;
    end
end