% Script to run the blood pressure simulation and save results
clear all;
close all;
clc;

% Change to the Blood Pressure directory
cd('Blood Pressure');

% Run the main simulation
fprintf('Running blood pressure simulation...\n');
fprintf('=====================================\n');

% Capture the output by running sa.m
sa;

% Get the current figure
fig = gcf;

% Save the figure as an image
saveas(fig, '../simulation_results.png');

% Create a summary text file with results
fid = fopen('../simulation_summary.txt', 'w');

fprintf(fid, 'BLOOD PRESSURE SIMULATION RESULTS\n');
fprintf(fid, '=================================\n\n');

% Get the simulation parameters
global T TS TMAX QMAX Rs Csa dt;
fprintf(fid, 'SIMULATION PARAMETERS:\n');
fprintf(fid, 'Heart Rate: %.1f beats/min\n', 1/T);
fprintf(fid, 'Systolic Duration: %.4f minutes (%.1f%% of cycle)\n', TS, (TS/T)*100);
fprintf(fid, 'Max Flow Time: %.4f minutes\n', TMAX);
fprintf(fid, 'Max Aortic Flow: %.1f L/min\n', QMAX);
fprintf(fid, 'Systemic Resistance: %.2f mmHg/(L/min)\n', Rs);
fprintf(fid, 'Arterial Compliance: %.4f L/mmHg\n', Csa);
fprintf(fid, 'Time Step: %.6f minutes\n', dt);
fprintf(fid, '\n');

% Calculate and display blood pressure statistics
if exist('Psa_plot', 'var')
    max_pressure = max(Psa_plot);
    min_pressure = min(Psa_plot);
    mean_pressure = mean(Psa_plot);
    
    fprintf(fid, 'BLOOD PRESSURE RESULTS:\n');
    fprintf(fid, 'Systolic Pressure: %.1f mmHg\n', max_pressure);
    fprintf(fid, 'Diastolic Pressure: %.1f mmHg\n', min_pressure);
    fprintf(fid, 'Mean Arterial Pressure: %.1f mmHg\n', mean_pressure);
    fprintf(fid, 'Pulse Pressure: %.1f mmHg\n', max_pressure - min_pressure);
    fprintf(fid, '\n');
    
    % Check if we achieved target of 120/80
    if abs(max_pressure - 120) < 5 && abs(min_pressure - 80) < 5
        fprintf(fid, 'TARGET ACHIEVED: Blood pressure is close to 120/80 mmHg!\n');
    else
        fprintf(fid, 'NOTE: Blood pressure is not exactly 120/80 mmHg\n');
        fprintf(fid, 'Consider adjusting compliance (Csa) in in_sa.m\n');
    end
    fprintf(fid, '\n');
end

% Calculate and display cardiac output
if exist('QAo_plot', 'var')
    cycles_to_use = 4;
    cycle_length = round(T/dt);
    start_idx = length(QAo_plot) - cycles_to_use * cycle_length + 1;
    cardiac_output = mean(QAo_plot(start_idx:end));
    
    fprintf(fid, 'CARDIAC OUTPUT:\n');
    fprintf(fid, 'Cardiac Output: %.2f L/min\n', cardiac_output);
    fprintf(fid, '\n');
end

% Display compliance adjustment information
fprintf(fid, 'COMPLIANCE ADJUSTMENT NOTES:\n');
fprintf(fid, 'Current compliance: %.4f L/mmHg\n', Csa);
fprintf(fid, 'To increase blood pressure: DECREASE compliance (make arteries stiffer)\n');
fprintf(fid, 'To decrease blood pressure: INCREASE compliance (make arteries more flexible)\n');
fprintf(fid, '\n');

fprintf(fid, 'SIMULATION COMPLETED SUCCESSFULLY\n');
fprintf(fid, 'Results saved to: simulation_results.png\n');

fclose(fid);

% Display results in command window
fprintf('\nSimulation completed!\n');
fprintf('Results saved to:\n');
fprintf('- simulation_summary.txt (detailed results)\n');
fprintf('- simulation_results.png (plots)\n');

% Go back to parent directory
cd('..');
