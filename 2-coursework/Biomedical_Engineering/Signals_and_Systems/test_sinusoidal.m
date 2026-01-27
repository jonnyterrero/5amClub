N = 1000;
dt = 0.001;
n = 0:(N-1);
t = n*dt;

f = 5;              % frequency (Hz)
A = 1;              % amplitude
x = A * sin(2*pi*f*t);

plot(t, x, 'LineWidth', 3)
xlabel('Time (s)')
ylabel('Amplitude')
title('Sinusoidal Function')
grid on
