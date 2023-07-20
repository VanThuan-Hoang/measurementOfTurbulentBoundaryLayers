%% Get data
% Van Thuan Hoang
% May 2023

clear; %close all; 
clc; 

%% initial parameters
fontSize = 14; lineWidth = 1.5;

%% Traveser setup 
% Adjust serial port address
% on MACOS it will look similar to '/dev/tty.usbserial-...'
% on Windows it will be a COM port, 'COM...'
% make sure the baud rate matches the arduino
% to list Com port: serialportlist

try
   stepperMotor=serialport('COM10', 57600);
   disp('Port: COM10')
catch exception
   stepperMotor=serialport('COM1', 57600);
   disp('Port: COM1')
end

configureTerminator(stepperMotor,"LF"); %identify end of the line from serial arduino
configureCallback(stepperMotor,"terminator",@ReadSerialInput); 

%% Initial setup to read data from the laser sensor
clear s
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1', 0, 'voltage'); % hot-wire sensor
addAnalogInputChannel(s,'Dev1', 1, 'voltage'); % pitot
addAnalogInputChannel(s,'Dev1', 2, 'voltage'); % laser displacement sensor

Fs_hotWire = 40e3;      % hertz 
Ts_hotWire = 30;        % seconds
Fs_pitot = 10e3;        % hertz
Ts_pitot = 30;          % seconds 
Fs_laser = 10e3;        % hertz
Ts_laser = 0.5;         % seconds
Fs_laserAcurate = 10e3; % hertz
Ts_laserAccurate = 2;   % seconds
connectorNum = 2;

checkingDuration = 4;
actualHomeDistance = 0;

%% Set up a TraverseRemote

X='3480'; RPM = '200'; Y = '0';
X='3810'; RPM = '200'; Y = '0';
X='4110'; RPM = '200'; Y = '0';
X='4020'; RPM = '200'; Y = '0';
%X='3810'; RPM = '200'; Y = '260';
%X='3570'; RPM = '350'; Y = '0';

surfaceLocation = SurfaceLocation(X,Y,RPM)
probeAdjustment = 0.0; % distance for the hot-wire to the lowest position of the hot-wire probe
homeDistance = 135;

s.Rate = Fs_laser; s.DurationInSeconds = Ts_laser;
clear traverseRemote
pause(0.1)

traverseRemote = TraverseThebarton(s, connectorNum, stepperMotor, surfaceLocation, homeDistance, actualHomeDistance,Fs_laser,Ts_laser);

traverseRemote.dispLocation
%traverseRemote.getHomeDistance

%% Set zero location
moveDirection = traverseRemote.goHome;
traverseRemote.dispLocation

if abs(traverseRemote.distanceToSensor - homeDistance) < 1 
    writeline(stepperMotor, 'S');

    % note that the Zero is set
    actualHomeDistance = traverseRemote.distanceToSensor;
    s.Rate = Fs_laser; s.DurationInSeconds = Ts_laser;
    clear traverseRemote
    pause(0.1)
    traverseRemote = TraverseThebarton(s, connectorNum, stepperMotor, surfaceLocation, homeDistance, actualHomeDistance,Fs_laser,Ts_laser);    
    disp(' ')
    disp(['--------------- Zero location is set at ' num2str(traverseRemote.actualHomeDistance) ' mm from the sensor'])
else
    disp('No zero location is set! Please move it manually')
end

sdfsdfdsf

%% To move up and down manually
%{

%UP
moveDirection = 1;
%DOWN
%moveDirection = -1;

stepMove = 20000;

%stepMove = 5000;
%stepMove = 2000;
%stepMove = 1000;
%stepMove = 500;
%stepMove = 200;
%stepMove = 100;

stepMove = moveDirection*stepMove;

if stepMove > 0
    comandStr = 'U'; 
else
    comandStr = 'D'; 
end
comandStr = [comandStr num2str(abs(stepMove))];
disp(comandStr)
pause(0.2)
writeline(stepperMotor, comandStr); check = MovementWait(traverseRemote);

traverseRemote.dispLocation

%sdfdf
%}

%% To move left and wright manually
%{

%disp("'Y10' to move to the 10-mm location in the spanwise axis, Y at the middle point varies ")
%disp("'L100' or 'R100' to move 100 steps in the left and righ direction referece to flow direction")

%comandStr = 'Y260';
comandStr = 'Y0';
disp(comandStr)
writeline(stepperMotor, comandStr); check = MovementWait(traverseRemote);

sdfsdfsdf
%}

%% To move automatically
%{

%clc
%targetLocation = 140;
%targetLocation = 137;
%targetLocation = 130;
%targetLocation = 50;
%targetLocation = 20;
%targetLocation = 15;
%targetLocation = 10;
%targetLocation = 5;
%targetLocation = 4;
%targetLocation = 3;
%targetLocation = 1;
%targetLocation = 0.5;
%targetLocation = 0.2;
%targetLocation = 0.1;
%targetLocation = -0.2;
%targetLocation = -0.4;

targetLocation = 130; % for calibration

%targetLocation = 5;
%targetLocation = 0.5;
%targetLocation = 0.3;
%targetLocation = 0.15;
%targetLocation = -0.15;
%targetLocation = -0.3;
disp(' ')
disp(['Target location: ' num2str(targetLocation) ' mm from the surface'])

moveDirection = traverseRemote.move(targetLocation, moveDirection);

traverseRemote.dispLocation

%traverseRemote.distanceToSensor
%traverseRemote.actualHomeDistance
%traverseRemote.surfaceLocation


%sdfsdfsdf
%}

%% Calibration
%{

% MAKE SURE THE PROBE LOCATION CORRECT
targetLocation = 200; % for calibration
moveDirection = traverseRemote.move(targetLocation, moveDirection); 
check = MovementWait(traverseRemote);

maker = '--+k';
maker = '--+b';
maker = '--+c';
%maker = '--+r';
%maker = '--+m';
%maker = '--+g';
%maker = '--ok';

% the serial number of the probe
serialNo = '90555P0151';                        % serial number of hot-wire in use

% revolutions of the wind tunnel
RPM = [0,100,150,200,250,300,350,400,450,500,550];
numRPM = length(RPM);

% directory
todayStr = char(today('datetime'));
time1 = clock; if time1(3) < 10, todayStr = [char(num2str(time1(3))), todayStr(3:end)]; end %clear time1

measuredTime = clock;
timeStr = ['-' num2str(measuredTime(4)) 'h-' num2str(measuredTime(5)) 'p'];
directoryName = ['data\' todayStr '\calibration_' todayStr timeStr '\'];
if ~isfolder(directoryName)
    mkdir(directoryName);
end

str = [directoryName '\measureTime.mat']; save(str,'measuredTime');

disp('---------------------------------------------------------------------')

caseName = '0';
controlName = 'calibration';
% Density calculation and save the temperature, the pressure, and the density
rho = Rho(0,directoryName,controlName,0,0,caseName);   

% Collecting data

% create a sound named A
numT = 9000;
t = 0:1/numT:0.6;
soundA = sin(2*pi*440*t);

tic
indexRPM = 1;%numRPM;
disp('------------------------------------------------------------');
while indexRPM <= numRPM %>= 1
        
        sound(soundA,numT); pause(0.8); sound(soundA,numT);
        str = ['Press Yes for the new RPM of ', num2str(RPM(indexRPM))];    
        answer = questdlg(str,'Action Menu','No','Repeat','Yes','Yes');
        % Handle response
        switch answer
            case 'Yes'
                disp(['Yes, the data for the RPM of ' num2str(RPM(indexRPM)) ' is collecting ...']);
            case 'Repeat'
                indexRPM = indexRPM - 1;
                disp(['Repeat! The data for the RPM of ' num2str(RPM(indexRPM)) ' is collecting ...']);
            case 'No'
                disp('No, stop')
                break
        end

        sound(soundA,numT); 
        
        if (indexRPM == 2), pause(15) ; end % special at RPM = 50 because taking time from 0 m/s
        
        % take a reading        
        s.Rate = Fs_pitot; s.DurationInSeconds = checkingDuration;          % Duration of checking
        [data,~] = startForeground(s);
        
        % is the flow stable        
        currentPressure = abs( mean(data(:,2)) ); 
        curretVelocity = (2*currentPressure*133.322368/rho).^0.5;

        lastVelocity = curretVelocity + 10;
        count = 0;
        while abs(curretVelocity - lastVelocity) > 0.03 && count<10  % 0.03 s is checked
            count = count + 1;
            
            lastVelocity = curretVelocity;
            
            pause(1); % 1s is checked with checkingDuration of 4s to have the best value with the error of U < 0.03 m/s
            s.Rate = Fs_pitot; s.DurationInSeconds = checkingDuration;          % Duration of checking
            [data,~] = startForeground(s);
            currentPressure = abs( mean(data(:,2)) ); 
            curretVelocity = (2*currentPressure*133.322368/rho).^0.5;
            
            disp(['Being stable after ' num2str(count*(checkingDuration+1)) ' (s) at ' num2str(curretVelocity) ' m/s' ]);
        end 
        %disp('----------------------------');
        s.Rate = Fs_pitot; s.DurationInSeconds = Ts_pitot;         % Duration of reading
        [data,~] = startForeground(s);
        
        % save data
        voltageTemp = data(:,1);               
        str = [directoryName 'calibartionVoltage_RPM',num2str(RPM(indexRPM)),'_wireNo_', serialNo ,'.mat']; % save hotwire recording to harddrive
        save(str,'voltageTemp');        
        
        pressureTemp = data(:,2);
        str = [directoryName 'calibrationPressure_RPM',num2str(RPM(indexRPM)),'_wireNo_', serialNo ,'.mat']; % save hotwire recording to harddrive
        save(str,'pressureTemp');
        
        disp(['The mean hot-wire votage (V)  : ' num2str(mean(voltageTemp))]);
        disp(['The mean pitot pressure (Torr): ' num2str(mean(mean(pressureTemp)))]);
        disp('------------------------------------------------------------');
        
        clear str data    
        
        indexRPM = indexRPM + 1;
end

toc
sound(soundA,numT); pause(0.5); sound(soundA,numT); pause(0.5); sound(soundA,numT);
msgbox('Calibration Completed');

disp(['The measurement at ' num2str(measuredTime(4)) 'h-' num2str(measuredTime(5)) 'p' ])
 

% load data and estimate the coefficients
numFigre = 301;
%directoryName = ['data\' todayStr '\calibration_' todayStr '-' timeStr '\'];

% load data
voltageMean0 = zeros(1,numRPM);                       % voltage read from the HWP
P0 = zeros(1,numRPM);                                 % pressure read from the barometer
for indexRPM = 1:numRPM
    str = [directoryName 'calibartionVoltage_RPM',num2str(RPM(indexRPM)),'_wireNo_', serialNo ,'.mat']; % save hotwire recording to harddrive
    if isfile(str)
        voltage = importdata(str,'voltageTemp');   
        voltageMean0(indexRPM) = mean(voltage);
    else
        voltageMean0(indexRPM) = -1;
    end
        
    str = [directoryName 'calibrationPressure_RPM',num2str(RPM(indexRPM)),'_wireNo_', serialNo ,'.mat']; % save hotwire recording to harddrive
    if isfile(str)
        pressure = importdata(str,'pressureTemp');
        P0(indexRPM) = mean(pressure);
    else
        P0(indexRPM) = -1;
    end
    
end
% at zero velocity
P = P0 - P0(1);
voltageMean = voltageMean0;

% velocity
str = [directoryName 'rho_RPM0_calibration_Y0mm_X0mm_case0.mat'];
rho = importdata(str);
baratronVelocity = (2*abs(P)*133.322368/rho).^0.5;

str = [directoryName 'humidity_RPM0_calibration_Y0mm_X0mm_case0.mat'];
humidity = importdata(str);
str = [directoryName 'temperature_RPM0_calibration_Y0mm_X0mm_case0.mat'];
T = importdata(str);
str = [directoryName 'pressureABS_RPM0_calibration_Y0mm_X0mm_case0.mat'];
pAbient = importdata(str);

% plot results
figure(numFigre); 
plot(voltageMean,baratronVelocity,maker); grid on; hold on;

set(gca,'FontSize',14);
xlabel('hot-wire voltage [V]');
ylabel('velocity [m/s]');
title({['Calibartion curve for hot-wire ' serialNo],['at ' timeStr ' on ' todayStr]});

%sdfsdf
% determine 5th order poly coefficients
coeffs = polyfit(voltageMean,baratronVelocity,5);

% save data
fileName = [directoryName 'coeffs_wireNo_',serialNo,'.mat'];
save(fileName, 'coeffs');

fileName = [directoryName 'calibrationVelocity_wireNo_',serialNo, '.mat'];
save(fileName, 'baratronVelocity');

fileName = [directoryName 'calibrationVoltage_wireNo_' serialNo '.mat'];
save(fileName, 'voltageMean');

%pAbient 
[pAbient*1e-3 T rho humidity]
%}

% -------------------------------------------------------------------------
%% Collect data
%%{

% Initial parameters
clear serialNo RPM X Y Z d controlName caseName caseDirectory calibrationFileName marker
[serialNo, RPM, X, Y, Z, d, controlName, caseName, caseDirectory, calibrationFileName, marker] = InputParameters();

surfaceLocation = SurfaceLocation(X,Y,RPM);
probeAdjustment = 0.0; % distance for the hot-wire to the lowest position of the hot-wire probe
homeDistance = 135;

% Set up a TraverseRemote
s.Rate = Fs_laser; s.DurationInSeconds = Ts_laser;
clear traverseRemote
pause(0.1)
traverseRemote = TraverseThebarton(s, connectorNum, stepperMotor, surfaceLocation, homeDistance, actualHomeDistance,Fs_laser,Ts_laser);
traverseRemote.dispLocation
pause(0.2)

% Enter ambient parameters
fileName = [caseDirectory '\rho_RPM' num2str(RPM) '_' controlName '_Y' num2str(Y) 'mm_X' num2str(X) 'mm_case' caseName '.mat'];
if ~isfile(fileName)
    rho = Rho(RPM,caseDirectory,controlName,X,Y,caseName);
else
    load(fileName);
end

% calibration coefficients
coeffs = importdata(calibrationFileName);
measuredTime = clock;

fileName = [caseDirectory, '\measuredTime.mat']; save(fileName,'measuredTime');
fileName = [caseDirectory, '\X.mat']; save(fileName,'X'); 
fileName = [caseDirectory, '\Y.mat']; save(fileName,'Y'); 
fileName = [caseDirectory, '\folderDirectory.mat']; save(fileName,'caseDirectory');
fileName = [caseDirectory, '\orificeDiameter.mat']; save(fileName,'d');

% Collecting
maxIndexZ = length(Z);
writeline(stepperMotor, 'U2000'); moveDirection = 1;

if strcmp(RPM,'350')
    xlimits = [0.1 200]; yUlimits = [0 11]; yUrmsLimits = [0 1.2];
elseif strcmp(RPM,'200')
    xlimits = [0 150]; yUlimits = [0 6]; yUrmsLimits = [0 1];
end

if strcmp(RPM,'525')
    Zsmall = 1.0;
else
    Zsmall = 1.3;
end

currentZ = Z(1);
currentUrms = 0;
maxUrms = 0;
deltaZ = 0.1;

index = 0;
%maxIndex = 40;
maxIndex = maxIndexZ;
currentZmin = -0.2;
Uback1 = 0;
Uback2 = Uback1;
Uback3 = Uback2;
%--------------------------------------------------------------------------
% toc; index = index - 1;
tic
while index < maxIndex && currentZ > currentZmin % this loops through all the wall heights after y = 0

    index = index + 1;
    fileName = [caseDirectory, '\voltagePoint',num2str(index),'.mat'];    

    if ~isfile(fileName)
    %----------------------------------------------------------------------
%{
    if currentZ <= Zsmall
        if urms >= currentUrms
            deltaZ = 0.1;
        else
            deltaZ = 0.05;
        end
        if strcmp(RPM,'200')
            deltaZ = 0.1;
        end

        if strcmp(RPM,'520') && currentZ < 0.8
            deltaZ = 0.05;
        end


        currentUrms = urms;            

        if currentUrms > maxUrms
            maxUrms = currentUrms;
        end

        if currentUrms < 0.6 * maxUrms
            break
        end

        targetLocation = currentZ - deltaZ;
    else
        if index <= maxIndexZ
            targetLocation = Z(index); 
        else
            targetLocation = currentZ - deltaZ;
        end
    end
%}
    
    % stop condition
    %if index > 4, Uback3 = Uback2; Uback2 = Uback1; Uback1 = U;
    %elseif index==4, Uback1 = U;
    %elseif index==3, Uback2 = U;
    %elseif index==2, Uback3 = U;
    %end

    %if index > 10 && U > Uback3, break; end
    
    targetLocation = Z(index);

    currentZ = targetLocation;
    Z0(index) = currentZ;
    if currentZ > 140
        actualZ(index) = currentZ;
    else
        actualZ(index) = traverseRemote.currentLocation;
    end
    % step to wall location
    disp('----------------------------------------------------------------');
    strDis = ['Moving to y = ' Y ' mm, z = ' num2str(currentZ,'%0.2f') ' mm. Please wait...'];                     
    disp(strDis);

    moveDirection = traverseRemote.move(targetLocation, moveDirection);
    check = MovementWait(traverseRemote);       
    
    % take measurement                    
    clear hotwireVoltage;
    s.Rate = Fs_hotWire; s.DurationInSeconds = Ts_hotWire;
    [data,~] = startForeground(s); 
    s.Rate = Fs_laser; s.DurationInSeconds = Ts_laser;

    hotwireVoltage = data(:,1);                    
    save(fileName,'hotwireVoltage'); 
                    
    % plot mean u and TI    
        clear velocity;
        velocity = coeffs(1).*hotwireVoltage.^5 + coeffs(2).*hotwireVoltage.^4 ...
            + coeffs(3).*hotwireVoltage.^3 + coeffs(4).*hotwireVoltage.^2 ...
            + coeffs(5).*hotwireVoltage + coeffs(6).*ones(size(hotwireVoltage));
 
        U = mean(velocity);
        urms = rms(velocity-U);
    
        fig = figure(2); fig.Position = [1100 92 600 400];    
        semilogx(currentZ,urms,marker,'LineWidth',lineWidth); grid on; hold on;
        ylim(yUrmsLimits); xlim(xlimits);
        set(gca,'FontSize',fontSize); set(gcf,'color','w');
        xlabel('Z [mm]','FontWeight','bold'); ylabel('u_{rms} [m/s]','FontWeight','bold');
        title('Turbulent intensity profiles');
        pause(0.1);
        
        fig = figure(1); fig.Position = [1100 550 600 400];    
        semilogx(currentZ,U,marker,'LineWidth',lineWidth); grid on;  hold on;
        ylim(yUlimits); xlim(xlimits);
        set(gca,'FontSize',fontSize); set(gcf,'color','w');
        xlabel('Z [mm]','FontWeight','bold'); ylabel('U [m/s]','FontWeight','bold');
        title(['Velocity profiles, U = ' num2str(U,'%0.4f') ' m/s']);
    %----------------------------------------------------------------------        
    end
end
toc
msgbox('Data colection completed');

Z = Z0;
fileName = [caseDirectory, '\Z.mat']; save(fileName,'Z'); 
fileName = [caseDirectory, '\actualZ.mat']; save(fileName,'actualZ');

writeline(stepperMotor, 'U20000'); moveDirection = 1;
check = MovementWait(traverseRemote);

targetLocation = 5;
moveDirection = traverseRemote.move(targetLocation, moveDirection);
check = MovementWait(traverseRemote);
sdfsdfdf

%}









