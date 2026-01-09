% Get specific values for Question 5
clear
close all
clc

% Run simulation
T = 0.0125; Ts = 0.0050; dt = .00005*T; Beats=16*T;
Csa = .00175; Rs = 17.28; Rmi =0.01; RAo =0.01; AoBkflo=0.00;
Vlvd = .027; Vsad = .825; Pla = 5;
CLVD =0.0150; CLVS = 5e-5; tauS = .0025; tauD = .005;
Plvi = 5; Psai = 80;

sim('Cardio_SA_LV')

% Extract data
t = BloodFlows.time;
Qmi = BloodFlows.signals.values(:,1);
QAo = BloodFlows.signals.values(:,2);

% Find key values
[edv, edv_idx] = max(VLV);
[esv, esv_idx] = min(VLV);
edp = PLV(edv_idx);
esp = PLV(esv_idx);

% Calculate derived values
stroke_volume = edv - esv;
heart_rate = 1/T;
cardiac_output = heart_rate * stroke_volume;

% Find valve timing
mitral_open_idx = find(Qmi > 0.01, 1, 'first');
mitral_close_idx = find(Qmi > 0.01, 1, 'last');
aortic_open_idx = find(QAo > 0.01, 1, 'first');
aortic_close_idx = find(QAo > 0.01, 1, 'last');

% Calculate work
work_per_cycle = trapz(VLV, PLV) * 133.32 * 0.001;

% Display results
fprintf('QUESTION 5 ANSWERS:\n\n');
fprintf('vi. End diastolic volume: %.3f L\n', edv);
fprintf('    End systolic volume: %.3f L\n', esv);
fprintf('\n');
fprintf('vii. Stroke volume: %.3f L (%.0f mL)\n', stroke_volume, stroke_volume*1000);
fprintf('\n');
fprintf('viii. Cardiac output: %.3f L/min\n', cardiac_output);
fprintf('     Formula: CO = HR × SV = %.1f beats/min × %.3f L/beat = %.3f L/min\n', heart_rate, stroke_volume, cardiac_output);
fprintf('\n');
fprintf('ix. Work done per cycle: %.6f J\n', work_per_cycle);
fprintf('    Calculation: Work = ∫ P dV × 133.32 Pa/mmHg × 0.001 m³/L\n');
fprintf('\n');
fprintf('VALVE TIMING:\n');
fprintf('Mitral valve opens: %.4f min (%.1f%% of cycle)\n', t(mitral_open_idx), (t(mitral_open_idx)/T)*100);
fprintf('Mitral valve closes: %.4f min (%.1f%% of cycle)\n', t(mitral_close_idx), (t(mitral_close_idx)/T)*100);
fprintf('Aortic valve opens: %.4f min (%.1f%% of cycle)\n', t(aortic_open_idx), (t(aortic_open_idx)/T)*100);
fprintf('Aortic valve closes: %.4f min (%.1f%% of cycle)\n', t(aortic_close_idx), (t(aortic_close_idx)/T)*100);
