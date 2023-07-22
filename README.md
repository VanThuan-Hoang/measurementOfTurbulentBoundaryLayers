# Measurement of turbulent boundary layers

This project was developed to measure flow velocities at a vertical distance of 0.15±0.03 mm from a flat plate.

A measurement is shown in the video below:

https://github.com/VanThuan-Hoang/measurementOfTurbulentBoundaryLayers/assets/139791063/e6ecf5bc-9d19-415a-b40f-12adae44799a

# The equipment includes:
+ Dantect box (Using a hot-wire probe to measure flow velocities) and the Baratron (using a pitot static tube to measure flow velocities):
  
![image](https://github.com/VanThuan-Hoang/measurementOfTurbulentBoundaryLayers/assets/139791063/3c858ca2-a24e-4fe7-9362-6eb1fbe9ebb4)

A long version of this above video can be found at: https://youtu.be/lI0LxWu6Khw

+ The hot-wire probe

![image](https://github.com/VanThuan-Hoang/measurementOfTurbulentBoundaryLayers/assets/139791063/9175bf94-0a57-45b6-8300-206a98096481)

+ Traverse: It is used to place the hot-wire probe at a vertical position from the flat plate

![image](https://github.com/VanThuan-Hoang/measurementOfTurbulentBoundaryLayers/assets/139791063/4d4a35e4-41f9-4f1e-98a6-fcbdc53ea6d6)

# The code includes:
The .ino code moves the traverse with a command from a serial port. The command is sent from the Matlab codes.

The Matlab codes read the current location of the hot-wire probe with a laser displacement sensor. 

The Matlab codes control the traverse to place the probe vertically from the plate surface with feedback from the laser displacement sensor. 

The Matlab codes then read the velocities from the Dantec box.

# The detection of the zero position is shown in the video below:

https://github.com/VanThuan-Hoang/measurementOfTurbulentBoundaryLayers/assets/139791063/08fe142c-f827-4f6a-93f5-b4d484c7f1a8

The camera

![image](https://github.com/VanThuan-Hoang/measurementOfTurbulentBoundaryLayers/assets/139791063/7004a109-0769-47bf-9eef-decb821e6e0c)


Thanks,
