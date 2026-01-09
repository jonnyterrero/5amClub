function Q = QAo_now(t, t_arrest, t_restart)
%filename: QAo_now.m
% Function to calculate aortic flow with cardiac arrest capability
% Inputs:
%   t - current time (minutes)
%   t_arrest - time when cardiac arrest begins (minutes)
%   t_restart - time when cardiac arrest ends (minutes)
% Output:
%   Q - aortic flow rate (L/min)

global T TS TMAX QMAX;

% Check if current time is within the cardiac arrest period
if t >= t_arrest && t <= t_restart
    Q = 0;  % No flow during cardiac arrest
    return;
end

% Normal cardiac cycle flow calculation
tc = rem(t, T);    % Time elapsed since beginning of current cycle
                   % rem(t,T) is the remainder when t is divided by T

if tc < TS         % SYSTOLE:
    if tc < TMAX   % BEFORE TIME OF MAXIMUM FLOW:
        Q = QMAX * tc / TMAX;
    else           % AFTER TIME OF PEAK FLOW:
        Q = QMAX * (TS - tc) / (TS - TMAX);
    end
else               % DIASTOLE:
    Q = 0;
end

end
