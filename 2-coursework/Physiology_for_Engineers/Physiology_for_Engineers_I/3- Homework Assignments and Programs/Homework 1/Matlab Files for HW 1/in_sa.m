%filename: in_sa.m  (initialization for the script sa)
T =0.0125 ;    %Duration of heartbeat (minutes)--> 80 beats/min
TS=0.4*T;    %Duration of systole   (minutes)
TMAX=0.16*T;  %Time at which flow is max (minutes)
QMAX=28;    %Max flow through aortic valve (liters/minute) - initial = 28
Rs=17.86;     %Systemic resistance (mmHg/(liter/minute)) - Normal= 17.86
Csa=0.00175;  %Systemic arterial compliance (liters/(mmHg)-initially 0.00175

dt=0.01*T;    %Time step duration (minutes)
        %This choice implies 100 timesteps per cardiac cycle.
klokmax=ceil(16*T/dt); %Total number of timesteps 
        %This choice implies simulation of 16 cardiac cycles.
Psa=0 ;         %Starting (diastolic) value of arterial pressure (mmHg)
%Any initial value is OK here; try some others.
%Initialize arrays to store data for plotting:
  t_plot=zeros(1,klokmax);
QAo_plot=zeros(1,klokmax);
Psa_plot=zeros(1,klokmax);
