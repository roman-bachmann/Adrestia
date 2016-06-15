/**
  @Project ADRESTIA; CS211 - Introduction to Visual Computing
  @File TangibleGame.pde
  @Authors Roman Bachmann
           Michael Allemann
           Andrea Caforio
*/

import processing.video.*;
import java.util.List;
import java.util.ArrayList;
import java.util.Random;

void settings() {
  size(1024, 720, P3D);
}

void setup() {
  cam = new Movie(this, "testvideo.mp4");
  cam.loop();
  boardDraw = createGraphics(640, 480, P2D);
  iteration = 0;
  twoThree = new TwoDThreeD(640, 480);
    
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
private float rY = 0;    // rotation of the board in the y axis
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

int iteration;

void draw() {
  background(255);
  lights();
  fill(200);
  
  // If the SHIFT button is pressed go into Object Placement Mode,
  // else run the game
  if (!shiftDown) {
    pushMatrix();
    translate(width/2, height/2, 0);
    
    rotateX(rX);
    rotateZ(rY);

    box(boxX, boxY, boxZ);
    drawCylinders();
    translate(ball.location.x, -ballOffset, -ball.location.y);
    ball.update(rX, rY);
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
  
  if (iteration % 10 == 0) {
    doDraw();
  }
  iteration ++;
  
  PImage boardDrawImg = boardDraw.get();
  boardDrawImg.resize(320, 240);
  image(boardDrawImg, 0, 0);
}

/**
  Calculation of the rotation angles X and Z, bound in the
  intervall [60°, 60°]. A smoothness ratio is applied to
  permit finer control over the rotation
*/
void mouseDragged() {
  if (!scrollbar.mouseOver) {
    rY += (mouseX - pmouseX) * smoothness * speed;
    if (rY > PI/3) { rY = PI/3; }
    else if (rY < -PI/3) { rY = -PI/3; }
  
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
 * Called every time a new frame is available to read
 */
void movieEvent(Movie m) {
  m.read();
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




/****** ImageProcessing *******/

PImage img;
Movie cam;
PImage result;
PGraphics boardDraw;

float hue1 = 75;
float hue2 = 140;             // Lower and upper bound for the hue thresholding
float lower = 30;             // Lower bound for the brightness thresholding
float upper = 235;            // Upper bound for the brightness thresholding
float saturationBound = 40;   // Bound for the saturation thresholding

int minVotes = 150;           // Minimal accumulator value for line selection in Hough transform
int nLines = 6;               // Maximal number of lines the Hough transform returns

float[][] gauss = { {  9, 12,  9 },        // Kernel used to perform a gaussian blur
                    { 12, 15, 12 },
                    {  9, 12,  9 } };
                          
TwoDThreeD twoThree;
PVector rotations;

void doDraw() {
  
  img = cam.get();
  
  PImage hbs = hueBrightnessSaturationThresholding(img, hue1, hue2, lower, upper, saturationBound);
  PImage conv = convolute(hbs, gauss);
  PImage intThr = intensityThreshold(conv, 250);
  PImage sobeled = sobel(intThr);
  
  boardDraw.beginDraw();
  
  boardDraw.background(color(0,0,0));
  boardDraw.image(img, 0, 0);
  ArrayList<PVector> lines = hough(sobeled, nLines);
  getIntersections(lines);
  QuadGraph qg = new QuadGraph();
  qg.build(lines, width, height);
  List<int[]> quads = qg.findCycles();
  quads = qg.filterCycles(quads, lines);
  quads = qg.biggestAreaQuad(quads, lines);
  
  drawQuads(quads, lines);
 
  //Get rotation
  if (quads.size() != 0) {
    List<PVector> quadIntersections = getQuadCornersFromCycle(quads.get(0), lines);
    quadIntersections = qg.sortCorners(quadIntersections);
    PVector rots = twoThree.get3DRotations(quadIntersections);
      
    rots.x = (rots.x > Math.PI/2) ? (float) (rots.x - Math.PI) : rots.x;
    rots.x = (rots.x < -Math.PI/2) ? (float) (rots.x + Math.PI) : rots.x;
     
    rotations = rots;
      
    rX = rots.x;
    rY = rots.y;
      
    println("X-Rotation: " + Math.toDegrees(rots.x));
    println("Y-Rotation: " + Math.toDegrees(rots.y));
    println("Z-Rotation: " + Math.toDegrees(rots.z));
  }
  
  boardDraw.endDraw();
}

/**
 * Thresholds an image using three different techniques:
 * 1) Pixels that have a brightness between lower and upper will be white, otherwise black.
 * 2) Pixels that have a hue between hue1 and hue2 will be white, otherwise black.
 * 3) Pixels that have a saturation lower than saturationBound will be black, otherwise white.
 */
PImage hueBrightnessSaturationThresholding(PImage input, float hue1, float hue2, 
                                           float lower, float upper, float saturationBound) {
                                           
  PImage out = createImage(input.width, input.height, RGB);
  
  for (int i = 0; i < input.width * input.height; i++) {
    if (brightness(input.pixels[i]) >= lower && brightness(input.pixels[i]) <= upper) {
      float h = hue(input.pixels[i]);
      Boolean hueBool = ((h > hue1 && h > hue2) || (h < hue1 && h < hue2));
      Boolean saturationBool = saturation(input.pixels[i]) < saturationBound;
      out.pixels[i] = (!hueBool && !saturationBool) ? color(255) : color(0);
    } else {
      out.pixels[i] = color(0);
    }
  }
  
  return out;
}

/**
 * Thresholds an image using the brightness of the input pixels. All pixels that have
 * a brightness below a certain threshold will be black, all others will be white.
 */
PImage intensityThreshold(PImage input, float intensity) {
  PImage out = createImage(input.width, input.height, RGB);
  
  for (int i = 0; i < input.width * input.height; i++) {
    if (brightness(input.pixels[i]) >= intensity) {
      out.pixels[i] = color(255);
    } else {
      out.pixels[i] = color(0);
    }
  }
  
  return out;
}

/**
 * Convolutes a given kernel over an image and outputs the result.
 * Eg: Use a Gaussian kernel to blur the image.
 */
PImage convolute(PImage img, float[][] kernel) {
  // kernel size N = 3
  int N = kernel[0].length;
  float weight = 0.f;
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      weight += kernel[i][j];
    }
  }
  
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      float sum = 0;
      
      if (!(x == 0 || x == img.width-1 || y == 0 || y == img.height-1)) {
        for (int i = 0; i < N; i++) {
          for (int j = 0; j < N; j++) {
            int index = (j+y-N/2) * img.width + (i+x-N/2);
            sum += kernel[i][j] * brightness(img.pixels[index]);
          }
        }
        sum /= weight;
      }
      
      result.pixels[y * img.width + x] = color(sum);
    }
  }
  
  return result;
}

/**
 * Performs the sobel filter on a given image, creating an
 * image that emphasizes the edges.
 */
PImage sobel(PImage img) {
  float[][] hKernel = { { 0, 1, 0 }, 
                        { 0, 0, 0 },
                        { 0,-1, 0 } };
  float[][] vKernel = { { 0, 0, 0 }, 
                        { 1, 0,-1 },
                        { 0, 0, 0 } };
  
  int N = 3;
  float weight = 1.f;
  
  PImage res = createImage(img.width, img.height, ALPHA);
  
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    res.pixels[i] = color(0);
  }
  
  float max = 0;
  float[] buffer = new float[img.width * img.height];
  
  // Double convolution of the two kernels hKernel and vKernel on the image
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      float sum_h = 0;
      float sum_v = 0;
      float sum = 0;
      
      if (x != 0 && x != img.width-1 && y != 0 && y != img.height-1) {
        for (int i = 0; i < N; i++) {
          for (int j = 0; j < N; j++) {
            int index = (j+y-N/2) * img.width + (i+x-N/2);
            sum_h += hKernel[i][j] * brightness(img.pixels[index]);
            sum_v += vKernel[i][j] * brightness(img.pixels[index]);
          }
        }
        sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2)) / weight;
        max = (sum >= max) ? sum : max;
      }
      
      buffer[y * img.width + x] = brightness(color(sum));
    }
  }
  
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges 
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max 
        res.pixels[y * img.width + x] = color(255);
      } else {
        res.pixels[y * img.width + x] = color(0);
      } 
    }
  }
  
  return res;
}

/**
 * Performs edge detection using the Hough transform.
 * Returns at most the nLines best lines found.
 */
ArrayList<PVector> hough(PImage edgeImg, int nLines) {
  
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  
  // Dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  
  // Pre-compute the sin and cos values
  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];
  float ang = 0;
  float inverseR = 1.f / discretizationStepsR;
  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
    // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
    tabSin[accPhi] = (float) (sin(ang) * inverseR);
    tabCos[accPhi] = (float) (cos(ang) * inverseR);
  }
  
  // Our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  
  // Initialize the accumulator to 0 in every pixel
  for (int i = 0; i < (phiDim + 2) * (rDim + 2); i++) {
    accumulator[i] = 0;
  }
  
  // Fill the accumulator: on edge points (ie, white pixels of the edge 
  // image), store all possible (r, phi) pairs describing lines going 
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        
        // Determines all the lines (r, phi) passing through the pixel
        // (x, y) and increments those values in the parameter space accumulator.
        for (int phiCoord = 0; phiCoord < phiDim; phiCoord++) {
          int rCoord = (int) (x * tabCos[phiCoord] + y * tabSin[phiCoord]);
          rCoord += (rDim - 1) / 2;   // Since r may be negative, center it onto the accumulator.
          accumulator[(phiCoord+1) * (rDim+2) + (rCoord+1)] += 1;
        }
        
      }
    }
  }
  
  
  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
  
  // size of the region we search for a local maximum
  int neighbourhood = 10;
  
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate = true;
        
        // iterate over the neighbourhood
        for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) { 
          
          // check we are not outside the image
          if( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          
          for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
            // check we are not outside the image
            if(accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if(accumulator[idx] < accumulator[neighbourIdx]) { 
              // the current idx is not a local maximum!
              bestCandidate=false;
              break;
            }
          }
          if(!bestCandidate) break;
        }
        if(bestCandidate) {
          // the current idx *is* a local maximum 
          bestCandidates.add(idx);
        }
      }
    }
  }
  
  java.util.Collections.sort(bestCandidates, new HoughComparator(accumulator));
  
  ArrayList<PVector> lines = new ArrayList<PVector>();
  int nBest = (nLines <= bestCandidates.size()) ? nLines : bestCandidates.size();
  for (int i = 0; i < nBest; i++) {
    int idx = bestCandidates.get(i);
    int accPhi = (int) (idx / (rDim + 2)) - 1;
    int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
    float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;
    
    lines.add(new PVector(r, phi));
    //drawLine(edgeImg.width, r, phi);
  }
  
  // *************** DISPLAY THE HOUGH ACCUMULATOR ****************
  //PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  //for (int i = 0; i < accumulator.length; i++) {
  //  houghImg.pixels[i] = color(min(255, accumulator[i]));
  //}
  //// You may want to resize the accumulator to make it easier to see:
  //houghImg.resize(600, 600);
  //houghImg.updatePixels();
  //image(houghImg, 800, 0);
  // **************************************************************
  
  return lines;
}

/**
 * Draws a line on the screen using the polar coordinates describing this line
 */
void drawLine(int edgeImgWidth, float r, float phi) {
  // Cartesian equation of a line: y = ax + b
  // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
  // => y = 0 : x = r / cos(phi)
  // => x = 0 : y = r / sin(phi)
  // compute the intersection of this line with the 4 borders of // the image
  int x0 = 0;
  int y0 = (int) (r / sin(phi));
  int x1 = (int) (r / cos(phi));
  int y1 = 0;
  int x2 = edgeImgWidth;
  int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
  int y3 = edgeImgWidth;
  int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
  // Finally, plot the lines
  boardDraw.stroke(204,102,0);
  if (y0 > 0) {
    if (x1 > 0)
      boardDraw.line(x0, y0, x1, y1);
    else if (y2 > 0)
      boardDraw.line(x0, y0, x2, y2);
    else
      boardDraw.line(x0, y0, x3, y3);
  }
  else {
    if (x1 > 0) {
      if (y2 > 0)
        boardDraw.line(x1, y1, x2, y2);
      else
        boardDraw.line(x1, y1, x3, y3);
    }
    else
      boardDraw.line(x2, y2, x3, y3);
  }
}

/**
 * Computes all the intersections of a List of lines
 */
ArrayList<PVector> getIntersections(List<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      
      // compute the intersection and add it to ’intersections’
      PVector inter = intersection(line1, line2);
      intersections.add(inter);
    }
  }
  return intersections;
}

/**
 * Computes the intersection of two lines.
 */ 
PVector intersection(PVector l1, PVector l2) {
  PVector intersected = new PVector();
  
  double d = cos(l2.y) * sin(l1.y) - cos(l1.y) * sin(l2.y);
  intersected.x = (float) ((l2.x * sin(l1.y) - l1.x * sin(l2.y)) / d);
  intersected.y = (float) ((-l2.x * cos(l1.y) + l1.x * cos(l2.y)) / d);
  
  return intersected;
}

/**
 * Draw and colour all the quads in a given List of quads.
 */
void drawQuads(List<int[]> quads, ArrayList<PVector> lines) {
  for (int[] quad : quads) {
    List<PVector> quadCorners = getQuadCornersFromCycle(quad, lines);
    
    PVector c12 = quadCorners.get(0);
    PVector c23 = quadCorners.get(1);
    PVector c34 = quadCorners.get(2);
    PVector c41 = quadCorners.get(3);
    
    // Draws the corners of the quad
    boardDraw.fill(255, 128, 0);
    boardDraw.ellipse(c12.x, c12.y, 10, 10);
    boardDraw.ellipse(c23.x, c23.y, 10, 10);
    boardDraw.ellipse(c34.x, c34.y, 10, 10);
    boardDraw.ellipse(c41.x, c41.y, 10, 10);
    
    // Draws the edges of the quad
    boardDraw.stroke(204,102,0);
    boardDraw.line(c12.x, c12.y, c23.x, c23.y);
    boardDraw.line(c23.x, c23.y, c34.x, c34.y);
    boardDraw.line(c34.x, c34.y, c41.x, c41.y);
    boardDraw.line(c41.x, c41.y, c12.x, c12.y);
    
    // Choose a random, semi-transparent colour and draw the quad surface
    //Random random = new Random();
    //boardDraw.fill(color(min(255, random.nextInt(300)),
    //min(255, random.nextInt(300)),
    //min(255, random.nextInt(300)), 50));
    boardDraw.fill(color(255, 247, 0, 100));  // For video, choose just one colour
    boardDraw.quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
  }
}

/**
 * Returns the corners of a given quad as a List of PVectors
 */
List<PVector> getQuadCornersFromCycle(int[] quad, List<PVector> lines) {
  PVector l1 = lines.get(quad[0]);
  PVector l2 = lines.get(quad[1]);
  PVector l3 = lines.get(quad[2]);
  PVector l4 = lines.get(quad[3]);
  
  List<PVector> quadCorners = new ArrayList<PVector>();
  
  quadCorners.add(intersection(l1, l2));
  quadCorners.add(intersection(l2, l3));
  quadCorners.add(intersection(l3, l4));
  quadCorners.add(intersection(l4, l1));
  
  return quadCorners;
}