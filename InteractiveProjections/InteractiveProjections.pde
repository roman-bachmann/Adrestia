/**
* @file Projections.pde - Assignment #2
* @brief Basic transformations and projections in 2D and 3D
*
* In this second assignment we are applying basic transformations
* and projections onto on points in two and three dimensions.
* The final picture portrays three boxes in different rotations
* and transformations.
*
* @authors Roman Bachmann
*          Michael Allemann
*          Andrea Caforio
* @date 28.03.16
*/


void settings() { size(800, 800, P3D); }

void setup() {}

/**
* Rotation angles modified by keyPressed.
*/
float rx = 0;
float ry = 0;

/**
* By pressing the arrow key the user rotates the
* cuboid around the x- and y-axis.
*/
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      rx += 0.10;
    }
    else if (keyCode == DOWN) {
      rx -= 0.10;
    }
    else if (keyCode == LEFT) {
      ry += 0.10;
    }
    else if (keyCode == RIGHT) {
      ry -= 0.10;
    }
  }
}

/**
* Given by the instruction guide.
*/
void draw(){
  background(255);
  My3DPoint eye = new My3DPoint(0, 0, -500);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 80, 80, 80);
  
  /* Rotation around the x-axis */
  float[][] t1 = rotateXMatrix(rx);
  input3DBox = transformBox(input3DBox, t1);
  
  /* Rotation around the y-axis */
  float[][] t2 = rotateYMatrix(ry);
  input3DBox = transformBox(input3DBox, t2);
  
  /* Translation to the center of the window */
  float[][] t3 = translationMatrix((width - 80) / 2, (height - 80) / 2, 0);
  input3DBox = transformBox(input3DBox, t3);

  projectBox(eye, input3DBox).render();
}

/**
* Translated a 3D-Point p into the eye's reference frame
* before projecting it. The equations follow
* from the instruction guide.
*/
My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
 float px = (-eye.x + p.x) / (1 - (p.z / eye.z));
 float py = (-eye.y + p.y) / (1 - (p.z / eye.z));
 return new My2DPoint(px, py);
}

/**
* Projects all the points in the 3DBox-object,
* resulting in a new 2DBox.
*/
My2DBox projectBox(My3DPoint eye, My3DBox box) {
  My2DPoint[] p = new My2DPoint[box.p.length];
  for (int i = 0; i < p.length; i++) {
    p[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(p);
}

/**
* Add the homogenous dimension to a 3D-Point p.
*/
float[] homogeneous3DPoint(My3DPoint p) {
  float[] result = { p.x, p.y, p.z, 1 };
  return result;
}

/**
* Restores the homogeneous form of a Point by dividing
* all coordinates by the homogeneous dimension.
*/
My3DPoint euclidian3DPoint(float[] a) {
  My3DPoint result = new My3DPoint(a[0] / a[3], a[1] / a[3], a[2] / a[3]);
  return result;
}

/**
* Cookbook 3D-rotation around the x-axis.
*/
float[][] rotateXMatrix(float angle) {
  return new float[][] { { 1, 0, 0, 0},
                         { 0, cos(angle), sin(angle), 0 },
                         { 0, -sin(angle), cos(angle), 0 },
                         { 0, 0, 0, 1 } };
}

/**
* Cookbook 3D-rotation around the y-axis.
*/
float[][] rotateYMatrix(float angle) {
  return new float[][] { { cos(angle), 0, sin(angle), 0},
                         { 0, 1, 0, 0 },
                         { -sin(angle), 0, cos(angle), 0 },
                         { 0, 0, 0, 1 } };
}

/**
* Cookbook 3D-rotation around the z-axis.
*/
float[][] rotateZMatrix(float angle) {
  return new float[][] { { cos(angle), -sin(angle), 0, 0},
                         { sin(angle), cos(angle), 0, 0 },
                         { 0, 0, 1, 0 },
                         { 0, 0, 0, 1 } };
}

/**
* Cookbook scaling of a 3D-point
*/
float[][] scaleMatrix(float x, float y, float z) {
  return new float[][] { { x, 0, 0, 0 },
                         { 0, y, 0, 0 },
                         { 0, 0, z, 0 },
                         { 0, 0, 0, 1 } };
}

/**
* Cookbook transformation of a 3D-point
*/
float[][] translationMatrix(float x, float y, float z) {
  return new float[][] { { 1, 0, 0, x },
                         { 0, 1, 0, y },
                         { 0, 0, 1, z },
                         { 0, 0, 0, 1 } };
}

/**
* Generic matrix multiplication facility. In this
* context mainly used to apply transformations etc.
* on a point array.
*/
float[] matrixProduct(float[][] a, float[] b) {
  float[] c = new float[b.length];
  for (int i = 0; i < a.length; i++) {
    for (int j = 0; j < b.length; j++) {
      c[i] += (a[i][j] * b[j]);
    }
  }
  return c;
}

/**
* Iterating over all points of a box objects applying
* the transformMatrix to create a new 3DBox object.
*/
My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] p = new My3DPoint[box.p.length];
  for (int i = 0; i < p.length; i++) {
    p[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])));
  }
  return new My3DBox(p);
}

/**
* Class depicting a 2D point
*/
class My2DPoint {
  float x;
  float y;
  
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

/**
* Class holding an array of 2DPoints creating
* a box in 2D space.
*/
class My2DBox {
  My2DPoint[] s;
  
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  
  /**
  * Drawing the edges of the 2DBox corresponding to
  * the information given in the instruction guide.
  */
  public void render() {
    strokeWeight(4);    
    stroke(0, 255, 0);
    line(s[5].x, s[5].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[7].x, s[7].y);
    line(s[7].x, s[7].y, s[4].x, s[4].y);
    line(s[4].x, s[4].y, s[5].x, s[5].y); 
    stroke(0, 0, 255);
    line(s[1].x, s[1].y, s[5].x, s[5].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);  
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    stroke(255, 0, 0);
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[0].x, s[0].y, s[3].x, s[3].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[2].x, s[2].y, s[1].x, s[1].y);   
  }
}

/**
* Class depicting a 3DPoint
*/
class My3DPoint {
  float x;
  float y;
  float z;
  
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

/**
* Class holding an array of 3DPoints that make up
* a box in 3D space.
*/
class My3DBox {
  My3DPoint[] p;
  
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    
    this.p = new My3DPoint[] { new My3DPoint(x, y + dimY, z + dimZ),
                               new My3DPoint(x, y, z + dimZ),
                               new My3DPoint(x + dimX, y, z + dimZ),
                               new My3DPoint(x + dimX, y + dimY, z + dimZ),
                               new My3DPoint(x, y + dimY, z),
                               origin,
                               new My3DPoint(x + dimX, y, z),
                               new My3DPoint(x + dimX, y + dimY, z) };
  }
  
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}