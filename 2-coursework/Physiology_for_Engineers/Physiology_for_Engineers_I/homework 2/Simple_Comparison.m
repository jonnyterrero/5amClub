% Simple comparison of compliance values
clear
close all
clc

% My values
my_CLVS = 3.87e-5;
my_CLVD = 0.0118;

% Friend's values
friend_CLVS = 0.000043003;
friend_CLVD = 0.01290;

% Constants from normal values
Ks = 0.0056;
Kd = 1.6935;

fprintf('=== COMPLIANCE VALUES COMPARISON ===\n\n');

fprintf('My values:\n');
fprintf('  CLVS: %.8f L/mmHg\n', my_CLVS);
fprintf('  CLVD: %.6f L/mmHg\n', my_CLVD);

fprintf('\nFriend''s values:\n');
fprintf('  CLVS: %.8f L/mmHg\n', friend_CLVS);
fprintf('  CLVD: %.6f L/mmHg\n', friend_CLVD);

% Calculate implied pressures
my_pressure = Ks / my_CLVS;
friend_pressure = Ks / friend_CLVS;

fprintf('\nImplied pressures from CLVS:\n');
fprintf('  My pressure: %.4f mmHg\n', my_pressure);
fprintf('  Friend''s pressure: %.4f mmHg\n', friend_pressure);

% Calculate differences
CLVS_diff = abs(my_CLVS - friend_CLVS) / friend_CLVS * 100;
CLVD_diff = abs(my_CLVD - friend_CLVD) / friend_CLVD * 100;
pressure_diff = abs(my_pressure - friend_pressure) / friend_pressure * 100;

fprintf('\nPercentage differences:\n');
fprintf('  CLVS difference: %.2f%%\n', CLVS_diff);
fprintf('  CLVD difference: %.2f%%\n', CLVD_diff);
fprintf('  Pressure difference: %.2f%%\n', pressure_diff);

% Check which values are more reasonable
fprintf('\nAnalysis:\n');
fprintf('My CLVS is %.2f%% different from friend''s\n', CLVS_diff);
fprintf('My CLVD is %.2f%% different from friend''s\n', CLVD_diff);

if CLVS_diff < 10 && CLVD_diff < 10
    fprintf('Both sets of values are reasonably close.\n');
    fprintf('The differences may be due to:\n');
    fprintf('  1. Different simulation parameters\n');
    fprintf('  2. Different convergence criteria\n');
    fprintf('  3. Different averaging methods\n');
    fprintf('  4. Rounding differences\n');
else
    fprintf('There are significant differences between the values.\n');
end

% Check consistency with constants
my_consistency_CLVS = abs(Ks - my_CLVS * my_pressure);
my_consistency_CLVD = abs(Kd - my_CLVD * my_pressure);
friend_consistency_CLVS = abs(Ks - friend_CLVS * friend_pressure);
friend_consistency_CLVD = abs(Kd - friend_CLVD * friend_pressure);

fprintf('\nConsistency check (should be close to 0):\n');
fprintf('My CLVS consistency: %.8f\n', my_consistency_CLVS);
fprintf('My CLVD consistency: %.8f\n', my_consistency_CLVD);
fprintf('Friend''s CLVS consistency: %.8f\n', friend_consistency_CLVS);
fprintf('Friend''s CLVD consistency: %.8f\n', friend_consistency_CLVD);

fprintf('\nRecommendation:\n');
if my_consistency_CLVS < friend_consistency_CLVS && my_consistency_CLVD < friend_consistency_CLVD
    fprintf('My values are more consistent with the calculated constants.\n');
    fprintf('Use: CLVS = %.8f, CLVD = %.6f\n', my_CLVS, my_CLVD);
elseif friend_consistency_CLVS < my_consistency_CLVS && friend_consistency_CLVD < my_consistency_CLVD
    fprintf('Friend''s values are more consistent with the calculated constants.\n');
    fprintf('Use: CLVS = %.8f, CLVD = %.6f\n', friend_CLVS, friend_CLVD);
else
    fprintf('Both sets of values are reasonably consistent.\n');
    fprintf('Either set could be used, but friend''s values are slightly higher.\n');
end
