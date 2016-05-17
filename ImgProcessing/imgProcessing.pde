/**
 * @Project ADRESTIA; CS211 - Introduction to Visual Computing
 * @file imgProcessing.pde
 * @brief Detection of a green lego board
 *
 * @authors Michael Allemann
 *          Roman Bachmann
 *          Andrea Caforio
 * @date 13.06.2016
 */

import processing.video.*;
import java.util.List;
import java.util.ArrayList;
import java.util.Random;

private PImage img;
private float hue1, hue2;                          // Lower and upper bound for the hue thresholding
private final static float lower = 20;             // Lower bound for the brightness thresholding
private final static float upper = 235;            // Upper bound for the brightness thresholding
private final static float saturationBound = 40;   // Bound for the saturation thresholding

private final static int minVotes = 190;           // Minimal accumulator value for line selection in Hough transform
private final static int nLines = 6;               // Maximal number of lines the Hough transform returns

private float[][] gauss = { {  9, 12,  9 },        // Kernel used to perform a gaussian blur
                            { 12, 15, 12 },
                            {  9, 12,  9 } };

void settings() {
  size(2200, 600);
}

void setup() {
  img = loadImage("board1.jpg");
  noLoop(); // no interactive behaviour: draw() will be called only once. 
  
  // Hues that are primarily green
  hue1 = 75;
  hue2 = 140;
}

void draw() {
  background(color(0,0,0));
  PImage hbs = hueBrightnessSaturationThresholding(img, hue1, hue2, lower, upper, saturationBound);
  PImage conv = convolute(hbs, gauss);
  PImage intThr = intensityThreshold(conv, 250);
  PImage sobeled = sobel(intThr);
  
  image(img, 0, 0);
  ArrayList<PVector> lines = hough(sobeled, nLines);
  getIntersections(lines);
  QuadGraph qg = new QuadGraph();
  qg.build(lines, width, height);
  List<int[]> quads = qg.findCycles();
  quads = qg.filterCycles(quads, lines);
  quads = qg.biggestAreaQuad(quads, lines);
  
  drawQuads(quads, lines);
  
  image(sobeled, 1400, 0);
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
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(600, 600);
  houghImg.updatePixels();
  image(houghImg, 800, 0);
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
  stroke(204,102,0);
  if (y0 > 0) {
    if (x1 > 0)
      line(x0, y0, x1, y1);
    else if (y2 > 0)
      line(x0, y0, x2, y2);
    else
      line(x0, y0, x3, y3);
  }
  else {
    if (x1 > 0) {
      if (y2 > 0)
        line(x1, y1, x2, y2);
      else
        line(x1, y1, x3, y3);
    }
    else
      line(x2, y2, x3, y3);
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
    fill(255, 128, 0);
    ellipse(c12.x, c12.y, 10, 10);
    ellipse(c23.x, c23.y, 10, 10);
    ellipse(c34.x, c34.y, 10, 10);
    ellipse(c41.x, c41.y, 10, 10);
    
    // Draws the edges of the quad
    stroke(204,102,0);
    line(c12.x, c12.y, c23.x, c23.y);
    line(c23.x, c23.y, c34.x, c34.y);
    line(c34.x, c34.y, c41.x, c41.y);
    line(c41.x, c41.y, c12.x, c12.y);
    
    // Choose a random, semi-transparent colour and draw the quad surface
    Random random = new Random();
    fill(color(min(255, random.nextInt(300)),
    min(255, random.nextInt(300)),
    min(255, random.nextInt(300)), 50));
    quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
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