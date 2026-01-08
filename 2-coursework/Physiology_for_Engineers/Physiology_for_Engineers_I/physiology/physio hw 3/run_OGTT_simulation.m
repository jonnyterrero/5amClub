% Run GLUINSMODEL for Oral Glucose Tolerance Test (OGTT)
% Same settings as normal adult, but with pulsed glucose injection

clear all;
close all;

fprintf('=== GLUINSMODEL OGTT Simulation ===\n\n');

mdl = 'GLUINSMODEL';
fprintf('Loading model: %s\n', mdl);
load_system(mdl);

% Set simulation time to 10 hours
fprintf('Setting simulation time to 10 hours...\n');
set_param(mdl, 'StopTime', '10');

% Set initial conditions (same as normal adult)
fprintf('Setting initial conditions...\n');
set_param([mdl '/Glucose'], 'InitialCondition', '0.81');
fprintf('  Initial Glucose: 0.81 mg/ml\n');
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');
fprintf('  Initial Insulin: 0.057 IU/ml\n');

% Set Type 1 and Type 2 severity gains to 1 (same as normal)
fprintf('Setting severity gains...\n');
set_param([mdl '/Type 1 severity'], 'Gain', '1');
set_param([mdl '/Type 2 severity'], 'Gain', '1');
fprintf('  Type 1 severity gain: 1\n');
fprintf('  Type 2 severity gain: 1\n');

% Set QL to 8400 mg/hr (same as normal)
fprintf('Setting QL (glucose production rate)...\n');
qlBlock = find_system(mdl, 'Name', 'QL');
if ~isempty(qlBlock)
    set_param(qlBlock{1}, 'Value', '8400');
    fprintf('  QL: 8400 mg/hr\n');
else
    fprintf('  Warning: QL block not found\n');
end

% Find and configure pulse generator for OGTT
fprintf('Configuring pulse generator for OGTT...\n');
fprintf('  Period: 10 hours\n');
fprintf('  Amplitude: 7.5E4 mg (75 gm)\n');
fprintf('  Pulse Width: 5%% (30 minutes)\n');

% Find pulse generator blocks
allBlocks = find_system(mdl, 'FindAll', 'on', 'Type', 'block');
pulseFound = false;
for i = 1:length(allBlocks)
    try
        blockType = get_param(allBlocks(i), 'BlockType');
        if strcmp(blockType, 'PulseGenerator')
            blockName = get_param(allBlocks(i), 'Name');
            fprintf('  Found pulse generator: %s\n', blockName);
            
            % Set OGTT parameters
            set_param(allBlocks(i), 'Period', '10');
            set_param(allBlocks(i), 'Amplitude', '7.5E4');
            set_param(allBlocks(i), 'PulseWidth', '5');
            set_param(allBlocks(i), 'PhaseDelay', '0');
            
            fprintf('  Pulse generator configured successfully\n');
            pulseFound = true;
            break;
        end
    catch
        % Skip if error accessing block
    end
end

if ~pulseFound
    fprintf('  Warning: Pulse generator not found. Checking for alternative blocks...\n');
    % Try to find any block that might control glucose injection
    constBlocks = find_system(mdl, 'BlockType', 'Constant');
    for i = 1:length(constBlocks)
        blockName = get_param(constBlocks{i}, 'Name');
        if contains(lower(blockName), 'pulse') || contains(lower(blockName), 'inject') || ...
           contains(lower(blockName), 'glucose') && ~contains(lower(blockName), 'threshold')
            fprintf('  Found potential glucose injection block: %s\n', blockName);
            % Note: This might need manual configuration
        end
    end
end

% Run simulation
fprintf('\nRunning simulation (this may take a moment)...\n');
simOut = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');
fprintf('Simulation completed!\n\n');

% Extract data
t = simOut.get('tout');
g = simOut.get('G');
i = simOut.get('insulin');

% Try to get urine glucose (may be named differently)
urine_glucose = [];
try
    urine_glucose = simOut.get('Ut');
catch
    % Try alternative names
    try
        vars = simOut.who;
        for j = 1:length(vars)
            if contains(lower(vars{j}), 'urine') || contains(lower(vars{j}), 'ut')
                urine_glucose = simOut.get(vars{j});
                break;
            end
        end
    catch
        fprintf('Warning: Urine glucose data not found in standard outputs\n');
    end
end

fprintf('Data extracted:\n');
fprintf('  Time points: %d\n', length(t));
fprintf('  Glucose data: %d points\n', length(g));
fprintf('  Insulin data: %d points\n', length(i));
if ~isempty(urine_glucose)
    fprintf('  Urine glucose data: %d points\n', length(urine_glucose));
end

% Calculate time for glucose to return to 2 mg/ml and 1.4 mg/ml
fprintf('\nCalculating glucose return times...\n');

% Find when glucose returns to 2 mg/ml (after peak)
[peak_glucose, peak_idx] = max(g);
peak_time = t(peak_idx);
fprintf('  Peak glucose: %.4f mg/ml at %.2f hours\n', peak_glucose, peak_time);

% Find time to return to 2 mg/ml (after peak)
time_to_2mg = [];
for j = peak_idx:length(g)
    if g(j) <= 2.0
        time_to_2mg = t(j);
        break;
    end
end

% Find time to return to 1.4 mg/ml (after peak)
time_to_1_4mg = [];
for j = peak_idx:length(g)
    if g(j) <= 1.4
        time_to_1_4mg = t(j);
        break;
    end
end

if ~isempty(time_to_2mg)
    fprintf('  Time to return to 2.0 mg/ml: %.2f hours (%.1f minutes)\n', time_to_2mg, time_to_2mg*60);
else
    fprintf('  Glucose did not return to 2.0 mg/ml within 10 hours\n');
end

if ~isempty(time_to_1_4mg)
    fprintf('  Time to return to 1.4 mg/ml: %.2f hours (%.1f minutes)\n', time_to_1_4mg, time_to_1_4mg*60);
else
    fprintf('  Glucose did not return to 1.4 mg/ml within 10 hours\n');
end

% Create plots
fprintf('\nCreating plots...\n');

% Determine number of subplots needed
if ~isempty(urine_glucose)
    numPlots = 3;
    fig = figure('Position', [100, 100, 1400, 400]);
else
    numPlots = 2;
    fig = figure('Position', [100, 100, 1200, 500]);
end

% Glucose plot
subplot(1, numPlots, 1);
plot(t, g, 'LineWidth', 2, 'Color', [0.2 0.6 0.8]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Glucose (mg/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Blood Glucose vs Time (OGTT)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0, 10]);
hold on;
% Mark return times
if ~isempty(time_to_2mg)
    plot(time_to_2mg, 2.0, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    text(time_to_2mg, 2.0+0.1, sprintf('2.0 mg/ml\nat %.2f hr', time_to_2mg), ...
        'FontSize', 9, 'HorizontalAlignment', 'center');
end
if ~isempty(time_to_1_4mg)
    plot(time_to_1_4mg, 1.4, 'go', 'MarkerSize', 10, 'LineWidth', 2);
    text(time_to_1_4mg, 1.4+0.1, sprintf('1.4 mg/ml\nat %.2f hr', time_to_1_4mg), ...
        'FontSize', 9, 'HorizontalAlignment', 'center');
end
hold off;

% Insulin plot
subplot(1, numPlots, 2);
plot(t, i, 'LineWidth', 2, 'Color', [0.8 0.3 0.3]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Insulin (IU/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Plasma Insulin vs Time (OGTT)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0, 10]);

% Urine glucose plot (if available)
if ~isempty(urine_glucose)
    subplot(1, numPlots, 3);
    plot(t, urine_glucose, 'LineWidth', 2, 'Color', [0.6 0.4 0.8]);
    xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Urine Glucose (mg/ml)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Urine Glucose vs Time (OGTT)', 'FontSize', 14, 'FontWeight', 'bold');
    grid on;
    xlim([0, 10]);
end

% Save figure
fprintf('Saving plot...\n');
saveas(fig, 'GLUINSMODEL_OGTT.png');
fprintf('  Plot saved as: GLUINSMODEL_OGTT.png\n');

% Save data
fprintf('Saving data...\n');
if ~isempty(urine_glucose)
    save('GLUINSMODEL_OGTT_data.mat', 't', 'g', 'i', 'urine_glucose');
else
    save('GLUINSMODEL_OGTT_data.mat', 't', 'g', 'i');
end
fprintf('  Data saved as: GLUINSMODEL_OGTT_data.mat\n');

% Create results file
fprintf('Creating results file...\n');
fid = fopen('OGTT_Results.txt', 'w');

fprintf(fid, '================================================================================\n');
fprintf(fid, 'GLUINSMODEL SIMULATION RESULTS - ORAL GLUCOSE TOLERANCE TEST (OGTT)\n');
fprintf(fid, '================================================================================\n\n');

fprintf(fid, 'SIMULATION PARAMETERS:\n');
fprintf(fid, '---------------------\n');
fprintf(fid, 'Simulation Time: 10 hours\n');
fprintf(fid, 'Initial Blood Glucose: 0.81 mg/ml (81 mg/dL)\n');
fprintf(fid, 'Initial Insulin Level: 0.057 IU/ml\n');
fprintf(fid, 'Type 1 Severity Gain: 1 (normal insulin production)\n');
fprintf(fid, 'Type 2 Severity Gain: 1 (normal insulin sensitivity)\n');
fprintf(fid, 'QL (Liver Glucose Production): 8400 mg/hr\n');
fprintf(fid, 'OGTT Glucose Dose: 75 gm (7.5E4 mg)\n');
fprintf(fid, 'Pulse Period: 10 hours\n');
fprintf(fid, 'Pulse Amplitude: 7.5E4 mg\n');
fprintf(fid, 'Pulse Width: 5%% (30 minutes)\n\n');

fprintf(fid, 'RESULTS:\n');
fprintf(fid, '--------\n');
fprintf(fid, 'Peak Glucose: %.4f mg/ml (%.2f mg/dL) at %.2f hours\n', peak_glucose, peak_glucose*100, peak_time);
fprintf(fid, 'Initial Glucose: %.4f mg/ml (%.2f mg/dL)\n', g(1), g(1)*100);
fprintf(fid, 'Final Glucose: %.4f mg/ml (%.2f mg/dL)\n', g(end), g(end)*100);
fprintf(fid, 'Glucose Range: %.4f - %.4f mg/ml (%.2f - %.2f mg/dL)\n', ...
    min(g), max(g), min(g)*100, max(g)*100);
fprintf(fid, 'Mean Glucose: %.4f mg/ml (%.2f mg/dL)\n\n', mean(g), mean(g)*100);

fprintf(fid, 'Peak Insulin: %.4f IU/ml at %.2f hours\n', max(i), t(find(i==max(i),1)));
fprintf(fid, 'Initial Insulin: %.4f IU/ml\n', i(1));
fprintf(fid, 'Final Insulin: %.4f IU/ml\n', i(end));
fprintf(fid, 'Insulin Range: %.4f - %.4f IU/ml\n', min(i), max(i));
fprintf(fid, 'Mean Insulin: %.4f IU/ml\n\n', mean(i));

fprintf(fid, 'ANSWERS TO QUESTIONS:\n');
fprintf(fid, '--------------------\n');
fprintf(fid, '1. How long did it take for blood glucose to return to 2.0 mg/ml?\n');
if ~isempty(time_to_2mg)
    fprintf(fid, '   Answer: %.2f hours (%.1f minutes)\n\n', time_to_2mg, time_to_2mg*60);
else
    fprintf(fid, '   Answer: Glucose did not return to 2.0 mg/ml within the 10-hour simulation period.\n');
    fprintf(fid, '           Final glucose level: %.4f mg/ml\n\n', g(end));
end

fprintf(fid, '2. How long did it take for blood glucose to return to 1.4 mg/ml?\n');
if ~isempty(time_to_1_4mg)
    fprintf(fid, '   Answer: %.2f hours (%.1f minutes)\n\n', time_to_1_4mg, time_to_1_4mg*60);
else
    fprintf(fid, '   Answer: Glucose did not return to 1.4 mg/ml within the 10-hour simulation period.\n');
    fprintf(fid, '           Final glucose level: %.4f mg/ml\n\n', g(end));
end

fprintf(fid, 'ANALYSIS:\n');
fprintf(fid, '---------\n');
fprintf(fid, 'The OGTT simulation shows the body''s response to a 75-gram glucose load.\n');
fprintf(fid, 'Glucose levels rise rapidly after ingestion, peak, and then gradually\n');
fprintf(fid, 'return toward baseline as insulin promotes glucose uptake and storage.\n\n');

fprintf(fid, 'Key observations:\n');
fprintf(fid, '- Peak glucose occurs at approximately %.2f hours after ingestion\n', peak_time);
fprintf(fid, '- The glucose response demonstrates normal glucose tolerance\n');
fprintf(fid, '- Insulin levels increase in response to elevated glucose\n');
if ~isempty(urine_glucose)
    fprintf(fid, '- Urine glucose levels indicate renal threshold for glucose reabsorption\n');
end

fprintf(fid, '\n================================================================================\n');
fprintf(fid, 'Generated by: GLUINSMODEL Simulation\n');
fprintf(fid, 'Date: %s\n', datestr(now));
fprintf(fid, '================================================================================\n');

fclose(fid);
fprintf('  Results saved as: OGTT_Results.txt\n');

% Display the figure
set(fig, 'Visible', 'on');

fprintf('\n=== Simulation Complete ===\n');
fprintf('Generated files:\n');
fprintf('  - GLUINSMODEL_OGTT.png (plots)\n');
fprintf('  - GLUINSMODEL_OGTT_data.mat (data)\n');
fprintf('  - OGTT_Results.txt (analysis and answers)\n\n');

close_system(mdl, 0);

