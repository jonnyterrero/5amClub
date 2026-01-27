function [t, x] = two_step_unit_function(t0, t1, A, T_max, dt)
% TWO_STEP_UNIT_FUNCTION - Creates a rectangular pulse (two-step unit function)
%
% Syntax: [t, x] = two_step_unit_function(t0, t1, A, T_max, dt)
%
% Inputs:
%   t0    - Step ON time (seconds) - pulse starts here
%   t1    - Step OFF time (seconds) - pulse ends here
%   A     - Step amplitude (default: 1)
%   T_max - Maximum time for simulation (default: 1 second)
%   dt    - Time step size (default: 0.001 seconds)
%
% Outputs:
%   t     - Time vector
%   x     - Two-step unit function (rectangular pulse)
%
% Example:
%   [t, x] = two_step_unit_function(0.3, 0.6, 1, 1, 0.001);
%   plot(t, x, 'LineWidth', 2);
%   xlabel('Time (s)');
%   ylabel('Amplitude');
%   title('Two-Step Unit Function (Rectangular Pulse)');
%   grid on;

% Set default values if not provided
if nargin < 5, dt = 0.001; end
if nargin < 4, T_max = 1; end
if nargin < 3, A = 1; end
if nargin < 2, error('At least t0 and t1 must be provided'); end

% Validate inputs
if t1 <= t0
    error('t1 must be greater than t0');
end

% Create time vector
N = ceil(T_max / dt);
n = 0:(N-1);
t = n * dt;

% Create two-step unit function (rectangular pulse)
% Step ON at t0, Step OFF at t1
x = A * (t >= t0) .* (t <= t1);

end
