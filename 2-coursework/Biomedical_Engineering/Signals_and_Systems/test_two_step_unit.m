% Test script for two_step_unit_function
% This demonstrates how to use the two-step unit function

clear all
close all
clc

% Parameters from original code
t0 = 0.3;          % step ON time (seconds)
t1 = 0.6;          % step OFF time (seconds)
A1 = 1;            % step amplitude
T_max = 1;         % maximum simulation time
dt = 0.001;        % time step

% Generate the two-step unit function
[t, x] = two_step_unit_function(t0, t1, A1, T_max, dt);

% Plot the result
figure;
plot(t, x, 'LineWidth', 2)
xlabel('Time (s)')
ylabel('Amplitude')
title('Two-Step Unit Function (Rectangular Pulse)')
grid on
axis([0 T_max -0.1 1.5])

% Add vertical lines to show step times
hold on
xline(t0, 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('t_0 = %.2f s', t0));
xline(t1, 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('t_1 = %.2f s', t1));
legend('Location', 'best')
hold off
