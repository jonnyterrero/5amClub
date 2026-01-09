% Question 6: Valve Malfunction Analysis
clear
close all
clc

% Base parameters
T = 0.0125; Ts = 0.0050; dt = .00005*T; Beats=16*T;
Csa = .00175; Rs = 17.28; Rmi_base = 0.01; RAo_base = 0.01;
AoBkflo = 0.00; Vlvd = .027; Vsad = .825; Pla = 5;
CLVD = 0.0150; CLVS = 5e-5; tauS = .0025; tauD = .005;
Plvi = 5; Psai = 80;

fprintf('=== VALVE MALFUNCTION ANALYSIS ===\n\n');

% Test normal case
Rmi = Rmi_base;
RAo = RAo_base;
sim('Cardio_SA_LV')
t = BloodFlows.time;
Qmi_normal = BloodFlows.signals.values(:,1);
QAo_normal = BloodFlows.signals.values(:,2);
HR = 1/T;
SV_normal = max(VLV) - min(VLV);
CO_normal = HR * SV_normal;

fprintf('NORMAL VALVE FUNCTION:\n');
fprintf('  Mitral resistance (Rmi): %.3f mmHg/(L/min)\n', Rmi);
fprintf('  Aortic resistance (RAo): %.3f mmHg/(L/min)\n', RAo);
fprintf('  Peak mitral flow: %.3f L/min\n', max(Qmi_normal));
fprintf('  Peak aortic flow: %.3f L/min\n', max(QAo_normal));
fprintf('  Cardiac output: %.3f L/min\n', CO_normal);

% Test mitral stenosis (5x resistance)
Rmi = Rmi_base * 5;
RAo = RAo_base;
sim('Cardio_SA_LV')
Qmi_stenotic = BloodFlows.signals.values(:,1);
QAo_stenotic = BloodFlows.signals.values(:,2);
SV_mitral_stenosis = max(VLV) - min(VLV);
CO_mitral_stenosis = HR * SV_mitral_stenosis;

fprintf('\nMITRAL STENOSIS (5x resistance):\n');
fprintf('  Mitral resistance (Rmi): %.3f mmHg/(L/min)\n', Rmi);
fprintf('  Peak mitral flow: %.3f L/min (%.1f%% of normal)\n', max(Qmi_stenotic), max(Qmi_stenotic)/max(Qmi_normal)*100);
fprintf('  Peak aortic flow: %.3f L/min\n', max(QAo_stenotic));
fprintf('  Cardiac output: %.3f L/min (%.1f%% of normal)\n', CO_mitral_stenosis, CO_mitral_stenosis/CO_normal*100);

% Test aortic stenosis (5x resistance)
Rmi = Rmi_base;
RAo = RAo_base * 5;
sim('Cardio_SA_LV')
Qmi_aortic_stenosis = BloodFlows.signals.values(:,1);
QAo_aortic_stenosis = BloodFlows.signals.values(:,2);
SV_aortic_stenosis = max(VLV) - min(VLV);
CO_aortic_stenosis = HR * SV_aortic_stenosis;

fprintf('\nAORTIC STENOSIS (5x resistance):\n');
fprintf('  Aortic resistance (RAo): %.3f mmHg/(L/min)\n', RAo);
fprintf('  Peak mitral flow: %.3f L/min\n', max(Qmi_aortic_stenosis));
fprintf('  Peak aortic flow: %.3f L/min (%.1f%% of normal)\n', max(QAo_aortic_stenosis), max(QAo_aortic_stenosis)/max(QAo_normal)*100);
fprintf('  Cardiac output: %.3f L/min (%.1f%% of normal)\n', CO_aortic_stenosis, CO_aortic_stenosis/CO_normal*100);

% Test severe mitral stenosis (20x resistance)
Rmi = Rmi_base * 20;
RAo = RAo_base;
sim('Cardio_SA_LV')
Qmi_severe = BloodFlows.signals.values(:,1);
SV_severe_mitral = max(VLV) - min(VLV);
CO_severe_mitral = HR * SV_severe_mitral;

fprintf('\nSEVERE MITRAL STENOSIS (20x resistance):\n');
fprintf('  Mitral resistance (Rmi): %.3f mmHg/(L/min)\n', Rmi);
fprintf('  Peak mitral flow: %.3f L/min (%.1f%% of normal)\n', max(Qmi_severe), max(Qmi_severe)/max(Qmi_normal)*100);
fprintf('  Cardiac output: %.3f L/min (%.1f%% of normal)\n', CO_severe_mitral, CO_severe_mitral/CO_normal*100);

% Test severe aortic stenosis (20x resistance)
Rmi = Rmi_base;
RAo = RAo_base * 20;
sim('Cardio_SA_LV')
QAo_severe = BloodFlows.signals.values(:,2);
SV_severe_aortic = max(VLV) - min(VLV);
CO_severe_aortic = HR * SV_severe_aortic;

fprintf('\nSEVERE AORTIC STENOSIS (20x resistance):\n');
fprintf('  Aortic resistance (RAo): %.3f mmHg/(L/min)\n', RAo);
fprintf('  Peak aortic flow: %.3f L/min (%.1f%% of normal)\n', max(QAo_severe), max(QAo_severe)/max(QAo_normal)*100);
fprintf('  Cardiac output: %.3f L/min (%.1f%% of normal)\n', CO_severe_aortic, CO_severe_aortic/CO_normal*100);

fprintf('\n=== ANALYSIS COMPLETE ===\n');
