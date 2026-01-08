% Simple simulation runner with logging
diary('simulation_log.txt');
fprintf('Starting simulation...\n');

mdl = 'GLUINSMODEL';
fprintf('Loading model: %s\n', mdl);
load_system(mdl);

% Set parameters
fprintf('Setting parameters...\n');
set_param([mdl '/Glucose'], 'InitialCondition', '0.81');
set_param([mdl '/Insulin'], 'InitialCondition', '0.057');
set_param([mdl '/Type 1 severity'], 'Gain', '1');
set_param([mdl '/Type 2 severity'], 'Gain', '1');

% Set QL
qlBlock = find_system(mdl, 'Name', 'QL');
if ~isempty(qlBlock)
    set_param(qlBlock{1}, 'Value', '8400');
    fprintf('QL set to 8400\n');
else
    fprintf('Warning: QL block not found\n');
end

% Set simulation time
set_param(mdl, 'StopTime', '10');
fprintf('Simulation time set to 10 hours\n');

% Run simulation
fprintf('Running simulation...\n');
try
    simOut = sim(mdl, 'StopTime', '10', 'ReturnWorkspaceOutputs', 'on');
    fprintf('Simulation completed successfully\n');
    
    % Get data
    t = simOut.get('tout');
    g = simOut.get('G');
    i = simOut.get('insulin');
    fprintf('Data extracted: t size=%d, g size=%d, i size=%d\n', length(t), length(g), length(i));
    
    % Create and save plot
    fprintf('Creating plot...\n');
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
    
    fprintf('Saving plot...\n');
    print(fig, '-dpng', '-r300', 'GLUINSMODEL_normal_adult.png');
    fprintf('Plot saved to GLUINSMODEL_normal_adult.png\n');
    
    % Save data
    fprintf('Saving data...\n');
    save('GLUINSMODEL_normal_adult_data.mat', 't', 'g', 'i');
    fprintf('Data saved to GLUINSMODEL_normal_adult_data.mat\n');
    
    % Display summary
    fprintf('\n=== Simulation Summary ===\n');
    fprintf('Initial Glucose: %.4f mg/ml\n', g(1));
    fprintf('Final Glucose: %.4f mg/ml\n', g(end));
    fprintf('Initial Insulin: %.4f IU/ml\n', i(1));
    fprintf('Final Insulin: %.4f IU/ml\n', i(end));
    fprintf('Mean Glucose: %.4f mg/ml\n', mean(g));
    fprintf('Mean Insulin: %.4f IU/ml\n', mean(i));
    
    close(fig);
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
    for k = 1:length(ME.stack)
        fprintf('  at %s line %d\n', ME.stack(k).file, ME.stack(k).line);
    end
end

close_system(mdl, 0);
fprintf('Done.\n');
diary off;

