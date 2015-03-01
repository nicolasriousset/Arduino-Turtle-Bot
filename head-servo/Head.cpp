#include "Head.h"

const uint8_t HEADING_FULL_RIGHT = 5;
const uint8_t HEADING_FULL_LEFT = 100;
const uint8_t HEADING_CENTERED = 44;

Head::Head() {
  compass = 0;
  heading = HEADING_CENTERED;
}

Head::~Head() {
}

void Head::setup(uint8_t neckServoPin, uint8_t sonarEchoPin, uint8_t sonarTriggerPin) {
  this->neckServoPin = neckServoPin;
  this->sonarEchoPin = sonarEchoPin;
  this->sonarTriggerPin = sonarTriggerPin;
  
  neckServo.attach(neckServoPin);
}

void Head::pointTo(int degrees) {
  neckServo.write(degrees); // tell servo to go to position
  heading = degrees;
  delay(25); // waits for the servo to reach the position 
}

void Head::sweep() {
  if (compass == 0) {
    sweepWithoutCompass();
  } else {
    sweepWithCompass();
  }
}

Servo Head::neck() {
  return neckServo;
}

void Head::setCompass(CompassSensor* compass) {
  this->compass = compass;
}

void Head::sweepWithCompass() {
}

void Head::sweepWithoutCompass() {
  uint8_t pos = 0;
  for(pos = 0; pos < 180; pos += 1) // goes from 0 degrees to 180 degrees 
  { // in steps of 1 degree 
    pointTo(pos); // tell servo to go to position in variable 'pos' 
  } 
  for(pos = 180; pos>=1; pos-=1) // goes from 180 degrees to 0 degrees 
  { 
    pointTo(pos); // tell servo to go to position in variable 'pos' 
  } 
}

void Head::calibrate() {
  Serial.println("Calibrating");
  if (compass == 0) {
    return;
  }
  
  int initialHeading = compass->getHeading();
  if (initialHeading == -1) {
    return;
  }
  
  uint8_t pos = 0;

  Serial.print("Initial heading :");
  Serial.println(initialHeading);

  Serial.println("Look left");
  for(pos = HEADING_FULL_RIGHT; pos < HEADING_FULL_LEFT; pos += 1)
  { // in steps of 1 degree 
    pointTo(pos); // tell servo to go to position in variable 'pos' 
    Serial.print("Pos :");
    Serial.print(pos);
    Serial.print(", Heading :");
    Serial.println(compass->getAvgHeading());
  } 
  Serial.print("End look left, wait. Current heading :");
  Serial.println(compass->getAvgHeading());
  Serial.println("Look right");
  for(pos = HEADING_FULL_LEFT; pos>HEADING_FULL_RIGHT; pos-=1)
  { 
    pointTo(pos); // tell servo to go to position in variable 'pos' 
    Serial.print("Pos :");
    Serial.print(pos);
    Serial.print(", Heading :");
    Serial.println(compass->getAvgHeading());
  } 
  Serial.print("End look right. Current heading :");
  Serial.println(compass->getAvgHeading());
  pointTo(HEADING_CENTERED);
  Serial.println("End of calibration");  
}

int Head::getRelativeHeading() {
  return HEADING_CENTERED - heading;
}

int Head::getAbsoluteHeading() {
  return compass->getAvgHeading();
}


