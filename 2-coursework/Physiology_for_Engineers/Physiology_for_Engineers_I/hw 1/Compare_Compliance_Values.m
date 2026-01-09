% Compare Compliance Values - My calculation vs Friend's calculation
clear
close all
clc

fprintf('=== COMPARING COMPLIANCE VALUES ===\n');

% Base parameters
T = 0.0125; Ts = 0.0050; dt = .00005*T; Beats=16*T;
Csa = .00175; Rs = 17.28; Rmi = 0.01; RAo_normal = 0.01; RAo_stenotic = 1.0;
AoBkflo = 0.00; Vlvd = .027; Vsad = .825; Pla = 5;
CLVD_normal = 0.0150; CLVS_normal = 5e-5; tauS = .0025; tauD = .005;
Plvi = 5; Psai = 80;

% Step 1: Get normal values
fprintf('STEP 1: Normal values\n');
RAo = RAo_normal;
sim('Cardio_SA_LV')
max_LV_pressure_normal = max(PLV);
Ks = CLVS_normal * max_LV_pressure_normal;
Kd = CLVD_normal * max_LV_pressure_normal;

fprintf('Normal maximum LV pressure: %.4f mmHg\n', max_LV_pressure_normal);
fprintf('Ks: %.6f\n', Ks);
fprintf('Kd: %.6f\n', Kd);

% Step 2: Run iterative process to get my values
fprintf('\nSTEP 2: My iterative calculation\n');
CLVS_current = CLVS_normal;
CLVD_current = CLVD_normal;
max_LV_pressure_previous = max_LV_pressure_normal;

for iteration = 1:10
    RAo = RAo_stenotic;
    sim('Cardio_SA_LV')
    max_LV_pressure_current = max(PLV);
    
    CLVS_new = Ks / max_LV_pressure_current;
    CLVD_new = Kd / max_LV_pressure_current;
    
    pressure_change = abs(max_LV_pressure_current - max_LV_pressure_previous) / max_LV_pressure_previous * 100;
    
    fprintf('Iteration %d: Pressure = %.4f, CLVS = %.8f, CLVD = %.6f, Change = %.2f%%\n', ...
        iteration, max_LV_pressure_current, CLVS_new, CLVD_new, pressure_change);
    
    % Update with averaging
    CLVS_current = 0.7 * CLVS_current + 0.3 * CLVS_new;
    CLVD_current = 0.7 * CLVD_current + 0.3 * CLVD_new;
    
    max_LV_pressure_previous = max_LV_pressure_current;
    
    if pressure_change < 1.0
        fprintf('Converged after %d iterations!\n', iteration);
        break;
    end
end

my_CLVS = CLVS_current;
my_CLVD = CLVD_current;

% Step 3: Check friend's values
fprintf('\nSTEP 3: Checking friend''s values\n');
friend_CLVS = 0.000043003;
friend_CLVD = 0.01290;

% Calculate what pressure friend's values would give
friend_pressure_from_CLVS = Ks / friend_CLVS;
friend_pressure_from_CLVD = Kd / friend_CLVD;

fprintf('Friend''s CLVS: %.8f\n', friend_CLVS);
fprintf('Friend''s CLVD: %.6f\n', friend_CLVD);
fprintf('Pressure implied by friend''s CLVS: %.4f mmHg\n', friend_pressure_from_CLVS);
fprintf('Pressure implied by friend''s CLVD: %.4f mmHg\n', friend_pressure_from_CLVD);

% Step 4: Run simulation with friend's values to see what pressure we get
fprintf('\nSTEP 4: Testing friend''s values\n');
CLVS = friend_CLVS;
CLVD = friend_CLVD;
RAo = RAo_stenotic;
sim('Cardio_SA_LV')
friend_actual_pressure = max(PLV);

fprintf('Actual pressure with friend''s values: %.4f mmHg\n', friend_actual_pressure);
fprintf('Difference from implied pressure: %.4f mmHg\n', abs(friend_actual_pressure - friend_pressure_from_CLVS));

% Step 5: Run simulation with my values
fprintf('\nSTEP 5: Testing my values\n');
CLVS = my_CLVS;
CLVD = my_CLVD;
RAo = RAo_stenotic;
sim('Cardio_SA_LV')
my_actual_pressure = max(PLV);

fprintf('Actual pressure with my values: %.4f mmHg\n', my_actual_pressure);
fprintf('Difference from implied pressure: %.4f mmHg\n', abs(my_actual_pressure - (Ks/my_CLVS)));

% Step 6: Comparison
fprintf('\nSTEP 6: Comparison\n');
fprintf('My values:\n');
fprintf('  CLVS: %.8f\n', my_CLVS);
fprintf('  CLVD: %.6f\n', my_CLVD);
fprintf('  Implied pressure: %.4f mmHg\n', Ks/my_CLVS);
fprintf('  Actual pressure: %.4f mmHg\n', my_actual_pressure);
fprintf('  Consistency: %.4f mmHg difference\n', abs(my_actual_pressure - (Ks/my_CLVS)));

fprintf('\nFriend''s values:\n');
fprintf('  CLVS: %.8f\n', friend_CLVS);
fprintf('  CLVD: %.6f\n', friend_CLVD);
fprintf('  Implied pressure: %.4f mmHg\n', friend_pressure_from_CLVS);
fprintf('  Actual pressure: %.4f mmHg\n', friend_actual_pressure);
fprintf('  Consistency: %.4f mmHg difference\n', abs(friend_actual_pressure - friend_pressure_from_CLVS));

% Determine which is more correct
my_consistency = abs(my_actual_pressure - (Ks/my_CLVS));
friend_consistency = abs(friend_actual_pressure - friend_pressure_from_CLVS);

fprintf('\nCONCLUSION:\n');
if my_consistency < friend_consistency
    fprintf('My values are more consistent (smaller pressure difference)\n');
    fprintf('My values should be used.\n');
else
    fprintf('Friend''s values are more consistent (smaller pressure difference)\n');
    fprintf('Friend''s values should be used.\n');
end

fprintf('\nFinal recommendation:\n');
if my_consistency < 1.0 && friend_consistency < 1.0
    fprintf('Both sets of values are reasonably consistent.\n');
    fprintf('The difference may be due to different simulation parameters or timing.\n');
elseif my_consistency < friend_consistency
    fprintf('Use my values: CLVS = %.8f, CLVD = %.6f\n', my_CLVS, my_CLVD);
else
    fprintf('Use friend''s values: CLVS = %.8f, CLVD = %.6f\n', friend_CLVS, friend_CLVD);
end
