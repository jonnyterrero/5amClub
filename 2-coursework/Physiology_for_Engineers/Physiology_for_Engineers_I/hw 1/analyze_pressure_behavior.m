% Analyze current pressure behavior to determine needed adjustments
clear
close all
clc

% Load the current parameters from the original file
%Time parameters 
T = 0.0125;                      %Duration of heartbeat: min
Ts = 0.0050;                     %Duration of systole: min       
dt = .00005*T;                   %This choice implies 20,000 timesteps 
                                 %per cardiac cycle
Beats=16*T;                      % 16 heart beats displayed
%Compliance and resistance parameters. Note that valve resistances are not
%supposed to be realistic, just small enough to be negligible
Csa = .00175;  %Systemic arterial compliance: L/mmHg, original=0.0175
Rs = 17.28;    %Systemic resistance: mmHg/(L/min) - initial value 17.28
Rmi =0.01;     %mitral valve resistance: mmHg/(L/min) - initial value 0.01
RAo =0.01;     %Aortic valve resistance: mmHg/(L/min)
AoBkflo=0.00;   % 1/Resistance to back flow in the aortic valve
               % Normally zero (1/infinity)- no back flow allowed
Vlvd = .027;   %Left ventricular volume when PLV=0 (ESV) 
Vsad = .825;   %Systemic arterial volume when Psa=diastol 
Pla = 5;       %Left atrial pressure:  mmHg Initially 5 mmHg

%Parameters for Clv(t)
CLVD =0.0150;     %Max (diastolic) value of CLV: L/mmHg Initially 0.0146 
CLVS = 5e-5;      %Min (systolic) value of CLV: L/mmHg initially 5e-5
tauS = .0025;     %CLV time constant during systole: min (0.0025)
tauD = .005;      %CLV time constant during diastole: min (0.001)

%Initialization parameters
Plvi = 5;         %Initial value of Plv: mmHg
Psai = 80;        %initial value of Psa: mmHg

% Run simulation
sim('Cardio_SA_LV')

% Analyze pressure behavior
t = BloodFlows.time;
final_time = max(t);
start_pressure = PSA(1);
end_pressure = PSA(end);

fprintf('Current pressure analysis:\n');
fprintf('Start pressure: %.2f mmHg\n', start_pressure);
fprintf('End pressure: %.2f mmHg\n', end_pressure);
fprintf('Pressure difference: %.2f mmHg\n', abs(end_pressure - start_pressure));

% Plot pressure over time to visualize the behavior
figure('color','white')
plot(t, PSA, 'linewidth', 2)
title('Current Systemic Arterial Pressure Behavior')
xlabel('Time')
ylabel('Pressure (mmHg)')
grid on

% Show the pressure values at the beginning and end
fprintf('\nFirst 10 pressure values: ');
fprintf('%.2f ', PSA(1:10));
fprintf('\nLast 10 pressure values: ');
fprintf('%.2f ', PSA(end-9:end));
fprintf('\n');
