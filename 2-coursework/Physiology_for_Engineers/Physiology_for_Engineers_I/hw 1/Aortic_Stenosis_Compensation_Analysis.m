% Aortic Stenosis Compensation Analysis - Iterative Process
% This script analyzes the progressive compensation for aortic stenosis
clear
close all
clc

fprintf('=== AORTIC STENOSIS COMPENSATION ANALYSIS ===\n');
fprintf('Analyzing iterative compensation process for aortic stenosis\n\n');

% Base parameters
T = 0.0125;                      % Duration of heartbeat: min
Ts = 0.0050;                     % Duration of systole: min
dt = .00005*T;                   % Time step
Beats=16*T;                      % 16 heart beats displayed

% Base compliance and resistance parameters
Csa = .00175;  % Systemic arterial compliance: L/mmHg
Rs = 17.28;    % Systemic resistance: mmHg/(L/min)
Rmi = 0.01;    % Mitral valve resistance: mmHg/(L/min)
RAo_normal = 0.01;     % Normal aortic valve resistance: mmHg/(L/min)
RAo_stenotic = 1.0;    % Stenotic aortic valve resistance: mmHg/(L/min)
AoBkflo = 0.00;        % No back flow allowed
Vlvd = .027;           % Left ventricular volume when PLV=0 (ESV)
Vsad = .825;           % Systemic arterial volume when Psa=diastol
Pla = 5;               % Left atrial pressure: mmHg

% Normal compliance parameters
CLVD_normal = 0.0150;  % Normal max (diastolic) value of CLV: L/mmHg
CLVS_normal = 5e-5;    % Normal min (systolic) value of CLV: L/mmHg
tauS = .0025;          % CLV time constant during systole: min
tauD = .005;           % CLV time constant during diastole: min

% Initialization parameters
Plvi = 5;              % Initial value of Plv: mmHg
Psai = 80;             % Initial value of Psa: mmHg

fprintf('STEP 1: Calculate normal compliance constants\n');

% Step 1: Run with normal aortic valve to get baseline values
RAo = RAo_normal;
sim('Cardio_SA_LV')

% Get normal maximum LV pressure
max_LV_pressure_normal = max(PLV);
fprintf('Normal maximum LV pressure: %.2f mmHg\n', max_LV_pressure_normal);

% Calculate compliance constants
Ks = CLVS_normal * max_LV_pressure_normal;  % Systolic compliance constant
Kd = CLVD_normal * max_LV_pressure_normal;  % Diastolic compliance constant

fprintf('Compliance constants:\n');
fprintf('  Ks (systolic): %.6f\n', Ks);
fprintf('  Kd (diastolic): %.6f\n', Kd);

fprintf('\nSTEP 2: Iterative compensation process\n');
fprintf('Iteration | Max LV Pressure | CLVS (L/mmHg) | CLVD (L/mmHg) | Change (%%)\n');
fprintf('----------|-----------------|----------------|---------------|------------\n');

% Initialize variables for iteration
max_iterations = 20;
tolerance = 0.01;  % 1% tolerance for convergence
converged = false;

% Start with normal compliances
CLVS_current = CLVS_normal;
CLVD_current = CLVD_normal;
max_LV_pressure_previous = max_LV_pressure_normal;

% Store results for analysis
iteration_results = [];
iteration_results(1, :) = [0, max_LV_pressure_normal, CLVS_normal, CLVD_normal, 0];

for iteration = 1:max_iterations
    % Set aortic stenosis resistance
    RAo = RAo_stenotic;
    
    % Run simulation with current compliances
    sim('Cardio_SA_LV')
    
    % Get new maximum LV pressure
    max_LV_pressure_current = max(PLV);
    
    % Calculate new compliances based on new pressure
    CLVS_new = Ks / max_LV_pressure_current;
    CLVD_new = Kd / max_LV_pressure_current;
    
    % Calculate percentage change
    pressure_change = abs(max_LV_pressure_current - max_LV_pressure_previous) / max_LV_pressure_previous * 100;
    
    % Store results
    iteration_results(iteration + 1, :) = [iteration, max_LV_pressure_current, CLVS_new, CLVD_new, pressure_change];
    
    fprintf('    %2d     |     %8.2f     |   %10.6f   |  %10.6f   |   %6.2f\n', ...
        iteration, max_LV_pressure_current, CLVS_new, CLVD_new, pressure_change);
    
    % Check for convergence
    if pressure_change < tolerance
        converged = true;
        fprintf('\nConvergence achieved after %d iterations!\n', iteration);
        break;
    end
    
    % Update compliances for next iteration (with averaging for stability)
    CLVS_current = 0.7 * CLVS_current + 0.3 * CLVS_new;  % Weighted average
    CLVD_current = 0.7 * CLVD_current + 0.3 * CLVD_new;  % Weighted average
    
    % Update pressure for next comparison
    max_LV_pressure_previous = max_LV_pressure_current;
end

if ~converged
    fprintf('\nMaximum iterations reached. Process may not have fully converged.\n');
end

% Final analysis
fprintf('\nSTEP 3: Final compensation analysis\n');
fprintf('=====================================\n');

% Run final simulation with compensated values
RAo = RAo_stenotic;
sim('Cardio_SA_LV')

% Calculate final metrics
HR = 1/T;
stroke_volume_final = max(VLV) - min(VLV);
cardiac_output_final = HR * stroke_volume_final;
mean_LV_pressure = mean(PLV);
max_LV_pressure_final = max(PLV);

fprintf('FINAL COMPENSATED VALUES:\n');
fprintf('  Aortic resistance (RAo): %.3f mmHg/(L/min)\n', RAo_stenotic);
fprintf('  Final CLVS: %.6f L/mmHg (%.1f%% of normal)\n', CLVS_current, CLVS_current/CLVS_normal*100);
fprintf('  Final CLVD: %.6f L/mmHg (%.1f%% of normal)\n', CLVD_current, CLVD_current/CLVD_normal*100);
fprintf('  Maximum LV pressure: %.2f mmHg (%.1f%% increase)\n', max_LV_pressure_final, (max_LV_pressure_final/max_LV_pressure_normal-1)*100);
fprintf('  Stroke volume: %.3f L\n', stroke_volume_final);
fprintf('  Cardiac output: %.3f L/min\n', cardiac_output_final);

% Calculate atrial pressure compensation needed
% Higher atrial pressure needed to fill stiffer ventricle
atrial_pressure_increase = (CLVD_normal - CLVD_current) / CLVD_current * 100;
fprintf('  Estimated atrial pressure increase needed: %.1f%%\n', atrial_pressure_increase);

% Generate comparison plots
figure('color','white', 'Position', [100, 100, 1200, 800])

% Plot 1: Pressure evolution over iterations
subplot(2,2,1)
plot(iteration_results(:,1), iteration_results(:,2), 'o-', 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
title('Maximum LV Pressure vs Iterations', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Iteration Number')
ylabel('Maximum LV Pressure (mmHg)')
grid on

% Plot 2: Compliance evolution
subplot(2,2,2)
plot(iteration_results(:,1), iteration_results(:,3), 'o-', 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on
plot(iteration_results(:,1), iteration_results(:,4), 'o-', 'linewidth', 2, 'Color', [0.2, 0.8, 0.2])
title('Ventricular Compliance vs Iterations', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Iteration Number')
ylabel('Compliance (L/mmHg)')
legend('CLVS (Systolic)', 'CLVD (Diastolic)', 'Location', 'best')
grid on

% Plot 3: Pressure-volume loops comparison
subplot(2,2,3)
% Normal case
RAo = RAo_normal;
CLVS = CLVS_normal;
CLVD = CLVD_normal;
sim('Cardio_SA_LV')
plot(VLV, PLV, 'linewidth', 2, 'Color', [0.2, 0.6, 0.8])
hold on

% Stenotic case
RAo = RAo_stenotic;
CLVS = CLVS_current;
CLVD = CLVD_current;
sim('Cardio_SA_LV')
plot(VLV, PLV, 'linewidth', 2, 'Color', [0.8, 0.2, 0.2])
title('Pressure-Volume Loops: Normal vs Compensated Stenosis', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Ventricular Volume (L)')
ylabel('Ventricular Pressure (mmHg)')
legend('Normal', 'Compensated Stenosis', 'Location', 'best')
grid on

% Plot 4: Convergence analysis
subplot(2,2,4)
plot(iteration_results(2:end,1), iteration_results(2:end,5), 'o-', 'linewidth', 2, 'Color', [0.6, 0.2, 0.8])
title('Convergence Analysis', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Iteration Number')
ylabel('Pressure Change (%)')
grid on
ylim([0, max(iteration_results(2:end,5))*1.1])

fprintf('\n=== ANALYSIS COMPLETE ===\n');
fprintf('Aortic stenosis compensation analysis completed.\n');
