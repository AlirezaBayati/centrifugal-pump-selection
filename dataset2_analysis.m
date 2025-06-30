%% Dataset‑2 Analysis  |  Alireza Bayati
clc; clear; close all

%% 1. Constants
g       = 9.81;               % m/s^2
rho     = 997;                % kg/m^3  (25 °C water)
D       = 0.15;               % m (suction & discharge)
N_rpm   = 1100;               % pump speed
Ns_fac  = N_rpm;              % convenience
A_pipe  = pi*D^2/4;           % m^2
Hz      = 0;                  % elevation difference

%% 2. Raw dataset (order as in project PDF)
Flow_LPM = [254 228 197 177 163 155 129 127 99 75 50 27 2];
Ps_bar   = [-0.08 -0.07 -0.05 -0.05 -0.04 -0.04 -0.03 -0.03 -0.02 -0.02 -0.02 -0.01 -0.01];
Pd_bar   = [0.06  0.11  0.18  0.25  0.25  0.21  0.29  0.29  0.32  0.34  0.35  0.36  0.36];
Torque_Nm = [2.1 2.0 1.9 1.8 1.7 1.7 1.5 1.5 1.4 1.2 1.1 1.0 0.9];
Pin_kW    = [0.52 0.50 0.48 0.47 0.46 0.45 0.42 0.42 0.40 0.38 0.36 0.33 0.31];

%% 3. Conversions
Q_m3s = Flow_LPM ./ (1000*60);                 % m^3/s  (FULL precision)
v     = Q_m3s / A_pipe;                        % m/s
dP_Pa = (Pd_bar - Ps_bar) * 1e5;               % Pa
Hp_m  = dP_Pa ./ (rho * g);                    % m  (pressure head)

Htot_m = Hp_m + Hz;                            % m (velocity head ≈0)

%% 4. Power calculations
P_hyd_kW = rho * g .* Q_m3s .* Htot_m / 1000;  % kW
P_mech_kW = 2*pi*N_rpm/60 .* Torque_Nm / 1000; % kW

eta_hyd   = P_hyd_kW ./ P_mech_kW;
eta_over  = P_hyd_kW ./ Pin_kW;

Ns_SI = N_rpm .* sqrt(Q_m3s) ./ (Htot_m .^ 0.75);  % dimensionless

%% 5. Polynomial curve‑fits (2nd order)
Q_fit = linspace(min(Flow_LPM), max(Flow_LPM), 300);

fit_H  = polyfit(Flow_LPM, Htot_m, 2);
fit_Ph = polyfit(Flow_LPM, P_hyd_kW, 2);
fit_Pm = polyfit(Flow_LPM, P_mech_kW, 2);
fit_Ns = polyfit(Flow_LPM, Ns_SI, 2);
fit_Et = polyfit(Flow_LPM, eta_over*100, 2);   % %

%% 6. Plots
set(groot,'defaultLineLineWidth',1.5,'defaultAxesFontSize',10)
figure('Position',[100 100 1000 780]);

subplot(3,2,1)
plot(Flow_LPM, Htot_m, 'o'); hold on
plot(Q_fit, polyval(fit_H,Q_fit),'--');
xlabel('Flow Rate (L/min)'); ylabel('Pump Head (m)');
legend('Data','Quadratic fit','Location','best'); grid on

subplot(3,2,2)
plot(Flow_LPM, P_hyd_kW, 'o'); hold on
plot(Q_fit, polyval(fit_Ph,Q_fit),'--');
xlabel('Flow Rate (L/min)'); ylabel('Hydraulic Power (kW)');
legend('Data','Quadratic fit','Location','best'); grid on

subplot(3,2,3)
plot(Flow_LPM, P_mech_kW, 'o'); hold on
plot(Q_fit, polyval(fit_Pm,Q_fit),'--');
xlabel('Flow Rate (L/min)'); ylabel('Mechanical Power (kW)');
legend('Data','Quadratic fit','Location','best'); grid on

subplot(3,2,4)
plot(Flow_LPM, Ns_SI, 'o'); hold on
plot(Q_fit, polyval(fit_Ns,Q_fit),'--');
xlabel('Flow Rate (L/min)'); ylabel('Specific Speed (SI)');
legend('Data','Quadratic fit','Location','best'); grid on

subplot(3,2,5)
plot(Flow_LPM, eta_over*100, 'o'); hold on
plot(Q_fit, polyval(fit_Et,Q_fit),'--');
xlabel('Flow Rate (L/min)'); ylabel('Overall Efficiency (%)');
legend('Data','Quadratic fit','Location','best'); grid on; ylim([0 100])

sgtitle('Dataset‑2 Performance Curves (quadratic fits)');

%% 7. Export figure 
exportgraphics(gcf, 'plots/dataset2_plots.png', 'Resolution', 300);

%% 8. Display row for 197 L/min
idx = Flow_LPM == 197;
disp(table(Flow_LPM(idx)', Htot_m(idx)', P_hyd_kW(idx)', P_mech_kW(idx)', eta_over(idx)'*100, ...
    'VariableNames',{'Flow_LPM','Head_m','P_hyd_kW','P_mech_kW','Eta_over_%'}));
