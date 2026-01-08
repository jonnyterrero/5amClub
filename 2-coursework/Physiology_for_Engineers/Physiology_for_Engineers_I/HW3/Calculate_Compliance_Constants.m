% Calculate Compliance Constants Ks and Kd
clear
close all
clc

fprintf('=== CALCULATING COMPLIANCE CONSTANTS ===\n');

% Base parameters
T = 0.0125;                      % Duration of heartbeat: min
Ts = 0.0050;                     % Duration of systole: min
dt = .00005*T;                   % Time step
Beats=16*T;                      % 16 heart beats displayed

% Base compliance and resistance parameters
Csa = .00175;  % Systemic arterial compliance: L/mmHg
Rs = 17.28;    % Systemic resistance: mmHg/(L/min)
Rmi = 0.01;    % Mitral valve resistance: mmHg/(L/min)
RAo = 0.01;    % Normal aortic valve resistance: mmHg/(L/min)
AoBkflo = 0.00;  % No back flow allowed
Vlvd = .027;   % Left ventricular volume when PLV=0 (ESV)
Vsad = .825;   % Systemic arterial volume when Psa=diastol
Pla = 5;       % Left atrial pressure: mmHg

% Normal compliance parameters
CLVD_normal = 0.0150;  % Normal max (diastolic) value of CLV: L/mmHg
CLVS_normal = 5e-5;    % Normal min (systolic) value of CLV: L/mmHg
tauS = .0025;          % CLV time constant during systole: min
tauD = .005;           % CLV time constant during diastole: min

% Initialization parameters
Plvi = 5;              % Initial value of Plv: mmHg
Psai = 80;             % Initial value of Psa: mmHg

fprintf('Running simulation with normal aortic valve (RAo = 0.01)...\n');

% Run simulation with normal aortic valve
sim('Cardio_SA_LV')

% Extract data
t = BloodFlows.time;
max_LV_pressure = max(PLV);

fprintf('\nRESULTS:\n');
fprintf('Normal maximum LV pressure: %.4f mmHg\n', max_LV_pressure);
fprintf('Normal CLVS: %.6f L/mmHg\n', CLVS_normal);
fprintf('Normal CLVD: %.6f L/mmHg\n', CLVD_normal);

% Calculate compliance constants
Ks = CLVS_normal * max_LV_pressure;
Kd = CLVD_normal * max_LV_pressure;

fprintf('\nCALCULATED CONSTANTS:\n');
fprintf('Ks = CLVS_normal × Max_LV_Pressure = %.6f × %.4f = %.4f\n', CLVS_normal, max_LV_pressure, Ks);
fprintf('Kd = CLVD_normal × Max_LV_Pressure = %.6f × %.4f = %.4f\n', CLVD_normal, max_LV_pressure, Kd);

fprintf('\nCOMPARISON WITH FRIEND''S VALUES:\n');
fprintf('My Ks: %.4f, Friend''s Ks: 0.0052, Difference: %.6f\n', Ks, abs(Ks - 0.0052));
fprintf('My Kd: %.4f, Friend''s Kd: 1.5684, Difference: %.6f\n', Kd, abs(Kd - 1.5684));

% Verify the relationship
fprintf('\nVERIFICATION:\n');
fprintf('CLVS = Ks / Max_LV_Pressure = %.4f / %.4f = %.6f (should equal %.6f)\n', Ks, max_LV_pressure, Ks/max_LV_pressure, CLVS_normal);
fprintf('CLVD = Kd / Max_LV_Pressure = %.4f / %.4f = %.6f (should equal %.6f)\n', Kd, max_LV_pressure, Kd/max_LV_pressure, CLVD_normal);

% Additional analysis
fprintf('\nADDITIONAL ANALYSIS:\n');
fprintf('Stroke volume: %.4f L\n', max(VLV) - min(VLV));
fprintf('Heart rate: %.1f beats/min\n', 1/T);
fprintf('Cardiac output: %.4f L/min\n', (1/T) * (max(VLV) - min(VLV)));
fprintf('Mean LV pressure: %.4f mmHg\n', mean(PLV));
fprintf('LV pressure range: %.4f mmHg\n', max(PLV) - min(PLV));
