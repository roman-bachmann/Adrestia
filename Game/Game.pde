/**
  @Project ADRESTIA; CS211 - Introduction to Visual Computing
  @File Game.pde
  @Authors Roman Bachmann
           Michael Allemann
           Andrea Caforio
*/

void settings() {
  size(1024, 720, P3D);
}

void setup() {
  noStroke();
  createCylinder();
  dashboard = new Dashboard();
  scrollbar = new HScrollbar(HSC_X, HSC_Y, HSC_WIDTH, HSC_HEIGHT);
  ball = new Mover(-1 * boxX / 2, boxX / 2, -1 * boxZ / 2, boxZ / 2, ballRadius, dashboard);
  pillar = loadShape("Models/pillar.obj");
  pillar.scale(2.5);
}

private final static float boxX = 300;
private final static float boxY = 20;
private final static float boxZ = 300;
private final static float ballRadius = 10;

private boolean shiftDown = false;
private boolean mouseClick = false;
public float cylinderBaseRadius = 20;
private float cylinderHeight = 50;
private int cylinderResolution = 40;
private PShape openCylinder = new PShape();
private PShape cylinderTop = new PShape();
private PShape cylinderBottom = new PShape();
public ArrayList<PVector> cylinders = new ArrayList<PVector>(); // stores the position of all cylinders
private PShape pillar = new PShape();

private float rX = 0;    // rotation of the board in the x axis
private float rZ = 0;    // rotation of the board in the y axis
private float speed = 1;

private Dashboard dashboard;
private HScrollbar scrollbar;

private final float HSC_X = 400;
private final float HSC_Y = 688;
private final float HSC_WIDTH = 300;
private final float HSC_HEIGHT = 20;

private final static float smoothness = 0.01;
private Mover ball;
private final static float ballOffset = ballRadius + (boxY / 2) + 1;



void draw() {
  background(255, 255, 255);
  lights();
  fill(200);
  
  // If the SHIFT button is pressed go into Object Placement Mode,
  // else run the game
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
  
  fill(255, 255, 255);
  dashboard.drawBackground();
  dashboard.drawTopView(cylinders, cylinderBaseRadius, ballRadius, ball.location, boxX);
  dashboard.drawTextView();
  dashboard.drawBarChart();
  dashboard.drawStat();
  dashboard.copyGraphList();
  scrollbar.update();
  scrollbar.display();
}

/**
  Calculation of the rotation angles X and Z, bound in the
  intervall [60°, 60°]. A smoothness ratio is applied to
  permit finer control over the rotation
*/
void mouseDragged() {
  if (!scrollbar.mouseOver) {
    rZ += (mouseX - pmouseX) * smoothness * speed;
    if (rZ > PI/3) { rZ = PI/3; }
    else if (rZ < -PI/3) { rZ = -PI/3; }
  
    rX -= (mouseY - pmouseY) * smoothness * speed;
    if (rX > PI/3) { rX = PI/3; }
    else if (rX < -PI/3) { rX = -PI/3; } 
  }
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

/**
  Registers the push of a key
*/
void keyPressed() {
  if ((key==CODED) && (keyCode == SHIFT))
    shiftDown = true;
}

/**
  Registers the release of a key
*/
void keyReleased() {
  if ((key==CODED) && (keyCode == SHIFT))
    shiftDown = false;
}

/**
  Registers a mouse click
*/
void mouseClicked() {
  if (shiftDown)
    mouseClick = true;
}

/**
  Create the shapes of a closed cylinder
*/
void createCylinder() {
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];
  // Get the x and y position on a circle for all the sides
  for(int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseRadius;
    y[i] = cos(angle) * cylinderBaseRadius;
  }
  
  // Create the border of the cylinder
  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  for(int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i] , 0);
    openCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  openCylinder.endShape();
  
  // Create the bottom face of the cylinder
  cylinderBottom = createShape();
  cylinderBottom.beginShape(TRIANGLE);
  for(int i = 0; i < x.length - 1; i++) {
    cylinderBottom.vertex(x[i], y[i], 0);
    cylinderBottom.vertex(x[i+1], y[i+1], 0);
    cylinderBottom.vertex(0, 0, 0);
  }
  cylinderBottom.endShape();
  
  // Create the top face of the cylinder
  cylinderTop = createShape();
  cylinderTop.beginShape(TRIANGLE);
  for(int i = 0; i < x.length - 1; i++) {
    cylinderTop.vertex(x[i], y[i], cylinderHeight);
    cylinderTop.vertex(x[i+1], y[i+1], cylinderHeight);
    cylinderTop.vertex(0, 0, cylinderHeight);
  }
  cylinderTop.endShape();
}

/**
  Draws all the cylinder shapes using the positions stored
  in the cylinders ArrayList
*/
void drawCylinders() {
  for(PVector c : cylinders) {
      pushMatrix();
      translate(c.x, -boxY/2, -c.y);
      //rotateX(PI/2);
      //shape(openCylinder);
      //shape(cylinderBottom);
      //shape(cylinderTop);
      rotateX(PI);
      shape(pillar);
      popMatrix();
  }
}