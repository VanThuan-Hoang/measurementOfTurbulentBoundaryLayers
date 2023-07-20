function [serialNo, RPM, X, Y, Z, d, controlName, caseName, caseDirectory, calibrationFileName, marker] = InputParameters()

%12-May-2023
%{
RPM = '400'; controlName = 'SmoothCase'; X = '3400'; Y = '0'; caseName = '1'; calibrationTime = '13h-29p'; marker = '+b'; % 1
RPM = '400'; controlName = 'SmoothCase'; X = '3400'; Y = '0'; caseName = '2'; calibrationTime = '13h-29p'; marker = '+m'; % 1
%}

%21-June-2023
%RPM = '350'; controlName = 'SmoothCase'; X = '2910'; Y = '0'; caseName = '1'; calibrationTime = '15h-6p'; marker = '+b'; % 1

%22-June-2023
%RPM = '350'; controlName = 'SmoothCase'; X = '2910'; Y = '0'; caseName = '2'; calibrationTime = '10h-43p'; marker = '+b'; % 1
%RPM = '200'; controlName = 'SmoothCase'; X = '2910'; Y = '0'; caseName = '1'; calibrationTime = '11h-45p'; marker = '+m'; % 1

%RPM = '350'; controlName = 'SmoothCase'; X = '2910'; Y = '0'; caseName = '1sandPaper'; calibrationTime = '14h-24p'; marker = '+c'; % 1
%RPM = '200'; controlName = 'SmoothCase'; X = '2910'; Y = '0'; caseName = '1sandPaper'; calibrationTime = '15h-27p'; marker = '+r'; % 1

%23-June-2023
%RPM = '200'; controlName = 'SmoothCase'; X = '3480'; Y = '0'; caseName = '1'; calibrationTime = '9h-51p';  marker = '+b'; % 1
%RPM = '350'; controlName = 'SmoothCase'; X = '3480'; Y = '0'; caseName = '1'; calibrationTime = '10h-50p'; marker = '+m'; % 1
%RPM = '525'; controlName = 'SmoothCase'; X = '3480'; Y = '0'; caseName = '1'; calibrationTime = '11h-39p'; marker = '+c'; % 1

%RPM = '200'; controlName = 'SmoothCase'; X = '3810'; Y = '0'; caseName = '1'; calibrationTime = '13h-9p';  marker = 'ob';
%RPM = '350'; controlName = 'SmoothCase'; X = '3810'; Y = '0'; caseName = '1'; calibrationTime = '14h-0p';  marker = 'om';
%RPM = '525'; controlName = 'SmoothCase'; X = '3810'; Y = '0'; caseName = '1'; calibrationTime = '14h-49p'; marker = 'oc';

%26-Jun-2023
RPM = '200'; controlName = 'SmoothCase'; X = '4110'; Y = '0'; caseName = '1'; calibrationTime = '9h-35p';  marker = '+b';
RPM = '350'; controlName = 'SmoothCase'; X = '4110'; Y = '0'; caseName = '1'; calibrationTime = '10h-33p';  marker = '+m';
RPM = '525'; controlName = 'SmoothCase'; X = '4110'; Y = '0'; caseName = '1'; calibrationTime = '11h-22p';  marker = '+c';

RPM = '200'; controlName = 'SmoothCase'; X = '3810'; Y = '260'; caseName = '1'; calibrationTime = '12h-50p';  marker = 'ob';
RPM = '350'; controlName = 'SmoothCase'; X = '3810'; Y = '260'; caseName = '1'; calibrationTime = '13h-36p';  marker = 'om';
RPM = '525'; controlName = 'SmoothCase'; X = '3810'; Y = '260'; caseName = '1'; calibrationTime = '14h-26p';  marker = 'oc';

%27-Jun-2023
RPM = '350'; controlName = 'LargeCavity'; X = '3810'; Y = '0'; caseName = '1'; calibrationTime = '11h-2p';  marker = 'sm';
RPM = '350'; controlName = 'LargeCavity'; X = '3810'; Y = '0'; caseName = '2'; calibrationTime = '11h-53p';  marker = '+m';

RPM = '350'; controlName = 'LargeCavity'; X = '3660'; Y = '0'; caseName = '1'; calibrationTime = '13h-27p';  marker = 'sb';

RPM = '350'; controlName = 'LargeCavity'; X = '4020'; Y = '0'; caseName = '1'; calibrationTime = '14h-53p';  marker = 'sg';

%28-Jun-2023
RPM = '350'; controlName = 'LargeCavity'; X = '4020'; Y = '0'; caseName = '2'; calibrationTime = '10h-25p';  marker = 'og';
RPM = '350'; controlName = 'LargeCavity'; X = '3915'; Y = '0'; caseName = '1'; calibrationTime = '12h-4p';  marker = 'om';
RPM = '350'; controlName = 'LargeCavity'; X = '3610'; Y = '0'; caseName = '1'; calibrationTime = '14h-19p';  marker = 'ob';

RPM = '200'; controlName = 'LargeCavity'; X = '3610'; Y = '0'; caseName = '1'; calibrationTime = '15h-10p';  marker = '+b';

%29-Jun-2023
RPM = '350'; controlName = 'LargeCavity'; X = '3610'; Y = '0'; caseName = '2'; calibrationTime = '11h-34p';  marker = '+b';
RPM = '350'; controlName = 'LargeCavity'; X = '3570'; Y = '0'; caseName = '1'; calibrationTime = '13h-3p';  marker = '+m';
RPM = '350'; controlName = 'LargeCavity'; X = '3570'; Y = '0'; caseName = '2'; calibrationTime = '14h-50p';  marker = 'om';

%29-Jun-2023
RPM = '350'; controlName = 'LargeCavitySealed'; X = '3570'; Y = '0'; caseName = '1'; calibrationTime = '10h-1p';  marker = '+b';
RPM = '350'; controlName = 'LargeCavitySealed'; X = '3810'; Y = '0'; caseName = '1'; calibrationTime = '11h-21p';  marker = '+m';
RPM = '350'; controlName = 'LargeCavitySealed'; X = '4020'; Y = '0'; caseName = '1'; calibrationTime = '12h-44p';  marker = '+g';
%--------------------------------------------------------------------------
% the serial number of the probe
serialNo = '90555P0151';                        % serial number of hot-wire in use                      

% no tripping technique
%Z = [ 1, 1.3, 1.7,   2, 2.5,  3,  4,  5,  6,  8, ...
%     10,  13,  17,  20,  25, 30, 40, 50, 60, 70, ...
%     80,  90, 100, 120, 150]; %mm

 % no tripping technique
%Z = [ 1, 1.3, 1.7,  2.3,  3,   4,   5,   7, 10,  15, ...
%     25,  40,  60, 80, 90, 100, 120, 150]; %mm

Z = [0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6, 0.65 0.7 0.75 0.8, 0.9, 1, 1.15 1.3, 1.7,  2.3,  3,   4,   5,   7, 10,  15, ...
     25,  40,  60, 80, 90, 100, 120, 150]; %mm
 
Z = fliplr(Z);

% oriffice diameter
if strcmp(controlName, 'SmoothCase'), d = 0;
else, d = 1.2e-3;
end

% crate a folder to save data
todayStr = char(today('datetime'));
t = clock; if t(3) < 10, todayStr = [char(num2str(t(3))), todayStr(3:end)]; end

folderDirectory = ['data\' todayStr];
if ~isfolder(folderDirectory)
    mkdir(folderDirectory);
end

caseDirectory = [folderDirectory '\RPM' RPM '\' controlName '\Y' num2str(Y) 'mmX' num2str(X) 'mm\case' caseName];
if ~isfolder(caseDirectory)
    mkdir(caseDirectory);
end

% directory of calibration
calDayStr = todayStr;
%calDayStr = '12-May-2023';

calFolderDirectory = ['data\' calDayStr];
calibrationFileName = [calFolderDirectory '\calibration_' calDayStr '-' calibrationTime '\coeffs_wireNo_' serialNo '.mat'];

end