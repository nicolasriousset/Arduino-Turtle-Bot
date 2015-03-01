#include <Servo.h> 
#include <NewPing.h>

// Servo headServo;
 // a maximum of eight servo objects can be created 

int pos = 0; // variable to store the servo position 

//-- MOTEUR A --
const uint8_t MOTOR_A_EN=11; //Connecté à Arduino pin 5(sortie pwm)
const uint8_t MOTOR_A_IN1=10; //Connecté à Arduino pin 2
const uint8_t MOTOR_A_IN2=9; //Connecté à Arduino pin 3

//-- MOTEUR B --
const uint8_t MOTOR_B_EN=6; //Connecté à Arduino pin 6(Sortie pwm)
const uint8_t MOTOR_B_IN3=7; //Connecté à Arduino pin 4
const uint8_t MOTOR_B_IN4=8; //Connecté à Arduino pin 7


const uint8_t SONAR_TRIGGER_PIN = 2;
const uint8_t SONAR_ECHO_PIN = 4;
const uint8_t MAX_DISTANCE = 200; // Maximum distance we want to ping for (in centimeters). Maximum sensor distance is rated at 400-500cm.
static uint32_t USdistanceCm = 255;

const uint8_t LED_PIN = 13;
const uint8_t LASER_PIN = 13;

const uint8_t simulateMove = 0;

enum MovingState {
  STOP,
  FORWARD,
  BACKWARD,
  TURN
};

MovingState movingState = STOP;
const uint8_t MAX_SPEED = 255;
uint8_t movingSpeed = 0;

NewPing sonar(SONAR_TRIGGER_PIN, SONAR_ECHO_PIN, MAX_DISTANCE); // NewPing setup of pins and maximum distance.

unsigned int pingSpeed = 50; // How frequently are we going to send out a ping (in milliseconds). 50ms would be 20 times a second.
unsigned long pingTimer;     // Holds the next ping time.

void setup() {
  Serial.begin(9600);

  pingTimer = millis(); // Start now.

//  headServo.attach(12);

  pinMode(MOTOR_A_EN,OUTPUT);//Configurer les broches comme sortie
  pinMode(MOTOR_B_EN,OUTPUT);
  pinMode(MOTOR_A_IN1,OUTPUT);
  pinMode(MOTOR_A_IN2,OUTPUT);
  pinMode(MOTOR_B_IN3,OUTPUT);
  pinMode(MOTOR_B_IN4,OUTPUT);
  digitalWrite(MOTOR_A_EN,LOW);// Moteur A - Ne pas tourner (désactivation moteur)
  digitalWrite(MOTOR_B_EN,LOW);// Moteur B - Ne pas tourner (désactivation moteur)
  
  // Direction du Moteur A
  digitalWrite(MOTOR_A_IN1,LOW); 
  digitalWrite(MOTOR_A_IN2,HIGH);
  
  // Direction du Moteur B
  // NB: en sens inverse du moteur A
  digitalWrite(MOTOR_B_IN3,HIGH);
  digitalWrite(MOTOR_B_IN4,LOW);
}

void log (const char* msg) {
  Serial.print(msg);
  Serial.print("\n");
}

void logValue (const char* msg, uint8_t value) {
  Serial.print(msg);
  Serial.print(value);
  Serial.print("\n");
}

//void headScan() {
//  for(pos = 0; pos < 180; pos += 1) // goes from 0 degrees to 180 degrees 
//  { // in steps of 1 degree 
//    headServo.write(pos); // tell servo to go to position in variable 'pos' 
//    delay(15); // waits 15ms for the servo to reach the position 
//  } blinkLed
//  for(pos = 180; pos>=1; pos-=1) // goes from 180 degrees to 0 degrees 
//  { 
//    headServo.write(pos); // tell servo to go to position in variable 'pos' 
//    delay(15); // waits 15ms for the servo to reach the position 
//  } 
//}

void blinkLed() {
  for (int i =0; i < 10; i++) {
    digitalWrite(LED_PIN, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(100);              // wait for a second
    digitalWrite(LED_PIN, LOW);   // turn the LED on (HIGH is the voltage level)
    delay(100);              // wait for a second
  }
}

void echoCheck() {
//  uint16_t duration; // duration of the round trip
//  uint32_t cm;        // distance of the obstacle
// 
//  // The sensor is triggered by a HIGH pulse of 10 or more microseconds.
//  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
//  pinMode(SONAR_TRIGGER_PIN, OUTPUT);
//  digitalWrite(SONAR_TRIGGER_PIN, LOW);
//  delayMicroseconds(3);
//
//
//  // Start trigger signal
//
//
//  digitalWrite(SONAR_TRIGGER_PIN, HIGH);
//  delayMicroseconds(10);
//  digitalWrite(SONAR_TRIGGER_PIN, LOW);
// 
//  // Read the signal from the sensor: a HIGH pulse whose
//  // duration is the time (in microseconds) from the sending
//  // of the ping to the reception of its echo off of an object.
//
//  pinMode(SONAR_ECHO_PIN, INPUT);
//  duration = pulseIn(SONAR_ECHO_PIN, HIGH);
// 
//  // convert the time into a distance
//  cm = (uint32_t)((duration<<4)+duration)/1000.0; // cm = 17 * duration/1000
//  
//  logValue("Distance : ", cm);
//  return cm;
  if (sonar.check_timer()) { // This is how you check to see if the ping was received.
    USdistanceCm = sonar.ping_result / US_ROUNDTRIP_CM;
  }
}

// Speed must be between 0 and 255
void forward(uint8_t speed) {
  logValue("Forward at speed ", speed);
  
  if (simulateMove == 1) {
    return;
  }
  
  // Direction du Moteur A
  digitalWrite(MOTOR_A_IN1,LOW); 
  digitalWrite(MOTOR_A_IN2,HIGH);
  
  // Direction du Moteur B
  // NB: en sens inverse du moteur A
  digitalWrite(MOTOR_B_IN3,HIGH);
  digitalWrite(MOTOR_B_IN4,LOW);
  
   analogWrite(MOTOR_A_EN,speed);
   analogWrite(MOTOR_B_EN,speed);

   movingState = FORWARD;
   movingSpeed = speed;
}

void backward(uint8_t speed) {
  logValue("Backward at speed ", speed);
  
  if (simulateMove == 1) {
    return;
  }

  // Direction du Moteur A
  digitalWrite(MOTOR_A_IN1,HIGH); 
  digitalWrite(MOTOR_A_IN2,LOW);
  
  // Direction du Moteur B
  // NB: en sens inverse du moteur A
  digitalWrite(MOTOR_B_IN3,LOW);
  digitalWrite(MOTOR_B_IN4,HIGH);
  
   analogWrite(MOTOR_A_EN,speed);
   analogWrite(MOTOR_B_EN,speed);

   movingState = BACKWARD;
   movingSpeed = speed;
}

void turn() {
  log("Turn !!!");
  
  if (simulateMove == 1) {
    return;
  }

  // Direction du Moteur A
  digitalWrite(MOTOR_A_IN1,HIGH); 
  digitalWrite(MOTOR_A_IN2,LOW);
  
  // Direction du Moteur B
  // NB: en sens inverse du moteur A
  digitalWrite(MOTOR_B_IN3,HIGH);
  digitalWrite(MOTOR_B_IN4,LOW);
  
   analogWrite(MOTOR_A_EN,255);
   analogWrite(MOTOR_B_EN,255);

   movingState = TURN;
   movingSpeed = 0;
}

void stop() {
   log("STOP !!!");
  
   analogWrite(MOTOR_A_EN,0);
   analogWrite(MOTOR_B_EN,0);
   
   movingState = STOP;
   movingSpeed = 0;
}

void fireLaser() {
    analogWrite(LASER_PIN,128);
}

void stopLaser() {
    analogWrite(LASER_PIN,0);
}

void loop() {  
  // headScan();
  if (millis() >= pingTimer) {   // pingSpeed milliseconds since last ping, do another ping.
    pingTimer += pingSpeed;      // Set the next ping time.
    sonar.ping_timer(echoCheck); // Send out the ping, calls "echoCheck" function every 24uS where you can check the ping status.
  }

   if (USdistanceCm > 22 || USdistanceCm == 0) {
     if (movingState != FORWARD || movingSpeed != MAX_SPEED) {
       stopLaser();
       logValue("Distance: ", USdistanceCm);
       forward(MAX_SPEED);
     }
   } else if (USdistanceCm > 10) { 
     // Slowdown, something is in our way
     uint8_t newSpeed = ((float)USdistanceCm - 10.0)* 10.0 * 2.0;
     if (movingState != FORWARD || movingSpeed != newSpeed) {
       stopLaser();       
       logValue("Distance: ", USdistanceCm);
       forward(newSpeed);
     }
   } else {
     fireLaser();
     if (movingState != TURN) {
       logValue("Distance: ", USdistanceCm);
       // backward(MAX_SPEED);
       // delay(1000);
       turn();
       // delay(250);
       // stop();
     }
   }

}
