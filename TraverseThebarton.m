% Traverse activities
classdef TraverseThebarton
    properties
        laserSensor = 0;  
        connectorNum = 0;
        stepperMotor = 0;
        homeDistance = 135;
        surfaceLocation = 0;
        actualHomeDistance = 0;
        fsensor = 10e3;
        Tsensor = 0.5;
    end
    
    methods (Access = public)
        %---------- Constructor
        function obj = TraverseThebarton(laserSensorIn, connectorNumIn, stepperMotorIn, surfaceLocationIn, homeDistanceIn, actualHomeDistanceIn, fsensorIn, TsensorIn)
            obj.laserSensor = laserSensorIn;
            obj.connectorNum = connectorNumIn;
            obj.stepperMotor = stepperMotorIn;
            obj.surfaceLocation = surfaceLocationIn;
            obj.homeDistance = homeDistanceIn;
            obj.actualHomeDistance = actualHomeDistanceIn;            
            obj.fsensor = fsensorIn; 
            obj.Tsensor = TsensorIn;
        end
        
        %---------- Data        
        function getSensor = getSensor(obj), getSensor=obj.laserSensor; end
        function getHomeDistance = getHomeDistance(obj), getHomeDistance=obj.actualHomeDistance; end
        function getHomeLocation = getHomeLocation(obj), getHomeLocation=obj.actualHomeDistance - obj.surfaceLocation; end
        function getSurfaceLocation = getSurfaceLocation(obj), getSurfaceLocation=obj.surfaceLocation; end
        
        %---------- Properties
        function distanceToSensor = distanceToSensor(obj)
            obj.laserSensor.Rate = obj.fsensor; obj.laserSensor.DurationInSeconds = obj.Tsensor;
            laserVoltage = startForeground(obj.laserSensor);
            currentVoltage = mean(laserVoltage(:,obj.connectorNum+1));
            distanceToSensor = voltageToDistance(currentVoltage);
        end
        function currentLocation = currentLocation(obj) 
            currentDistance = obj.distanceToSensor();
            currentLocation = currentDistance - obj.surfaceLocation;
        end        
        function moveDirection = move(obj,targetLocation, moveDirection)            
            targetDistance = targetLocation + obj.surfaceLocation;
            currentDistance = obj.distanceToSensor;                
            deltaDistance = targetDistance - currentDistance;  
            flagStep = sign(deltaDistance);

            if targetDistance > (obj.surfaceLocation-1) && targetDistance<=(obj.homeDistance+5) && obj.actualHomeDistance > 0
                %% Sovel the backlash problem
                currentDistance = obj.distanceToSensor;
                flagStep = sign(targetDistance - currentDistance);
    
                if abs(targetDistance - currentDistance) < 1 && moveDirection*flagStep<0
                    if obj.currentLocation < 1
                        backStep = 1*2000; % up 1 mm
                        moveDirection = 1;
                        MoveTraverse(obj.stepperMotor,backStep,moveDirection); check = MovementWait(obj); obj.print();                       
        
                        currentDistance = obj.distanceToSensor;
                        flagStep = sign(targetDistance - currentDistance);
    
                        backStep
                    else
                        backStep = 1000;                        
                        stepNumber = backStep; moveDirection = -flagStep;
                        MoveTraverse(obj.stepperMotor,stepNumber,moveDirection); check = MovementWait(obj); obj.print();

                        moveDirection = flagStep;
                        MoveTraverse(obj.stepperMotor,stepNumber,moveDirection); check = MovementWait(obj); obj.print();

                        currentDistance = obj.distanceToSensor;
                        flagStep = sign(targetDistance - currentDistance);
    
                        backStep
                    end
                end 

                %% go fast to the destination 
                currentDistance = obj.distanceToSensor;                
                deltaDistance = targetDistance - currentDistance;  
                flagStep = sign(deltaDistance);


                if targetLocation > 2
                    maxIndex = 300;
                    index = 0;  

                    disp('Moving fast')
                    
                    % The traverse goes in one direction and stop when it passed the destination            
                    while (index < maxIndex) && flagStep*deltaDistance > 0 && abs(deltaDistance) > 2 && currentDistance>1 
                        index = index + 1;
                        
                        if flagStep>0
                            commandStr = 'U';
                        else
                            commandStr = 'D';
                        end


                        if abs(deltaDistance) > 5
                            stepNum = floor(abs(deltaDistance)/2*2000);
                        elseif abs(deltaDistance) > 2
                            stepNum = floor(abs(deltaDistance)/2*1000);
                        else
                            stepNum = floor(abs(deltaDistance)/2*400);
                        end

                        if stepNum > 20000
                            stepNum = 20000;
                        end

                        commandStr = [commandStr num2str(stepNum)];
                        writeline(obj.stepperMotor, commandStr); check = MovementWait(obj);

                        currentDistance = obj.distanceToSensor;                
                        deltaDistance = targetDistance - currentDistance;                          

                        moveDirection = flagStep;

                        obj.dispLocation;
                    end
                    %moveDirection = flagStep;
                end

                %% go slowly to the destination
                currentDistance = obj.distanceToSensor;                
                deltaDistance = targetDistance - currentDistance;  
                flagStep = sign(deltaDistance);
                
                disp('Moving slow')

                maxIndex = 3000;
                stepIndex = 0;
                index = 1;    
                counter = 0;    % repeat counter
                maxCounter = 2;

                while index<maxIndex && counter<maxCounter && currentDistance > 0.01%&& checkStop()==0
        
                    stepDelta = TraverseStep(deltaDistance,targetLocation);
    
                    % move
                    if checkStop() == 0
                        stepNumber = stepDelta; moveDirection = flagStep;
                        MoveTraverse(obj.stepperMotor,stepNumber,moveDirection); check = MovementWait(obj); obj.print();
                    else
                        break
                    end
                    stepIndex = stepIndex + flagStep*stepDelta;        
    
                    currentDistance = obj.distanceToSensor;
                    currentLocation = obj.currentLocation;
                    deltaDistance = targetLocation - currentLocation;
                    
                    %stepIndex 
                    %[deltaDistance currentLocation]
                    obj.dispLocation;
    
                    % stop if near the target position 
                    if (abs(deltaDistance) < 0.03 && targetLocation <= 5) || (abs(deltaDistance) < 0.5 && targetLocation > 5)
                        disp(' ')
                        disp(['Target location: ' num2str(targetLocation) ' mm, located at: ' num2str(currentLocation) ' mm, error: ' num2str(abs(deltaDistance)) ' mm']);
                        break
                    end
                    
                    if counter > 1 && abs(deltaDistance) > 5 
                        disp('Wrong direction!');
                        
                        backStep = 2000;
                        %pause(5);
                        if checkStop() == 0
                            stepNumber = backStep; moveDirection = 1;
                            MoveTraverse(obj.stepperMotor,stepNumber,moveDirection); check = MovementWait(obj); obj.print();
                        else
                            break; 
                        end
                        
                        moveDirection = 1;
                        stepIndex = 0;
            
                        currentDistance = obj.distanceToSensor;                
                        deltaDistance = targetDistance - currentDistance;  
                        flagStep = sign(deltaDistance);
                    end
        
                    % repeated if the traverse further passes the destination
                    if flagStep * sign(deltaDistance) < 0 
                        counter = counter + 1;            
                        disp(['The number of times to reach the destination: ' num2str(counter) ', error: ' num2str(deltaDistance) ' mm']);
                        
                        backStep = 2000 + 70*counter;
                        if checkStop() == 0 && counter<maxCounter
                            stepNumber = backStep; moveDirection = 1;
                            MoveTraverse(obj.stepperMotor,stepNumber,moveDirection); check = MovementWait(obj); obj.print();
                        else
                            break;
                        end
                        moveDirection = 1;
                        stepIndex = 0;
            
                        currentDistance = obj.distanceToSensor;                
                        deltaDistance = targetDistance - currentDistance;  
                        flagStep = sign(deltaDistance);
                    end
    
                    % stop if get NaN voltage, the traverse goes out the sensor range
                    if isnan(currentDistance), break
                    end
       
                    index = index + 1;
                end
                
                
            end

            if targetDistance > obj.actualHomeDistance  && obj.actualHomeDistance > 0
                currentDistance = obj.distanceToSensor;                
                deltaDistance = targetDistance - currentDistance;  
                flagStep = sign(deltaDistance);

                newTargetDistance = targetDistance - obj.actualHomeDistance;
                if newTargetDistance <= 120
                    commandStr = ['Z' num2str(newTargetDistance)];
                    writeline(obj.stepperMotor, commandStr); check = MovementWait(obj);
                    disp(['Located at: ' num2str(targetLocation) ' mm']);
                else
                    disp(['The target location is too high. Please check: ' num2str(targetLocation)  ' < ' num2str(255+obj.surfaceLocation) ' mm'])
                end
            end

            if obj.actualHomeDistance == 0
                disp('Home position have not set!')
            end

            %-----------------------------------------------------------
            %pause(1);
            obj.print();
            moveDirection = flagStep;
        end
        function moveDirection = goHome(obj)
            writeline(obj.stepperMotor, 'U3000'); check = MovementWait(obj);
            moveDirection = 1;

            %targetLocation = obj.getHomeLocation;
            %moveDirection = obj.move(targetLocation,moveDirection);

            targetDistance = obj.homeDistance;
            targetLocation = targetDistance - obj.surfaceLocation;

            currentDistance = obj.distanceToSensor;                
            deltaDistance = targetDistance - currentDistance;  
            flagStep = sign(deltaDistance);

            if targetLocation > 2
                    maxIndex = 300;
                    index = 0;                  
                    
                    % The traverse goes in one direction and stop when it passed the destination            
                    while (index < maxIndex) && flagStep*deltaDistance > 0 && abs(deltaDistance) > 0.3 && currentDistance>(obj.surfaceLocation-1) && currentDistance<142
                        index = index + 1;
                        
                        if flagStep>0
                            commandStr = 'U';
                        else
                            commandStr = 'D';
                        end

                        if abs(deltaDistance) > 5
                            stepNum = floor(abs(deltaDistance)/2*2000);
                        elseif abs(deltaDistance) > 2
                            stepNum = floor(abs(deltaDistance)/2*1000);
                        else
                            stepNum = floor(abs(deltaDistance)/2*400);
                        end

                        if stepNum > 20000
                            stepNum = 20000;
                        end

                        commandStr = [commandStr num2str(stepNum)];
                        writeline(obj.stepperMotor, commandStr); check = MovementWait(obj);

                        currentDistance = obj.distanceToSensor;                
                        deltaDistance = targetDistance - currentDistance;                          

                        moveDirection = flagStep;

                        obj.dispLocation;
                    end                                        

                    if currentDistance>=142
                        disp('The current location is out of the sensor range! Please move it manually')
                    end
            end  
        end
        function print(obj)
            directionName = 'control\';
            currentLocationSave = num2str(obj.currentLocation);
            
            % print current location
            delete([directionName, 'currentLocation_*']); 
            pause(0.01);
            
            fileName = [directionName, 'currentLocation_' num2str(currentLocationSave) 'mm.txt'];
            fileID = fopen(fileName,'w+');
            fclose(fileID);            
        end        
        function dispLocation(obj)
            currentDistance = obj.distanceToSensor();
            currentLocation = currentDistance - obj.surfaceLocation;
            if currentDistance <= 142
                disp(['Distance to the sensor: ' num2str(currentDistance,'%0.3f') ' mm, from the surface: ' num2str(currentLocation,'%0.3f') ' mm']);
            else
                disp('Traveser is out of the sensor range: > 142 mm')
            end
        end
    end
end

%---------- function inside the class
function dis = voltageToDistance(vol)
    disp0 = [0 8.68 23.59 53.37 83.05 112.77 143.63 171.61 203.39 231.87 249.09];
    voltage0 = [0.2 0.5 1 2 3.01 4.01 5.04 6 7.05 8.01 8.62];
    dis = interp1(voltage0,disp0,vol);
end

function stepDelta = TraverseStep(distance,targetLocation)
    % roughly 1 mm = 2000 but errors occurr every time
    stepPer1mm = 2000;

    distance = abs(distance);
    if distance > 20
        %stepDelta = stepPer1mm*20;
        stepDelta = stepPer1mm*(floor(distance-10));
    elseif distance > 10
        %stepDelta = stepPer1mm*5;
        stepDelta = stepPer1mm*(floor(distance-3));
    elseif distance > 3
        %stepDelta = stepPer1mm*2;
        stepDelta = stepPer1mm*(floor(distance));
    elseif distance > 1
        stepDelta = stepPer1mm*0.5;
    elseif distance > 0.5
        stepDelta = stepPer1mm*0.25;
    else

        if targetLocation > 0.5
            stepDelta = 100; 
        else
            if distance > 0.5
                stepDelta = 100;
            else
                stepDelta = 50;
            end                    
        end

    end

    if stepDelta > stepPer1mm*10
        stepDelta = stepPer1mm*10;
    end
end  

function checkStop = checkStop() 
    directionName = 'control\';
            
    fileNameSource = [directionName, 'stop.txt'];
    fileNameRead = [directionName, 'readStop.txt'];    
    copyfile(fileNameSource,fileNameRead);
            
    pause(0.5);
    
    fileID = fopen(fileNameRead);
    strLine = string( textscan(fileID,'%f',1) );
    checkStop = str2double(strLine);
    fclose(fileID);
end





