%filename: sa.m
clear all % clear all variables
close all % and figures
clc       % and Command Window
global T TS TMAX QMAX;
global Rs Csa dt;
in_sa %initialization

   
    for klok=1:klokmax 
      
      t=klok*dt;
      QAo=QAo_now(t);
      Psa=Psa_new(Psa,QAo); %new Psa overwrites old
      %Store values in arrays for future plotting:
      t_plot(klok)=t;
      QAo_plot(klok)=QAo;
      Psa_plot(klok)=Psa;
    end

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