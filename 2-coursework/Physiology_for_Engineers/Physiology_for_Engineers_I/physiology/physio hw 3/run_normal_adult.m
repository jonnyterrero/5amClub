% Run GLUINSMODEL for normal adult conditions
% Simulation parameters:
% - Simulation time = 10 hr
% - Initial blood sugar = 0.81 mg/ml
% - Initial insulin level = 0.057 IU/ml
% - Type 1 severity gain = 1
% - Type 2 severity gain = 1
% - QL = 8400 mg/hr
% - Pulsed Glucose injection amplitude = 0

clear all;
close all;

mdl = 'GLUINSMODEL';
load_system(mdl);

% Set simulation time
set_param(mdl, 'StopTime', '10');

% Set initial conditions
set_param([mdl '/Glucose'], 'InitialCondition', '0.81');
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');

% Set Type 1 and Type 2 severity gains to 1
set_param([mdl '/Type 1 severity'], 'Gain', '1');
set_param([mdl '/Type 2 severity'], 'Gain', '1');

% Verify QL is set to 8400 (should already be correct)
% Find QL block (may have trailing space)
qlBlock = find_system(mdl, 'Name', 'QL');
if ~isempty(qlBlock)
    set_param(qlBlock{1}, 'Value', '8400');
    fprintf('QL set to 8400 mg/hr\n');
end

% Find and set pulsed glucose injection amplitude to 0
% Search for blocks that might control glucose injection
allBlocks = find_system(mdl, 'FindAll', 'on', 'Type', 'block');
for i = 1:length(allBlocks)
    blockName = get_param(allBlocks(i), 'Name');
    blockType = get_param(allBlocks(i), 'BlockType');
    
    % Check for pulse generator or constant blocks related to glucose injection
    if strcmp(blockType, 'PulseGenerator')
        % Set amplitude to 0
        set_param(allBlocks(i), 'Amplitude', '0');
        fprintf('Set %s amplitude to 0\n', blockName);
    elseif strcmp(blockType, 'Constant')
        % Check if this might be a glucose injection constant
        value = get_param(allBlocks(i), 'Value');
        if contains(lower(blockName), 'pulse') || contains(lower(blockName), 'inject') || ...
           contains(lower(blockName), 'glucose') && ~contains(lower(blockName), 'threshold')
            set_param(allBlocks(i), 'Value', '0');
            fprintf('Set %s value to 0\n', blockName);
        end
    end
end

% Run simulation
fprintf('Running simulation...\n');
simOut = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');

% Extract data
t = simOut.get('tout');
glucose = simOut.get('G');
insulin = simOut.get('insulin');

% Create plots
figure('Position', [100, 100, 1200, 500]);

% Glucose plot
subplot(1, 2, 1);
plot(t, glucose, 'LineWidth', 2, 'Color', [0.2 0.6 0.8]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Glucose (mg/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Blood Glucose vs Time (Normal Adult)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0, 10]);

% Insulin plot
subplot(1, 2, 2);
plot(t, insulin, 'LineWidth', 2, 'Color', [0.8 0.3 0.3]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Insulin (IU/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Plasma Insulin vs Time (Normal Adult)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0, 10]);

% Save figure
saveas(gcf, 'GLUINSMODEL_normal_adult.png');
fprintf('Plot saved as GLUINSMODEL_normal_adult.png\n');

% Save data
save('GLUINSMODEL_normal_adult_data.mat', 't', 'glucose', 'insulin');
fprintf('Data saved to GLUINSMODEL_normal_adult_data.mat\n');

% Display summary statistics
fprintf('\n=== Simulation Summary ===\n');
fprintf('Initial Glucose: %.4f mg/ml\n', glucose(1));
fprintf('Final Glucose: %.4f mg/ml\n', glucose(end));
fprintf('Initial Insulin: %.4f IU/ml\n', insulin(1));
fprintf('Final Insulin: %.4f IU/ml\n', insulin(end));
fprintf('Mean Glucose: %.4f mg/ml\n', mean(glucose));
fprintf('Mean Insulin: %.4f IU/ml\n', mean(insulin));

% Close model
close_system(mdl, 0);

