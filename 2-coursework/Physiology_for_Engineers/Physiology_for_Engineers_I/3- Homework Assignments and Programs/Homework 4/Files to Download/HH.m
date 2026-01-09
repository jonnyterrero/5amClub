%filename HH.m
%numerical solution of the space-clamped Hodgkin-Huxley equations
clear 
close all
clc
global check;
global t1p t2p ip; %parameters for the function izero(t)
in_HH
in_mhnv

   
    for klok=1:klokmax
        t=klok*dt;                      %note time
        m=snew(m,alpham(v),betam(v),dt); %update m
        h=snew(h,alphah(v),betah(v),dt); %update h
        n=snew(n,alphan(v),betan(v),dt); %update n
        gNa=gNabar*(m^3)*h;    %sodium conductance
        gK =gKbar*(n^4);    %potassium conductance
        g=gNa+gK+gLbar;         %total conductance
        gE=gNa*ENa+gK*EK+gLbar*EL;         %gE=g*E
        %save old value of v for checking purposes:
        v_old=v;
        %update v:
        v=(v+(dt/C)*(gE+izero(t)))/(1+(dt/C)*g);
        if(check)
            E=gE/g;
            chv=C*(v-v_old)/dt+g*(v-E)-izero(t);
        end
        %store results for future plotting:
        mhn_plot(:,klok)=[m h n]';
        v_plot(klok)=v;
        t_plot(klok)=t;
    end
    figure('color','w')
    TITLE=['Impulse = ',num2str(ip),' uA' ];
    subplot(2,1,1),plot(t_plot,v_plot,'linewidth',2)
    xlabel('mSec','FontSize',14,'FontWeight','bold')
    ylabel('mV','FontSize',14,'FontWeight','bold')
    title(TITLE,FontSize=18,FontWeight="bold")
    subplot(2,1,2),plot(t_plot,mhn_plot, 'linewidth',2)
    ylabel('Percent Open Gates','FontSize',14,'FontWeight','bold')
    xlabel('mSec','FontSize',14,'FontWeight','bold')
    title('Gate Openings','FontSize',18,'FontWeight','bold')
    legend('m','h','n')

