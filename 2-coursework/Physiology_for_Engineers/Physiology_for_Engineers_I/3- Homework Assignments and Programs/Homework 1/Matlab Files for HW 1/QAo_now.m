function Q=QAo_now(t)
%filename: QAo_now.m
global T TS TMAX QMAX ;
    tc=rem(t,T);    % tc=time elapsed since 
                    % the beginning of the current cycle
                    % rem(t,T) is the remainder when t is divided
                    % by T
    if(tc<TS)       %SYSTOLE:
      if(tc<TMAX)   %BEFORE TIME OF MAXIMUM FLOW:
        Q=QMAX*tc/TMAX;
      else          %AFTER TIME OF PEAK FLOW:
        Q=QMAX*(TS-tc)/(TS-TMAX);
      end
    else            %DIASTOLE:
      Q=0;
    end

