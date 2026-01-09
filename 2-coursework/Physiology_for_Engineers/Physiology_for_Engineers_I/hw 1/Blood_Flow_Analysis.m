% Blood Flow Analysis - Detailed examination of valve flows
clear
close all
clc

fprintf('=== BLOOD FLOW ANALYSIS ===\n');
fprintf('Analyzing flows through aortic valve, mitral valve, and venous system\n\n');

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

% Extract time and flow data
t = BloodFlows.time;
Qmi = BloodFlows.signals.values(:,1);  % Mitral valve flow
QAo = BloodFlows.signals.values(:,2);  % Aortic valve flow
Qs = BloodFlows.signals.values(:,3);   % Venous flow

% Calculate time parameters
T = 0.0125;  % Duration of one cardiac cycle in minutes
dt = t(2) - t(1);  % Time step
num_cycles = length(t) / (T / dt);  % Number of complete cycles

fprintf('SIMULATION PARAMETERS:\n');
fprintf('Cardiac cycle duration: %.4f min (%.1f seconds)\n', T, T*60);
fprintf('Time step: %.6f min\n', dt);
fprintf('Total simulation time: %.3f min\n', max(t));
fprintf('Number of cardiac cycles: %.1f\n', num_cycles);
fprintf('\n');

% Analyze flow characteristics
fprintf('=== FLOW CHARACTERISTICS ===\n');

% Mitral valve analysis
fprintf('MITRAL VALVE FLOW (Qmi):\n');
fprintf('  Maximum flow: %.3f L/min\n', max(Qmi));
fprintf('  Minimum flow: %.3f L/min\n', min(Qmi));
fprintf('  Flow range: %.3f L/min\n', max(Qmi) - min(Qmi));

% Find when mitral flow starts and ends in one cycle
cycle_start = 1;
cycle_end = round(T / dt);
Qmi_cycle = Qmi(cycle_start:cycle_end);
t_cycle = t(cycle_start:cycle_end);

% Find flow periods for mitral valve
mitral_flow_indices = find(Qmi_cycle > 0.01);  % Flow > 0.01 L/min
if ~isempty(mitral_flow_indices)
    mitral_start_time = t_cycle(mitral_flow_indices(1));
    mitral_end_time = t_cycle(mitral_flow_indices(end));
    mitral_duration = mitral_end_time - mitral_start_time;
    fprintf('  Flow starts at: %.4f min (%.1f%% of cycle)\n', mitral_start_time, (mitral_start_time/T)*100);
    fprintf('  Flow ends at: %.4f min (%.1f%% of cycle)\n', mitral_end_time, (mitral_end_time/T)*100);
    fprintf('  Flow duration: %.4f min (%.1f%% of cycle)\n', mitral_duration, (mitral_duration/T)*100);
end

% Aortic valve analysis
fprintf('\nAORTIC VALVE FLOW (QAo):\n');
fprintf('  Maximum flow: %.3f L/min\n', max(QAo));
fprintf('  Minimum flow: %.3f L/min\n', min(QAo));
fprintf('  Flow range: %.3f L/min\n', max(QAo) - min(QAo));

% Find flow periods for aortic valve
QAo_cycle = QAo(cycle_start:cycle_end);
aortic_flow_indices = find(QAo_cycle > 0.01);  % Flow > 0.01 L/min
if ~isempty(aortic_flow_indices)
    aortic_start_time = t_cycle(aortic_flow_indices(1));
    aortic_end_time = t_cycle(aortic_flow_indices(end));
    aortic_duration = aortic_end_time - aortic_start_time;
    fprintf('  Flow starts at: %.4f min (%.1f%% of cycle)\n', aortic_start_time, (aortic_start_time/T)*100);
    fprintf('  Flow ends at: %.4f min (%.1f%% of cycle)\n', aortic_end_time, (aortic_end_time/T)*100);
    fprintf('  Flow duration: %.4f min (%.1f%% of cycle)\n', aortic_duration, (aortic_duration/T)*100);
end

% Venous flow analysis
fprintf('\nVENOUS FLOW (Qs):\n');
fprintf('  Maximum flow: %.3f L/min\n', max(Qs));
fprintf('  Minimum flow: %.3f L/min\n', min(Qs));
fprintf('  Flow range: %.3f L/min\n', max(Qs) - min(Qs));
fprintf('  Mean flow: %.3f L/min\n', mean(Qs));

% Venous flow is continuous, so duration is the entire cycle
fprintf('  Flow duration: %.4f min (100%% of cycle - continuous)\n', T);

fprintf('\n=== FLOW TIMING COMPARISON ===\n');
fprintf('MITRAL VALVE: Diastolic filling phase\n');
fprintf('AORTIC VALVE: Systolic ejection phase\n');
fprintf('VENOUS FLOW: Continuous throughout cycle\n');

% Calculate total flows per minute
fprintf('\n=== TOTAL FLOW CALCULATIONS ===\n');

% Method 1: Integration over time
total_mitral_flow = trapz(t, Qmi);  % Total flow in L over entire simulation
total_aortic_flow = trapz(t, QAo);
total_venous_flow = trapz(t, Qs);

% Convert to flow per minute
mitral_flow_per_min = total_mitral_flow / max(t);  % L/min
aortic_flow_per_min = total_aortic_flow / max(t);
venous_flow_per_min = total_venous_flow / max(t);

fprintf('TOTAL FLOWS PER MINUTE:\n');
fprintf('  Mitral valve: %.3f L/min\n', mitral_flow_per_min);
fprintf('  Aortic valve: %.3f L/min\n', aortic_flow_per_min);
fprintf('  Venous flow: %.3f L/min\n', venous_flow_per_min);

% Method 2: Average flow calculation
avg_mitral = mean(Qmi);
avg_aortic = mean(QAo);
avg_venous = mean(Qs);

fprintf('\nAVERAGE FLOWS:\n');
fprintf('  Mitral valve: %.3f L/min\n', avg_mitral);
fprintf('  Aortic valve: %.3f L/min\n', avg_aortic);
fprintf('  Venous flow: %.3f L/min\n', avg_venous);

% Calculate cardiac output
fprintf('\n=== CARDIAC OUTPUT CALCULATION ===\n');
heart_rate = 1/T;  % beats per minute
stroke_volume = max(VLV) - min(VLV);  % L per beat
cardiac_output = heart_rate * stroke_volume;  % L/min

fprintf('Heart rate: %.1f beats/min\n', heart_rate);
fprintf('Stroke volume: %.3f L/beat\n', stroke_volume);
fprintf('Cardiac output: %.3f L/min\n', cardiac_output);

% Generate detailed flow plots
figure('color','white', 'Position', [100, 100, 1200, 800])

% Plot 1: All flows over time
subplot(2,2,1)
plot(t, Qmi, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on
plot(t, QAo, 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
plot(t, Qs, 'linewidth', 2, 'Color', [0.2, 0.8, 0.2])
title('All Blood Flows Over Time', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Flow (L/min)')
legend('Mitral (Qmi)', 'Aortic (QAo)', 'Venous (Qs)', 'Location', 'best')
grid on

% Plot 2: Single cardiac cycle
subplot(2,2,2)
cycle_indices = 1:round(T/dt);
plot(t(cycle_indices), Qmi(cycle_indices), 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on
plot(t(cycle_indices), QAo(cycle_indices), 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
plot(t(cycle_indices), Qs(cycle_indices), 'linewidth', 2, 'Color', [0.2, 0.8, 0.2])
title('Single Cardiac Cycle Flows', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Flow (L/min)')
legend('Mitral (Qmi)', 'Aortic (QAo)', 'Venous (Qs)', 'Location', 'best')
grid on

% Plot 3: Flow timing comparison
subplot(2,2,3)
% Create binary flow indicators
mitral_binary = Qmi > 0.01;
aortic_binary = QAo > 0.01;
venous_binary = Qs > 0.01;

plot(t(cycle_indices), mitral_binary(cycle_indices), 'linewidth', 3, 'Color', [0.2, 0.6, 0.8])
hold on
plot(t(cycle_indices), aortic_binary(cycle_indices), 'linewidth', 3, 'Color', [0.8, 0.2, 0.2])
plot(t(cycle_indices), venous_binary(cycle_indices), 'linewidth', 3, 'Color', [0.2, 0.8, 0.2])
title('Flow Timing Comparison (Binary)', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Flow Present (1) or Absent (0)')
legend('Mitral', 'Aortic', 'Venous', 'Location', 'best')
grid on
ylim([-0.1, 1.1])

% Plot 4: Cumulative flow
subplot(2,2,4)
cumulative_mitral = cumtrapz(t, Qmi);
cumulative_aortic = cumtrapz(t, QAo);
cumulative_venous = cumtrapz(t, Qs);

plot(t, cumulative_mitral, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on
plot(t, cumulative_aortic, 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
plot(t, cumulative_venous, 'linewidth', 2, 'Color', [0.2, 0.8, 0.2])
title('Cumulative Flow Over Time', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Cumulative Flow (L)')
legend('Mitral', 'Aortic', 'Venous', 'Location', 'best')
grid on

fprintf('\n=== ANALYSIS COMPLETE ===\n');
fprintf('All flow calculations and plots generated.\n');
