

%Calculate and print cardiac output
%Cardiac output = average flow over one cardiac cycle
%Use the last few cycles to get steady-state value
cycles_to_use = 4; % Use last 4 cycles
cycle_length = round(T/dt); % Number of time steps per cycle
start_idx = klokmax - cycles_to_use * cycle_length + 1;
cardiac_output = mean(QAo_plot(start_idx:end));
fprintf('Cardiac Output: %.2f L/min\n', cardiac_output);

%Now plot results in one figure 
%with QAo(t) in upper frame
% and Psa(t) in lower frame
figure('color','white')
subplot(2,1,1), plot(t_plot,QAo_plot,'linewidth',2)
xlabel('TIME - minutes')
ylabel('Aortic Flow (L/m)')
title('Aortic Flow')
grid on;
subplot(2,1,2), plot(t_plot,Psa_plot,'linewidth',2)
xlabel('TIME - Minutes')
ylabel('Blood Pressure - mmHg')
TITLE=['Arterial Blood Pressure'];
title(TITLE)
grid on,
axis([0, max(t_plot), min(Psa_plot)-10, max(Psa_plot)+10]);
