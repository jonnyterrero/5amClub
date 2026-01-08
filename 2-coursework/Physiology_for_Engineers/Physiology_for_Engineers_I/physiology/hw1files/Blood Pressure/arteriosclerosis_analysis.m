%filename: arteriosclerosis_analysis.m
% Analysis of arteriosclerosis effects on blood pressure
clear all % clear all variables
close all % and figures
clc       % and Command Window

% Define target pressures for arteriosclerosis
target_pressures = [140, 65; 180, 50]; % [systolic, diastolic] pairs
target_names = {'Moderate Arteriosclerosis', 'Severe Arteriosclerosis'};

% Define compliance range to test (decreasing values for stiffer arteries)
compliance_values = [0.0015, 0.0012, 0.0010, 0.0008, 0.0006, 0.0005, 0.0004, 0.0003];

fprintf('=== ARTERIOSCLEROSIS ANALYSIS ===\n');
fprintf('Testing reduced compliance (stiffer arteries) effects on blood pressure\n\n');

% Store results for each compliance value
results = zeros(length(compliance_values), 4); % [compliance, systolic, diastolic, cardiac_output]

for i = 1:length(compliance_values)
    % Set global variables
    global T TS TMAX QMAX Rs Csa dt;
    
    % Initialize with current compliance value
    T = 0.0125;
    TS = 0.4*T;
    TMAX = 0.16*T;
    QMAX = 28;
    Rs = 17.86;
    Csa = compliance_values(i);
    dt = 0.01*T;
    klokmax = ceil(20*T/dt); % 20 cycles for steady state
    Psa = 80; % Start at diastolic pressure
    
    % Initialize arrays
    t_plot = zeros(1,klokmax);
    QAo_plot = zeros(1,klokmax);
    Psa_plot = zeros(1,klokmax);
    
    % Run simulation
    for klok = 1:klokmax
        t = klok*dt;
        QAo = QAo_now(t);
        Psa = Psa_new(Psa, QAo);
        t_plot(klok) = t;
        QAo_plot(klok) = QAo;
        Psa_plot(klok) = Psa;
    end
    
    % Calculate pressures from last 4 cycles
    cycles_to_use = 4;
    cycle_length = round(T/dt);
    start_idx = klokmax - cycles_to_use * cycle_length + 1;
    pressure_data = Psa_plot(start_idx:end);
    systolic = max(pressure_data);
    diastolic = min(pressure_data);
    cardiac_output = mean(QAo_plot(start_idx:end));
    
    % Store results
    results(i,:) = [Csa, systolic, diastolic, cardiac_output];
    
    % Check if this matches our target pressures
    for j = 1:size(target_pressures,1)
        target_sys = target_pressures(j,1);
        target_dia = target_pressures(j,2);
        sys_error = abs(systolic - target_sys);
        dia_error = abs(diastolic - target_dia);
        
        if sys_error < 10 && dia_error < 10 % Within 10 mmHg of target
            fprintf('✓ FOUND MATCH for %s:\n', target_names{j});
            fprintf('  Compliance: %.4f L/mmHg\n', Csa);
            fprintf('  Pressure: %.1f/%.1f mmHg (target: %.0f/%.0f mmHg)\n', ...
                    systolic, diastolic, target_sys, target_dia);
            fprintf('  Cardiac Output: %.2f L/min\n\n', cardiac_output);
            
            % Plot this specific case
            figure('color','white')
            subplot(2,1,1), plot(t_plot,QAo_plot,'linewidth',2)
            xlabel('TIME - minutes')
            ylabel('Aortic Flow (L/min)')
            title(sprintf('Aortic Flow - %s', target_names{j}))
            grid on;
            
            subplot(2,1,2), plot(t_plot,Psa_plot,'linewidth',2)
            xlabel('TIME - Minutes')
            ylabel('Blood Pressure - mmHg')
            title(sprintf('Arterial Blood Pressure - %s (%.1f/%.1f mmHg)', ...
                         target_names{j}, systolic, diastolic))
            grid on;
            axis([0, max(t_plot), 40, 200]);
            
            % Add target lines
            hold on;
            yline(target_sys, 'r--', 'LineWidth', 2, 'DisplayName', sprintf('Target Systolic (%.0f mmHg)', target_sys));
            yline(target_dia, 'g--', 'LineWidth', 2, 'DisplayName', sprintf('Target Diastolic (%.0f mmHg)', target_dia));
            hold off;
        end
    end
end

% Display summary table
fprintf('=== SUMMARY TABLE ===\n');
fprintf('Compliance\tSystolic\tDiastolic\tCardiac Output\n');
fprintf('----------------------------------------------------\n');
for i = 1:length(compliance_values)
    fprintf('%.4f\t\t%.1f\t\t%.1f\t\t%.2f\n', results(i,1), results(i,2), results(i,3), results(i,4));
end

fprintf('\n=== ANALYSIS COMPLETE ===\n');
fprintf('Note: Lower compliance values represent stiffer arteries (arteriosclerosis)\n');
fprintf('Higher pressures result from reduced arterial elasticity\n');
