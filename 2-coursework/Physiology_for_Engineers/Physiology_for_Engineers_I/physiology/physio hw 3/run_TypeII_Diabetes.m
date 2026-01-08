% Run GLUINSMODEL for Type II Diabetic Patient
% This script simulates a Type II diabetic under fasting conditions

clear all;
close all;

fprintf('=== GLUINSMODEL Type II Diabetes Simulation ===\n\n');

mdl = 'GLUINSMODEL';
fprintf('Loading model: %s\n', mdl);
load_system(mdl);

% Set simulation time to 10 hours
fprintf('Setting simulation time to 10 hours...\n');
set_param(mdl, 'StopTime', '10');

% Set initial conditions for Type II diabetes
fprintf('Setting initial conditions...\n');
set_param([mdl '/Glucose'], 'InitialCondition', '0.8');
fprintf('  Initial Glucose: 0.8 mg/ml (80 mg/dL)\n');
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');
fprintf('  Initial Insulin: 0.057 IU/ml\n');

% Set Type II diabetes severity gains
fprintf('Setting Type II diabetes severity gains...\n');
set_param([mdl '/Type 1 severity'], 'Gain', '0.6');
fprintf('  Type 1 severity gain (insulin production): 0.6 (reduced)\n');
set_param([mdl '/Type 2 severity'], 'Gain', '0.4');
fprintf('  Type 2 severity gain (insulin sensitivity): 0.4 (insulin resistance)\n');

% Set QL to 8400 mg/hr (same as normal)
fprintf('Setting QL (glucose production rate)...\n');
qlBlock = find_system(mdl, 'Name', 'QL');
if ~isempty(qlBlock)
    set_param(qlBlock{1}, 'Value', '8400');
    fprintf('  QL: 8400 mg/hr\n');
else
    fprintf('  Warning: QL block not found\n');
end

% Set pulse generator amplitude to 0 (fasting conditions)
fprintf('Setting pulse generator to 0 (fasting conditions)...\n');
allBlocks = find_system(mdl, 'FindAll', 'on', 'Type', 'block');
pulseFound = false;
for i = 1:length(allBlocks)
    try
        blockType = get_param(allBlocks(i), 'BlockType');
        if strcmp(blockType, 'PulseGenerator')
            blockName = get_param(allBlocks(i), 'Name');
            fprintf('  Found pulse generator: %s\n', blockName);
            
            % Set amplitude to 0
            set_param(allBlocks(i), 'Amplitude', '0');
            fprintf('  Pulse generator amplitude set to 0\n');
            pulseFound = true;
            break;
        end
    catch
        % Skip if error accessing block
    end
end

if ~pulseFound
    fprintf('  Warning: Pulse generator not found. Checking for alternative blocks...\n');
    % Try to find constant blocks that might control glucose injection
    constBlocks = find_system(mdl, 'BlockType', 'Constant');
    for i = 1:length(constBlocks)
        blockName = get_param(constBlocks{i}, 'Name');
        if contains(lower(blockName), 'pulse') || contains(lower(blockName), 'inject') || ...
           (contains(lower(blockName), 'glucose') && ~contains(lower(blockName), 'threshold'))
            fprintf('  Found potential glucose injection block: %s\n', blockName);
            set_param(constBlocks{i}, 'Value', '0');
            fprintf('  Set value to 0\n');
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

fprintf('Data extracted:\n');
fprintf('  Time points: %d\n', length(t));
fprintf('  Initial Glucose: %.4f mg/ml (%.2f mg/dL)\n', g(1), g(1)*100);
fprintf('  Final Glucose: %.4f mg/ml (%.2f mg/dL)\n', g(end), g(end)*100);
fprintf('  Initial Insulin: %.4f IU/ml\n', i(1));
fprintf('  Final Insulin: %.4f IU/ml\n', i(end));
fprintf('  Mean Glucose: %.4f mg/ml (%.2f mg/dL)\n', mean(g), mean(g)*100);
fprintf('  Mean Insulin: %.4f IU/ml\n', mean(i));

% Calculate additional statistics
glucose_range = [min(g), max(g)];
insulin_range = [min(i), max(i)];
glucose_change = g(end) - g(1);
insulin_change = i(end) - i(1);
glucose_change_pct = (glucose_change / g(1)) * 100;
insulin_change_pct = (insulin_change / i(1)) * 100;

% Create plots
fprintf('\nCreating plots...\n');
fig = figure('Position', [100, 100, 1200, 500]);

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
text(0.5, g(1)+0.05, sprintf('Initial: %.2f mg/ml', g(1)), 'FontSize', 9);
text(9, g(end)+0.05, sprintf('Final: %.2f mg/ml', g(end)), 'FontSize', 9);
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
text(0.5, i(1)+0.002, sprintf('Initial: %.4f IU/ml', i(1)), 'FontSize', 9);
text(9, i(end)+0.002, sprintf('Final: %.4f IU/ml', i(end)), 'FontSize', 9);
hold off;

% Save figure
fprintf('Saving plot...\n');
saveas(fig, 'GLUINSMODEL_TypeII_Diabetes.png');
fprintf('  Plot saved as: GLUINSMODEL_TypeII_Diabetes.png\n');

% Save data
fprintf('Saving data...\n');
save('GLUINSMODEL_TypeII_Diabetes_data.mat', 't', 'g', 'i');
fprintf('  Data saved as: GLUINSMODEL_TypeII_Diabetes_data.mat\n');

% Create results file
fprintf('Creating results file...\n');
fid = fopen('TypeII_Diabetes_Results.txt', 'w');

fprintf(fid, '================================================================================\n');
fprintf(fid, 'GLUINSMODEL SIMULATION RESULTS - TYPE II DIABETES\n');
fprintf(fid, '================================================================================\n\n');

fprintf(fid, 'SIMULATION PARAMETERS:\n');
fprintf(fid, '---------------------\n');
fprintf(fid, 'Simulation Time: 10 hours\n');
fprintf(fid, 'Initial Blood Glucose: 0.8 mg/ml (80 mg/dL)\n');
fprintf(fid, 'Initial Insulin Level: 0.057 IU/ml\n');
fprintf(fid, 'Type 1 Severity Gain (Insulin Production): 0.6 (reduced - 60%% of normal)\n');
fprintf(fid, 'Type 2 Severity Gain (Insulin Sensitivity): 0.4 (insulin resistance - 40%% of normal)\n');
fprintf(fid, 'QL (Liver Glucose Production): 8400 mg/hr\n');
fprintf(fid, 'Pulsed Glucose Injection Amplitude: 0 (fasting conditions)\n\n');

fprintf(fid, 'RESULTS:\n');
fprintf(fid, '--------\n');
fprintf(fid, 'Initial Glucose: %.4f mg/ml (%.2f mg/dL)\n', g(1), g(1)*100);
fprintf(fid, 'Final Glucose: %.4f mg/ml (%.2f mg/dL)\n', g(end), g(end)*100);
fprintf(fid, 'Glucose Change: %.4f mg/ml (%.2f%%) over 10 hours\n', glucose_change, glucose_change_pct);
fprintf(fid, 'Glucose Range: %.4f - %.4f mg/ml (%.2f - %.2f mg/dL)\n', ...
    glucose_range(1), glucose_range(2), glucose_range(1)*100, glucose_range(2)*100);
fprintf(fid, 'Mean Glucose: %.4f mg/ml (%.2f mg/dL)\n\n', mean(g), mean(g)*100);

fprintf(fid, 'Initial Insulin: %.4f IU/ml\n', i(1));
fprintf(fid, 'Final Insulin: %.4f IU/ml\n', i(end));
fprintf(fid, 'Insulin Change: %.4f IU/ml (%.2f%%) over 10 hours\n', insulin_change, insulin_change_pct);
fprintf(fid, 'Insulin Range: %.4f - %.4f IU/ml\n', insulin_range(1), insulin_range(2));
fprintf(fid, 'Mean Insulin: %.4f IU/ml\n\n', mean(i));

fprintf(fid, 'FASTING LEVELS FOR TYPE II DIABETES:\n');
fprintf(fid, '------------------------------------\n');
fprintf(fid, 'The final glucose and insulin levels after 10 hours of fasting represent\n');
fprintf(fid, 'good approximations of the fasting levels for this Type II diabetic patient:\n\n');
fprintf(fid, 'Fasting Blood Glucose: %.4f mg/ml (%.2f mg/dL)\n', g(end), g(end)*100);
fprintf(fid, 'Fasting Plasma Insulin: %.4f IU/ml\n\n', i(end));

fprintf(fid, 'ANALYSIS AND INTERPRETATION:\n');
fprintf(fid, '----------------------------\n');
fprintf(fid, '1. Type II Diabetes Characteristics:\n');
fprintf(fid, '   - Reduced insulin production (Type 1 gain = 0.6): The beta cells\n');
fprintf(fid, '     produce only 60%% of normal insulin levels.\n');
fprintf(fid, '   - Insulin resistance (Type 2 gain = 0.4): The body''s cells are only\n');
fprintf(fid, '     40%% as sensitive to insulin as normal, requiring more insulin\n');
fprintf(fid, '     to achieve the same glucose uptake.\n\n');

fprintf(fid, '2. Glucose Homeostasis:\n');
if g(end) > 1.0
    fprintf(fid, '   The final fasting glucose level (%.2f mg/dL) is elevated compared\n', g(end)*100);
    fprintf(fid, '   to normal fasting levels (70-100 mg/dL), which is characteristic\n');
    fprintf(fid, '   of Type II diabetes. This reflects the impaired glucose regulation\n');
    fprintf(fid, '   due to both reduced insulin production and insulin resistance.\n\n');
else
    fprintf(fid, '   Glucose levels show the effects of impaired insulin function.\n\n');
end

fprintf(fid, '3. Insulin Levels:\n');
fprintf(fid, '   Despite reduced insulin production capacity, the final insulin level\n');
fprintf(fid, '   (%.4f IU/ml) may be elevated compared to normal due to compensatory\n', i(end));
fprintf(fid, '   mechanisms or may be reduced depending on the severity of beta cell\n');
fprintf(fid, '   dysfunction. The combination of reduced production and insulin\n');
fprintf(fid, '   resistance creates a challenging metabolic state.\n\n');

fprintf(fid, '4. Comparison with Normal Adult:\n');
fprintf(fid, '   Compared to the normal adult simulation:\n');
fprintf(fid, '   - Glucose levels are typically higher in Type II diabetes\n');
fprintf(fid, '   - The glucose-insulin regulatory system is less effective\n');
fprintf(fid, '   - Both reduced insulin production and insulin resistance contribute\n');
fprintf(fid, '     to impaired glucose homeostasis\n\n');

fprintf(fid, '5. Clinical Significance:\n');
fprintf(fid, '   These fasting levels (glucose: %.2f mg/dL, insulin: %.4f IU/ml)\n', ...
    g(end)*100, i(end));
fprintf(fid, '   represent the baseline metabolic state of a Type II diabetic patient.\n');
fprintf(fid, '   Elevated fasting glucose is a key diagnostic criterion for diabetes.\n');
fprintf(fid, '   The impaired insulin function leads to chronic hyperglycemia, which\n');
fprintf(fid, '   can cause long-term complications if not properly managed.\n\n');

fprintf(fid, 'CONCLUSION:\n');
fprintf(fid, '-----------\n');
fprintf(fid, 'The simulation demonstrates the impaired glucose-insulin regulation\n');
fprintf(fid, 'characteristic of Type II diabetes. The combination of reduced insulin\n');
fprintf(fid, 'production (60%% of normal) and insulin resistance (40%% sensitivity)\n');
fprintf(fid, 'results in elevated fasting glucose levels. The final values represent\n');
fprintf(fid, 'the fasting metabolic state for this Type II diabetic patient.\n\n');

fprintf(fid, '================================================================================\n');
fprintf(fid, 'Generated by: GLUINSMODEL Simulation\n');
fprintf(fid, 'Date: %s\n', datestr(now));
fprintf(fid, '================================================================================\n');

fclose(fid);
fprintf('  Results saved as: TypeII_Diabetes_Results.txt\n');

% Display the figure
set(fig, 'Visible', 'on');

fprintf('\n=== Simulation Complete ===\n');
fprintf('Generated files:\n');
fprintf('  - GLUINSMODEL_TypeII_Diabetes.png (plot)\n');
fprintf('  - GLUINSMODEL_TypeII_Diabetes_data.mat (data)\n');
fprintf('  - TypeII_Diabetes_Results.txt (analysis and results)\n\n');

fprintf('KEY FINDINGS:\n');
fprintf('  Final Glucose (Fasting): %.4f mg/ml (%.2f mg/dL)\n', g(end), g(end)*100);
fprintf('  Final Insulin (Fasting): %.4f IU/ml\n', i(end));
fprintf('  These represent the fasting levels for this Type II diabetic patient.\n\n');

close_system(mdl, 0);

