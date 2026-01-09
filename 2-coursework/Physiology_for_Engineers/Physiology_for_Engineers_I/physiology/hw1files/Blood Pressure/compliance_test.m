% Script to adjust compliance to achieve 120/80 mmHg blood pressure
clear all
close all
clc

% Test different compliance values
compliance_values = [0.0008, 0.0010, 0.0012, 0.0014, 0.0016, 0.0018, 0.0020];
target_systolic = 120;
target_diastolic = 80;

fprintf('Testing different compliance values to achieve 120/80 mmHg:\n');
fprintf('Compliance\tSystolic\tDiastolic\tCardiac Output\n');
fprintf('----------------------------------------------------\n');

best_compliance = 0.0012;
best_error = inf;

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
    klokmax = ceil(20*T/dt); % Use 20 cycles for better steady state
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
    
    % Calculate error from target
    error = abs(systolic - target_systolic) + abs(diastolic - target_diastolic);
    
    fprintf('%.4f\t\t%.1f\t\t%.1f\t\t%.2f\n', compliance_values(i), systolic, diastolic, cardiac_output);
    
    % Track best compliance
    if error < best_error
        best_error = error;
        best_compliance = compliance_values(i);
    end
end

fprintf('\nBest compliance value: %.4f L/mmHg\n', best_compliance);
fprintf('This should be used as the normal value for subsequent exercises.\n');
