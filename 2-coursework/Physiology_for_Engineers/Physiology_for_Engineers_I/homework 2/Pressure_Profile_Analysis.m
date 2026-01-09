% Pressure Profile Analysis - Left Ventricle vs Systemic Arterial Pressure
clear
close all
clc

fprintf('=== PRESSURE PROFILE ANALYSIS ===\n');
fprintf('Comparing left ventricular and systemic arterial pressure profiles\n\n');

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

% Extract time and pressure data
t = BloodFlows.time;

% Analyze pressure profiles
fprintf('=== PRESSURE PROFILE ANALYSIS ===\n');

% Left ventricular pressure analysis
fprintf('LEFT VENTRICULAR PRESSURE (PLV):\n');
fprintf('  Maximum pressure: %.1f mmHg\n', max(PLV));
fprintf('  Minimum pressure: %.1f mmHg\n', min(PLV));
fprintf('  Pressure range: %.1f mmHg\n', max(PLV) - min(PLV));
fprintf('  Mean pressure: %.1f mmHg\n', mean(PLV));

% Systemic arterial pressure analysis
fprintf('\nSYSTEMIC ARTERIAL PRESSURE (PSA):\n');
fprintf('  Maximum pressure: %.1f mmHg\n', max(PSA));
fprintf('  Minimum pressure: %.1f mmHg\n', min(PSA));
fprintf('  Pressure range: %.1f mmHg\n', max(PSA) - min(PSA));
fprintf('  Mean pressure: %.1f mmHg\n', mean(PSA));

% Calculate pressure differences
fprintf('\nPRESSURE COMPARISON:\n');
fprintf('  LV max - PSA max: %.1f mmHg\n', max(PLV) - max(PSA));
fprintf('  LV min - PSA min: %.1f mmHg\n', min(PLV) - min(PSA));
fprintf('  LV range: %.1f mmHg\n', max(PLV) - min(PLV));
fprintf('  PSA range: %.1f mmHg\n', max(PSA) - min(PSA));

% Analyze diastolic pressures specifically
fprintf('\nDIASTOLIC PRESSURE ANALYSIS:\n');
fprintf('  LV diastolic pressure: %.1f mmHg\n', min(PLV));
fprintf('  PSA diastolic pressure: %.1f mmHg\n', min(PSA));
fprintf('  Diastolic pressure difference: %.1f mmHg\n', min(PSA) - min(PLV));

% Analyze systolic pressures
fprintf('\nSYSTOLIC PRESSURE ANALYSIS:\n');
fprintf('  LV systolic pressure: %.1f mmHg\n', max(PLV));
fprintf('  PSA systolic pressure: %.1f mmHg\n', max(PSA));
fprintf('  Systolic pressure difference: %.1f mmHg\n', max(PLV) - max(PSA));

% Find timing of pressure peaks and valleys
[~, lv_max_idx] = max(PLV);
[~, lv_min_idx] = min(PLV);
[~, psa_max_idx] = max(PSA);
[~, psa_min_idx] = min(PSA);

fprintf('\nTIMING ANALYSIS:\n');
fprintf('  LV pressure peak at: %.4f min (%.1f%% of cycle)\n', t(lv_max_idx), (t(lv_max_idx)/T)*100);
fprintf('  LV pressure minimum at: %.4f min (%.1f%% of cycle)\n', t(lv_min_idx), (t(lv_min_idx)/T)*100);
fprintf('  PSA pressure peak at: %.4f min (%.1f%% of cycle)\n', t(psa_max_idx), (t(psa_max_idx)/T)*100);
fprintf('  PSA pressure minimum at: %.4f min (%.1f%% of cycle)\n', t(psa_min_idx), (t(psa_min_idx)/T)*100);

% Calculate pressure variation coefficients
lv_cv = std(PLV) / mean(PLV) * 100;
psa_cv = std(PSA) / mean(PSA) * 100;

fprintf('\nPRESSURE VARIABILITY:\n');
fprintf('  LV coefficient of variation: %.1f%%\n', lv_cv);
fprintf('  PSA coefficient of variation: %.1f%%\n', psa_cv);

% Generate detailed pressure comparison plots
figure('color','white', 'Position', [100, 100, 1200, 800])

% Plot 1: Pressure profiles over time
subplot(2,2,1)
plot(t, PLV, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on
plot(t, PSA, 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
title('Pressure Profiles Over Time', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Pressure (mmHg)')
legend('Left Ventricular', 'Systemic Arterial', 'Location', 'best')
grid on

% Plot 2: Single cardiac cycle
subplot(2,2,2)
cycle_indices = 1:round(T/dt);
plot(t(cycle_indices), PLV(cycle_indices), 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on
plot(t(cycle_indices), PSA(cycle_indices), 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
title('Single Cardiac Cycle Pressures', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Pressure (mmHg)')
legend('Left Ventricular', 'Systemic Arterial', 'Location', 'best')
grid on

% Plot 3: Pressure difference
subplot(2,2,3)
pressure_diff = PLV - PSA;
plot(t, pressure_diff, 'linewidth', 2, 'Color', [0.6, 0.2, 0.8])
title('Pressure Difference (LV - Arterial)', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Pressure Difference (mmHg)')
grid on

% Plot 4: Pressure ranges comparison
subplot(2,2,4)
pressure_ranges = [max(PLV) - min(PLV), max(PSA) - min(PSA)];
bar([1, 2], pressure_ranges, 'FaceColor', [0.2, 0.8, 0.6])
title('Pressure Range Comparison', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Pressure Type')
ylabel('Pressure Range (mmHg)')
set(gca, 'XTickLabel', {'Left Ventricular', 'Systemic Arterial'})
grid on

fprintf('\n=== ANALYSIS COMPLETE ===\n');
fprintf('Pressure profile analysis completed.\n');

