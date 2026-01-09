% ============================================================================
% Metformin Simulation Code
% ============================================================================
% This code runs the Prob_7_Oral_Metformin-3 (1) Simulink model
% ============================================================================

clear all;
close all;

% Load the Simulink model
mdl = 'Prob_7_Oral_Metformin-3 (1)';
load_system(mdl);

% ============================================================================
% RUN SIMULATION
% ============================================================================
simOut = sim(mdl, 'ReturnWorkspaceOutputs', 'on');

% Extract time vector
t = simOut.get('tout');

% Get all output variables
vars = simOut.who;

% Extract data variables (excluding tout)
data_vars = {};
for i = 1:length(vars)
    if ~strcmp(vars{i}, 'tout')
        try
            data = simOut.get(vars{i});
            data_vars{end+1} = vars{i};
            eval(sprintf('%s = data;', vars{i}));
        catch
        end
    end
end

% ============================================================================
% CREATE PLOTS
% ============================================================================
if length(data_vars) > 0
    numPlots = length(data_vars);
    
    % Determine subplot layout
    if numPlots == 1
        rows = 1; cols = 1;
    elseif numPlots == 2
        rows = 1; cols = 2;
    elseif numPlots <= 4
        rows = 2; cols = 2;
    elseif numPlots <= 6
        rows = 2; cols = 3;
    else
        rows = 3; cols = 3;
    end
    
    figure('Position', [100, 100, 1400, 800]);
    
    for i = 1:min(numPlots, rows*cols)
        subplot(rows, cols, i);
        eval(sprintf('data = %s;', data_vars{i}));
        
        if size(data, 2) == 1
            plot(t, data, 'LineWidth', 2);
        else
            plot(t, data, 'LineWidth', 2);
        end
        
        xlabel('Time', 'FontSize', 10, 'FontWeight', 'bold');
        ylabel(data_vars{i}, 'FontSize', 10, 'FontWeight', 'bold');
        title(sprintf('%s vs Time', data_vars{i}), 'FontSize', 12, 'FontWeight', 'bold');
        grid on;
    end
    
    % Save figure
    saveas(gcf, 'Metformin_Results.png');
end

% ============================================================================
% DISPLAY RESULTS
% ============================================================================
fprintf('\n=== Metformin Simulation Results ===\n');
fprintf('Time points: %d\n', length(t));
fprintf('Output variables: %d\n', length(data_vars));

for i = 1:length(data_vars)
    eval(sprintf('data = %s;', data_vars{i}));
    fprintf('\n%s:\n', data_vars{i});
    fprintf('  Min: %.6f, Max: %.6f, Mean: %.6f\n', ...
        min(data(:)), max(data(:)), mean(data(:)));
end

% Close model
close_system(mdl, 0);

