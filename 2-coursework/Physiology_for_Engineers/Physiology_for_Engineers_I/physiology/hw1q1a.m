% Blood Pressure Simulation - Main Runner
% This script runs the complete blood pressure simulation system
% 
% Core files:
% - in_sa.m: Initialization and parameter setup
% - QAo_now.m: Aortic flow calculation
% - Psa_new.m: Arterial pressure calculation  
% - sa.m: Main simulation loop and plotting

clear all
close all
clc

fprintf('=== Blood Pressure Simulation System ===\n');
fprintf('Starting simulation...\n\n');

% Run the main simulation
sa

fprintf('\n=== Simulation Complete ===\n');
fprintf('Results plotted in figure window.\n');
