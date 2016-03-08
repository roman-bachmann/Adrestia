float rX = 0;
float rZ = 0;
float speed = 1;

void settings() {
  size(800, 800, P3D);
}

void setup() {
  noStroke();
}
void draw() {
  background(200);
  lights();
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(rX);
  rotateZ(rZ);
  box(300, 20, 300);
  popMatrix();
  text("X rotation = " + Math.round(Math.toDegrees(rX) * 100.0) / 100.0, 20, 20);
  text("Z rotation = " + Math.round(Math.toDegrees(rZ) * 100.0) / 100.0, 20, 40);
  text("Speed = " + Math.round(speed * 100.0) / 100.0, 20, 60);
}

void mouseDragged() {
  rZ += (mouseX - pmouseX) * 0.01 * speed;
  if (rZ > PI/3) {
    rZ = PI/3; 
  } else if (rZ < -PI/3) {
    rZ = -PI/3;
  }  
  rX -= (mouseY - pmouseY) * 0.01 * speed;
  if (rX > PI/3) {
    rX = PI/3; 
  } else if (rX < -PI/3) {
    rX = -PI/3;
  } 
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0 && speed < 3) {
    speed += 0.03;
  } else if (e < 0 && speed > 0.2) {
    speed -= 0.03;
  }
}