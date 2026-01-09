% Simulate normal adult glucose-insulin model
mdl = 'GLUINSMODEL';
load_system(mdl);

% Set initial conditions
set_param([mdl '/Glucose'], 'InitialCondition', '0.81');
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');

% Set severity gains
set_param([mdl '/Type 1 severity'], 'Gain', '1');
set_param([mdl '/Type 2 severity'], 'Gain', '1');

% Set QL
qlBlock = find_system(mdl, 'Name', 'QL');
if ~isempty(qlBlock)
    set_param(qlBlock{1}, 'Value', '8400');
end

% Set simulation time
set_param(mdl, 'StopTime', '10');

% Run simulation
simOut = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');

% Extract data
t = simOut.get('tout');
g = simOut.get('G');
i = simOut.get('insulin');

% Create plots
fig = figure('Visible', 'off', 'Position', [100 100 1200 500]);

subplot(1, 2, 1);
plot(t, g, 'LineWidth', 2, 'Color', [0.2 0.6 0.8]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Glucose (mg/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Blood Glucose vs Time (Normal Adult)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0 10]);

subplot(1, 2, 2);
plot(t, i, 'LineWidth', 2, 'Color', [0.8 0.3 0.3]);
xlabel('Time (hr)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Insulin (IU/ml)', 'FontSize', 12, 'FontWeight', 'bold');
title('Plasma Insulin vs Time (Normal Adult)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0 10]);

% Save plot
print(fig, '-dpng', '-r300', 'GLUINSMODEL_normal_adult.png');

% Save data
save('GLUINSMODEL_normal_adult_data.mat', 't', 'g', 'i');

close(fig);
close_system(mdl, 0);

