/**
  @Project ADRESTIA; CS211 - Introduction to Visual Computing
  @File Mover.pde
  @Authors Roman Bachmann
           Michael Allemann
           Andrea Caforio
*/

class Mover {
  private PVector location;
  private PVector velocity;
  private PVector gravity;
  
  private float xMin;
  private float xMax;
  private float yMin;
  private float yMax;
  private float ballRadius;
  
  Mover(float xMin, float xMax, float yMin, float yMax, float ballRadius) {
    this.location = new PVector(0, 0);
    this.velocity = new PVector(0, 0);
    this.gravity = new PVector(0, 0);
    
    this.xMin = xMin;
    this.xMax = xMax;
    this.yMin = yMin;
    this.yMax = yMax;
    this.ballRadius = ballRadius;
  }
      
  /**
    Updates the balls velocity and location based on the
    rotation of the board, the ball's friction and the 
    collisions with the board edges and cylinders
  */
  void update(float rX, float rZ) {
    gravity.x = sin(rZ) * 0.1;
    gravity.y = sin(rX) * 0.1;
    
    velocity.add(gravity);
    velocity.add(friction());
    location.add(velocity);
    checkCylinderCollision();
  }
  
  /**
    Returns the friction vector of the ball
  */
  PVector friction() {
    float normalForce = 1;
    float mu = 0.025;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.copy();
    
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    return friction;
  }
      
  /**
    Draws a sphere with radius ballRadius
  */
  void display() {
    sphere(ballRadius);
  }
  
  /**
    Rebounce calculation when the ball hits the
    edge of the playing board
  */
  void checkEdges() {
    if (location.x >= xMax) {
       velocity.x = velocity.x * -0.55;
       location.x = xMax;
    } else if (location.x <= xMin) {
        velocity.x = velocity.x * -0.55;
        location.x = xMin;
    }
     
    if (location.y >= yMax) {
         velocity.y = velocity.y * -1;
         location.y = yMax;
    } else if (location.y <= yMin) {
         velocity.y = velocity.y * -1;
         location.y = yMin;
    }
  } 
  
  /**
    Rebounce calculation when the ball hits a cylinder
  */
  void checkCylinderCollision() {
    for(PVector c : cylinders) {
      float d = location.dist(c);
      if (d <= ballRadius + cylinderBaseRadius) {
        PVector n = c.copy().sub(location).normalize();
        velocity.sub(n.copy().mult(2 * (velocity.dot(n))));
        location = c.copy().add(n.mult(-d*1.01));
      }
    }
  }
}