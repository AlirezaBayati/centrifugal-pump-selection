%% Dataset‑1 Analysis  |  Alireza Bayati
clc; clear; close all

%% 1. Constants & unit factors
g       = 32.174;            % ft/s^2
gamma   = 62.4;              % lbf/ft^3  (specific weight of water, 80 °F)
Hz      = 3;                 % static lift, ft
D       = 6/12;              % pipe diameter, ft
eta_m   = 0.90;              % motor efficiency
PF      = 0.875;             % power factor
V_line  = 460;               % V (3‑phase)
N_rpm   = 1750;              % pump speed, rpm
gpm2cfs = 0.00222801;        % 1 gpm → ft³/s

A = pi*D^2/4;                % pipe area, ft²

%% 2. Raw dataset
Q_gpm  = [0 500 800 1000 1100 1200 1400 1500];
Ps_psi = [0.65 0.25 -0.35 -0.92 -1.24 -1.62 -2.42 -2.89];  % suction
Pd_psi = [53.3 48.3 42.3 36.9 33.0 27.8 15.3 7.3];         % discharge
I_amp  = [18 26.2 31 33.9 35.2 36.3 38 39];

%% 3. Conversions
Q_cfs  = Q_gpm * gpm2cfs;      % ft³/s
v      = Q_cfs / A;            % ft/s

dP_psi = Pd_psi - Ps_psi;      % ΔP, psi
Hp     = dP_psi * 144 / gamma; % pressure head, ft
Hv     = zeros(size(Hp));      % velocity head (≈0, equal diam.)
Htot   = Hp + Hv + Hz;         % total head, ft

%% 4. Powers & efficiencies
P_hyd   = gamma .* Q_cfs .* Htot / 550;   % hydraulic HP
P_in    = sqrt(3)*V_line .* I_amp .* PF / 746; % electric HP
P_mech  = eta_m * P_in;                    % shaft HP

eta_hyd  = P_hyd ./ P_mech;
eta_over = P_hyd ./ P_in;
Ns_US    = N_rpm .* sqrt(Q_gpm) ./ (Htot.^0.75);

%% 5. 2nd‑order polynomial fits
Q_fit  = linspace(min(Q_gpm), max(Q_gpm), 300);
poly_H   = polyfit(Q_gpm, Htot , 2);
poly_P   = polyfit(Q_gpm, P_hyd, 2);
poly_Ns  = polyfit(Q_gpm, Ns_US, 2);
poly_eta = polyfit(Q_gpm, eta_over*100, 2);   % overall efficiency in %

%% 6. Plots
set(groot, 'defaultLineLineWidth',1.5, 'defaultAxesFontSize',10)

figure('Position',[100 100 960 720]);

subplot(2,2,1)
plot(Q_gpm, Htot,'o'); hold on
plot(Q_fit, polyval(poly_H,Q_fit),'--');
xlabel('Flow Rate  (gpm)'); ylabel('Total Head  (ft)');
legend('Data','Quadratic fit','Location','best'); grid on

subplot(2,2,2)
plot(Q_gpm, P_hyd,'o'); hold on
plot(Q_fit, polyval(poly_P,Q_fit),'--');
xlabel('Flow Rate  (gpm)'); ylabel('Hydraulic Power  (HP)');
legend('Data','Quadratic fit','Location','best'); grid on

subplot(2,2,3)
plot(Q_gpm, Ns_US,'o'); hold on
plot(Q_fit, polyval(poly_Ns,Q_fit),'--');
xlabel('Flow Rate  (gpm)'); ylabel('Specific Speed  (US)');
legend('Data','Quadratic fit','Location','best'); grid on

subplot(2,2,4)
plot(Q_gpm, eta_over*100,'o'); hold on
plot(Q_fit, polyval(poly_eta,Q_fit),'--');
xlabel('Flow Rate  (gpm)'); ylabel('Overall Efficiency  (%)');
legend('Data','Quadratic fit','Location','best'); grid on; ylim([0 100])

sgtitle('Dataset‑1 Performance Curves (quadratic fits)');

%% 7. Export figure for Report
exportgraphics(gcf, 'dataset1_plots.png', 'Resolution', 300);


%% 8. Result check for 800 gpm
idx = Q_gpm == 800;
disp(table(Q_gpm(idx)', Htot(idx)', P_hyd(idx)', eta_over(idx)', ...
    'VariableNames',{'Q_gpm','H_tot_ft','P_hyd_HP','eta_over'}));
