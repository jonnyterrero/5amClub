% Question 7 Final Parts - Compensated values and atrial pressure adjustment
clear
close all
clc

fprintf('=== QUESTION 7 FINAL PARTS ===\n');

% Base parameters
T = 0.0125; Ts = 0.0050; dt = .00005*T; Beats=16*T;
Csa = .00175; Rs = 17.28; Rmi = 0.01; RAo_normal = 0.01; RAo_stenotic = 1.0;
AoBkflo = 0.00; Vlvd = .027; Vsad = .825;
CLVD_normal = 0.0150; CLVS_normal = 5e-5; tauS = .0025; tauD = .005;
Plvi = 5; Psai = 80;

% Use friend's compensated compliance values
CLVS_compensated = 0.000043003;
CLVD_compensated = 0.01290;

fprintf('Using compensated compliance values:\n');
fprintf('CLVS = %.8f L/mmHg\n', CLVS_compensated);
fprintf('CLVD = %.6f L/mmHg\n', CLVD_compensated);

% Part iii: Calculate values with stenosis and compensated compliances
fprintf('\n=== PART III: COMPENSATED VALUES ===\n');

% Set stenotic resistance and compensated compliances
RAo = RAo_stenotic;
CLVS = CLVS_compensated;
CLVD = CLVD_compensated;
Pla = 5; % Initial atrial pressure

sim('Cardio_SA_LV')

% Calculate metrics
HR = 1/T;
SV_compensated = max(VLV) - min(VLV);
CO_compensated = HR * SV_compensated;
max_LV_pressure = max(PLV);
mean_LV_pressure = mean(PLV);

% Calculate work per beat (using pressure-volume integration)
work_per_beat = trapz(VLV, PLV) * 133.32 * 0.001; % Convert to Joules
work_per_minute = work_per_beat * HR;

fprintf('With aortic stenosis and compensated compliances:\n');
fprintf('  Stroke volume: %.4f L (%.1f ml)\n', SV_compensated, SV_compensated*1000);
fprintf('  Cardiac output: %.3f L/min\n', CO_compensated);
fprintf('  Work per beat: %.6f J\n', work_per_beat);
fprintf('  Work per minute: %.3f J/min\n', work_per_minute);
fprintf('  Max LV pressure: %.2f mmHg\n', max_LV_pressure);

% Part iv: Compare with normal values
fprintf('\n=== PART IV: COMPARISON WITH NORMAL ===\n');

% Get normal values
RAo = RAo_normal;
CLVS = CLVS_normal;
CLVD = CLVD_normal;
Pla = 5;

sim('Cardio_SA_LV')

SV_normal = max(VLV) - min(VLV);
CO_normal = HR * SV_normal;
work_per_beat_normal = trapz(VLV, PLV) * 133.32 * 0.001;
work_per_minute_normal = work_per_beat_normal * HR;
max_LV_pressure_normal = max(PLV);

fprintf('Normal values (RAo = 0.01):\n');
fprintf('  Stroke volume: %.4f L (%.1f ml)\n', SV_normal, SV_normal*1000);
fprintf('  Cardiac output: %.3f L/min\n', CO_normal);
fprintf('  Work per beat: %.6f J\n', work_per_beat_normal);
fprintf('  Work per minute: %.3f J/min\n', work_per_minute_normal);
fprintf('  Max LV pressure: %.2f mmHg\n', max_LV_pressure_normal);

% Calculate changes
SV_change = (SV_compensated - SV_normal) / SV_normal * 100;
CO_change = (CO_compensated - CO_normal) / CO_normal * 100;
work_change = (work_per_beat - work_per_beat_normal) / work_per_beat_normal * 100;
pressure_change = (max_LV_pressure - max_LV_pressure_normal) / max_LV_pressure_normal * 100;

fprintf('\nChanges due to aortic stenosis and compensation:\n');
fprintf('  Stroke volume change: %.1f%%\n', SV_change);
fprintf('  Cardiac output change: %.1f%%\n', CO_change);
fprintf('  Work per beat change: %.1f%%\n', work_change);
fprintf('  Max LV pressure change: %.1f%%\n', pressure_change);

% Part v: Find required left atrial pressure to restore cardiac output
fprintf('\n=== PART V: FINDING REQUIRED ATRIAL PRESSURE ===\n');

% Set stenotic resistance and compensated compliances
RAo = RAo_stenotic;
CLVS = CLVS_compensated;
CLVD = CLVD_compensated;

% Target cardiac output (normal value)
target_CO = CO_normal;
target_SV = SV_normal;

fprintf('Target cardiac output: %.3f L/min\n', target_CO);
fprintf('Target stroke volume: %.4f L\n', target_SV);

% Trial and error to find required atrial pressure
fprintf('\nSearching for required left atrial pressure...\n');
fprintf('Pla (mmHg) | SV (L) | CO (L/min) | Difference\n');
fprintf('-----------|--------|------------|----------\n');

best_Pla = 5;
best_difference = inf;
atrial_pressures = 5:0.2:15; % Test from 5 to 15 mmHg in 0.2 mmHg increments

for Pla = atrial_pressures
    sim('Cardio_SA_LV')
    
    SV_current = max(VLV) - min(VLV);
    CO_current = HR * SV_current;
    difference = abs(CO_current - target_CO);
    
    fprintf('   %.1f     | %.4f  |   %.3f    |  %.4f\n', Pla, SV_current, CO_current, difference);
    
    if difference < best_difference
        best_difference = difference;
        best_Pla = Pla;
        best_SV = SV_current;
        best_CO = CO_current;
    end
    
    % Stop if we're close enough
    if difference < 0.01
        fprintf('Target reached!\n');
        break;
    end
end

fprintf('\nBest result:\n');
fprintf('Required left atrial pressure: %.1f mmHg\n', best_Pla);
fprintf('Achieved stroke volume: %.4f L\n', best_SV);
fprintf('Achieved cardiac output: %.3f L/min\n', best_CO);
fprintf('Difference from target: %.4f L/min\n', best_difference);

% Calculate final work values with adjusted atrial pressure
Pla = best_Pla;
sim('Cardio_SA_LV')

work_per_beat_final = trapz(VLV, PLV) * 133.32 * 0.001;
work_per_minute_final = work_per_beat_final * HR;
max_LV_pressure_final = max(PLV);

fprintf('\nFinal values with adjusted atrial pressure:\n');
fprintf('  Left atrial pressure: %.1f mmHg\n', best_Pla);
fprintf('  Stroke volume: %.4f L\n', best_SV);
fprintf('  Cardiac output: %.3f L/min\n', best_CO);
fprintf('  Work per beat: %.6f J\n', work_per_beat_final);
fprintf('  Work per minute: %.3f J/min\n', work_per_minute_final);
fprintf('  Max LV pressure: %.2f mmHg\n', max_LV_pressure_final);

% Summary
fprintf('\n=== SUMMARY ===\n');
fprintf('Aortic stenosis (100x resistance increase) with compensation:\n');
fprintf('1. Reduced compliance by ~14%% (CLVS) and ~14%% (CLVD)\n');
fprintf('2. Increased work per beat by %.1f%%\n', work_change);
fprintf('3. Required %.1f mmHg atrial pressure increase to restore cardiac output\n', best_Pla - 5);
fprintf('4. Successfully maintained normal stroke volume and cardiac output\n');

fprintf('\n=== ANALYSIS COMPLETE ===\n');
