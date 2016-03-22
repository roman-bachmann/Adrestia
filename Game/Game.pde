/**
  @Project ADRESTIA; CS211 - Introduction to Visual Computing
  @File Game.pde
  @Authors Roman Bachmann
           Michael Allemann
           Andrea Caforio
*/

void settings() {
  size(800, 800, P3D);
}

void setup() {
  noStroke();
  drawCylinder();
}

private final static float boxX = 300;
private final static float boxY = 20;
private final static float boxZ = 300;
private final static float ballRadius = 20;

private boolean shiftDown = false;
private boolean mouseClick = false;
public float cylinderBaseSize = 10;
private float cylinderHeight = 50;
private int cylinderResolution = 40;
private PShape openCylinder = new PShape();
private PShape cylinderTop = new PShape();
private PShape cylinderBottom = new PShape();
public ArrayList<PVector> cylinders = new ArrayList<PVector>();

private float rX = 0;
private float rZ = 0;
private float speed = 1;

private final static float smoothness = 0.01;
private Mover ball = new Mover(-1 * boxX / 2, boxX / 2, -1 * boxZ / 2, boxZ / 2, ballRadius);
private final static float ballOffset = ballRadius + (boxY / 2) + 1;

void draw() {
  background(255, 255, 255);
  lights();
  
  if (!shiftDown) {
    pushMatrix();
    translate(width/2, height/2, 0);
    rotateX(rX);
    rotateZ(rZ);
    box(boxX, boxY, boxZ);
    drawCylinders();
    translate(ball.location.x, -ballOffset, -ball.location.y);
    ball.update(rX, rZ);
    ball.display();
    ball.checkEdges();
  } else {
    pushMatrix();
    translate(width/2, height/2, 0);
    rotateX(-PI/2);
    box(boxX, boxY, boxZ);
    drawCylinders();
    translate(ball.location.x, -ballOffset, -ball.location.y);
    ball.display();
    if (mouseClick) {
      if ((mouseX-width/2) > -boxX/2 && (mouseX-width/2) < boxX/2 &&
          (mouseY-height/2) > -boxZ/2 && (mouseY-height/2) < boxZ/2)
        cylinders.add(new PVector(mouseX-width/2, -(mouseY-height/2)));
      mouseClick = false;
    }
  }
  popMatrix();
  
  text("X rotation = " + Math.round(Math.toDegrees(rX) * 100.0) / 100.0, 20, 20);
  text("Z rotation = " + Math.round(Math.toDegrees(rZ) * 100.0) / 100.0, 20, 40);
  text("Speed = " + Math.round(speed * 100.0) / 100.0, 20, 60);
}

/**
  Calculation of the rotation angles X and Z, bound in the
  intervall [60°, 60°]. A smoothness ratio is applied to
  permit finer control over the rotation
*/
void mouseDragged() {
  rZ += (mouseX - pmouseX) * smoothness * speed;
  if (rZ > PI/3) { rZ = PI/3; }
  else if (rZ < -PI/3) { rZ = -PI/3; }
  
  rX -= (mouseY - pmouseY) * smoothness * speed;
  if (rX > PI/3) { rX = PI/3; }
  else if (rX < -PI/3) { rX = -PI/3; } 
}

/**
  De/Incrementation of the rotation speed comprised
  between ]0.2, 3[. Relevant for mouseDragged()
*/
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0 && speed < 3) { speed += 0.03; }
  else if (e < 0 && speed > 0.2) { speed -= 0.03; }
}

void keyPressed() {
  if ((key==CODED) && (keyCode == SHIFT))
    shiftDown = true;
}

void keyReleased() {
  if ((key==CODED) && (keyCode == SHIFT))
    shiftDown = false;
}

void mouseClicked() {
  if (shiftDown)
    mouseClick = true;
}

void drawCylinder() {
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];
  //get the x and y position on a circle for all the sides
  for(int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }
  
  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
  for(int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i] , 0);
    openCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  openCylinder.endShape();
  
  cylinderBottom = createShape();
  cylinderBottom.beginShape(TRIANGLE);
  for(int i = 0; i < x.length - 1; i++) {
    cylinderBottom.vertex(x[i], y[i], 0);
    cylinderBottom.vertex(x[i+1], y[i+1], 0);
    cylinderBottom.vertex(0, 0, 0);
  }
  cylinderBottom.endShape();
  
  cylinderTop = createShape();
  cylinderTop.beginShape(TRIANGLE);
  for(int i = 0; i < x.length - 1; i++) {
    cylinderTop.vertex(x[i], y[i], cylinderHeight);
    cylinderTop.vertex(x[i+1], y[i+1], cylinderHeight);
    cylinderTop.vertex(0, 0, cylinderHeight);
  }
  cylinderTop.endShape();
}

void drawCylinders() {
  for(PVector c : cylinders) {
      pushMatrix();
      translate(c.x, -boxY/2, -c.y);
      rotateX(PI/2);
      shape(openCylinder);
      shape(cylinderBottom);
      shape(cylinderTop);
      popMatrix();
  }
}