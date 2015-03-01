#ifndef HEAD_H
#define HEAD_H

#include <Arduino.h> //It is very important to remember this! note that if you are using Arduino 1.0 IDE, change "WProgram.h" to "Arduino.h" 
#include <Servo.h> 
#include <CompassSensor.h>

class Head {
public:
  Head();
  ~Head();
  // degrees goes from 0 to 180
  void pointTo(int degrees);
  void sweep();
  Servo neck();
  void setup(uint8_t neckServoPin, uint8_t sonarEchoPin, uint8_t sonarTriggerPin);
  void setCompass(CompassSensor* compass);
  void calibrate();
  int getRelativeHeading();
  int getAbsoluteHeading();

private:
  uint8_t neckServoPin;
  uint8_t sonarEchoPin;
  uint8_t sonarTriggerPin;
  int heading;
  
  CompassSensor* compass;
  
  Servo neckServo;
  
  void sweepWithCompass();
  void sweepWithoutCompass();
  
};

#endif
