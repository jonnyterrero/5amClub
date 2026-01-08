% ============================================================================
% GLUINSMODEL Simulation Code - Normal Adult
% ============================================================================
% This code simulates glucose-insulin dynamics for a normal adult
% under fasting conditions for 10 hours.
% ============================================================================

clear all;
close all;

% Load the Simulink model
mdl = 'GLUINSMODEL';
load_system(mdl);

% ============================================================================
% SIMULATION PARAMETERS
% ============================================================================
% Simulation time: 10 hours
set_param(mdl, 'StopTime', '10');

% Initial conditions (fasting levels for normal adult)
set_param([mdl '/Glucose'], 'InitialCondition', '0.81');  % 0.81 mg/ml = 81 mg/dL
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');  % 0.057 IU/ml

% Severity gains (both = 1 for normal function)
set_param([mdl '/Type 1 severity'], 'Gain', '1');  % Normal insulin production
set_param([mdl '/Type 2 severity'], 'Gain', '1');  % Normal insulin sensitivity

% Liver glucose production rate (glycogenolysis)
qlBlock = find_system(mdl, 'Name', 'QL');
if ~isempty(qlBlock)
    set_param(qlBlock{1}, 'Value', '8400');  % 8400 mg/hr
end

% Pulsed glucose injection amplitude = 0 (fasting conditions)
% Note: Verify this setting in the Simulink model if a specific block exists

% ============================================================================
% RUN SIMULATION
% ============================================================================
simOut = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');

% Extract data
t = simOut.get('tout');      % Time vector (hours)
g = simOut.get('G');         % Glucose concentration (mg/ml)
i = simOut.get('insulin');   % Insulin concentration (IU/ml)

% ============================================================================
% CREATE PLOTS
% ============================================================================
figure('Position', [100, 100, 1200, 500]);

% Glucose plot
subplot(1, 2, 1);
plot(t, g, 'LineWidth', 2, 'Color', [0.2 0.6 0.8]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Glucose (mg/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Blood Glucose vs Time (Normal Adult)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0, 10]);

% Insulin plot
subplot(1, 2, 2);
plot(t, i, 'LineWidth', 2, 'Color', [0.8 0.3 0.3]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Insulin (IU/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Plasma Insulin vs Time (Normal Adult)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0, 10]);

% Save figure
saveas(gcf, 'GLUINSMODEL_normal_adult.png');

% ============================================================================
% CALCULATE STATISTICS
% ============================================================================
fprintf('\n=== SIMULATION RESULTS ===\n');
fprintf('Initial Glucose: %.4f mg/ml (%.2f mg/dL)\n', g(1), g(1)*100);
fprintf('Final Glucose: %.4f mg/ml (%.2f mg/dL)\n', g(end), g(end)*100);
fprintf('Glucose Change: %.4f mg/ml (%.2f%%) over 10 hours\n', ...
    g(end)-g(1), ((g(end)-g(1))/g(1))*100);
fprintf('Mean Glucose: %.4f mg/ml (%.2f mg/dL)\n\n', mean(g), mean(g)*100);

fprintf('Initial Insulin: %.4f IU/ml\n', i(1));
fprintf('Final Insulin: %.4f IU/ml\n', i(end));
fprintf('Insulin Change: %.4f IU/ml (%.2f%%) over 10 hours\n', ...
    i(end)-i(1), ((i(end)-i(1))/i(1))*100);
fprintf('Mean Insulin: %.4f IU/ml\n\n', mean(i));

% Close model
close_system(mdl, 0);

