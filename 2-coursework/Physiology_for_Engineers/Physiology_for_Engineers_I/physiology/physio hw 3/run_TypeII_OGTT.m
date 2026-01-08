% Run OGTT for Type II Diabetic Patient
% Uses fasting glucose and insulin levels from Type II diabetes simulation
% as initial conditions

clear all;
close all;

fprintf('=== GLUINSMODEL Type II Diabetes OGTT Simulation ===\n\n');

mdl = 'GLUINSMODEL';
fprintf('Loading model: %s\n', mdl);
load_system(mdl);

% First, get the fasting levels by running a quick Type II diabetes simulation
fprintf('Step 1: Determining fasting levels for Type II diabetes...\n');
set_param(mdl, 'StopTime', '10');
set_param([mdl '/Glucose'], 'InitialCondition', '0.8');
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');
set_param([mdl '/Type 1 severity'], 'Gain', '0.6');
set_param([mdl '/Type 2 severity'], 'Gain', '0.4');
qlBlock = find_system(mdl, 'Name', 'QL');
if ~isempty(qlBlock)
    set_param(qlBlock{1}, 'Value', '8400');
end

% Set pulse generator to 0 for fasting
allBlocks = find_system(mdl, 'FindAll', 'on', 'Type', 'block');
for i = 1:length(allBlocks)
    try
        bt = get_param(allBlocks(i), 'BlockType');
        if strcmp(bt, 'PulseGenerator')
            set_param(allBlocks(i), 'Amplitude', '0');
            break;
        end
    catch
    end
end

fprintf('Running fasting simulation to get baseline levels...\n');
simOut_fasting = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');
g_fasting = simOut_fasting.get('G');
i_fasting = simOut_fasting.get('insulin');

% Get final (fasting) values
fasting_glucose = g_fasting(end);
fasting_insulin = i_fasting(end);

fprintf('Fasting levels determined:\n');
fprintf('  Fasting Glucose: %.4f mg/ml (%.2f mg/dL)\n', fasting_glucose, fasting_glucose*100);
fprintf('  Fasting Insulin: %.4f IU/ml\n\n', fasting_insulin);

% Now configure for OGTT with Type II diabetes parameters
fprintf('Step 2: Configuring OGTT with Type II diabetes parameters...\n');
set_param(mdl, 'StopTime', '10');

% Set initial conditions to fasting levels
set_param([mdl '/Glucose'], 'InitialCondition', num2str(fasting_glucose));
fprintf('  Initial Glucose: %.4f mg/ml (%.2f mg/dL) [fasting level]\n', fasting_glucose, fasting_glucose*100);
set_param([mdl '/Insulin'], 'InitialCondition', num2str(fasting_insulin));
fprintf('  Initial Insulin: %.4f IU/ml [fasting level]\n', fasting_insulin);

% Keep Type II diabetes severity gains
set_param([mdl '/Type 1 severity'], 'Gain', '0.6');
set_param([mdl '/Type 2 severity'], 'Gain', '0.4');
fprintf('  Type 1 severity gain: 0.6 (reduced insulin production)\n');
fprintf('  Type 2 severity gain: 0.4 (insulin resistance)\n');

% QL remains at 8400 mg/hr
if ~isempty(qlBlock)
    set_param(qlBlock{1}, 'Value', '8400');
    fprintf('  QL: 8400 mg/hr\n');
end

% Configure pulse generator for OGTT
fprintf('Configuring pulse generator for OGTT...\n');
fprintf('  Period: 10 hours\n');
fprintf('  Amplitude: 7.5E4 mg (75 gm)\n');
fprintf('  Pulse Width: 5%% (30 minutes)\n');

for i = 1:length(allBlocks)
    try
        bt = get_param(allBlocks(i), 'BlockType');
        if strcmp(bt, 'PulseGenerator')
            set_param(allBlocks(i), 'Period', '10');
            set_param(allBlocks(i), 'Amplitude', '7.5E4');
            set_param(allBlocks(i), 'PulseWidth', '5');
            set_param(allBlocks(i), 'PhaseDelay', '0');
            fprintf('  Pulse generator configured successfully\n');
            break;
        end
    catch
    end
end

% Run OGTT simulation
fprintf('\nStep 3: Running OGTT simulation...\n');
simOut = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');
fprintf('Simulation completed!\n\n');

% Extract data
t = simOut.get('tout');
g = simOut.get('G');
i = simOut.get('insulin');

% Try to get urine glucose
urine_glucose = [];
try
    urine_glucose = simOut.get('Ut');
catch
    vars = simOut.who;
    for j = 1:length(vars)
        if contains(lower(vars{j}), 'urine') || contains(lower(vars{j}), 'ut')
            urine_glucose = simOut.get(vars{j});
            break;
        end
    end
end

fprintf('Data extracted:\n');
fprintf('  Time points: %d\n', length(t));
fprintf('  Glucose data: %d points\n', length(g));
fprintf('  Insulin data: %d points\n', length(i));
if ~isempty(urine_glucose)
    fprintf('  Urine glucose data: %d points\n', length(urine_glucose));
end

% Find peak glucose
[peak_glucose, peak_idx] = max(g);
peak_time = t(peak_idx);
fprintf('\nPeak glucose: %.4f mg/ml (%.2f mg/dL) at %.2f hours\n', peak_glucose, peak_glucose*100, peak_time);

% Calculate return times
fprintf('\nCalculating glucose return times...\n');

% Find time to return to 2.0 mg/ml (after peak)
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
    fprintf('  Final glucose: %.4f mg/ml\n', g(end));
end

if ~isempty(time_to_1_4mg)
    fprintf('  Time to return to 1.4 mg/ml: %.2f hours (%.1f minutes)\n', time_to_1_4mg, time_to_1_4mg*60);
else
    fprintf('  Glucose did not return to 1.4 mg/ml within 10 hours\n');
    fprintf('  Final glucose: %.4f mg/ml\n', g(end));
end

% Create plots
fprintf('\nCreating plots...\n');

if ~isempty(urine_glucose)
    numPlots = 3;
    fig = figure('Position', [100, 100, 1400, 400]);
else
    numPlots = 2;
    fig = figure('Position', [100, 100, 1200, 500]);
end

% Glucose plot
subplot(1, numPlots, 1);
plot(t, g, 'LineWidth', 2, 'Color', [0.8 0.2 0.2]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Glucose (mg/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Blood Glucose vs Time (Type II Diabetes OGTT)', 'FontSize', 14, 'FontWeight', 'bold');
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
plot(t, i, 'LineWidth', 2, 'Color', [0.6 0.2 0.8]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Insulin (IU/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Plasma Insulin vs Time (Type II Diabetes OGTT)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0, 10]);

% Urine glucose plot (if available)
if ~isempty(urine_glucose)
    subplot(1, numPlots, 3);
    plot(t, urine_glucose, 'LineWidth', 2, 'Color', [0.6 0.4 0.8]);
    xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Urine Glucose (mg/ml)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Urine Glucose vs Time (Type II Diabetes OGTT)', 'FontSize', 14, 'FontWeight', 'bold');
    grid on;
    xlim([0, 10]);
end

% Save figure
fprintf('Saving plot...\n');
saveas(fig, 'GLUINSMODEL_TypeII_OGTT.png');
fprintf('  Plot saved as: GLUINSMODEL_TypeII_OGTT.png\n');

% Save data
fprintf('Saving data...\n');
if ~isempty(urine_glucose)
    save('GLUINSMODEL_TypeII_OGTT_data.mat', 't', 'g', 'i', 'urine_glucose', 'fasting_glucose', 'fasting_insulin');
else
    save('GLUINSMODEL_TypeII_OGTT_data.mat', 't', 'g', 'i', 'fasting_glucose', 'fasting_insulin');
end
fprintf('  Data saved as: GLUINSMODEL_TypeII_OGTT_data.mat\n');

% Create results file
fprintf('Creating results file...\n');
fid = fopen('TypeII_OGTT_Results.txt', 'w');

fprintf(fid, '================================================================================\n');
fprintf(fid, 'GLUINSMODEL SIMULATION RESULTS - TYPE II DIABETES OGTT\n');
fprintf(fid, '================================================================================\n\n');

fprintf(fid, 'SIMULATION PARAMETERS:\n');
fprintf(fid, '---------------------\n');
fprintf(fid, 'Simulation Time: 10 hours\n');
fprintf(fid, 'Initial Blood Glucose: %.4f mg/ml (%.2f mg/dL) [fasting level from Type II diabetes]\n', ...
    fasting_glucose, fasting_glucose*100);
fprintf(fid, 'Initial Insulin Level: %.4f IU/ml [fasting level from Type II diabetes]\n', fasting_insulin);
fprintf(fid, 'Type 1 Severity Gain (Insulin Production): 0.6 (reduced - 60%% of normal)\n');
fprintf(fid, 'Type 2 Severity Gain (Insulin Sensitivity): 0.4 (insulin resistance - 40%% of normal)\n');
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
fprintf(fid, 'c. How long did it take for the blood sugar to return to 2.0 mg/ml?\n');
if ~isempty(time_to_2mg)
    fprintf(fid, '   Answer: %.2f hours (%.1f minutes)\n\n', time_to_2mg, time_to_2mg*60);
else
    fprintf(fid, '   Answer: Glucose did not return to 2.0 mg/ml within the 10-hour simulation period.\n');
    fprintf(fid, '           Final glucose level: %.4f mg/ml (%.2f mg/dL)\n\n', g(end), g(end)*100);
end

fprintf(fid, 'c. How long did it take for the blood sugar to return to 1.4 mg/ml?\n');
if ~isempty(time_to_1_4mg)
    fprintf(fid, '   Answer: %.2f hours (%.1f minutes)\n\n', time_to_1_4mg, time_to_1_4mg*60);
else
    fprintf(fid, '   Answer: Glucose did not return to 1.4 mg/ml within the 10-hour simulation period.\n');
    fprintf(fid, '           Final glucose level: %.4f mg/ml (%.2f mg/dL)\n\n', g(end), g(end)*100);
end

fprintf(fid, 'ANALYSIS:\n');
fprintf(fid, '---------\n');
fprintf(fid, 'The OGTT simulation for Type II diabetes shows impaired glucose tolerance.\n');
fprintf(fid, 'Compared to a normal individual:\n');
fprintf(fid, '- Peak glucose is higher due to reduced insulin production and insulin resistance\n');
fprintf(fid, '- Glucose clearance is slower, taking longer to return to baseline levels\n');
fprintf(fid, '- The combination of reduced insulin production (0.6) and insulin resistance (0.4)\n');
fprintf(fid, '  significantly impairs the body''s ability to handle a glucose load\n\n');

fprintf(fid, 'Key observations:\n');
fprintf(fid, '- Peak glucose occurs at approximately %.2f hours after ingestion\n', peak_time);
fprintf(fid, '- The glucose response demonstrates impaired glucose tolerance characteristic of Type II diabetes\n');
if ~isempty(time_to_2mg)
    fprintf(fid, '- Time to return to 2.0 mg/ml: %.2f hours\n', time_to_2mg);
end
if ~isempty(time_to_1_4mg)
    fprintf(fid, '- Time to return to 1.4 mg/ml: %.2f hours\n', time_to_1_4mg);
end
if isempty(time_to_2mg) || isempty(time_to_1_4mg)
    fprintf(fid, '- Glucose did not fully return to baseline within the 10-hour period,\n');
    fprintf(fid, '  indicating persistent hyperglycemia\n');
end

fprintf(fid, '\n================================================================================\n');
fprintf(fid, 'Generated by: GLUINSMODEL Simulation\n');
fprintf(fid, 'Date: %s\n', datestr(now));
fprintf(fid, '================================================================================\n');

fclose(fid);
fprintf('  Results saved as: TypeII_OGTT_Results.txt\n');

% Display the figure
set(fig, 'Visible', 'on');

fprintf('\n=== Simulation Complete ===\n');
fprintf('Generated files:\n');
fprintf('  - GLUINSMODEL_TypeII_OGTT.png (plots)\n');
fprintf('  - GLUINSMODEL_TypeII_OGTT_data.mat (data)\n');
fprintf('  - TypeII_OGTT_Results.txt (analysis and answers)\n\n');

close_system(mdl, 0);

