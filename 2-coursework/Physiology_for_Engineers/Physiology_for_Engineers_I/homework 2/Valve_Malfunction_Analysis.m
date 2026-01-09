% Valve Malfunction Analysis - Stenosis and Insufficiency
% This script analyzes the effects of valve resistance changes on cardiac function
clear
close all
clc

fprintf('=== VALVE MALFUNCTION ANALYSIS ===\n');
fprintf('Analyzing effects of stenosis (increased resistance) on cardiac function\n\n');

% Base parameters
T = 0.0125;                      % Duration of heartbeat: min
Ts = 0.0050;                     % Duration of systole: min
dt = .00005*T;                   % Time step
Beats=16*T;                      % 16 heart beats displayed

% Base compliance and resistance parameters
Csa = .00175;  % Systemic arterial compliance: L/mmHg
Rs = 17.28;    % Systemic resistance: mmHg/(L/min)
Rmi_base = 0.01;     % Base mitral valve resistance: mmHg/(L/min)
RAo_base = 0.01;     % Base aortic valve resistance: mmHg/(L/min)
AoBkflo = 0.00;      % No back flow allowed
Vlvd = .027;         % Left ventricular volume when PLV=0 (ESV)
Vsad = .825;         % Systemic arterial volume when Psa=diastol
Pla = 5;             % Left atrial pressure: mmHg

% Parameters for Clv(t)
CLVD = 0.0150;       % Max (diastolic) value of CLV: L/mmHg
CLVS = 5e-5;         % Min (systolic) value of CLV: L/mmHg
tauS = .0025;        % CLV time constant during systole: min
tauD = .005;         % CLV time constant during diastole: min

% Initialization parameters
Plvi = 5;            % Initial value of Plv: mmHg
Psai = 80;           % Initial value of Psa: mmHg

% Test different resistance values to simulate stenosis
resistance_multipliers = [1, 2, 5, 10, 20]; % 1x, 2x, 5x, 10x, 20x normal resistance

fprintf('Testing mitral valve stenosis (increased Rmi):\n');
fprintf('Resistance Multiplier | Rmi (mmHg/(L/min)) | Max Qmi (L/min) | Mean Qmi (L/min) | Cardiac Output (L/min)\n');
fprintf('---------------------|---------------------|-----------------|------------------|----------------------\n');

% Store results for plotting
results_mitral = [];
results_aortic = [];

% Test mitral valve stenosis
for i = 1:length(resistance_multipliers)
    Rmi = Rmi_base * resistance_multipliers(i);
    RAo = RAo_base; % Keep aortic resistance normal
    
    % Run simulation
    sim('Cardio_SA_LV')
    
    % Extract data
    t = BloodFlows.time;
    Qmi = BloodFlows.signals.values(:,1);
    QAo = BloodFlows.signals.values(:,2);
    
    % Calculate cardiac output
    HR = 1/T;
    stroke_volume = max(VLV) - min(VLV);
    cardiac_output = HR * stroke_volume;
    
    % Store results
    results_mitral(i, :) = [Rmi, max(Qmi), mean(Qmi), cardiac_output];
    
    fprintf('         %2.0fx         |      %8.3f      |    %8.3f    |     %8.3f     |        %8.3f\n', ...
        resistance_multipliers(i), Rmi, max(Qmi), mean(Qmi), cardiac_output);
end

fprintf('\nTesting aortic valve stenosis (increased RAo):\n');
fprintf('Resistance Multiplier | RAo (mmHg/(L/min)) | Max QAo (L/min) | Mean QAo (L/min) | Cardiac Output (L/min)\n');
fprintf('---------------------|---------------------|-----------------|------------------|----------------------\n');

% Test aortic valve stenosis
for i = 1:length(resistance_multipliers)
    Rmi = Rmi_base; % Keep mitral resistance normal
    RAo = RAo_base * resistance_multipliers(i);
    
    % Run simulation
    sim('Cardio_SA_LV')
    
    % Extract data
    t = BloodFlows.time;
    Qmi = BloodFlows.signals.values(:,1);
    QAo = BloodFlows.signals.values(:,2);
    
    % Calculate cardiac output
    HR = 1/T;
    stroke_volume = max(VLV) - min(VLV);
    cardiac_output = HR * stroke_volume;
    
    % Store results
    results_aortic(i, :) = [RAo, max(QAo), mean(QAo), cardiac_output];
    
    fprintf('         %2.0fx         |      %8.3f      |    %8.3f    |     %8.3f     |        %8.3f\n', ...
        resistance_multipliers(i), RAo, max(QAo), mean(QAo), cardiac_output);
end

% Generate comparison plots
figure('color','white', 'Position', [100, 100, 1200, 800])

% Plot 1: Mitral valve stenosis effects
subplot(2,2,1)
plot(resistance_multipliers, results_mitral(:,2), 'o-', 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
title('Mitral Valve Stenosis - Peak Flow', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Resistance Multiplier')
ylabel('Peak Mitral Flow (L/min)')
grid on

subplot(2,2,2)
plot(resistance_multipliers, results_mitral(:,4), 'o-', 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
title('Mitral Valve Stenosis - Cardiac Output', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Resistance Multiplier')
ylabel('Cardiac Output (L/min)')
grid on

% Plot 2: Aortic valve stenosis effects
subplot(2,2,3)
plot(resistance_multipliers, results_aortic(:,2), 'o-', 'linewidth', 2, 'Color', [0.2, 0.8, 0.2])
title('Aortic Valve Stenosis - Peak Flow', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Resistance Multiplier')
ylabel('Peak Aortic Flow (L/min)')
grid on

subplot(2,2,4)
plot(resistance_multipliers, results_aortic(:,4), 'o-', 'linewidth', 2, 'Color', [0.8, 0.4, 0.2])
title('Aortic Valve Stenosis - Cardiac Output', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Resistance Multiplier')
ylabel('Cardiac Output (L/min)')
grid on

% Analyze the effects
fprintf('\n=== ANALYSIS OF VALVE STENOSIS EFFECTS ===\n');

% Mitral stenosis analysis
mitral_flow_reduction = (results_mitral(1,2) - results_mitral(end,2)) / results_mitral(1,2) * 100;
mitral_co_reduction = (results_mitral(1,4) - results_mitral(end,4)) / results_mitral(1,4) * 100;

fprintf('MITRAL VALVE STENOSIS (20x resistance increase):\n');
fprintf('  Peak flow reduction: %.1f%%\n', mitral_flow_reduction);
fprintf('  Cardiac output reduction: %.1f%%\n', mitral_co_reduction);
fprintf('  Effect: Reduces ventricular filling, leading to decreased stroke volume\n');

% Aortic stenosis analysis
aortic_flow_reduction = (results_aortic(1,2) - results_aortic(end,2)) / results_aortic(1,2) * 100;
aortic_co_reduction = (results_aortic(1,4) - results_aortic(end,4)) / results_aortic(1,4) * 100;

fprintf('\nAORTIC VALVE STENOSIS (20x resistance increase):\n');
fprintf('  Peak flow reduction: %.1f%%\n', aortic_flow_reduction);
fprintf('  Cardiac output reduction: %.1f%%\n', aortic_co_reduction);
fprintf('  Effect: Increases afterload, reducing stroke volume and cardiac output\n');

% Demonstrate normal vs stenotic valve behavior
fprintf('\n=== NORMAL vs STENOTIC VALVE COMPARISON ===\n');

% Run normal case
Rmi = Rmi_base;
RAo = RAo_base;
sim('Cardio_SA_LV')
t_normal = BloodFlows.time;
Qmi_normal = BloodFlows.signals.values(:,1);
QAo_normal = BloodFlows.signals.values(:,2);

% Run severe mitral stenosis
Rmi = Rmi_base * 20;
RAo = RAo_base;
sim('Cardio_SA_LV')
Qmi_stenotic = BloodFlows.signals.values(:,1);

% Run severe aortic stenosis
Rmi = Rmi_base;
RAo = RAo_base * 20;
sim('Cardio_SA_LV')
QAo_stenotic = BloodFlows.signals.values(:,2);

% Create comparison plots
figure('color','white', 'Position', [200, 200, 1200, 600])

subplot(1,2,1)
plot(t_normal, Qmi_normal, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on
plot(t_normal, Qmi_stenotic, 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
title('Mitral Valve Flow: Normal vs Stenotic', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Flow (L/min)')
legend('Normal (Rmi=0.01)', 'Stenotic (Rmi=0.20)', 'Location', 'best')
grid on

subplot(1,2,2)
plot(t_normal, QAo_normal, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on
plot(t_normal, QAo_stenotic, 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
title('Aortic Valve Flow: Normal vs Stenotic', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (min)')
ylabel('Flow (L/min)')
legend('Normal (RAo=0.01)', 'Stenotic (RAo=0.20)', 'Location', 'best')
grid on

fprintf('\n=== ANALYSIS COMPLETE ===\n');
fprintf('Valve malfunction analysis completed.\n');
