% Verify Compliance Constants Calculation
clear
close all
clc

fprintf('=== VERIFYING COMPLIANCE CONSTANTS ===\n');

% From our previous analysis, we know:
% Normal maximum LV pressure: approximately 112.9 mmHg (from Pressure_Profile_Analysis)
% Normal CLVS: 5e-5 L/mmHg
% Normal CLVD: 0.0150 L/mmHg

% Let's use the values from our previous analysis
max_LV_pressure = 112.9;  % mmHg
CLVS_normal = 5e-5;       % L/mmHg
CLVD_normal = 0.0150;     % L/mmHg

fprintf('Using values from our previous analysis:\n');
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

% Let's also try with a slightly different pressure value to see if we can match
fprintf('\nTrying different pressure values to match friend''s constants:\n');
pressure_to_match_Ks = 0.0052 / CLVS_normal;
pressure_to_match_Kd = 1.5684 / CLVD_normal;

fprintf('Pressure needed to get Ks = 0.0052: %.4f mmHg\n', pressure_to_match_Ks);
fprintf('Pressure needed to get Kd = 1.5684: %.4f mmHg\n', pressure_to_match_Kd);

% Calculate what the pressure should be for exact match
exact_pressure = (0.0052 + 1.5684) / (CLVS_normal + CLVD_normal);
fprintf('Average pressure for exact match: %.4f mmHg\n', exact_pressure);

% Verify the relationship
fprintf('\nVERIFICATION WITH FRIEND''S CONSTANTS:\n');
fprintf('If Ks = 0.0052, then Max_LV_Pressure = %.4f mmHg\n', 0.0052 / CLVS_normal);
fprintf('If Kd = 1.5684, then Max_LV_Pressure = %.4f mmHg\n', 1.5684 / CLVD_normal);

% Check if the constants are consistent
if abs(0.0052 / CLVS_normal - 1.5684 / CLVD_normal) < 0.1
    fprintf('Constants are consistent! Both give similar pressure values.\n');
else
    fprintf('Constants may not be consistent - different pressure values.\n');
end
