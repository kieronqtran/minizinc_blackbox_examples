function [Strt, End] = getshifthours(daystring,getreadyhrs,gettobedhrs)
    if(strcmp(daystring,'D'))
        Strt=7-getreadyhrs;
        End=15+gettobedhrs;
    elseif(strcmp(daystring,'E'))
        Strt=14.5-getreadyhrs;
        End=22.5+gettobedhrs;
    elseif(strcmp(daystring,'N'))
        Strt=22-getreadyhrs;
        End=24+7.5+gettobedhrs;
    elseif(strcmp(daystring,'O'))
        Strt=0;
        End=0;
    elseif strcmp(daystring,'currentlynight')
        Strt=-.0001;
        End=7.5+gettobedhrs;
    end
end