% Test script to run the blood pressure simulation
clear all
close all
clc

% Run the main simulation
sa

% Display the results
fprintf('\n=== SIMULATION RESULTS ===\n');
fprintf('Current Compliance (Csa): %.4f L/mmHg\n', Csa);
fprintf('Systolic Pressure: %.1f mmHg\n', systolic_pressure);
fprintf('Diastolic Pressure: %.1f mmHg\n', diastolic_pressure);
fprintf('Cardiac Output: %.2f L/min\n', cardiac_output);

% Check if we need to adjust compliance
target_systolic = 120;
target_diastolic = 80;
systolic_error = abs(systolic_pressure - target_systolic);
diastolic_error = abs(diastolic_pressure - target_diastolic);

fprintf('\n=== TARGET ANALYSIS ===\n');
fprintf('Target: %.0f/%.0f mmHg\n', target_systolic, target_diastolic);
fprintf('Current: %.1f/%.1f mmHg\n', systolic_pressure, diastolic_pressure);
fprintf('Systolic Error: %.1f mmHg\n', systolic_error);
fprintf('Diastolic Error: %.1f mmHg\n', diastolic_error);

if systolic_error < 5 && diastolic_error < 5
    fprintf('✓ Blood pressure is within acceptable range!\n');
else
    fprintf('⚠ Blood pressure needs adjustment\n');
    if systolic_pressure > target_systolic || diastolic_pressure > target_diastolic
        fprintf('→ Consider INCREASING compliance (Csa)\n');
    else
        fprintf('→ Consider DECREASING compliance (Csa)\n');
    end
end
