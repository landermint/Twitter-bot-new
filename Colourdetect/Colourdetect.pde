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
color current;
color previous;
float redvar;
float bluevar;
float greenvar;
float rmap;
float gmap;
float bmap;
void setup() {
  size(320,240);
  video = new Capture(this, width, height, 30);
  // Create an empty image the same size as the video
  prevFrame = createImage(video.width,video.height,RGB);
  video.start();
}

void draw() {
    background(rmap,gmap,bmap);

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
       current = video.pixels[loc];      // Step 2, what is the current color
       previous = prevFrame.pixels[loc]; // Step 3, what is the previous color
       redvar+=red(current);
       greenvar+=green(current);
       bluevar+=blue(current);
    }
  }
  rmap = map(redvar,5000000,13000000,0,255);
  gmap = map(greenvar,5000000,13000000,0,255);
  bmap = map(bluevar,5000000,13000000,0,255);

  println(rmap+","+gmap+","+bmap);
  redvar = 0;
  greenvar = 0;
  bluevar = 0;
  updatePixels();
  
}

