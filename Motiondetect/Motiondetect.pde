// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Example 16-13: Simple motion detection

import processing.video.*;
// Variable for capture device
Capture video;
// Previous Frame
PImage prevFrame;
// How different must a pixel be to be a "motion" pixel
float threshold = 50;
float diff;
float diff2;
float olddiff;
float newdiff;
float videonumber;
float videonumberMapped;
int[] motiondetectarray = new int[1000];
int counter = 0;
void setup() {
  size(320,240);
  video = new Capture(this, width, height, 30);
  // Create an empty image the same size as the video
  prevFrame = createImage(video.width,video.height,RGB);
  video.start();
}

void draw() {
  // Capture video
  if (video.available()) {
    // Save previous frame for motion detection!!
    prevFrame.copy(video,0,0,video.width,video.height,0,0,video.width,video.height); // Before we read the new frame, we always save the previous frame for comparison!
    prevFrame.updatePixels();
    video.read();
  }
  
  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();
  
  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      
      int loc = x + y*video.width;            // Step 1, what is the 1D pixel location
      color current = video.pixels[loc];      // Step 2, what is the current color
      color previous = prevFrame.pixels[loc]; // Step 3, what is the previous color
      
      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); float g1 = green(current); float b1 = blue(current);
      float r2 = red(previous); float g2 = green(previous); float b2 = blue(previous);
      diff = dist(r1,g1,b1,r2,g2,b2);
      
      // Step 5, How different are the colors?
      // If the color at that pixel has changed, then there is motion at that pixel.
      if (diff > threshold) { 
        // If motion, display black
        pixels[loc] = color(0);
        diff2++;
      } else {
        // If not, display white
        pixels[loc] = color(255);
        //diff2--;
      }
    }
  }

  if (counter < 1000){
      println(diff2);

    motiondetectarray[counter] = int(diff2);
  }
  diff2 = 0;
  updatePixels();
  counter++;
  if (counter == 1000){
//    counter = 0;
    int sum = 0;
    for (int i = 0; i < motiondetectarray.length; i++){
      sum = sum + motiondetectarray[i];
    }
    double average = sum / motiondetectarray.length;
    println("average: " + average);
  }
}

