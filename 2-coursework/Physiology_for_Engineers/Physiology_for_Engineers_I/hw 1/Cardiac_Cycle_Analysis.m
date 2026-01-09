% Cardiac Cycle Analysis - Detailed examination of pressure-volume loop
clear
close all
clc

fprintf('=== CARDIAC CYCLE ANALYSIS ===\n');
fprintf('Analyzing pressure-volume loop and cardiac cycle phases\n\n');

% Run simulation first
fprintf('Running simulation...\n');

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

%Initialization parameters
Plvi = 5;         %Initial value of Plv: mmHg
Psai = 80;        %initial value of Psa: mmHg

% Run simulation
sim('Cardio_SA_LV')
fprintf('Simulation completed.\n\n');

% Extract time and data
t = BloodFlows.time;
Qmi = BloodFlows.signals.values(:,1);  % Mitral valve flow
QAo = BloodFlows.signals.values(:,2);  % Aortic valve flow

% Analyze cardiac cycle phases
fprintf('=== CARDIAC CYCLE ANALYSIS ===\n');

% Find end-diastolic and end-systolic points
[edv, edv_idx] = max(VLV);  % End-diastolic volume
[esv, esv_idx] = min(VLV);  % End-systolic volume
edp = PLV(edv_idx);  % End-diastolic pressure
esp = PLV(esv_idx);  % End-systolic pressure

fprintf('END-DIASTOLIC VALUES:\n');
fprintf('  Volume: %.3f L\n', edv);
fprintf('  Pressure: %.1f mmHg\n', edp);
fprintf('  Time: %.4f min (%.1f%% of cycle)\n', t(edv_idx), (t(edv_idx)/T)*100);

fprintf('\nEND-SYSTOLIC VALUES:\n');
fprintf('  Volume: %.3f L\n', esv);
fprintf('  Pressure: %.1f mmHg\n', esp);
fprintf('  Time: %.4f min (%.1f%% of cycle)\n', t(esv_idx), (t(esv_idx)/T)*100);

% Calculate stroke volume and cardiac output
stroke_volume = edv - esv;
heart_rate = 1/T;  % beats per minute
cardiac_output = heart_rate * stroke_volume;

fprintf('\nCARDIAC OUTPUT CALCULATION:\n');
fprintf('  Stroke volume: %.3f L/beat\n', stroke_volume);
fprintf('  Heart rate: %.1f beats/min\n', heart_rate);
fprintf('  Cardiac output: %.3f L/min\n', cardiac_output);
fprintf('  Formula: CO = HR × SV = %.1f × %.3f = %.3f L/min\n', heart_rate, stroke_volume, cardiac_output);

% Find valve opening and closing points
% Mitral valve: opens when Qmi > 0.01, closes when Qmi < 0.01
mitral_open_idx = find(Qmi > 0.01, 1, 'first');
mitral_close_idx = find(Qmi > 0.01, 1, 'last');

% Aortic valve: opens when QAo > 0.01, closes when QAo < 0.01
aortic_open_idx = find(QAo > 0.01, 1, 'first');
aortic_close_idx = find(QAo > 0.01, 1, 'last');

fprintf('\nVALVE TIMING:\n');
fprintf('  Mitral valve opens at: %.4f min (%.1f%% of cycle)\n', t(mitral_open_idx), (t(mitral_open_idx)/T)*100);
fprintf('  Mitral valve closes at: %.4f min (%.1f%% of cycle)\n', t(mitral_close_idx), (t(mitral_close_idx)/T)*100);
fprintf('  Aortic valve opens at: %.4f min (%.1f%% of cycle)\n', t(aortic_open_idx), (t(aortic_open_idx)/T)*100);
fprintf('  Aortic valve closes at: %.4f min (%.1f%% of cycle)\n', t(aortic_close_idx), (t(aortic_close_idx)/T)*100);

% Calculate work done by ventricle
% Work = ∫ P dV (integral of pressure times volume change)
% Convert mmHg to Pa: 1 mmHg = 133.32 Pa
% Convert L to m³: 1 L = 0.001 m³
% Work in Joules = ∫ P(Pa) × dV(m³)

% Calculate work using trapezoidal integration
work_per_cycle = trapz(VLV, PLV) * 133.32 * 0.001;  % Joules per cycle
work_per_minute = work_per_cycle * heart_rate;  % Joules per minute

fprintf('\nWORK CALCULATION:\n');
fprintf('  Work per cycle: %.6f J\n', work_per_cycle);
fprintf('  Work per minute: %.3f J/min\n', work_per_minute);
fprintf('  Formula: Work = ∫ P dV × 133.32 Pa/mmHg × 0.001 m³/L\n');

% Generate detailed cardiac cycle plot with annotations
figure('color','white', 'Position', [100, 100, 1200, 800])

% Plot 1: Pressure-Volume Loop with annotations
subplot(2,2,1)
plot(VLV, PLV, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on

% Mark key points
plot(edv, edp, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'red')
plot(esv, esp, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'green')

% Add annotations
text(edv+0.005, edp+5, 'EDV/EDP', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'red')
text(esv+0.005, esp+5, 'ESV/ESP', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'green')

title('Cardiac Cycle (Pressure-Volume Loop)', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Left Ventricular Volume (L)')
ylabel('Left Ventricular Pressure (mmHg)')
grid on
axis([0.01 max(VLV)+0.01 0 max(PLV)+10])

% Plot 2: Volume over time
subplot(2,2,2)
plot(t, VLV, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on
plot(t(edv_idx), edv, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'red')
plot(t(esv_idx), esv, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'green')
title('Ventricular Volume Over Time', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Volume (L)')
legend('Volume', 'EDV', 'ESV', 'Location', 'best')
grid on

% Plot 3: Pressure over time
subplot(2,2,3)
plot(t, PLV, 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
hold on
plot(t(edv_idx), edp, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'red')
plot(t(esv_idx), esp, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'green')
title('Ventricular Pressure Over Time', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Pressure (mmHg)')
legend('Pressure', 'EDP', 'ESP', 'Location', 'best')
grid on

% Plot 4: Valve flows with timing
subplot(2,2,4)
plot(t, Qmi, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on
plot(t, QAo, 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
plot(t(mitral_open_idx), Qmi(mitral_open_idx), 'ro', 'MarkerSize', 8)
plot(t(mitral_close_idx), Qmi(mitral_close_idx), 'ro', 'MarkerSize', 8)
plot(t(aortic_open_idx), QAo(aortic_open_idx), 'go', 'MarkerSize', 8)
plot(t(aortic_close_idx), QAo(aortic_close_idx), 'go', 'MarkerSize', 8)
title('Valve Flows with Opening/Closing Points', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Flow (L/min)')
legend('Mitral', 'Aortic', 'Mitral Open', 'Mitral Close', 'Aortic Open', 'Aortic Close', 'Location', 'best')
grid on

fprintf('\n=== ANALYSIS COMPLETE ===\n');
fprintf('Cardiac cycle analysis completed.\n');
