function check = MovementWait(traverseRemote)

distance = traverseRemote.distanceToSensor;
pause(0.1)

%maxIndex = 10000;
maxIndex = 30*100;
index = 0;
while (index < maxIndex) && (abs(distance - traverseRemote.distanceToSensor)>0.1)
    index = index + 1;
    distance = traverseRemote.distanceToSensor;

    pause(0.1)
end

if abs(distance - traverseRemote.distanceToSensor)>0.02
    check = 0;
else
    check = 1;
end

end