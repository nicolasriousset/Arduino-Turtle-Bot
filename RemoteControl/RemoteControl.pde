import processing.serial.*;
import java.util.Map;
import java.util.List;
import java.io.*;

int SIDE_LENGTH = 1000;
int ANGLE_BOUNDS = 90;
int ANGLE_STEP = 2;
int HISTORY_SIZE = 100;
int POINTS_HISTORY_SIZE = HISTORY_SIZE;
int MAX_DISTANCE = 120;

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
LoadSamplesThread loadSamplesThread = null;

void setup() {
  if (isInitialized) {
    return;
  }
  isInitialized = true;

  println("Beginning setup");

  if (isTestMode) {
    loadSamplesThread = new LoadSamplesThread(); 
    loadSamplesThread.start();
  } else if (Serial.list().length > 0) {
    String comPortId = Serial.list()[0];
    println("COM port initialization. Using " + comPortId);
    myPort = new Serial(this, comPortId, 115200);
    if (myPort != null) {
      myPort.bufferUntil('\n'); // Trigger a SerialEvent on new line
    } else {
      println("COM port initialization failure");
    }
  } else {
    println("COM port initialization failure, no port found.");
    exit();
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
  drawIdentifiedObjects();
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

void drawIdentifiedObjects() {
  ArrayList<ArrayList<Point>> pointsGroupedByProximity = new ArrayList<ArrayList<Point>>();
  for (int i=0; i<POINTS_HISTORY_SIZE; i++) {

    Point point = points[i];
    if (point != null) {
      if (point.x==0 && point.y==0) continue;

      boolean wasAdded = false;
      for (List<Point> pointsGroup : pointsGroupedByProximity) {
        for (Point neighbour : pointsGroup) {
          if (neighbour.distance(point) < 20) {
            pointsGroup.add(point);
            wasAdded = true;
            break;
          }
        }
        if (wasAdded) {
          break;
        }
      }

      if (!wasAdded) {
        ArrayList<Point> newGroup = new ArrayList<Point>();
        newGroup.add(point);
        pointsGroupedByProximity.add(newGroup);
      }
    }
  }

  // For each group, compute a line.
  println("Drawing groups");
  for (List<Point> pointsGroup : pointsGroupedByProximity) {
    println("Draw group");
    Point left = new Point(pointsGroup.get(0).getX(), pointsGroup.get(0).getY());
    Point right = new Point(left.getX(), left.getY()); 
    for (Point neighbour : pointsGroup) {
      if (left.getX() < neighbour.getX()) {
        left.setX(neighbour.getX()); 
        left.setY(neighbour.getY());
      }
      if (right.getX() > neighbour.getX()) {
        right.setX(neighbour.getX()); 
        right.setY(neighbour.getY());
      }
    }
    fill(204, 102, 0);
    stroke(204, 102, 0);
    line(left.getX(), left.getY(), right.getX(), right.getY());
  }
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
    onDataRead(comPortString);
  }
}

void onDataRead(String data) {
  data=trim(data);

  println("Parsing " + data);
  String[] values = split(data, ',');
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

  void setX(int x) {
    this.x = x;
  }

  void setY(int y) {
    this.y = y;
  }

  float distance(Point other) {
    return sqrt(sq(x - other.x) + sq(y - other.y));
  }
}

class LoadSamplesThread extends Thread {
  LoadSamplesThread() {
  }

  public void run() {
    loadSamples();
  }

  void loadSamples() {
    try {
      String sampleFile = "samples.csv";  
      println(sampleFile);

      InputStream fis = createInput(sampleFile);

      //Construct BufferedReader from InputStreamReader
      BufferedReader br = new BufferedReader(new InputStreamReader(fis));

      String line = null;
      while ( (line = br.readLine ()) != null) {
        onDataRead(line);
        Thread.sleep(50);
      }

      br.close();
    } 
    catch (Exception e) 
    { 
      e.printStackTrace();
    }
  }
}

