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
}

private final static float boxX = 300;
private final static float boxY = 20;
private final static float boxZ = 300;
private final static float ballRadius = 20;

private float rX = 0;
private float rZ = 0;
private float speed = 1;

private final static float smoothness = 0.01;
private Mover ball = new Mover(-1 * boxX / 2, boxX / 2, -1 * boxZ / 2, boxZ / 2, ballRadius);
private final static float ballOffset = ballRadius + (boxY / 2) + 1;

void draw() {
  background(255, 255, 255);
  lights();
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(rX);
  rotateZ(rZ);
  box(boxX, boxY, boxZ);
  
  translate(ball.location.x, -ballOffset, -ball.location.y);
  ball.update(rX, rZ);
  ball.display();
  ball.checkEdges();
  
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