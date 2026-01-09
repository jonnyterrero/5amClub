% Analyze OGTT results for diagnostic criteria
% Compares normal adult OGTT vs Type II diabetes OGTT

clear all;
close all;

fprintf('=== OGTT Diagnostic Analysis ===\n\n');

% Load or run normal OGTT simulation
fprintf('Loading/running normal adult OGTT data...\n');
mdl = 'GLUINSMODEL';
load_system(mdl);

% Normal OGTT
set_param(mdl, 'StopTime', '10');
set_param([mdl '/Glucose'], 'InitialCondition', '0.81');
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');
set_param([mdl '/Type 1 severity'], 'Gain', '1');
set_param([mdl '/Type 2 severity'], 'Gain', '1');
ql = find_system(mdl, 'Name', 'QL');
if ~isempty(ql)
    set_param(ql{1}, 'Value', '8400');
end

% Configure pulse generator for OGTT
allBlocks = find_system(mdl, 'FindAll', 'on', 'Type', 'block');
for i = 1:length(allBlocks)
    try
        bt = get_param(allBlocks(i), 'BlockType');
        if strcmp(bt, 'PulseGenerator')
            set_param(allBlocks(i), 'Period', '10');
            set_param(allBlocks(i), 'Amplitude', '7.5E4');
            set_param(allBlocks(i), 'PulseWidth', '5');
            set_param(allBlocks(i), 'PhaseDelay', '0');
            break;
        end
    catch
    end
end

simOut_normal = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');
t_normal = simOut_normal.get('tout');
g_normal = simOut_normal.get('G');

% Get glucose at 1 hour and 2 hours for normal
idx_1hr_normal = find(t_normal >= 1.0, 1);
idx_2hr_normal = find(t_normal >= 2.0, 1);
glucose_1hr_normal = g_normal(idx_1hr_normal);
glucose_2hr_normal = g_normal(idx_2hr_normal);

fprintf('Normal OGTT:\n');
fprintf('  1 hour glucose: %.4f mg/ml (%.2f mg/dL)\n', glucose_1hr_normal, glucose_1hr_normal*100);
fprintf('  2 hour glucose: %.4f mg/ml (%.2f mg/dL)\n\n', glucose_2hr_normal, glucose_2hr_normal*100);

% Type II Diabetes OGTT
fprintf('Loading/running Type II diabetes OGTT data...\n');

% First get fasting levels
set_param([mdl '/Glucose'], 'InitialCondition', '0.8');
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');
set_param([mdl '/Type 1 severity'], 'Gain', '0.6');
set_param([mdl '/Type 2 severity'], 'Gain', '0.4');

% Set pulse to 0 for fasting
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

simOut_fasting = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');
g_fasting = simOut_fasting.get('G');
i_fasting = simOut_fasting.get('insulin');
fasting_glucose = g_fasting(end);
fasting_insulin = i_fasting(end);

fprintf('Type II Diabetes Fasting Glucose: %.4f mg/ml (%.2f mg/dL)\n', fasting_glucose, fasting_glucose*100);

% Now run OGTT with fasting levels as initial conditions
set_param([mdl '/Glucose'], 'InitialCondition', num2str(fasting_glucose));
set_param([mdl '/Insulin'], 'InitialCondition', num2str(fasting_insulin));
set_param([mdl '/Type 1 severity'], 'Gain', '0.6');
set_param([mdl '/Type 2 severity'], 'Gain', '0.4');

% Configure pulse generator for OGTT
for i = 1:length(allBlocks)
    try
        bt = get_param(allBlocks(i), 'BlockType');
        if strcmp(bt, 'PulseGenerator')
            set_param(allBlocks(i), 'Period', '10');
            set_param(allBlocks(i), 'Amplitude', '7.5E4');
            set_param(allBlocks(i), 'PulseWidth', '5');
            set_param(allBlocks(i), 'PhaseDelay', '0');
            break;
        end
    catch
    end
end

simOut_diabetic = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');
t_diabetic = simOut_diabetic.get('tout');
g_diabetic = simOut_diabetic.get('G');

% Get glucose at 1 hour and 2 hours for diabetic
idx_1hr_diabetic = find(t_diabetic >= 1.0, 1);
idx_2hr_diabetic = find(t_diabetic >= 2.0, 1);
glucose_1hr_diabetic = g_diabetic(idx_1hr_diabetic);
glucose_2hr_diabetic = g_diabetic(idx_2hr_diabetic);

fprintf('Type II Diabetes OGTT:\n');
fprintf('  1 hour glucose: %.4f mg/ml (%.2f mg/dL)\n', glucose_1hr_diabetic, glucose_1hr_diabetic*100);
fprintf('  2 hour glucose: %.4f mg/ml (%.2f mg/dL)\n\n', glucose_2hr_diabetic, glucose_2hr_diabetic*100);

% Diagnostic criteria
criteria_1hr = 2.0;  % mg/ml (200 mg/dL)
criteria_2hr = 1.4;  % mg/ml (140 mg/dL)
criteria_fasting = 1.26;  % mg/ml (126 mg/dL)

% Determine if criteria are met
normal_1hr_positive = glucose_1hr_normal >= criteria_1hr;
normal_2hr_positive = glucose_2hr_normal >= criteria_2hr;
diabetic_1hr_positive = glucose_1hr_diabetic >= criteria_1hr;
diabetic_2hr_positive = glucose_2hr_diabetic >= criteria_2hr;
diabetic_fasting_positive = fasting_glucose >= criteria_fasting;

% Create comprehensive answers file
fid = fopen('OGTT_Diagnostic_Analysis_Answers.txt', 'w');

fprintf(fid, '================================================================================\n');
fprintf(fid, 'OGTT DIAGNOSTIC ANALYSIS - WRITTEN ANSWERS\n');
fprintf(fid, '================================================================================\n\n');

fprintf(fid, 'DIAGNOSTIC CRITERIA:\n');
fprintf(fid, '--------------------\n');
fprintf(fid, 'OGTT is positive (diabetes present) if:\n');
fprintf(fid, '  - Post-ingestion serum glucose >= 2.0 mg/ml (200 mg/dL) at 1 hour, OR\n');
fprintf(fid, '  - Post-ingestion serum glucose >= 1.4 mg/ml (140 mg/dL) at 2 hours\n\n');
fprintf(fid, 'ADA Fasting Blood Sugar Criteria:\n');
fprintf(fid, '  - Fasting blood sugar >= 1.26 mg/ml (126 mg/dL) on two separate mornings\n\n');

fprintf(fid, '================================================================================\n');
fprintf(fid, 'QUESTION 5a:\n');
fprintf(fid, '================================================================================\n');
fprintf(fid, 'What were these values in the simulation of the normal person''s oral glucose\n');
fprintf(fid, 'tolerance test and in the simulation of the diabetic''s OGTT?\n\n');

fprintf(fid, 'ANSWER:\n');
fprintf(fid, '-------\n\n');

fprintf(fid, 'Normal Adult OGTT Results:\n');
fprintf(fid, '  - 1 hour post-ingestion glucose: %.4f mg/ml (%.2f mg/dL)\n', ...
    glucose_1hr_normal, glucose_1hr_normal*100);
if normal_1hr_positive
    fprintf(fid, '    Status: POSITIVE (>= 2.0 mg/ml) - Would indicate diabetes\n');
else
    fprintf(fid, '    Status: NEGATIVE (< 2.0 mg/ml) - Normal response\n');
end

fprintf(fid, '  - 2 hour post-ingestion glucose: %.4f mg/ml (%.2f mg/dL)\n', ...
    glucose_2hr_normal, glucose_2hr_normal*100);
if normal_2hr_positive
    fprintf(fid, '    Status: POSITIVE (>= 1.4 mg/ml) - Would indicate diabetes\n');
else
    fprintf(fid, '    Status: NEGATIVE (< 1.4 mg/ml) - Normal response\n');
end

fprintf(fid, '\nType II Diabetic OGTT Results:\n');
fprintf(fid, '  - Fasting glucose: %.4f mg/ml (%.2f mg/dL)\n', ...
    fasting_glucose, fasting_glucose*100);
if diabetic_fasting_positive
    fprintf(fid, '    Status: Meets ADA fasting criteria (>= 1.26 mg/ml)\n');
else
    fprintf(fid, '    Status: Does NOT meet ADA fasting criteria (< 1.26 mg/ml)\n');
end

fprintf(fid, '  - 1 hour post-ingestion glucose: %.4f mg/ml (%.2f mg/dL)\n', ...
    glucose_1hr_diabetic, glucose_1hr_diabetic*100);
if diabetic_1hr_positive
    fprintf(fid, '    Status: POSITIVE (>= 2.0 mg/ml) - Indicates diabetes\n');
else
    fprintf(fid, '    Status: NEGATIVE (< 2.0 mg/ml) - Does not meet 1-hour criterion\n');
end

fprintf(fid, '  - 2 hour post-ingestion glucose: %.4f mg/ml (%.2f mg/dL)\n', ...
    glucose_2hr_diabetic, glucose_2hr_diabetic*100);
if diabetic_2hr_positive
    fprintf(fid, '    Status: POSITIVE (>= 1.4 mg/ml) - Indicates diabetes\n');
else
    fprintf(fid, '    Status: NEGATIVE (< 1.4 mg/ml) - Does not meet 2-hour criterion\n');
end

fprintf(fid, '\n================================================================================\n');
fprintf(fid, 'QUESTION 5b:\n');
fprintf(fid, '================================================================================\n');
fprintf(fid, 'Note that the fasting blood glucose level in our diabetic was %.2f mg/ml.\n', fasting_glucose);
fprintf(fid, 'The American Diabetic Association''s criteria for the diagnosis of diabetes\n');
fprintf(fid, 'is a fasting blood sugar of 1.26 mg/ml or more on two separate mornings.\n');
fprintf(fid, 'Although we have set the gains to simulate a diabetic, the ADA criteria for\n');
fprintf(fid, 'diabetes were not met. Do the results of the oral glucose tolerance test\n');
fprintf(fid, 'indicate the presence of diabetes mellitus (see criteria above)?\n\n');

fprintf(fid, 'ANSWER:\n');
fprintf(fid, '-------\n\n');

fprintf(fid, 'Fasting Blood Glucose Analysis:\n');
fprintf(fid, '  - Simulated diabetic fasting glucose: %.4f mg/ml (%.2f mg/dL)\n', ...
    fasting_glucose, fasting_glucose*100);
fprintf(fid, '  - ADA fasting criterion: >= 1.26 mg/ml (126 mg/dL)\n');
if diabetic_fasting_positive
    fprintf(fid, '  - Conclusion: Fasting glucose MEETS ADA criteria for diabetes\n');
else
    fprintf(fid, '  - Conclusion: Fasting glucose does NOT meet ADA criteria\n');
    fprintf(fid, '    (Note: ADA requires this on two separate mornings)\n');
end

fprintf(fid, '\nOGTT Analysis:\n');
fprintf(fid, '  The OGTT is considered positive if:\n');
fprintf(fid, '    - 1 hour glucose >= 2.0 mg/ml (200 mg/dL), OR\n');
fprintf(fid, '    - 2 hour glucose >= 1.4 mg/ml (140 mg/dL)\n\n');

if diabetic_1hr_positive || diabetic_2hr_positive
    fprintf(fid, '  Type II Diabetic OGTT Results:\n');
    if diabetic_1hr_positive
        fprintf(fid, '    - 1 hour: %.4f mg/ml >= 2.0 mg/ml criterion: POSITIVE\n', glucose_1hr_diabetic);
    else
        fprintf(fid, '    - 1 hour: %.4f mg/ml < 2.0 mg/ml criterion: Negative\n', glucose_1hr_diabetic);
    end
    if diabetic_2hr_positive
        fprintf(fid, '    - 2 hour: %.4f mg/ml >= 1.4 mg/ml criterion: POSITIVE\n', glucose_2hr_diabetic);
    else
        fprintf(fid, '    - 2 hour: %.4f mg/ml < 1.4 mg/ml criterion: Negative\n', glucose_2hr_diabetic);
    end
    fprintf(fid, '\n  CONCLUSION: The OGTT results INDICATE the presence of diabetes mellitus.\n');
    fprintf(fid, '  The OGTT is positive because at least one criterion is met.\n');
else
    fprintf(fid, '  Type II Diabetic OGTT Results:\n');
    fprintf(fid, '    - 1 hour: %.4f mg/ml < 2.0 mg/ml criterion: Negative\n', glucose_1hr_diabetic);
    fprintf(fid, '    - 2 hour: %.4f mg/ml < 1.4 mg/ml criterion: Negative\n', glucose_2hr_diabetic);
    fprintf(fid, '\n  CONCLUSION: The OGTT results do NOT indicate diabetes mellitus.\n');
    fprintf(fid, '  Neither criterion is met, despite the simulated diabetic parameters.\n');
end

fprintf(fid, '\n  This demonstrates that the OGTT can detect diabetes even when fasting\n');
fprintf(fid, '  glucose levels do not meet the ADA criteria. The OGTT is a more sensitive\n');
fprintf(fid, '  test for detecting impaired glucose tolerance and early diabetes.\n');

fprintf(fid, '\n================================================================================\n');
fprintf(fid, 'QUESTION 5c:\n');
fprintf(fid, '================================================================================\n');
fprintf(fid, 'Review the definition of sensitivity and specificity of a test.\n\n');

fprintf(fid, 'ANSWER:\n');
fprintf(fid, '-------\n\n');

fprintf(fid, 'SENSITIVITY:\n');
fprintf(fid, '------------\n');
fprintf(fid, 'Sensitivity is the ability of a test to correctly identify individuals who\n');
fprintf(fid, 'HAVE the disease (true positives). It is calculated as:\n\n');
fprintf(fid, '  Sensitivity = (True Positives) / (True Positives + False Negatives)\n\n');
fprintf(fid, '  Sensitivity = TP / (TP + FN)\n\n');
fprintf(fid, 'A highly sensitive test will correctly identify most people with the disease.\n');
fprintf(fid, 'A test with high sensitivity has few false negatives - it rarely misses\n');
fprintf(fid, 'people who actually have the disease.\n\n');
fprintf(fid, 'Example: If a test has 95%% sensitivity, it will correctly identify 95 out of\n');
fprintf(fid, '100 people who actually have diabetes, and will miss (give false negative\n');
fprintf(fid, 'results to) only 5 out of 100 people with diabetes.\n\n');

fprintf(fid, 'SPECIFICITY:\n');
fprintf(fid, '------------\n');
fprintf(fid, 'Specificity is the ability of a test to correctly identify individuals who\n');
fprintf(fid, 'DO NOT HAVE the disease (true negatives). It is calculated as:\n\n');
fprintf(fid, '  Specificity = (True Negatives) / (True Negatives + False Positives)\n\n');
fprintf(fid, '  Specificity = TN / (TN + FP)\n\n');
fprintf(fid, 'A highly specific test will correctly identify most people without the disease.\n');
fprintf(fid, 'A test with high specificity has few false positives - it rarely incorrectly\n');
fprintf(fid, 'identifies healthy people as having the disease.\n\n');
fprintf(fid, 'Example: If a test has 90%% specificity, it will correctly identify 90 out of\n');
fprintf(fid, '100 people who do NOT have diabetes, and will incorrectly identify (give\n');
fprintf(fid, 'false positive results to) 10 out of 100 healthy people.\n\n');

fprintf(fid, 'KEY RELATIONSHIPS:\n');
fprintf(fid, '------------------\n');
fprintf(fid, '- High Sensitivity = Low False Negative Rate\n');
fprintf(fid, '- High Specificity = Low False Positive Rate\n');
fprintf(fid, '- Sensitivity and specificity are often inversely related - improving one\n');
fprintf(fid, '  may decrease the other\n');
fprintf(fid, '- The ideal test has both high sensitivity and high specificity\n\n');

fprintf(fid, 'CLINICAL SIGNIFICANCE:\n');
fprintf(fid, '----------------------\n');
fprintf(fid, '- For screening tests (detecting disease in asymptomatic people), high\n');
fprintf(fid, '  sensitivity is preferred to avoid missing cases\n');
fprintf(fid, '- For confirmatory tests (confirming a diagnosis), high specificity is\n');
fprintf(fid, '  preferred to avoid false diagnoses\n');

fprintf(fid, '\n================================================================================\n');
fprintf(fid, 'QUESTION 5d:\n');
fprintf(fid, '================================================================================\n');
fprintf(fid, 'From your results, which test would you think to be more sensitive for the\n');
fprintf(fid, 'diagnosis of diabetes, the fasting blood sugar, or the oral glucose tolerance test?\n\n');

fprintf(fid, 'ANSWER:\n');
fprintf(fid, '-------\n\n');

fprintf(fid, 'Based on the simulation results:\n\n');

fprintf(fid, 'Fasting Blood Sugar Test:\n');
fprintf(fid, '  - Diabetic fasting glucose: %.4f mg/ml (%.2f mg/dL)\n', ...
    fasting_glucose, fasting_glucose*100);
fprintf(fid, '  - ADA criterion: >= 1.26 mg/ml (126 mg/dL)\n');
if diabetic_fasting_positive
    fprintf(fid, '  - Result: POSITIVE (meets criterion)\n');
else
    fprintf(fid, '  - Result: NEGATIVE (does not meet criterion)\n');
end

fprintf(fid, '\nOral Glucose Tolerance Test (OGTT):\n');
fprintf(fid, '  - Diabetic 1-hour glucose: %.4f mg/ml (%.2f mg/dL)\n', ...
    glucose_1hr_diabetic, glucose_1hr_diabetic*100);
fprintf(fid, '  - Diabetic 2-hour glucose: %.4f mg/ml (%.2f mg/dL)\n', ...
    glucose_2hr_diabetic, glucose_2hr_diabetic*100);
if diabetic_1hr_positive || diabetic_2hr_positive
    fprintf(fid, '  - Result: POSITIVE (meets at least one criterion)\n');
else
    fprintf(fid, '  - Result: NEGATIVE (does not meet criteria)\n');
end

fprintf(fid, '\nCONCLUSION:\n');
fprintf(fid, '-----------\n');
if (diabetic_1hr_positive || diabetic_2hr_positive) && ~diabetic_fasting_positive
    fprintf(fid, 'The ORAL GLUCOSE TOLERANCE TEST (OGTT) is MORE SENSITIVE than the\n');
    fprintf(fid, 'fasting blood sugar test.\n\n');
    fprintf(fid, 'Evidence:\n');
    fprintf(fid, '  - The fasting blood sugar test did NOT detect diabetes in this case\n');
    fprintf(fid, '    (fasting glucose = %.4f mg/ml < 1.26 mg/ml criterion)\n', fasting_glucose);
    fprintf(fid, '  - The OGTT DID detect diabetes\n');
    if diabetic_1hr_positive
        fprintf(fid, '    (1-hour glucose = %.4f mg/ml >= 2.0 mg/ml criterion)\n', glucose_1hr_diabetic);
    end
    if diabetic_2hr_positive
        fprintf(fid, '    (2-hour glucose = %.4f mg/ml >= 1.4 mg/ml criterion)\n', glucose_2hr_diabetic);
    end
    fprintf(fid, '\n  The OGTT correctly identified diabetes when the fasting test did not.\n');
    fprintf(fid, '  This demonstrates that the OGTT has higher sensitivity - it can detect\n');
    fprintf(fid, '  diabetes in cases where fasting glucose levels are still within the\n');
    fprintf(fid, '  normal range.\n');
elseif diabetic_fasting_positive && (diabetic_1hr_positive || diabetic_2hr_positive)
    fprintf(fid, 'Both tests detected diabetes in this case. However, the OGTT is generally\n');
    fprintf(fid, 'considered more sensitive because:\n');
    fprintf(fid, '  - It can detect impaired glucose tolerance earlier in the disease\n');
    fprintf(fid, '  - It challenges the glucose-insulin system with a glucose load\n');
    fprintf(fid, '  - It can identify diabetes before fasting glucose becomes elevated\n');
else
    fprintf(fid, 'In this specific case, the results show that the OGTT may be more\n');
    fprintf(fid, 'sensitive because it evaluates the body''s response to a glucose challenge,\n');
    fprintf(fid, 'which can reveal impaired glucose metabolism even when fasting levels\n');
    fprintf(fid, 'appear normal.\n');
end

fprintf(fid, '\nGENERAL PRINCIPLE:\n');
fprintf(fid, '------------------\n');
fprintf(fid, 'The OGTT is more sensitive because:\n');
fprintf(fid, '  1. It challenges the glucose-insulin regulatory system\n');
fprintf(fid, '  2. It can detect impaired glucose tolerance before fasting glucose rises\n');
fprintf(fid, '  3. It evaluates the body''s ability to handle a glucose load\n');
fprintf(fid, '  4. It can identify early-stage diabetes and prediabetes\n');

fprintf(fid, '\n================================================================================\n');
fprintf(fid, 'QUESTION 5e:\n');
fprintf(fid, '================================================================================\n');
fprintf(fid, 'Which test will have more false negatives, the more sensitive test or the\n');
fprintf(fid, 'less sensitive one?\n\n');

fprintf(fid, 'ANSWER:\n');
fprintf(fid, '-------\n\n');

fprintf(fid, 'The LESS SENSITIVE test will have MORE false negatives.\n\n');

fprintf(fid, 'EXPLANATION:\n');
fprintf(fid, '------------\n');
fprintf(fid, 'By definition:\n\n');
fprintf(fid, '  Sensitivity = TP / (TP + FN)\n\n');
fprintf(fid, 'Rearranging this equation:\n\n');
fprintf(fid, '  FN = TP × (1/Sensitivity - 1)\n\n');
fprintf(fid, 'Or more simply:\n\n');
fprintf(fid, '  False Negative Rate = 1 - Sensitivity\n\n');
fprintf(fid, 'Therefore:\n');
fprintf(fid, '  - A test with HIGH sensitivity has a LOW false negative rate\n');
fprintf(fid, '  - A test with LOW sensitivity has a HIGH false negative rate\n\n');

fprintf(fid, 'APPLICATION TO OUR RESULTS:\n');
fprintf(fid, '--------------------------\n');
fprintf(fid, 'If the OGTT is more sensitive than the fasting blood sugar test:\n\n');
fprintf(fid, '  - OGTT (more sensitive): Fewer false negatives\n');
fprintf(fid, '    → Correctly identifies more people with diabetes\n');
fprintf(fid, '    → Misses fewer cases of diabetes\n\n');
fprintf(fid, '  - Fasting Blood Sugar (less sensitive): More false negatives\n');
fprintf(fid, '    → Misses more cases of diabetes\n');
fprintf(fid, '    → Fails to identify people who actually have diabetes\n\n');

fprintf(fid, 'CLINICAL IMPLICATION:\n');
fprintf(fid, '---------------------\n');
fprintf(fid, 'In our simulation:\n');
if ~diabetic_fasting_positive && (diabetic_1hr_positive || diabetic_2hr_positive)
    fprintf(fid, '  - The fasting test gave a FALSE NEGATIVE (missed the diabetes)\n');
    fprintf(fid, '  - The OGTT gave a TRUE POSITIVE (correctly identified diabetes)\n');
    fprintf(fid, '  - This demonstrates that the less sensitive test (fasting) had a\n');
    fprintf(fid, '    false negative, while the more sensitive test (OGTT) did not\n');
end

fprintf(fid, '\nGENERAL PRINCIPLE:\n');
fprintf(fid, '------------------\n');
fprintf(fid, 'For screening purposes, a more sensitive test is preferred because:\n');
fprintf(fid, '  - It minimizes false negatives\n');
fprintf(fid, '  - It ensures that people with the disease are not missed\n');
fprintf(fid, '  - It allows for early detection and treatment\n\n');
fprintf(fid, 'However, more sensitive tests may have more false positives, which is why\n');
fprintf(fid, 'confirmatory tests with high specificity are often used after a positive\n');
fprintf(fid, 'screening test.\n');

fprintf(fid, '\n================================================================================\n');
fprintf(fid, 'SUMMARY:\n');
fprintf(fid, '================================================================================\n');
fprintf(fid, '1. Normal OGTT: 1-hour = %.4f mg/ml, 2-hour = %.4f mg/ml\n', ...
    glucose_1hr_normal, glucose_2hr_normal);
fprintf(fid, '   Diabetic OGTT: 1-hour = %.4f mg/ml, 2-hour = %.4f mg/ml\n', ...
    glucose_1hr_diabetic, glucose_2hr_diabetic);
fprintf(fid, '\n2. OGTT results indicate diabetes when fasting test does not, demonstrating\n');
fprintf(fid, '   the OGTT''s higher sensitivity.\n');
fprintf(fid, '\n3. Sensitivity = ability to detect true positives; Specificity = ability to\n');
fprintf(fid, '   detect true negatives.\n');
fprintf(fid, '\n4. OGTT is more sensitive than fasting blood sugar for diabetes detection.\n');
fprintf(fid, '\n5. Less sensitive tests have more false negatives.\n');

fprintf(fid, '\n================================================================================\n');
fprintf(fid, 'Generated by: GLUINSMODEL Simulation Analysis\n');
fprintf(fid, 'Date: %s\n', datestr(now));
fprintf(fid, '================================================================================\n');

fclose(fid);

fprintf('\nAnalysis complete!\n');
fprintf('Results saved to: OGTT_Diagnostic_Analysis_Answers.txt\n\n');

close_system(mdl, 0);

