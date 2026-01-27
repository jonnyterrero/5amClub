N = 1000;
dt = 0.001;
n = 0:(N-1);
t = n*dt;

f = 5;              % frequency (Hz)
A1 = 1;            % amplitude
x1 = A1 * sin(2*pi*f*t); % sinusoidal function
x2 = A1 * sin(2*pi*f*t + pi/2); % sinusoidal function with phase shift

plot(t, x1, t, x2, 'LineWidth', 3)
xlabel('Time (s)')
ylabel('Amplitude')
title('Sinusoidal Function')
grid on
