/*
Environment bot
Jack Lambermont
DIGF 2B03 - Physical computing
OCAD University
April 7th, 2015

BASED ON:
http://www.learningprocessing.com/examples/chapter-16/example-16-13/
http://codasign.com/tutorials/processing-and-twitter/
http://code.compartmental.net/minim/audiosample_field_mix.html
https://github.com/atduskgreg/opencv-processing/blob/master/examples/LiveCamTest/LiveCamTest.pde
*/

import processing.video.*;
//import org.firmata.*;
//import cc.arduino.*;

//import processing.serial.*;
import twitter4j.util.*;
import twitter4j.*;
import twitter4j.management.*;
import twitter4j.api.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.auth.*;
///
import processing.serial.*;
import ddf.minim.*;
import gab.opencv.*;
import java.awt.*;
import java.util.Date;
OpenCV opencv;
Minim minim;
AudioInput in;
float soundValue;
float soundValue2;

float humidityValue;        // red value
float temperatureValue;      // green value
float lightValue;
float pressureValue;
Serial myPort;
///
static String OAuthConsumerKey = "CENSORED";
static String OAuthConsumerSecret = "CENSORED";

// This is where you enter your Access Token info
static String AccessToken = "CENSORED";
static String AccessTokenSecret = "CENSORED";

// Just some random variables kicking around

String myTimeline;
java.util.List statuses = null;
//User[] friends;
Twitter twitter = new TwitterFactory().getInstance();
RequestToken requestToken;
String[] theSearchTweets = new String[11];

// Variable for capture device
Capture video;

//Arduino arduino; //creates arduino object

color back = color(64, 218, 255); //variables for the 2 colors
int timevar = 500;

int sensor= 0;
int read;
float value;
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
int[] motiondetectarray = new int[timevar];
int[] humidityarray = new int [timevar];
int[] temperaturearray = new int [timevar];
int[] photocellarray = new int [timevar];
int[] pressurearray = new int [timevar];
int[] redarray = new int [timevar];
int[] greenarray = new int [timevar];
int[] bluearray = new int [timevar];
int[] soundarray = new int [timevar];
int[] facearray = new int [timevar];
///////////////////////////////HERE ARE THE KEYWORDS
String[] highmotionarray = { "rapid","quick","fast","rush","commotion","bustle","pandemonium" };
String[] lowmotionarray = { "motionless","still","calm","lifeless","peaceful","restful","serene","tranquil" };
String[] highlightarray = { "bright","flashing","illuminated","sunny","sunshine","sun","radiant","shiny" };
String[] lowlightarray = { "dark","cloudy","dusk","dim","overcast","lightless","shade","unlit" };
String[] highhumarray = { "wet","humid","soggy","steamy","moist","watery","drenched","soppy" };
String[] lowhumarray = { "dry","dehydrated","arid","moistureless" };
String[] hightemparray = { "hot","sweltering","scorching","burning","sizzling","boiling" };
String[] medtemparray = { "warm","temperate","pleasant","snug" };
String[] lowtemparray = { "cold","freezing","frigid","frosty","icy","chilly" };
String[] moderateweatherarray = { "temperate","agreeable","fair","beautiful weather","nice weather","good weather" };
String[] muggyweatherarray = { "muggy","sweaty","hot" };
String[] badweatherarray = { "rainy","stormy","unseasonable","bad weather","overcast","shitty weather" };
String[] loudarray = { "loud","deafening","roaring","rambunctious","blustering","thunder","thundering","ear-piercing","noisy","blaring" };
String[] quietarray = { "quiet","silent","peaceful","muted","muffled","hushed","reticent" };
String[] alonearray = { "alone","lonely","solo","friendless","lonesome","solitary","companionless" };
String[] oneotherarray = { "together","date","good company" };
String[] twoothersarray = { "with friends","small gathering", "two friends" };
String[] lotsothersarray = { "group","gang","mob","crowd","assemblage","crew","squad" };
String[] redstringarray = { "red","rose","flame","maroon","magenta","blood" };
String[] bluestringarray = { "blue","sapphire","water","cold","sad","depressed" };
String[] greenstringarray = { "green","grass","leafy","foliage","plantlife","environment","lush","grassy" };

String[] tweetarray = new String [8];
////////////////////////
int counter = 0;
color current;
color previous;
float redvar;
float bluevar;
float greenvar;
float rmap;
float gmap;
float bmap;
Capture video2;



void setup() {
  size(320,240);
  
    println(Serial.list());
  myPort = new Serial(this, Serial.list()[2], 9600);
  myPort.bufferUntil('\n');
  
    connectTwitter();

  video = new Capture(this, width, height,"Logitech Camera");
  video2 = new Capture(this, width, height,"Logitech Camera");

  opencv = new OpenCV(this, width, height);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  // Create an empty image the same size as the video
  prevFrame = createImage(video.width,video.height,RGB);
  
  //arduino = new Arduino(this, Arduino.list()[2], 57600); //sets up arduino
  //arduino.pinMode(sensor, Arduino.INPUT);//setup pins to be input (A0 =0?)
    minim = new Minim(this);

  in = minim.getLineIn();
  video.start();
  video2.start();
}

void draw() {
  video2.read();
  opencv.loadImage(video2);

  //read=arduino.analogRead(sensor);
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
  //sound loop
    for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    soundValue = in.mix.get(i);
    if (soundValue > 0){
      soundValue2+=soundValue;
    } else {
      soundValue2-=soundValue;
    }
  }
  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      
      int loc = x + y*video.width;            // Step 1, what is the 1D pixel location
      current = video.pixels[loc];      // Step 2, what is the current color
      previous = prevFrame.pixels[loc]; // Step 3, what is the previous color
      
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
       redvar+=red(current);
       greenvar+=green(current);
       bluevar+=blue(current);
    }
  }

  //video2.read();
  Rectangle[] faces = opencv.detect();
 // video.stop();
  rmap = map(redvar,5000000,13000000,0,255);
  gmap = map(greenvar,5000000,13000000,0,255);
  bmap = map(bluevar,5000000,13000000,0,255);
  
  if (counter < timevar){
    //println(diff2);
      //println(rmap+","+gmap+","+bmap);
    //println(faces.length);
    motiondetectarray[counter] = int(diff2);

    humidityarray[counter] = int(humidityValue);
    temperaturearray[counter] = int(temperatureValue);
    photocellarray[counter] = int(lightValue);
    pressurearray[counter] = int(pressureValue);
    soundarray[counter] = int(soundValue2);
    redarray[counter] = int(rmap);
    greenarray[counter] = int(gmap);
    bluearray[counter] = int(bmap);
    facearray[counter] = int(faces.length);
  }
  diff2 = 0;
  updatePixels();
  counter++;
  //when cycle is complete
  if (counter == timevar){
    counter = 0;
    //MOTION

    double average1 = findaverage(motiondetectarray);
    //PHOTOCELL
    double average6 = findaverage(humidityarray);

    double average7 = findaverage(temperaturearray);
    
    double average2 = findaverage(photocellarray);

    double average8 = findaverage(pressurearray);
    
    double average9 = findaverage(soundarray);
    
    double average10 = findaverage(facearray);
    
    //RED GREEN BLUE BEGIN
    double average3 = findaverage(redarray);
    
    double average4 = findaverage(greenarray);
    
    double average5 = findaverage(bluearray);
    
    //RED GREEN BLUE END
    println("red: " + average3 + "green: "+average4 + "blue: "+average5);
    println("averagephoto: " + average2);
    String tweet = "";
    if (average3 > average4 && average3 > average5){
        tweetarray[0] = redstringarray[int(random(redstringarray.length))];
    }
    if (average4 > average3 && average4 > average5){
        tweetarray[0] = greenstringarray[int(random(greenstringarray.length))];
    }
    if (average5 > average4 && average5 > average3){
        tweetarray[0] = bluestringarray[int(random(bluestringarray.length))];
    }
    if (average1 > 5000){
        tweetarray[1] = highmotionarray[int(random(highmotionarray.length))];
    } else {
        tweetarray[1] = lowmotionarray[int(random(lowmotionarray.length))];
    }
    if (average2 > 890){
        tweetarray[2] = highlightarray[int(random(highlightarray.length))];
    } else {
        tweetarray[2] = lowlightarray[int(random(lowlightarray.length))];
    }
    if (average6 > 40){
        tweetarray[3] = highhumarray[int(random(highhumarray.length))];
    } else {
        tweetarray[3] = lowhumarray[int(random(lowhumarray.length))];
    }
    if (average7 > 21 && average7 < 26){
        tweetarray[4] = medtemparray[int(random(medtemparray.length))];
    } else if (average7 >= 26){
        tweetarray[4] = hightemparray[int(random(hightemparray.length))];
    } else {
        tweetarray[4] = lowtemparray[int(random(lowtemparray.length))];
    }
    if (average8 >= 1006 && average8 <= 1015){
        tweetarray[5] = moderateweatherarray[int(random(moderateweatherarray.length))];
    }
    if (average8 > 1015){
        tweetarray[5] = muggyweatherarray[int(random(muggyweatherarray.length))];
    }
    if (average8 < 1006){
        tweetarray[5] = badweatherarray[int(random(badweatherarray.length))];
    }
    if (average9 > 50){
        tweetarray[6] = loudarray[int(random(loudarray.length))];
    } else {
        tweetarray[6] = quietarray[int(random(quietarray.length))];
    }
    if (average10 == 0){
        tweetarray[7] = alonearray[int(random(alonearray.length))];
    }
    if (average10 == 1){
        tweetarray[7] = oneotherarray[int(random(oneotherarray.length))];
    }
    if (average10 == 2){
        tweetarray[7] = twoothersarray[int(random(twoothersarray.length))];
    }
    if (average10 > 2){
        tweetarray[7] = lotsothersarray[int(random(lotsothersarray.length))];
    }
    //sendTweet(tweet);
    if (frameCount > timevar){
      //println(tweet);
      println(average6+" "+average7+" "+average8+" "+average9);
      println(tweetarray[int(random(tweetarray.length))]);
      getSearchTweets(tweetarray[int(random(tweetarray.length))]);
    }
  }
  redvar = 0;
  greenvar = 0;
  bluevar = 0;
  soundValue2 = 0;
}

void connectTwitter() {

  twitter.setOAuthConsumer(OAuthConsumerKey, OAuthConsumerSecret);
  AccessToken accessToken = loadAccessToken();
  twitter.setOAuthAccessToken(accessToken);

}

// Sending a tweet
void sendTweet(String t) {

  try {
    Status status = twitter.updateStatus(t);
    println("Successfully updated the status to [" + status.getText() + "].");
  } catch(TwitterException e) { 
    println("Send tweet: " + e + " Status code: " + e.getStatusCode());
  }

}


// Loading up the access token
private static AccessToken loadAccessToken(){
  return new AccessToken(AccessToken, AccessTokenSecret);
}

void serialEvent(Serial myPort) {
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    inString = trim(inString);
    float[] colors = float(split(inString, ","));
    if (colors.length >=2) {
      if (frameCount > 500){
      // map them to the range 0-255:
      humidityValue = colors[0];
      temperatureValue = colors[1];
      lightValue = colors[2];
      pressureValue = colors[3];
      }
    }
  }
}
double findaverage(int[] arrayname){
    int sum = 0;
    for (int i = 0; i < arrayname.length; i++){
      sum = sum + arrayname[i];
    }
    double average = sum / arrayname.length;
    return average;
}
void getSearchTweets(String searchthing) {

  String queryStr = searchthing;

  try {
    Query query = new Query(queryStr);    
    query.count(1); // Get 10 of the 100 search results  
    QueryResult result = twitter.search(query);    
    ArrayList tweets = (ArrayList) result.getTweets();    
    long messageid;
    for (int i=0; i<tweets.size(); i++) {  
      Status t = (Status)tweets.get(i);  
      User u=(User) t.getUser();
      String user=u.getName();
      String msg = t.getText();
      Date d = t.getCreatedAt();  
      theSearchTweets[i] = msg.substring(queryStr.length()+1);
      messageid = t.getId();
      println(messageid);
      twitter.retweetStatus(messageid);
    }

  } catch (TwitterException e) {    
    println("Search tweets: " + e);  
  }

}

