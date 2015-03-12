import processing.serial.*;
import java.util.Map;
import java.util.List;
import java.io.*;

int SIDE_LENGTH = 1000;
int ANGLE_BOUNDS = 90;
int ANGLE_STEP = 2;
int HISTORY_SIZE = 100;
int MEASURES_HISTORY_SIZE = HISTORY_SIZE;
int MAX_DISTANCE = 40;

int radius = SIDE_LENGTH / 4;
float leftAngleRad  = radians(-ANGLE_BOUNDS) - HALF_PI; 
float rightAngleRad = radians(ANGLE_BOUNDS) - HALF_PI;

Point[] radarLineHistory = new Point[HISTORY_SIZE]; // used by the radar line
Measure[] measures = new Measure[MEASURES_HISTORY_SIZE];

int centerX = SIDE_LENGTH / 2; 
int centerY= SIDE_LENGTH / 2;

boolean isInitialized = false;
boolean isTestMode = false;

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
  noStroke();
  //smooth();
  rectMode(CENTER);

  println("End setup");
}


void draw() {
  background(0);

  drawRadar();

  drawMeasures();
  drawRadarLine();
  
  Obstacles obstacles = detectObstacles();
  drawObstacles(obstacles);
}

void addAngleToHistory(int angle) {
  shiftHistoryArray();
  float radian = radians(angle);
  int x = (int)(radius * sin(radian));
  int y = (int)(radius * cos(radian));


  int px = centerX + x;
  int py = centerY - y;

  radarLineHistory[0] = new Point(px, py);
}


void drawRadarLine() {
  for (int i=0; i<HISTORY_SIZE; i++) {

    stroke(50, 150, 50, 255 - (25*i));
    Point endOfLine = radarLineHistory[i];
    if (endOfLine != null) {
      line(centerX, centerY, endOfLine.getX(), endOfLine.getY());
    }
  }
}

void addMeasure(int angle, int distanceCm) {
  shiftMeasuresArray();

  println("angle : "+ angle + ", distance (cm): " + distanceCm);

  measures[0] = new Measure(angle, distanceCm);

  addAngleToHistory(angle);
}

Obstacles detectObstacles() {
  // An obstacle is a group of neighbouring measures
  Obstacles obstacles = new Obstacles();
  for (Measure measure : measures) {
    if (measure != null && measure.getDistanceCm() >0) {

      // Compare with each detected obstacle. If close enough, add to the obstacle, else, create new obstacle.
      boolean wasAdded = false;
      for (Obstacle obstacle : obstacles) {
        for (Measure otherMeasure : obstacle) {
          if (otherMeasure.computeDistance(measure) < measure.computeMinDistance()) {
            obstacle.add(new Measure(measure));
            wasAdded = true;
            break;
          }
        }
        if (wasAdded) {
          break;
        }
      }

      if (!wasAdded) {
        Obstacle newObstacle = new Obstacle();
        newObstacle.add(new Measure(measure));
        obstacles.add(newObstacle);
      }
    }
  }
  
  return obstacles;
}

void drawObstacles(Obstacles obstacles) {

  // For each group, compute a line.
  for (List<Measure> obstacle : obstacles) {
    if (obstacle.size() <= 1)
      continue;
    Measure left = new Measure(obstacle.get(0));
    Measure right = new Measure(left); 
    for (Measure neighbour : obstacle) {
      if (left.getAngle() < neighbour.getAngle()) {
        left.setAngle(neighbour.getAngle()); 
        left.setDistanceCm(neighbour.getDistanceCm());
      }
      if (right.getAngle() > neighbour.getAngle()) {
        right.setAngle(neighbour.getAngle()); 
        right.setDistanceCm(neighbour.getDistanceCm());
      }
    }
    fill(204, 102, 0);
    stroke(204, 102, 0);
    Point leftPoint = left.computePoint();
    Point rightPoint = right.computePoint();
    line(leftPoint.getX(), leftPoint.getY(), rightPoint.getX(), rightPoint.getY());
  }
}

void drawMeasures() {
  for (Measure measure : measures) {

    if (measure != null && measure.getDistanceCm() > 0) {
      Point point = measure.computePoint();

      int colorAlfa = 50; // (int)map(i, 0, MEASURES_HISTORY_SIZE, 50, 20);
      int size = 10; // (int)map(i, 0, MEASURES_HISTORY_SIZE, 30, 5);

      fill(50, 150, 50, colorAlfa);
      noStroke();
      ellipse(point.x, point.y, size, size);
    }
  }
}

void drawRadar() {
  stroke(100);
  noFill();

  for (int i = 0; i <= (SIDE_LENGTH / 100); i++) {
    arc(centerX, centerY, 100 * i, 100 * i, leftAngleRad, rightAngleRad);
  }

  for (int i = 0; i <= (ANGLE_BOUNDS*2/20); i++) {
    float angle = -ANGLE_BOUNDS + i * 20;
    float radAngle = radians(angle);
    line(centerX, centerY, centerX + radius*sin(radAngle), centerY - radius*cos(radAngle));
  }
}

void shiftHistoryArray() {
  for (int i = HISTORY_SIZE; i > 1; i--) {
    radarLineHistory[i-1] = radarLineHistory[i-2];
  }
}

void shiftMeasuresArray() {
  for (int i = MEASURES_HISTORY_SIZE; i > 1; i--) {
      measures[i-1] = measures[i-2];
  }
}

void serialEvent(Serial cPort) {
  comPortString = cPort.readString();
  if (comPortString != null) {
    onDataRead(comPortString);
  }
}

void onDataRead(String data) {
  data=trim(data);

  String[] values = split(data, ',');
  try {
    char command = values[0].charAt(0);      

    int angle = Integer.parseInt(values[1]);      
    int distanceCm = Integer.parseInt(values[2]);
    addMeasure(angle, distanceCm);
  } 
  catch (Exception e) {
  }
}

class Measure {
  private int angle;
  private int distanceCm;
  
  public Measure(int angle, int distanceCm) {
    this.angle = angle;
    this.distanceCm = distanceCm;
  }
  
  public Measure(Measure other) {
    this.angle = other.angle;
    this.distanceCm = other.distanceCm;
  }

  public int getDistanceCm() {
    return distanceCm;
  }

  public void setDistanceCm(int distanceCm) {
    this.distanceCm = distanceCm;
  }

  public int getAngle() {
    return angle;
  }
  
  public void setAngle(int angle) {
    this.angle = angle;
  }

  Point computePoint() {
    int distancePixels = int(map(distanceCm, 1, MAX_DISTANCE, 1, radius));

    float radian = radians(angle);
    int x = (int)(distancePixels * sin(radian));
    int y = (int)(distancePixels * cos(radian));
  
    int px = (int)(centerX + x);
    int py = (int)(centerY - y);
  
    return new Point(px, py);    
  }

  public float computeDistance(Measure other) {
    return computePoint().computeDistance(other.computePoint()); // TODO : should return value in cm
  }
  
  public float computeMinDistance() {
    return 20; // TODO : compute real distance in cm
  }
  
  public String toString() {
    return angle + "deg, " + distanceCm + "cm"; 
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

  float computeDistance(Point other) {
    return sqrt(sq(x - other.x) + sq(y - other.y));
  }
  
  String toString() {
    return "[" + x + ", " + y + "]";
  }
}

class LoadSamplesThread extends Thread {
  LoadSamplesThread() {
  }

  public void run() {
    while (true) {
      loadSamples();
    }
  }

  void loadSamples() {
    try {
      InputStream fis = createInput("samples.csv");

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

class Obstacle extends ArrayList<Measure>{
} 

class Obstacles extends ArrayList<Obstacle> {
}
