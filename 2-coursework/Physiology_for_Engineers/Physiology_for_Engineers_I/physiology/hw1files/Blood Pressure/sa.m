%filename: sa.m
% Blood Pressure Simulation with Cardiac Arrest Analysis
% This script simulates arterial blood pressure and aortic flow
% with the ability to model cardiac arrest periods

clear all % clear all variables
close all % and figures
clc       % and Command Window

%==============================================================================
% SIMULATION PARAMETERS
%==============================================================================
global T TS TMAX QMAX Rs Csa dt;

% Cardiac cycle parameters
T = 0.0125;        % Duration of heartbeat (minutes) → 80 beats/min
TS = 0.4*T;        % Duration of systole (minutes)
TMAX = 0.16*T;     % Time at which flow is maximum (minutes)
QMAX = 28;         % Maximum flow through aortic valve (L/min)

% Cardiovascular system parameters
Rs = 17.86;        % Systemic resistance (mmHg/(L/min))
Csa = 0.0015;      % Systemic arterial compliance (L/mmHg)

% Simulation timing parameters
dt = 0.01*T;       % Time step duration (minutes)
klokmax = ceil(20*T/dt); % Total number of time steps (20 cardiac cycles)

% Initial conditions
Psa = 80;          % Starting diastolic pressure (mmHg)

% Cardiac arrest parameters
t_arrest = 0.03;   % Time when cardiac arrest begins (minutes) - 1.8 seconds
t_restart = 0.13;  % Time when cardiac arrest ends (minutes) - 7.8 seconds

%==============================================================================
% INITIALIZE ARRAYS FOR DATA STORAGE
%==============================================================================
t_plot = zeros(1, klokmax);
QAo_plot = zeros(1, klokmax);
Psa_plot = zeros(1, klokmax);

%==============================================================================
% MAIN SIMULATION LOOP
%==============================================================================
fprintf('=== BLOOD PRESSURE SIMULATION WITH CARDIAC ARREST ===\n');
fprintf('Cardiac arrest period: %.2f - %.2f minutes (%.1f - %.1f seconds)\n', ...
        t_arrest, t_restart, t_arrest*60, t_restart*60);
fprintf('Running simulation...\n\n');

for klok = 1:klokmax
    t = klok * dt;
    
    % Calculate aortic flow (includes cardiac arrest logic)
    QAo = QAo_now(t, t_arrest, t_restart);
    
    % Update arterial pressure using Euler's method
    Psa = Psa_new(Psa, QAo);
    
    % Store values for plotting
    t_plot(klok) = t;
    QAo_plot(klok) = QAo;
    Psa_plot(klok) = Psa;
end

%==============================================================================
% CALCULATE AND DISPLAY RESULTS
%==============================================================================
% Calculate cardiac output (average flow over last 4 cardiac cycles)
cycles_to_use = 4;
cycle_length = round(T/dt);
start_idx = klokmax - cycles_to_use * cycle_length + 1;
cardiac_output = mean(QAo_plot(start_idx:end));

% Calculate systolic and diastolic pressures
pressure_data = Psa_plot(start_idx:end);
systolic_pressure = max(pressure_data);
diastolic_pressure = min(pressure_data);

% Display results
fprintf('=== SIMULATION RESULTS ===\n');
fprintf('Cardiac Output: %.2f L/min\n', cardiac_output);
fprintf('Systolic Pressure: %.1f mmHg\n', systolic_pressure);
fprintf('Diastolic Pressure: %.1f mmHg\n', diastolic_pressure);
fprintf('Current Compliance (Csa): %.4f L/mmHg\n', Csa);
fprintf('Systemic Resistance (Rs): %.2f mmHg/(L/min)\n', Rs);

%==============================================================================
% CREATE PLOTS
%==============================================================================
figure('color', 'white', 'Position', [100, 100, 800, 600]);

% Upper plot: Aortic Flow
subplot(2,1,1);
plot(t_plot, QAo_plot, 'b-', 'linewidth', 2);
xlabel('Time (minutes)');
ylabel('Aortic Flow (L/min)');
title('Aortic Flow with Cardiac Arrest');
grid on;

% Add vertical lines to mark cardiac arrest period
hold on;
xline(t_arrest, 'r--', 'LineWidth', 2, 'DisplayName', 'Arrest Start');
xline(t_restart, 'g--', 'LineWidth', 2, 'DisplayName', 'Arrest End');
hold off;
legend('Aortic Flow', 'Arrest Start', 'Arrest End', 'Location', 'best');

% Lower plot: Arterial Blood Pressure
subplot(2,1,2);
plot(t_plot, Psa_plot, 'r-', 'linewidth', 2);
xlabel('Time (minutes)');
ylabel('Blood Pressure (mmHg)');
title(sprintf('Arterial Blood Pressure (%.1f/%.1f mmHg)', ...
              systolic_pressure, diastolic_pressure));
grid on;

% Add vertical lines to mark cardiac arrest period
hold on;
xline(t_arrest, 'r--', 'LineWidth', 2, 'DisplayName', 'Arrest Start');
xline(t_restart, 'g--', 'LineWidth', 2, 'DisplayName', 'Arrest End');
hold off;
legend('Blood Pressure', 'Arrest Start', 'Arrest End', 'Location', 'best');

% Set appropriate axis limits
axis([0, max(t_plot), 0, max(Psa_plot)*1.1]);

fprintf('\n=== SIMULATION COMPLETE ===\n');
fprintf('Plots generated showing aortic flow and blood pressure\n');
fprintf('with cardiac arrest period marked in red and green lines.\n');