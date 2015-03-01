import processing.serial.*;

int SIDE_LENGTH = 1000;
int ANGLE_BOUNDS = 90;
int ANGLE_STEP = 2;
int HISTORY_SIZE = 100;
int POINTS_HISTORY_SIZE = HISTORY_SIZE;
int MAX_DISTANCE = 50;

int radius = SIDE_LENGTH / 4;
float x = 0.0;
float y = 0.0;
float leftAngleRad  = radians(-ANGLE_BOUNDS) - HALF_PI; 
float rightAngleRad = radians(ANGLE_BOUNDS) - HALF_PI;

float[] historyX = new float[HISTORY_SIZE]; // used by the radar line
float[] historyY = new float[HISTORY_SIZE]; // used by the radar line
Point[] points = new Point[POINTS_HISTORY_SIZE];

int centerX = SIDE_LENGTH / 2; 
int centerY= SIDE_LENGTH / 2;

boolean isInitialized = false;
boolean isTestMode = true;

String comPortString;
Serial myPort = null;

void setup() {
  if (isInitialized) {
    return;
  }
  isInitialized = true;
  
  print("Ports série : ");
  println(Serial.list());
  println("Beginning setup");

  println("Initialisation port");
  if (isTestMode) { 
    recordTestData();
  } else {
    myPort = new Serial(this, "COM8", 115200);
    if (myPort != null) {
      myPort.bufferUntil('\n'); // Trigger a SerialEvent on new line
    } else {
      println("Impossible d'initialiser ");
    }
  }
  
  size(SIDE_LENGTH, SIDE_LENGTH/2, P2D);
  println("Beginning setup 2");
  noStroke();
  //smooth();
  println("Beginning setup 3");
  rectMode(CENTER);

  println("End setup");
}


void draw() {
  // println("Draw");
  background(0);

  drawRadar();

  drawFoundObjects();
  drawRadarLine();
}

void addAngleToHistory(int angle) {
  shiftHistoryArray();
  float radian = radians(angle);
  x = radius * sin(radian);
  y = radius * cos(radian);


  float px = centerX + x;
  float py = centerY - y;

  historyX[0] = px;
  historyY[0] = py;
}


void drawRadarLine() {
  // println("drawRadarLine");
  for (int i=0; i<HISTORY_SIZE; i++) {

    stroke(50, 150, 50, 255 - (25*i));
    line(centerX, centerY, historyX[i], historyY[i]);
  }
}

void addPointFromAngleAndDistance(int angle, int distance) {
  shiftPointsArray();
  
  float radian = radians(angle);
  x = distance * sin(radian);
  y = distance * cos(radian);

  int px = (int)(centerX + x);
  int py = (int)(centerY - y);

  points[0] = new Point(px, py);
  
  addAngleToHistory(angle);  
}

void drawFoundObjects() {
  // println("drawFoundObjects");
  for (int i=0; i<POINTS_HISTORY_SIZE; i++) {

    Point point = points[i];
    if (point != null) {
      int x = point.x;
      int y = point.y;

      if (x==0 && y==0) continue;

      int colorAlfa = 50; // (int)map(i, 0, POINTS_HISTORY_SIZE, 50, 20);
      int size = 10; // (int)map(i, 0, POINTS_HISTORY_SIZE, 30, 5);

      fill(50, 150, 50, colorAlfa);
      noStroke();
      ellipse(x, y, size, size);
    }
  }
}

void drawRadar() {
  // println("drawRadar");
  stroke(100);
  noFill();

  // casti kruznic vzdalenosti od stredu
  for (int i = 0; i <= (SIDE_LENGTH / 100); i++) {
    arc(centerX, centerY, 100 * i, 100 * i, leftAngleRad, rightAngleRad);
  }

  // ukazatele uhlu
  for (int i = 0; i <= (ANGLE_BOUNDS*2/20); i++) {
    float angle = -ANGLE_BOUNDS + i * 20;
    float radAngle = radians(angle);
    line(centerX, centerY, centerX + radius*sin(radAngle), centerY - radius*cos(radAngle));
  }
}

void shiftHistoryArray() {
  // println("shiftHistoryArray");
  for (int i = HISTORY_SIZE; i > 1; i--) {
    historyX[i-1] = historyX[i-2];
    historyY[i-1] = historyY[i-2];
  }
}

void shiftPointsArray() {
  // println("shiftPointsArray");
  for (int i = POINTS_HISTORY_SIZE; i > 1; i--) {
    Point oldPoint = points[i-2];
    if (oldPoint != null) {

      Point point = new Point(oldPoint.x, oldPoint.y);
      points[i-1] = point;
    }
  }
}

void serialEvent(Serial cPort) {
  println("serialEvent");
  comPortString = cPort.readString();
  if (comPortString != null) {
    comPortString=trim(comPortString);
    String[] values = split(comPortString, ',');
    try {
      int angle = Integer.parseInt(values[0]);      
      int distance = int(map(Integer.parseInt(values[1]), 1, MAX_DISTANCE, 1, radius));
      print("angle : ");
      print(angle);
      print(", distance : ");
      println(distance);
      addPointFromAngleAndDistance(angle, distance);
    } 
    catch (Exception e) {
    }
  }
}

void recordTestData() {
  addPointFromAngleAndDistance(-37,82);
  
  addPointFromAngleAndDistance(-36,82);
  
  addPointFromAngleAndDistance(-35,82);
  
  addPointFromAngleAndDistance(-34,82);
  
  addPointFromAngleAndDistance(-33,82);
  
  addPointFromAngleAndDistance(-32,82);
  
  addPointFromAngleAndDistance(-31,82);
  
  addPointFromAngleAndDistance(-30,82);
  
  addPointFromAngleAndDistance(-29,77);
  
  addPointFromAngleAndDistance(-28,77);
  
  addPointFromAngleAndDistance(-27,77);
  
  addPointFromAngleAndDistance(-26,77);
  
  addPointFromAngleAndDistance(-25,77);
  
  addPointFromAngleAndDistance(-24,77);
  
  addPointFromAngleAndDistance(-23,77);
  
  addPointFromAngleAndDistance(-22,77);
  
  addPointFromAngleAndDistance(-21,77);
  
  addPointFromAngleAndDistance(-20,77);
  
  addPointFromAngleAndDistance(-19,72);
  
  addPointFromAngleAndDistance(-18,72);
  
  addPointFromAngleAndDistance(-17,77);
  
  addPointFromAngleAndDistance(-16,77);
  
  addPointFromAngleAndDistance(-15,77);
  
  addPointFromAngleAndDistance(-14,77);
  
  addPointFromAngleAndDistance(-13,77);
  
  addPointFromAngleAndDistance(-12,77);
  
  addPointFromAngleAndDistance(-11,77);
  
  addPointFromAngleAndDistance(-10,77);
  
  addPointFromAngleAndDistance(-9,77);
  
  addPointFromAngleAndDistance(-8,77);
  
  addPointFromAngleAndDistance(-7,77);
  
  addPointFromAngleAndDistance(-6,82);
  
  addPointFromAngleAndDistance(-5,82);
  
  addPointFromAngleAndDistance(-4,82);
  
  addPointFromAngleAndDistance(-3,82);
  
  addPointFromAngleAndDistance(-2,82);
  
  addPointFromAngleAndDistance(-1,82);
  
  addPointFromAngleAndDistance(0,87);
  
  addPointFromAngleAndDistance(1,87);
  
  

addPointFromAngleAndDistance(2,783);
  addPointFromAngleAndDistance(3,783);
  
  addPointFromAngleAndDistance(4,341);
  
  addPointFromAngleAndDistance(5,341);
  
  addPointFromAngleAndDistance(6,783);
  
  addPointFromAngleAndDistance(7,783);
  
  addPointFromAngleAndDistance(8,316);
  
  addPointFromAngleAndDistance(9,316);
  
  addPointFromAngleAndDistance(10,783);
  
  addPointFromAngleAndDistance(11,783);
  
  addPointFromAngleAndDistance(12,778);
  
  addPointFromAngleAndDistance(13,778);
  
  addPointFromAngleAndDistance(14,473);
  
  addPointFromAngleAndDistance(15,839);
  
  addPointFromAngleAndDistance(16,839);
  
  addPointFromAngleAndDistance(17,600);
  
  addPointFromAngleAndDistance(18,600);
  
  addPointFromAngleAndDistance(19,615);
  
  addPointFromAngleAndDistance(20,615);
  
  addPointFromAngleAndDistance(21,87);
  
  addPointFromAngleAndDistance(22,87);
  
  addPointFromAngleAndDistance(23,87);
  
  addPointFromAngleAndDistance(24,87);
  
  addPointFromAngleAndDistance(25,82);
  
  addPointFromAngleAndDistance(26,82);
  
  addPointFromAngleAndDistance(27,82);
  
  addPointFromAngleAndDistance(28,82);
  
  addPointFromAngleAndDistance(29,82);
  
  addPointFromAngleAndDistance(30,82);
  
  addPointFromAngleAndDistance(31,92);
  
  addPointFromAngleAndDistance(32,92);
  
  addPointFromAngleAndDistance(33,956);
  
  addPointFromAngleAndDistance(34,956);
  
  addPointFromAngleAndDistance(35,138);
  
  addPointFromAngleAndDistance(36,138);
  
  addPointFromAngleAndDistance(37,819);
  
  addPointFromAngleAndDistance(38,819);
  
  addPointFromAngleAndDistance(39,966);
  
  addPointFromAngleAndDistance(38,966);
  
  addPointFromAngleAndDistance(37,493);
  
  addPointFromAngleAndDistance(36,961);
  
  addPointFromAngleAndDistance(35,961);
  
  addPointFromAngleAndDistance(34,956);
  
  addPointFromAngleAndDistance(33,956);
  
  addPointFromAngleAndDistance(32,951);
  
  addPointFromAngleAndDistance(31,951);
  
  addPointFromAngleAndDistance(30,341);
  
  addPointFromAngleAndDistance(29,341);
  
  addPointFromAngleAndDistance(28,951);
  
  addPointFromAngleAndDistance(27,951);
  
  addPointFromAngleAndDistance(26,951);
  
  addPointFromAngleAndDistance(25,951);
  
  addPointFromAngleAndDistance(24,737);
  
  addPointFromAngleAndDistance(23,737);
  
  addPointFromAngleAndDistance(22,951);
  
  addPointFromAngleAndDistance(21,951);
  
  addPointFromAngleAndDistance(20,407);
  
  addPointFromAngleAndDistance(19,407);
  
  addPointFromAngleAndDistance(18,92);
  
  addPointFromAngleAndDistance(17,92);
  
  addPointFromAngleAndDistance(16,87);
  
  addPointFromAngleAndDistance(15,87);
  
  addPointFromAngleAndDistance(14,87);
  
  addPointFromAngleAndDistance(13,87);
  
  addPointFromAngleAndDistance(12,92);
  
  addPointFromAngleAndDistance(11,92);
  
  addPointFromAngleAndDistance(10,87);
  
  addPointFromAngleAndDistance(9,82);
  
  addPointFromAngleAndDistance(8,82);
  
  addPointFromAngleAndDistance(7,102);
  
  addPointFromAngleAndDistance(6,102);
  
  addPointFromAngleAndDistance(5,834);
  
  addPointFromAngleAndDistance(4,834);
  
  addPointFromAngleAndDistance(3,448);
  
  addPointFromAngleAndDistance(2,448);
  
  addPointFromAngleAndDistance(1,783);
  
  addPointFromAngleAndDistance(0,783);
  
  addPointFromAngleAndDistance(-1,199);
  
  addPointFromAngleAndDistance(-2,199);
  
  addPointFromAngleAndDistance(-3,692);
  
  addPointFromAngleAndDistance(-4,692);
  
  addPointFromAngleAndDistance(-5,788);
  
  addPointFromAngleAndDistance(-6,788);
  
  addPointFromAngleAndDistance(-7,610);
  
  addPointFromAngleAndDistance(-8,610);
  
  addPointFromAngleAndDistance(-9,793);
  
  addPointFromAngleAndDistance(-10,793);
  
  addPointFromAngleAndDistance(-11,87);
  
  addPointFromAngleAndDistance(-12,87);
  
  addPointFromAngleAndDistance(-13,82);
  
  addPointFromAngleAndDistance(-14,82);
  
  addPointFromAngleAndDistance(-15,72);
  
  addPointFromAngleAndDistance(-16,72);
  
  addPointFromAngleAndDistance(-17,77);
  
  addPointFromAngleAndDistance(-18,77);
  
  addPointFromAngleAndDistance(-19,77);
  
  addPointFromAngleAndDistance(-20,72);
  
  addPointFromAngleAndDistance(-21,72);
  
  addPointFromAngleAndDistance(-22,77);
  
  addPointFromAngleAndDistance(-23,77);
  
  addPointFromAngleAndDistance(-24,77);
  
  addPointFromAngleAndDistance(-25,77);
  
  addPointFromAngleAndDistance(-26,77);
  
  addPointFromAngleAndDistance(-27,77);
  
  addPointFromAngleAndDistance(-28,77);
  
  addPointFromAngleAndDistance(-29,77);
  
  addPointFromAngleAndDistance(-30,77);
  
  addPointFromAngleAndDistance(-31,77);
  
  addPointFromAngleAndDistance(-32,72);
  
  addPointFromAngleAndDistance(-33,72);
  
  addPointFromAngleAndDistance(-34,72);
  
  addPointFromAngleAndDistance(-35,72);
  
  addPointFromAngleAndDistance(-36,77);
  
  addPointFromAngleAndDistance(-37,77);
  
  addPointFromAngleAndDistance(-38,77);
  
  addPointFromAngleAndDistance(-39,77);
  
  addPointFromAngleAndDistance(-40,82);
  
  addPointFromAngleAndDistance(-41,82);
  
  addPointFromAngleAndDistance(-42,77);
  
  addPointFromAngleAndDistance(-43,77);
  
  addPointFromAngleAndDistance(-44,82);
  
  addPointFromAngleAndDistance(-45,82);
  
  addPointFromAngleAndDistance(-46,82);
  
  addPointFromAngleAndDistance(-47,82);
  
  addPointFromAngleAndDistance(-48,82);
  
  addPointFromAngleAndDistance(-49,82);
  
  addPointFromAngleAndDistance(-50,82);
  
  addPointFromAngleAndDistance(-51,87);
  
  addPointFromAngleAndDistance(-52,87);
  
  addPointFromAngleAndDistance(-53,87);
  
  addPointFromAngleAndDistance(-54,87);
  
  addPointFromAngleAndDistance(-55,97);
  
  addPointFromAngleAndDistance(-56,97);
  
  addPointFromAngleAndDistance(-55,102);
  
  addPointFromAngleAndDistance(-54,102);
  
  addPointFromAngleAndDistance(-53,97);
  
  addPointFromAngleAndDistance(-52,97);
  
  addPointFromAngleAndDistance(-51,97);
  
  addPointFromAngleAndDistance(-50,97);
  
  addPointFromAngleAndDistance(-49,92);
  
  addPointFromAngleAndDistance(-48,92);
  
  addPointFromAngleAndDistance(-47,92);
  
  addPointFromAngleAndDistance(-46,92);
  
  addPointFromAngleAndDistance(-45,87);
  
  addPointFromAngleAndDistance(-44,87);
  
  addPointFromAngleAndDistance(-43,87);
  
  addPointFromAngleAndDistance(-42,87);
  
  addPointFromAngleAndDistance(-41,87);
  
  addPointFromAngleAndDistance(-40,87);
  
  addPointFromAngleAndDistance(-39,87);
  
  addPointFromAngleAndDistance(-38,82);
  
  addPointFromAngleAndDistance(-37,82);
  
  addPointFromAngleAndDistance(-36,82);
  
  addPointFromAngleAndDistance(-35,82);
  
  addPointFromAngleAndDistance(-34,77);
  
  addPointFromAngleAndDistance(-33,77);
  
  addPointFromAngleAndDistance(-32,77);
  
  addPointFromAngleAndDistance(-31,77);
  
  addPointFromAngleAndDistance(-30,82);
  
  addPointFromAngleAndDistance(-29,82);
  
  addPointFromAngleAndDistance(-28,77);
  
  addPointFromAngleAndDistance(-27,77);
  
  addPointFromAngleAndDistance(-26,77);
  
  addPointFromAngleAndDistance(-25,77);
  
  addPointFromAngleAndDistance(-24,77);
  
  addPointFromAngleAndDistance(-23,77);
  
  addPointFromAngleAndDistance(-22,77);
  
  addPointFromAngleAndDistance(-21,77);
  
  addPointFromAngleAndDistance(-20,77);
  
  addPointFromAngleAndDistance(-19,77);
  
  addPointFromAngleAndDistance(-18,77);
  
  addPointFromAngleAndDistance(-17,77);
  
  addPointFromAngleAndDistance(-16,77);
  
  addPointFromAngleAndDistance(-15,77);
  
  addPointFromAngleAndDistance(-14,77);
  
  addPointFromAngleAndDistance(-13,77);
  
  addPointFromAngleAndDistance(-12,72);
  
  addPointFromAngleAndDistance(-11,72);
  
  addPointFromAngleAndDistance(-10,77);
  
  addPointFromAngleAndDistance(-9,72);
  
  addPointFromAngleAndDistance(-8,72);
  
  addPointFromAngleAndDistance(-7,77);
  
  addPointFromAngleAndDistance(-6,77);
  
  addPointFromAngleAndDistance(-5,87);
  
  addPointFromAngleAndDistance(-4,87);
  
  addPointFromAngleAndDistance(-3,82);
  
  addPointFromAngleAndDistance(-2,82);
  
  addPointFromAngleAndDistance(-1,87);
  
  addPointFromAngleAndDistance(0,87);
  
  addPointFromAngleAndDistance(1,183);
  
  addPointFromAngleAndDistance(2,183);
  
  addPointFromAngleAndDistance(3,783);
  
  addPointFromAngleAndDistance(4,783);
  
  addPointFromAngleAndDistance(5,778);
  
  addPointFromAngleAndDistance(6,778);
  
  addPointFromAngleAndDistance(7,615);
  
  addPointFromAngleAndDistance(8,615);
  
  addPointFromAngleAndDistance(9,768);
  
  addPointFromAngleAndDistance(10,768);
  
  addPointFromAngleAndDistance(11,326);
  
  addPointFromAngleAndDistance(12,326);
  
  addPointFromAngleAndDistance(13,788);
  
  addPointFromAngleAndDistance(14,788);
  
  addPointFromAngleAndDistance(15,97);
  
  addPointFromAngleAndDistance(16,97);
  
  addPointFromAngleAndDistance(17,605);
  
  addPointFromAngleAndDistance(18,605);
  
  addPointFromAngleAndDistance(19,87);
  
  addPointFromAngleAndDistance(20,87);
  
  addPointFromAngleAndDistance(21,87);
  
  addPointFromAngleAndDistance(22,82);
  
  addPointFromAngleAndDistance(23,82);
  
  addPointFromAngleAndDistance(24,87);
  
  addPointFromAngleAndDistance(25,87);
}

class Point {
  int x, y;

  Point(int xPos, int yPos) {
    x = xPos;
    y = yPos;
  }

  int getX() {
    return x;
  }

  int getY() {
    return y;
  }
}

