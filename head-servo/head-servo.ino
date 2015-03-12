// Sweep
// by BARRAGAN <http://barraganstudio.com> 
// This example code is in the public domain.
#include <Servo.h> 
#include "Head.h"
#include "Command.h"
#include <CompassSensor.h>
#include <Wire.h>
#include <NewPing.h>


const uint8_t SONAR_TRIGGER_PIN = 2;
const uint8_t SONAR_ECHO_PIN = 4;
const uint8_t MAX_DISTANCE = 200; // Maximum distance we want to ping for (in centimeters). Maximum sensor distance is rated at 400-500cm.
static uint32_t USdistanceCm = 255;

NewPing sonar(SONAR_TRIGGER_PIN, SONAR_ECHO_PIN, MAX_DISTANCE); // NewPing setup of pins and maximum distance.

unsigned int pingSpeed = 50; // How frequently are we going to send out a ping (in milliseconds). 50ms would be 20 times a second.
unsigned long pingTimer;     // Holds the next ping time.


Command receivedCommand;

const byte MAX_BUF_SIZE = 12;

char commandBuffer[MAX_BUF_SIZE];
byte commandBufferLen = 0;

Head head; // create servo object to control a servo 
CompassSensor compass;

void log (const char* msg) 
{
  Serial.println(msg);
}

void sendCommand(const Command& command)
{
  char buffer[MAX_BUF_SIZE];
  if (command.print(buffer, sizeof(buffer))) 
  {
    Serial.println(buffer);
  }
}

boolean readCommand()
{
  boolean result = false;
  while (Serial.available() > 0) 
  {
    if (commandBufferLen == sizeof(commandBuffer)) 
    {
      // Should not happen, reset buffer
      commandBufferLen = 0;
    }
    
    char ch = Serial.read();
    commandBuffer[commandBufferLen++] = ch;
    if (ch == '\n')
    {
      result = receivedCommand.parse(commandBuffer, commandBufferLen - 1);
      commandBufferLen = 0;
    }
  }
  
  return result;
}

void processCommand()
{
  if (readCommand()) 
  {
    executeCommand();
  }
}

boolean executeCommand() 
{
}

void setup() 
{
  Serial.begin(115200);
  log("Head test");

  pingTimer = millis(); // Start now.
  
  compass.setup();
  head.setup(12, 0, 0);  
  head.setCompass(&compass);
  // head.calibrate();
} 

void loop() 
{
  uint8_t maxDegreesRight = 5;
  uint8_t maxDegreesLeft = 100;
  Command command(SCAN_START, 0, 0);
  sendCommand(command);
  for(uint8_t pos = maxDegreesRight; pos < maxDegreesLeft; pos += 1)  
  { // in steps of 1 degree 
    head.pointTo(pos); // tell servo to go to position in variable 'pos' 
    if (millis() >= pingTimer) 
    {   // pingSpeed milliseconds since last ping, do another ping.
      pingTimer += pingSpeed;      // Set the next ping time.
      sonar.ping_timer(echoCheck); // Send out the ping, calls "echoCheck" function every 24uS where you can check the ping status.
    }
    command.init(OBSTACLE, head.getRelativeHeading(), USdistanceCm);
    sendCommand(command);
  } 

  for(uint8_t pos = maxDegreesLeft; pos > maxDegreesRight ; pos -= 1)  
  { // in steps of 1 degree 
    head.pointTo(pos); // tell servo to go to position in variable 'pos' 
   if (millis() >= pingTimer) 
   {   // pingSpeed milliseconds since last ping, do another ping.
     pingTimer += pingSpeed;      // Set the next ping time.
     sonar.ping_timer(echoCheck); // Send out the ping, calls "echoCheck" function every 24uS where you can check the ping status.
   }
    command.init(OBSTACLE, head.getRelativeHeading(), USdistanceCm);
    sendCommand(command);
  } 
  command.init(SCAN_STOP, 0, 0);
  sendCommand(command);

}

void echoCheck() 
{
  if (sonar.check_timer()) 
  { // This is how you check to see if the ping was received.
    USdistanceCm = sonar.ping_result / US_ROUNDTRIP_CM;
  }
}

