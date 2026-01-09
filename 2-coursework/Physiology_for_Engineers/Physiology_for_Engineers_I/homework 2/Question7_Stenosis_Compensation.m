% Question 7: Aortic Stenosis Compensation Analysis
clear
close all
clc

% Base parameters
T = 0.0125; Ts = 0.0050; dt = .00005*T; Beats=16*T;
Csa = .00175; Rs = 17.28; Rmi = 0.01; RAo_normal = 0.01; RAo_stenotic = 1.0;
AoBkflo = 0.00; Vlvd = .027; Vsad = .825; Pla = 5;
CLVD_normal = 0.0150; CLVS_normal = 5e-5; tauS = .0025; tauD = .005;
Plvi = 5; Psai = 80;

fprintf('=== AORTIC STENOSIS COMPENSATION ANALYSIS ===\n\n');

% Step 1: Calculate normal compliance constants
fprintf('STEP 1: Calculate compliance constants from normal values\n');
RAo = RAo_normal;
sim('Cardio_SA_LV')
max_LV_pressure_normal = max(PLV);
Ks = CLVS_normal * max_LV_pressure_normal;
Kd = CLVD_normal * max_LV_pressure_normal;

fprintf('Normal maximum LV pressure: %.2f mmHg\n', max_LV_pressure_normal);
fprintf('Ks (systolic constant): %.6f\n', Ks);
fprintf('Kd (diastolic constant): %.6f\n', Kd);

% Step 2: Iterative compensation process
fprintf('\nSTEP 2: Iterative compensation process\n');
fprintf('Iteration | Max LV Pressure | CLVS | CLVD | Change\n');

% Initialize
CLVS_current = CLVS_normal;
CLVD_current = CLVD_normal;
max_LV_pressure_previous = max_LV_pressure_normal;

for iteration = 1:10
    % Set stenotic resistance
    RAo = RAo_stenotic;
    sim('Cardio_SA_LV')
    
    % Get new pressure
    max_LV_pressure_current = max(PLV);
    
    % Calculate new compliances
    CLVS_new = Ks / max_LV_pressure_current;
    CLVD_new = Kd / max_LV_pressure_current;
    
    % Calculate change
    pressure_change = abs(max_LV_pressure_current - max_LV_pressure_previous) / max_LV_pressure_previous * 100;
    
    fprintf('    %2d     |     %8.2f     | %.6f | %.6f | %.2f%%\n', ...
        iteration, max_LV_pressure_current, CLVS_new, CLVD_new, pressure_change);
    
    % Update compliances (with averaging)
    CLVS_current = 0.7 * CLVS_current + 0.3 * CLVS_new;
    CLVD_current = 0.7 * CLVD_current + 0.3 * CLVD_new;
    
    max_LV_pressure_previous = max_LV_pressure_current;
    
    % Check convergence
    if pressure_change < 1.0
        fprintf('Converged after %d iterations!\n', iteration);
        break;
    end
end

% Final analysis
fprintf('\nSTEP 3: Final compensated values\n');
RAo = RAo_stenotic;
sim('Cardio_SA_LV')
HR = 1/T;
SV_final = max(VLV) - min(VLV);
CO_final = HR * SV_final;

fprintf('Final CLVS: %.6f L/mmHg (%.1f%% of normal)\n', CLVS_current, CLVS_current/CLVS_normal*100);
fprintf('Final CLVD: %.6f L/mmHg (%.1f%% of normal)\n', CLVD_current, CLVD_current/CLVD_normal*100);
fprintf('Maximum LV pressure: %.2f mmHg\n', max(PLV));
fprintf('Stroke volume: %.3f L\n', SV_final);
fprintf('Cardiac output: %.3f L/min\n', CO_final);

% Calculate atrial pressure compensation
atrial_pressure_increase = (CLVD_normal - CLVD_current) / CLVD_current * 100;
fprintf('Atrial pressure increase needed: %.1f%%\n', atrial_pressure_increase);
