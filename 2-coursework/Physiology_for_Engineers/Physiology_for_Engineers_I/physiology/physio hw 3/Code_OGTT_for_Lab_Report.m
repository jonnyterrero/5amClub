% ============================================================================
% GLUINSMODEL Simulation Code - Oral Glucose Tolerance Test (OGTT)
% ============================================================================
% This code simulates an OGTT with 75 gm glucose ingestion
% Same settings as normal adult (QL, β, ν) but with pulsed glucose injection
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

% Liver glucose production rate (same as normal adult)
qlBlock = find_system(mdl, 'Name', 'QL');
if ~isempty(qlBlock)
    set_param(qlBlock{1}, 'Value', '8400');  % 8400 mg/hr
end

% ============================================================================
% CONFIGURE PULSE GENERATOR FOR OGTT
% ============================================================================
% OGTT: 75 gm (7.5E4 mg) glucose ingested
% Rapidly absorbed (~30 min = 5% of 10 hours)
% Find and configure pulse generator
allBlocks = find_system(mdl, 'FindAll', 'on', 'Type', 'block');
for i = 1:length(allBlocks)
    try
        blockType = get_param(allBlocks(i), 'BlockType');
        if strcmp(blockType, 'PulseGenerator')
            % Set OGTT parameters
            set_param(allBlocks(i), 'Period', '10');        % 10 hours
            set_param(allBlocks(i), 'Amplitude', '7.5E4');  % 7.5E4 mg = 75 gm
            set_param(allBlocks(i), 'PulseWidth', '5');     % 5% = 30 minutes
            set_param(allBlocks(i), 'PhaseDelay', '0');     % Start immediately
            break;
        end
    catch
        % Skip if error
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

% Extract urine glucose (if available)
try
    urine_glucose = simOut.get('Ut');
catch
    % Try to find urine glucose with alternative name
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
% CALCULATE RETURN TIMES
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
% CREATE PLOTS
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
saveas(gcf, 'GLUINSMODEL_OGTT.png');

% ============================================================================
% DISPLAY RESULTS
% ============================================================================
fprintf('\n=== OGTT SIMULATION RESULTS ===\n');
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

