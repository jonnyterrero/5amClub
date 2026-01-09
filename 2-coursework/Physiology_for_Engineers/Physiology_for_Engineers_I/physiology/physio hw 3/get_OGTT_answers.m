% Get answers to OGTT questions
clear all;

mdl = 'GLUINSMODEL';
load_system(mdl);

% Set parameters (same as normal adult)
set_param([mdl '/Glucose'], 'InitialCondition', '0.81');
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');
set_param([mdl '/Type 1 severity'], 'Gain', '1');
set_param([mdl '/Type 2 severity'], 'Gain', '1');
ql = find_system(mdl, 'Name', 'QL');
if ~isempty(ql)
    set_param(ql{1}, 'Value', '8400');
end
set_param(mdl, 'StopTime', '10');

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
            fprintf('Pulse generator configured\n');
            break;
        end
    catch
    end
end

% Run simulation
fprintf('Running simulation...\n');
simOut = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');
t = simOut.get('tout');
g = simOut.get('G');
i = simOut.get('insulin');

% Find peak
[peak_g, peak_idx] = max(g);
peak_time = t(peak_idx);

% Find return times
time_to_2mg = [];
for j = peak_idx:length(g)
    if g(j) <= 2.0
        time_to_2mg = t(j);
        break;
    end
end

time_to_1_4mg = [];
for j = peak_idx:length(g)
    if g(j) <= 1.4
        time_to_1_4mg = t(j);
        break;
    end
end

% Create answers file
fid = fopen('OGTT_Answers.txt', 'w');
fprintf(fid, '================================================================================\n');
fprintf(fid, 'ANSWERS TO OGTT QUESTIONS\n');
fprintf(fid, '================================================================================\n\n');

fprintf(fid, 'f. How long did it take for the blood glucose level to return to 2 mg/ml?\n');
fprintf(fid, '   Answer: ');
if ~isempty(time_to_2mg)
    fprintf(fid, '%.2f hours (%.1f minutes)\n', time_to_2mg, time_to_2mg*60);
    fprintf('Time to return to 2.0 mg/ml: %.2f hours (%.1f minutes)\n', time_to_2mg, time_to_2mg*60);
else
    fprintf(fid, 'Glucose did not return to 2.0 mg/ml within 10 hours.\n');
    fprintf(fid, 'Final glucose level: %.4f mg/ml\n', g(end));
    fprintf('Glucose did not return to 2.0 mg/ml within 10 hours. Final: %.4f mg/ml\n', g(end));
end

fprintf(fid, '\n');
fprintf(fid, 'f. How long did it take for the blood glucose level to return to 1.4 mg/ml?\n');
fprintf(fid, '   Answer: ');
if ~isempty(time_to_1_4mg)
    fprintf(fid, '%.2f hours (%.1f minutes)\n', time_to_1_4mg, time_to_1_4mg*60);
    fprintf('Time to return to 1.4 mg/ml: %.2f hours (%.1f minutes)\n', time_to_1_4mg, time_to_1_4mg*60);
else
    fprintf(fid, 'Glucose did not return to 1.4 mg/ml within 10 hours.\n');
    fprintf(fid, 'Final glucose level: %.4f mg/ml\n', g(end));
    fprintf('Glucose did not return to 1.4 mg/ml within 10 hours. Final: %.4f mg/ml\n', g(end));
end

fprintf(fid, '\n');
fprintf(fid, 'Additional Information:\n');
fprintf(fid, 'Peak glucose: %.4f mg/ml (%.2f mg/dL) at %.2f hours\n', peak_g, peak_g*100, peak_time);
fprintf(fid, 'Initial glucose: %.4f mg/ml (%.2f mg/dL)\n', g(1), g(1)*100);
fprintf(fid, 'Final glucose: %.4f mg/ml (%.2f mg/dL)\n', g(end), g(end)*100);

fprintf(fid, '\n================================================================================\n');
fclose(fid);

fprintf('\nAnswers saved to OGTT_Answers.txt\n');
close_system(mdl, 0);

