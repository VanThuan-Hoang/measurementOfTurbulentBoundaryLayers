function rho = Rho(RPM,directoryName,controlName,X,Y,caseName)

T_ref =  input('Ambient temperature (Celcius): ');
P_ref =  input('Ambient pressure        (hPa): ');
RH_ref = input('Relative humidity         (%): ');
%R_pro =  input('Probe resistance (Ohm)       : '); % 3.4 (typical sensor
%resistance) + 0.5 (lead resistance) Ohm at start: does not change
%R_pro =  3.9; % 55P15
%R_sup = 0.44; % 90 degree support 55H22
%R_wir = 0.2;  % 4m wire A1683

R_air = 287.058;    % Specific gas constant of dry air [J/kgK]
R_vapor = 461.495;  % Specific gas constant of water vapor [J/kgK]

P_sat = 6.1078 * exp(T_ref/(T_ref + 238.3) * 17.2694);
P_vapor = RH_ref/100*P_sat;
P_dryAir = P_ref - P_vapor;

rho = P_dryAir*100/(R_air*(T_ref+273.15)) + P_vapor*100/(R_vapor*(T_ref+273.15));

str = [directoryName '\pressureABS_RPM' num2str(RPM) '_' controlName '_Y' num2str(Y) 'mm_X' num2str(X) 'mm_case' caseName '.mat'];
save(str,'P_ref')

str = [directoryName '\rho_RPM' num2str(RPM) '_' controlName '_Y' num2str(Y) 'mm_X' num2str(X) 'mm_case' caseName '.mat'];
save(str,'rho')

str = [directoryName '\temperature_RPM' num2str(RPM) '_' controlName '_Y' num2str(Y) 'mm_X' num2str(X) 'mm_case' caseName '.mat'];
save(str,'T_ref')

str = [directoryName '\humidity_RPM' num2str(RPM) '_' controlName '_Y' num2str(Y) 'mm_X' num2str(X) 'mm_case' caseName '.mat'];
save(str,'RH_ref')

end