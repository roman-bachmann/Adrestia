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

float rX = 0;
float rZ = 0;
float speed = 1;

final float smoothness = 0.01;

void draw() {
  background(200);
  lights();
  pushMatrix();
  translate(width/2, height/2, 0); // Box including the rotation in the center of the screen
  rotateX(rX);
  rotateZ(rZ);
  box(300, 20, 300);
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