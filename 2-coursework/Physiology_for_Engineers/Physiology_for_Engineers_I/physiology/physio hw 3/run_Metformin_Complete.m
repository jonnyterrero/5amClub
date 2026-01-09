% Run Prob_7_Oral_Metformin-3 (1) Simulink Model
% Complete script with plotting and data saving

clear all;
close all;

mdl = 'Prob_7_Oral_Metformin-3 (1)';
load_system(mdl);

% Get simulation parameters
stopTime = get_param(mdl, 'StopTime');
fprintf('Running simulation for %s time units...\n', stopTime);

% Run simulation
simOut = sim(mdl, 'ReturnWorkspaceOutputs', 'on');

% Get all output variables
vars = simOut.who;
t = simOut.get('tout');

fprintf('Simulation complete. Found %d output variables.\n', length(vars));

% Extract all data variables (excluding tout)
data_vars = {};
data_values = {};

for i = 1:length(vars)
    if ~strcmp(vars{i}, 'tout')
        try
            data = simOut.get(vars{i});
            data_vars{end+1} = vars{i};
            data_values{end+1} = data;
            fprintf('Extracted: %s (size: %d x %d)\n', vars{i}, size(data,1), size(data,2));
        catch
            fprintf('Could not extract: %s\n', vars{i});
        end
    end
end

% Create plots
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
    
    fig = figure('Position', [100, 100, 1400, 800]);
    
    for i = 1:min(numPlots, rows*cols)
        subplot(rows, cols, i);
        data = data_values{i};
        
        % Plot data
        if size(data, 2) == 1
            plot(t, data, 'LineWidth', 2);
        else
            plot(t, data, 'LineWidth', 2);
            legend_labels = cell(1, size(data,2));
            for j = 1:size(data,2)
                legend_labels{j} = sprintf('Column %d', j);
            end
            legend(legend_labels);
        end
        
        xlabel('Time', 'FontSize', 10, 'FontWeight', 'bold');
        ylabel(data_vars{i}, 'FontSize', 10, 'FontWeight', 'bold');
        title(sprintf('%s vs Time', data_vars{i}), 'FontSize', 12, 'FontWeight', 'bold');
        grid on;
    end
    
    % Save figure
    saveas(fig, 'Metformin_Results.png');
    fprintf('Plot saved as: Metformin_Results.png\n');
    
    % Save data to workspace variables and MAT file
    for i = 1:length(data_vars)
        eval(sprintf('%s = data_values{%d};', data_vars{i}, i));
    end
    
    save_cmd = 'save(''Metformin_Data.mat'', ''t''';
    for i = 1:length(data_vars)
        save_cmd = [save_cmd, ', ''' data_vars{i} ''''];
    end
    save_cmd = [save_cmd, ');'];
    eval(save_cmd);
    fprintf('Data saved as: Metformin_Data.mat\n');
    
    % Create summary file
    fid = fopen('Metformin_Summary.txt', 'w');
    fprintf(fid, '================================================================================\n');
    fprintf(fid, 'METFORMIN SIMULATION RESULTS\n');
    fprintf(fid, '================================================================================\n\n');
    fprintf(fid, 'Model: %s\n', mdl);
    fprintf(fid, 'Simulation Time: %s\n', stopTime);
    fprintf(fid, 'Time Points: %d\n', length(t));
    fprintf(fid, 'Output Variables: %d\n\n', length(data_vars));
    
    fprintf(fid, 'VARIABLES AND STATISTICS:\n');
    fprintf(fid, '------------------------\n');
    for i = 1:length(data_vars)
        data = data_values{i};
        fprintf(fid, '%s:\n', data_vars{i});
        fprintf(fid, '  Size: %d x %d\n', size(data,1), size(data,2));
        fprintf(fid, '  Minimum: %.6f\n', min(data(:)));
        fprintf(fid, '  Maximum: %.6f\n', max(data(:)));
        fprintf(fid, '  Mean: %.6f\n', mean(data(:)));
        fprintf(fid, '  Initial Value: %.6f\n', data(1));
        fprintf(fid, '  Final Value: %.6f\n\n', data(end));
    end
    
    fprintf(fid, '================================================================================\n');
    fprintf(fid, 'Generated: %s\n', datestr(now));
    fprintf(fid, '================================================================================\n');
    fclose(fid);
    fprintf('Summary saved as: Metformin_Summary.txt\n');
    
    set(fig, 'Visible', 'on');
else
    fprintf('No data variables found.\n');
end

close_system(mdl, 0);
fprintf('Simulation complete!\n');

