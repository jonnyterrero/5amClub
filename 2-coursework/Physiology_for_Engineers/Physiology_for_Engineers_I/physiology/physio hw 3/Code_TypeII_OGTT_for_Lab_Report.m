% ============================================================================
% GLUINSMODEL Simulation Code - Type II Diabetes OGTT
% ============================================================================
% This code simulates an OGTT for a Type II diabetic patient
% Uses fasting glucose and insulin levels as initial conditions
% ============================================================================

clear all;
close all;

% Load the Simulink model
mdl = 'GLUINSMODEL';
load_system(mdl);

% ============================================================================
% STEP 1: DETERMINE FASTING LEVELS
% ============================================================================
% First run a simulation to get the fasting glucose and insulin levels
% for Type II diabetes

set_param(mdl, 'StopTime', '10');
set_param([mdl '/Glucose'], 'InitialCondition', '0.8');
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');
set_param([mdl '/Type 1 severity'], 'Gain', '0.6');  % Reduced insulin production
set_param([mdl '/Type 2 severity'], 'Gain', '0.4');  % Insulin resistance

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

% Run fasting simulation
simOut_fasting = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');
g_fasting = simOut_fasting.get('G');
i_fasting = simOut_fasting.get('insulin');

% Get final (fasting) values
fasting_glucose = g_fasting(end);
fasting_insulin = i_fasting(end);

fprintf('Fasting levels for Type II diabetes:\n');
fprintf('  Glucose: %.4f mg/ml (%.2f mg/dL)\n', fasting_glucose, fasting_glucose*100);
fprintf('  Insulin: %.4f IU/ml\n\n', fasting_insulin);

% ============================================================================
% STEP 2: CONFIGURE OGTT WITH FASTING LEVELS AS INITIAL CONDITIONS
% ============================================================================
set_param(mdl, 'StopTime', '10');

% Set initial conditions to fasting levels
set_param([mdl '/Glucose'], 'InitialCondition', num2str(fasting_glucose));
set_param([mdl '/Insulin'], 'InitialCondition', num2str(fasting_insulin));

% Keep Type II diabetes parameters
set_param([mdl '/Type 1 severity'], 'Gain', '0.6');
set_param([mdl '/Type 2 severity'], 'Gain', '0.4');

% QL remains at 8400 mg/hr
if ~isempty(qlBlock)
    set_param(qlBlock{1}, 'Value', '8400');
end

% Configure pulse generator for OGTT (75 gm glucose, 30 min absorption)
for i = 1:length(allBlocks)
    try
        bt = get_param(allBlocks(i), 'BlockType');
        if strcmp(bt, 'PulseGenerator')
            set_param(allBlocks(i), 'Period', '10');        % 10 hours
            set_param(allBlocks(i), 'Amplitude', '7.5E4');  % 7.5E4 mg = 75 gm
            set_param(allBlocks(i), 'PulseWidth', '5');     % 5% = 30 minutes
            set_param(allBlocks(i), 'PhaseDelay', '0');     % Start immediately
            break;
        end
    catch
    end
end

% ============================================================================
% STEP 3: RUN OGTT SIMULATION
% ============================================================================
simOut = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');

% Extract data
t = simOut.get('tout');
g = simOut.get('G');
i = simOut.get('insulin');

% Extract urine glucose (if available)
try
    urine_glucose = simOut.get('Ut');
catch
    vars = simOut.who;
    urine_glucose = [];
    for j = 1:length(vars)
        if contains(lower(vars{j}), 'urine') || contains(lower(vars{j}), 'ut')
            urine_glucose = simOut.get(vars{j});
            break;
        end
    end
end

% ============================================================================
% STEP 4: CALCULATE RETURN TIMES
% ============================================================================
% Find peak glucose
[peak_glucose, peak_idx] = max(g);
peak_time = t(peak_idx);

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

% ============================================================================
% STEP 5: CREATE PLOTS
% ============================================================================
if ~isempty(urine_glucose)
    fig = figure('Position', [100, 100, 1400, 400]);
    numPlots = 3;
else
    fig = figure('Position', [100, 100, 1200, 500]);
    numPlots = 2;
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
saveas(gcf, 'GLUINSMODEL_TypeII_OGTT.png');

% ============================================================================
% STEP 6: DISPLAY RESULTS
% ============================================================================
fprintf('\n=== TYPE II DIABETES OGTT RESULTS ===\n');
fprintf('Peak Glucose: %.4f mg/ml (%.2f mg/dL) at %.2f hours\n', ...
    peak_glucose, peak_glucose*100, peak_time);

fprintf('\nTime for glucose to return to 2.0 mg/ml: ');
if ~isempty(time_to_2mg)
    fprintf('%.2f hours (%.1f minutes)\n', time_to_2mg, time_to_2mg*60);
else
    fprintf('Not reached within 10 hours\n');
end

fprintf('Time for glucose to return to 1.4 mg/ml: ');
if ~isempty(time_to_1_4mg)
    fprintf('%.2f hours (%.1f minutes)\n', time_to_1_4mg, time_to_1_4mg*60);
else
    fprintf('Not reached within 10 hours\n');
end

% Close model
close_system(mdl, 0);

