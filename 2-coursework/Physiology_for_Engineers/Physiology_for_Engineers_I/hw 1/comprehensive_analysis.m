% Comprehensive Analysis of LEFT HEART AND AORTA Model
% This script runs the simulation and generates all required plots and analysis

clear
close all
clc

fprintf('=== LEFT HEART AND AORTA MODEL ANALYSIS ===\n');
fprintf('Starting comprehensive analysis...\n\n');

%Time parameters 
T = 0.0125;                      %Duration of heartbeat: min
Ts = 0.0050;                     %Duration of systole: min       
dt = .00005*T;                   %This choice implies 20,000 timesteps 
                                 %per cardiac cycle
Beats=16*T;                      % 16 heart beats displayed

%Compliance and resistance parameters
Csa = .00175;  %Systemic arterial compliance: L/mmHg
Rs = 17.28;    %Systemic resistance: mmHg/(L/min)
Rmi =0.01;     %mitral valve resistance: mmHg/(L/min)
RAo =0.01;     %Aortic valve resistance: mmHg/(L/min)
AoBkflo=0.00;   % 1/Resistance to back flow in the aortic valve
Vlvd = .027;   %Left ventricular volume when PLV=0 (ESV) 
Vsad = .825;   %Systemic arterial volume when Psa=diastol 
Pla = 5;       %Left atrial pressure: mmHg

%Parameters for Clv(t)
CLVD =0.0150;     %Max (diastolic) value of CLV: L/mmHg
CLVS = 5e-5;      %Min (systolic) value of CLV: L/mmHg
tauS = .0025;     %CLV time constant during systole: min
tauD = .005;      %CLV time constant during diastole: min

%Initialization parameters - ADJUSTED for steady state
Plvi = 5;         %Initial value of Plv: mmHg
Psai = 80;        %initial value of Psa: mmHg

fprintf('Model Parameters:\n');
fprintf('Heart rate: %.1f beats/min\n', 1/T);
fprintf('Systole duration: %.3f min (%.1f%% of cycle)\n', Ts, (Ts/T)*100);
fprintf('Diastole duration: %.3f min (%.1f%% of cycle)\n', T-Ts, ((T-Ts)/T)*100);
fprintf('Time step: %.6f min\n', dt);
fprintf('Total simulation time: %.3f min (%.0f heartbeats)\n', Beats, Beats/T);
fprintf('\n');

% Run simulation
fprintf('Running Simulink simulation...\n');
sim('Cardio_SA_LV')
fprintf('Simulation completed.\n\n');

% Extract time vector and data
t = BloodFlows.time;
Qmi = BloodFlows.signals.values(:,1);  % Mitral valve flow
QAo = BloodFlows.signals.values(:,2);  % Aortic valve flow
Qs = BloodFlows.signals.values(:,3);  % Venous flow

% Analysis of pressure behavior
fprintf('=== PRESSURE ANALYSIS ===\n');
fprintf('Initial systemic arterial pressure: %.2f mmHg\n', PSA(1));
fprintf('Final systemic arterial pressure: %.2f mmHg\n', PSA(end));
fprintf('Pressure difference: %.2f mmHg\n', abs(PSA(end) - PSA(1)));
fprintf('Initial left ventricular pressure: %.2f mmHg\n', PLV(1));
fprintf('Final left ventricular pressure: %.2f mmHg\n', PLV(end));
fprintf('\n');

% Flow analysis
fprintf('=== FLOW ANALYSIS ===\n');
fprintf('Mitral valve flow - Max: %.3f L/min, Min: %.3f L/min\n', max(Qmi), min(Qmi));
fprintf('Aortic valve flow - Max: %.3f L/min, Min: %.3f L/min\n', max(QAo), min(QAo));
fprintf('Venous flow - Max: %.3f L/min, Min: %.3f L/min\n', max(Qs), min(Qs));
fprintf('\n');

% Compliance analysis
fprintf('=== VENTRICULAR COMPLIANCE ANALYSIS ===\n');
fprintf('Max compliance (diastolic): %.6f L/mmHg\n', max(CLV));
fprintf('Min compliance (systolic): %.6f L/mmHg\n', min(CLV));
fprintf('Compliance ratio (max/min): %.1f\n', max(CLV)/min(CLV));
fprintf('\n');

% Volume analysis
fprintf('=== VOLUME ANALYSIS ===\n');
fprintf('Left ventricular volume - Max: %.3f L, Min: %.3f L\n', max(VLV), min(VLV));
fprintf('Stroke volume: %.3f L\n', max(VLV) - min(VLV));
fprintf('Ejection fraction: %.1f%%\n', ((max(VLV) - min(VLV))/max(VLV))*100);
fprintf('Systemic arterial volume - Max: %.3f L, Min: %.3f L\n', max(VSA), min(VSA));
fprintf('\n');

% Generate all required plots
fprintf('Generating plots...\n');

% 1. Blood Flows
figure('color','white', 'Position', [100, 100, 800, 600])
subplot(3,1,1)
plot(t, Qmi, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
title('Mitral Valve Flow (Qmi)', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Flow (L/min)')
grid on

subplot(3,1,2)
plot(t, QAo, 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
title('Aortic Valve Flow (QAo)', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Flow (L/min)')
grid on

subplot(3,1,3)
plot(t, Qs, 'linewidth', 2, 'Color', [0.2, 0.8, 0.2])
title('Venous Flow (Qs)', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Flow (L/min)')
grid on
sgtitle('Blood Flows Through Heart Valves', 'FontSize', 16, 'FontWeight', 'bold')

% 2. Ventricular Compliance
figure('color','white', 'Position', [200, 200, 800, 400])
plot(t, CLV, 'linewidth', 2, 'Color', [0.6, 0.2, 0.8])
title('Ventricular Compliance Over Time', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Compliance (L/mmHg)')
grid on

% 3. Cardiac Cycle (Pressure-Volume Loop)
figure('color','white', 'Position', [300, 300, 800, 600])
plot(VLV, PLV, 'linewidth', 2, 'Color', [0.8, 0.4, 0.2])
title('Cardiac Cycle (Pressure-Volume Loop)', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Left Ventricular Volume (L)')
ylabel('Left Ventricular Pressure (mmHg)')
grid on
axis([0.01 max(VLV)+0.01 0 max(PLV)+10])

% 4. Pressure Measurements
figure('color','white', 'Position', [400, 400, 800, 600])
subplot(2,1,1)
plot(t, PLV, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
title('Left Ventricular Pressure', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Pressure (mmHg)')
grid on

subplot(2,1,2)
plot(t, PSA, 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
title('Systemic Arterial Pressure', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Pressure (mmHg)')
grid on
sgtitle('Pressure Measurements', 'FontSize', 16, 'FontWeight', 'bold')

% 5. Combined Pressure Plot
figure('color','white', 'Position', [500, 500, 800, 400])
plot(t, PSA, 'linewidth', 2, 'Color', [0.8, 0.2, 0.2]); 
hold on
plot(t, PLV, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
legend('Systemic Arterial Pressure', 'Left Ventricular Pressure', 'Location', 'best')
title('Systemic Arterial vs Left Ventricular Pressure', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Pressure (mmHg)')
grid on
axis([0 max(t) 0 max(PLV)+10])
hold off

% 6. Systemic Volume vs Pressure Relationship
figure('color','white', 'Position', [600, 600, 800, 400])
plot(VSA, PSA, 'linewidth', 2, 'Color', [0.2, 0.8, 0.6])
title('Systemic Arterial Volume vs Pressure Relationship', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Systemic Arterial Volume (L)')
ylabel('Systemic Arterial Pressure (mmHg)')
grid on

fprintf('All plots generated successfully!\n\n');

% Save workspace for further analysis
save('simulation_results.mat', 't', 'Qmi', 'QAo', 'Qs', 'PLV', 'PSA', 'CLV', 'VLV', 'VSA');

fprintf('=== ANALYSIS COMPLETE ===\n');
fprintf('Results saved to simulation_results.mat\n');
fprintf('All required plots have been generated.\n');

