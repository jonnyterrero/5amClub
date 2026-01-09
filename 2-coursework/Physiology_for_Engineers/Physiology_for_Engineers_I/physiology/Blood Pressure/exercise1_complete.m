% Exercise 1: Blood Pressure Simulation Setup
% This script runs the complete Exercise 1 requirements

clear all
close all
clc

fprintf('=== EXERCISE 1: Blood Pressure Simulation Setup ===\n\n');

% Run the main simulation
sa

fprintf('\n=== EXERCISE 1 RESULTS ===\n');
fprintf('a. Plots generated showing aortic flow and arterial pressure\n');
fprintf('b. Compliance adjusted to achieve target blood pressure\n');
fprintf('c. Initial pressure set to diastolic for immediate equilibrium\n');
fprintf('d. Cardiac output calculated and displayed\n\n');

fprintf('=== PARAMETER SUMMARY ===\n');
fprintf('Current Compliance (Csa): %.4f L/mmHg\n', Csa);
fprintf('Initial Pressure: 80 mmHg (diastolic)\n');
fprintf('Systemic Resistance: %.2f mmHg/(L/min)\n', Rs);
fprintf('Heart Rate: 80 bpm\n');
fprintf('Max Aortic Flow: %.0f L/min\n', QMAX);

fprintf('\n=== INSTRUCTIONS FOR SUBSEQUENT EXERCISES ===\n');
fprintf('1. Use Csa = %.4f L/mmHg as the normal compliance value\n', Csa);
fprintf('2. Reset all parameters to normal values except the one being tested\n');
fprintf('3. Always start with Psa = 80 mmHg for immediate equilibrium\n');
fprintf('4. Cardiac output will be automatically calculated and displayed\n');





