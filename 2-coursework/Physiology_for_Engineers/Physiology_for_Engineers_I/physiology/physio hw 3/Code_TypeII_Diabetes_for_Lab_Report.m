% ============================================================================
% GLUINSMODEL Simulation Code - Type II Diabetes
% ============================================================================
% This code simulates a Type II diabetic patient under fasting conditions
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

% Initial conditions for Type II diabetes
set_param([mdl '/Glucose'], 'InitialCondition', '0.8');  % 0.8 mg/ml = 80 mg/dL
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');  % 0.057 IU/ml

% Type II diabetes severity gains
set_param([mdl '/Type 1 severity'], 'Gain', '0.6');  % Reduced insulin production (60% of normal)
set_param([mdl '/Type 2 severity'], 'Gain', '0.4');  % Insulin resistance (40% sensitivity)

% Liver glucose production rate (same as normal)
qlBlock = find_system(mdl, 'Name', 'QL');
if ~isempty(qlBlock)
    set_param(qlBlock{1}, 'Value', '8400');  % 8400 mg/hr
end

% Set pulse generator amplitude to 0 (fasting conditions)
allBlocks = find_system(mdl, 'FindAll', 'on', 'Type', 'block');
for i = 1:length(allBlocks)
    try
        blockType = get_param(allBlocks(i), 'BlockType');
        if strcmp(blockType, 'PulseGenerator')
            set_param(allBlocks(i), 'Amplitude', '0');
            break;
        end
    catch
    end
end

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
plot(t, g, 'LineWidth', 2, 'Color', [0.8 0.2 0.2]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Glucose (mg/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Blood Glucose vs Time (Type II Diabetes)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0, 10]);
hold on;
% Mark initial and final values
plot(0, g(1), 'go', 'MarkerSize', 8, 'LineWidth', 2);
plot(10, g(end), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
text(0.5, g(1)+0.05, sprintf('Initial: %.2f', g(1)), 'FontSize', 9);
text(9, g(end)+0.05, sprintf('Final: %.2f', g(end)), 'FontSize', 9);
hold off;

% Insulin plot
subplot(1, 2, 2);
plot(t, i, 'LineWidth', 2, 'Color', [0.6 0.2 0.8]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Insulin (IU/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Plasma Insulin vs Time (Type II Diabetes)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0, 10]);
hold on;
% Mark initial and final values
plot(0, i(1), 'go', 'MarkerSize', 8, 'LineWidth', 2);
plot(10, i(end), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
text(0.5, i(1)+0.002, sprintf('Initial: %.4f', i(1)), 'FontSize', 9);
text(9, i(end)+0.002, sprintf('Final: %.4f', i(end)), 'FontSize', 9);
hold off;

% Save figure
saveas(gcf, 'GLUINSMODEL_TypeII_Diabetes.png');

% ============================================================================
% DISPLAY RESULTS
% ============================================================================
fprintf('\n=== TYPE II DIABETES SIMULATION RESULTS ===\n');
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

fprintf('FASTING LEVELS FOR TYPE II DIABETES:\n');
fprintf('Final Glucose (Fasting): %.4f mg/ml (%.2f mg/dL)\n', g(end), g(end)*100);
fprintf('Final Insulin (Fasting): %.4f IU/ml\n', i(end));
fprintf('These represent good approximations of the fasting levels for this Type II diabetic patient.\n\n');

% Close model
close_system(mdl, 0);

