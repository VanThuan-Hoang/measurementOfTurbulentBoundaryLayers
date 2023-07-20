// Required Libraries
#include <Arduino.h>
#include <Streaming.h> // by Peter Polidoro (arduino library)
#include <Vector.h> // by Peter Polidoro (arduino library)
#include <ArduinoQueue.h> //by Elinar Arnason (arduino library)

// if debugging is required, change to true
const bool debug = true;

const long BAUD = 57600; // working with 57600
//int measurementTime = 1000; //in milliseconds
float resY = 4000.0; //pulses per rev - needs to match the setting on the driver
float resZ = 4000.0; //pulses per rev - needs to match the setting on the driver
float ballScrewLead = 2.0; //mm
float pinionDiameter = 47.7;//mm
double yPosition;//mm
double zPosition;
double oneStepZ;// = ballScrewLead / resY (mm)
double oneStepY;// = PI*pinionDiameter / resY;
double rightLimit = 450.0;
double leftLimit = -450.0;

// PIN ASSIGNMENT
//interrupt pins for various of arduino boards
//https://www.arduino.cc/reference/en/language/functions/external-interrupts/attachinterrupt/
#define CLOCKOUTP 9  // Mega 2560
#define CLOCKOUTM 10  // Mega 2560

#define upSwitch 53
#define downSwitch 42

//stepper driver
#define xPUL 43
#define xDIR 44
#define xENA 45

#define yPUL 48
#define yDIR 49
#define yENA 50
#define yEB 20
#define yEA 21


//check if there is a new string received from the user
      //update the string received to the new user input
      //otherwise leave the string received unchanged
String serialRead(String received)
{
  if(Serial.available() > 0)
  {
      received = Serial.readString();
      if(debug){Serial.write("A: reading serial\n");}
  }
  return received;
}

//Movement
void right()
{
  //readEncoder();
  if(yPosition < rightLimit)
  {
    yPosition += oneStepY;
    //if not end of rack
    digitalWrite(xDIR, HIGH);
    delay(5);
    digitalWrite(xDIR, LOW);
  }
  else
  {
    if(debug){Serial.write("A: Out of bounds, stopped right\n");}
  }
}

void left()
{
  //readEncoder();
  if(yPosition > leftLimit)
  {
    yPosition -= oneStepY;
    //if not end of rack
    digitalWrite(xPUL, HIGH);
    delay(5);
    digitalWrite(xPUL, LOW);
  }
  else
  {
    if(debug){Serial.write("A: Out of bounds, stopped left\n");}
  }
}

void up()
{
  //as long as it hasn't reached its limits
  if(digitalRead(upSwitch) == LOW)
  {
    zPosition += oneStepZ;
    digitalWrite(yPUL, HIGH);
    delayMicroseconds(50);
    digitalWrite(yPUL, LOW);
  }
  else{Serial<<"A: reached top limit"<<endl;}
}

void down()
{
  //as long as it hasn't reached its limits
    if(digitalRead(downSwitch) == LOW)
    {
      zPosition -= oneStepZ;
      digitalWrite(yDIR, HIGH);            
      delayMicroseconds(50);
      digitalWrite(yDIR, LOW);
    }
    else{Serial<<"A: reached lower limit"<<endl;/*zPosition = 0;*/}
}

//allow motor movement by arduino, prevent manual movement
void engageY()
{
    digitalWrite(xENA, LOW); //engage motor
}

//allow for manual movement, disengagement of driver
void disengageY()
{
    digitalWrite(xENA, HIGH); //disengage motor
}

//allow motor movement by arduino, prevent manual movement
void engageZ()
{
    digitalWrite(yENA, LOW); //engage motor
}

//allow for manual movement, disengagement of driver
void disengageZ()
{
    digitalWrite(yENA, HIGH); //disengage motor
}

void moveY(double requiredPosition)
{
  //readEncoder(); //mm
  double difference = requiredPosition - yPosition;
  long offset = difference/oneStepY;
  //while(abs(yPosition - requiredPosition) > 1)
  //{
    for(int i = 0; i < abs(offset); i++)
    {
      if(offset>=0)
      {
        //yPosition += difference/offset;
        right();
      }
      else
      {
       // yPosition -= difference/offset;
        left();
      }
    }
    difference =  requiredPosition - yPosition;
    offset = difference/oneStepY;
    //delay(movementDelay);
  //}
  Serial<<"Current Position: Z="<< zPosition<<" Y="<<yPosition<<endl;
}


void moveZ(double requiredPosition)
{
  double difference = requiredPosition - zPosition;
  long offset = difference/oneStepZ;
  //while(abs(yPosition - requiredPosition) >= 0.01)
  //{
    for(int i = 0; i < abs(offset); i++)
    {
      if(offset>=0)
      {
        //zPosition += difference/offset;
        up();
      }
      else
      {
         //zPosition -= difference/offset;
        down();
      }
    }
    difference =  requiredPosition - zPosition;
    offset = difference/oneStepZ;
    //delay(movementDelay);
 // }
  Serial<<"Current Position: Z="<< zPosition<<" Y="<<yPosition<<endl;
}


//get co-ordinates from matlab
String serialWait()
{
  String received = "";
  String points;
  while(received[0] < 33) //looking for inpropper character input
  {
    received = serialRead(received);
  }
  return received;
}

void setup()
{
  Serial.begin(BAUD);
  while(!Serial){}

  oneStepZ = ballScrewLead / resZ; //mm
  oneStepY = PI*pinionDiameter / resY; 

  yPosition = (rightLimit - leftLimit)/2;//mm - to allow for movement to occur as soon as its turned on

  //motor drivers
  //x axis
  pinMode(xPUL, OUTPUT);
  pinMode(xDIR, OUTPUT);
  pinMode(xENA, OUTPUT);

  //y axis
  pinMode(yPUL, OUTPUT);
  pinMode(yDIR, OUTPUT);
  pinMode(yENA, OUTPUT);
  pinMode(yEB, INPUT_PULLUP);
  pinMode(yEA, INPUT_PULLUP);

  pinMode(upSwitch, INPUT);
  pinMode(downSwitch, INPUT);
  
  //engage the motors
  engageY();
  engageZ();

}

void loop()
{
  String received;
  String pointString;
  double value;
  received = "";
  received = serialWait();

  if(received[0] == 'H') // home
  {
    Serial<<"Moving Home"<<endl;
    while(zPosition != 0 && zPosition > 0) {down();}
    while(zPosition != 0 && zPosition < 0) {up();}
    while(yPosition != 0 && yPosition > 0) {left();}
    while(yPosition != 0 && yPosition < 0) {right();}
  }
  else if(received[0] == 'Y') //move y axis mm
  {
    //convert string to double 
    pointString = (received.substring(1));
    value = pointString.toDouble();
    Serial<<"Move Y "<<value<<"mm"<<endl;
    moveY(value);
  }
  else if(received[0] == 'Z') //move z axis mm
  {
    //convert string to double
    pointString = (received.substring(1));
    value = pointString.toDouble();
    Serial<<"Move Z "<<value<<"mm"<<endl;

    moveZ(value);
  }
  else if(received[0] == 'U') //move up in steps
  {
    //convert string to double
    pointString = (received.substring(1));
    value = pointString.toDouble();
    Serial<<"Move UP "<<value<<" steps"<<endl;

    for(int i=0;i<value; i++){up();}
  }
  else if(received[0] == 'D') //move down in steps
  {
    //convert string to double
    pointString = (received.substring(1));
    value = pointString.toDouble();
    Serial<<"Move DOWN "<<value<<" steps"<<endl;

    for(int i=0;i<value; i++){down();}
  }
  else if(received[0] == 'L') //move left in steps
  {
    pointString = (received.substring(1));
    value = pointString.toDouble();
    Serial<<"Move LEFT "<<value<<" steps"<<endl;

    for(int i=0;i<value; i++){left();}
  }
  else if(received[0] == 'R') //move right in steps
  {
    pointString = (received.substring(1));
    value = pointString.toDouble();
    Serial<<"Move RIGHT "<<value<<" steps"<<endl;

    for(int i=0;i<value; i++){right();}
  }
  else if(received[0] == 'E') 
  {
    Serial<<"Engage Motors"<<endl;
    engageY(); engageZ();
    } //engage the motors
  else if(received[0] == 'M') 
  {
    Serial<<"Disengage Motors"<<endl;
    disengageY(); disengageZ();
    } //disengage the motors
  else if(received[0] == 'S') //set home position for each axis
  {
    if(received[1] == 'Y') 
    {
      Serial<<"Set Y Home Position"<<endl;
      yPosition = 0;} //set only y axis
    else if(received[1] == 'Z')
    {
      Serial<<"Set Z Home Position\n"<<endl;
      zPosition = 0;} //set only z axis
    else 
    {
      Serial<<"Set Home Position of Both Axis"<<endl;
      yPosition = 0; zPosition = 0;} // set both 
  }
  else
  {
    Serial<<"Invalid Input : "<<received<<endl;
    Serial<<"\n"<<endl;
    //invalid input
  }
}
