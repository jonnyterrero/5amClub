% Minimal test
mdl = 'GLUINSMODEL';
load_system(mdl);
set_param([mdl '/Glucose'], 'InitialCondition', '0.81');
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');
set_param([mdl '/Type 1 severity'], 'Gain', '1');
set_param([mdl '/Type 2 severity'], 'Gain', '1');
ql = find_system(mdl, 'Name', 'QL');
if ~isempty(ql)
    set_param(ql{1}, 'Value', '8400');
end
set_param(mdl, 'StopTime', '10');

fprintf('Starting simulation...\n');
simOut = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');
fprintf('Simulation done\n');

t = simOut.get('tout');
g = simOut.get('G');
i = simOut.get('insulin');

fprintf('Data: t=%d, g=%d, i=%d\n', length(t), length(g), length(i));
fprintf('g(1)=%.4f, g(end)=%.4f\n', g(1), g(end));

% Test save
test_var = 123;
save('test_save.mat', 'test_var');
fprintf('Test save worked\n');

% Create and save plot
fig = figure('Visible', 'off');
plot(t, g);
xlabel('Time (hr)');
ylabel('Glucose (mg/ml)');
title('Test Plot');
print(fig, '-dpng', 'test_plot.png');
fprintf('Test plot saved\n');
close(fig);

% Save actual data
save('test_data.mat', 't', 'g', 'i');
fprintf('Data saved\n');

close_system(mdl, 0);
fprintf('Done\n');

