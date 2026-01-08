% Quick test to verify pressure values
clear all
close all
clc

% Set up parameters
global T TS TMAX QMAX Rs Csa dt;
T = 0.0125;
TS = 0.4*T;
TMAX = 0.16*T;
QMAX = 28;
Rs = 17.86;
Csa = 0.0015;  % Adjusted compliance
dt = 0.01*T;
klokmax = ceil(16*T/dt);
Psa = 80;

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

% Calculate final values from last 4 cycles
cycles_to_use = 4;
cycle_length = round(T/dt);
start_idx = klokmax - cycles_to_use * cycle_length + 1;
pressure_data = Psa_plot(start_idx:end);
systolic = max(pressure_data);
diastolic = min(pressure_data);
cardiac_output = mean(QAo_plot(start_idx:end));

% Display results
fprintf('=== SIMULATION RESULTS ===\n');
fprintf('Compliance (Csa): %.4f L/mmHg\n', Csa);
fprintf('Systolic Pressure: %.1f mmHg\n', systolic);
fprintf('Diastolic Pressure: %.1f mmHg\n', diastolic);
fprintf('Cardiac Output: %.2f L/min\n', cardiac_output);

% Check if we're close to target
if abs(systolic - 120) < 5 && abs(diastolic - 80) < 5
    fprintf('\n✓ SUCCESS: Blood pressure is close to target 120/80 mmHg!\n');
    fprintf('Compliance was INCREASED from 0.0012 to %.4f L/mmHg\n', Csa);
else
    fprintf('\n⚠ Need further adjustment. Current values:\n');
    fprintf('Target: 120/80 mmHg\n');
    fprintf('Actual: %.1f/%.1f mmHg\n', systolic, diastolic);
end






