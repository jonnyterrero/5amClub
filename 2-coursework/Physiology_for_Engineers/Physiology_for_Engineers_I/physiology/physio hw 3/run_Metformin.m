% Run Prob_7_Oral_Metformin-3 (1) Simulink Model
% This script runs the metformin simulation and generates plots

clear all;
close all;

fprintf('=== Metformin Simulation ===\n\n');

mdl = 'Prob_7_Oral_Metformin-3 (1)';
fprintf('Loading model: %s\n', mdl);
load_system(mdl);

% Get simulation parameters
stopTime = get_param(mdl, 'StopTime');
fprintf('Simulation time: %s\n', stopTime);

% Find output blocks
fprintf('\nFinding output blocks...\n');
outs = find_system(mdl, 'BlockType', 'ToWorkspace');
for i = 1:length(outs)
    varName = get_param(outs{i}, 'VariableName');
    fprintf('  Output: %s -> %s\n', outs{i}, varName);
end

% Run simulation
fprintf('\nRunning simulation...\n');
simOut = sim(mdl, 'ReturnWorkspaceOutputs', 'on');
fprintf('Simulation completed!\n\n');

% Get all output variables
vars = simOut.who;
fprintf('Available outputs:\n');
for i = 1:length(vars)
    fprintf('  %s\n', vars{i});
end

% Extract time vector
t = simOut.get('tout');
fprintf('\nTime vector: %d points\n', length(t));

% Try to extract common variables
data_vars = {};
try
    % Try common variable names
    possible_vars = {'G', 'glucose', 'Glucose', 'I', 'insulin', 'Insulin', ...
                     'M', 'metformin', 'Metformin', 'C', 'concentration', ...
                     'y', 'x', 'output', 'signal'};
    
    for i = 1:length(possible_vars)
        try
            data = simOut.get(possible_vars{i});
            data_vars{end+1} = possible_vars{i};
            fprintf('Found variable: %s (size: %d x %d)\n', ...
                possible_vars{i}, size(data,1), size(data,2));
        catch
        end
    end
    
    % Also try all variables from the list
    for i = 1:length(vars)
        if ~strcmp(vars{i}, 'tout')
            try
                data = simOut.get(vars{i});
                if ~ismember(vars{i}, data_vars)
                    data_vars{end+1} = vars{i};
                    fprintf('Found variable: %s (size: %d x %d)\n', ...
                        vars{i}, size(data,1), size(data,2));
                end
            catch
            end
        end
    end
catch ME
    fprintf('Error extracting data: %s\n', ME.message);
end

% Create plots
fprintf('\nCreating plots...\n');
numVars = length(data_vars);

if numVars > 0
    % Determine subplot layout
    if numVars == 1
        rows = 1; cols = 1;
    elseif numVars == 2
        rows = 1; cols = 2;
    elseif numVars <= 4
        rows = 2; cols = 2;
    elseif numVars <= 6
        rows = 2; cols = 3;
    else
        rows = 3; cols = 3;
    end
    
    fig = figure('Position', [100, 100, 1400, 800]);
    
    for i = 1:min(numVars, rows*cols)
        try
            data = simOut.get(data_vars{i});
            subplot(rows, cols, i);
            
            % Handle different data formats
            if size(data, 2) == 1
                plot(t, data, 'LineWidth', 2);
            else
                plot(t, data, 'LineWidth', 2);
            end
            
            xlabel('Time', 'FontSize', 10, 'FontWeight', 'bold');
            ylabel(data_vars{i}, 'FontSize', 10, 'FontWeight', 'bold');
            title(sprintf('%s vs Time', data_vars{i}), 'FontSize', 12, 'FontWeight', 'bold');
            grid on;
        catch ME
            fprintf('Error plotting %s: %s\n', data_vars{i}, ME.message);
        end
    end
    
    % Save figure
    saveas(fig, 'Metformin_Results.png');
    fprintf('Plot saved as: Metformin_Results.png\n');
    
    % Save data
    save_cmd = 'save(''Metformin_Data.mat'', ''t''';
    for i = 1:length(data_vars)
        eval(sprintf('%s = simOut.get(''%s'');', data_vars{i}, data_vars{i}));
        save_cmd = [save_cmd, ', ''' data_vars{i} ''''];
    end
    save_cmd = [save_cmd, ');'];
    eval(save_cmd);
    fprintf('Data saved as: Metformin_Data.mat\n');
    
    set(fig, 'Visible', 'on');
else
    fprintf('No data variables found to plot.\n');
end

% Display summary
fprintf('\n=== Simulation Summary ===\n');
fprintf('Model: %s\n', mdl);
fprintf('Simulation time: %s\n', stopTime);
fprintf('Time points: %d\n', length(t));
fprintf('Output variables: %d\n', numVars);
for i = 1:length(data_vars)
    try
        data = simOut.get(data_vars{i});
        fprintf('  %s: min=%.4f, max=%.4f, mean=%.4f\n', ...
            data_vars{i}, min(data), max(data), mean(data));
    catch
    end
end

close_system(mdl, 0);
fprintf('\nDone.\n');

