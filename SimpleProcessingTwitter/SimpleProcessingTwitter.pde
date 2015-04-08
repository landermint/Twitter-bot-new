import twitter4j.util.*;
import twitter4j.*;
import twitter4j.management.*;
import twitter4j.api.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.auth.*;
import java.util.Date;
static String OAuthConsumerKey = "a5Vrknofo8o4NzbRF4r3wrXyu";
static String OAuthConsumerSecret = "oqg2kJdeiPmziappXlGLttP4OfDMhXXDLoimNYDHgOtwbrc76b";

// This is where you enter your Access Token info
static String AccessToken = "3111290033-VY62d4Su3uzRWwb2OWwjkzYuSPOujYl1NYkUPok";
static String AccessTokenSecret = "dFghBwlYzG7suf6aI9c6Gurrvukb1h9L6tNGBu56EVWcY";

// Just some random variables kicking around

String myTimeline;
java.util.List statuses = null;
//User[] friends;
Twitter twitter = new TwitterFactory().getInstance();
RequestToken requestToken;
String[] theSearchTweets = new String[1];


void setup() {
  
  size(100,100);
  background(0);
  
  connectTwitter();
  //sendTweet("Hello from processing");
    getSearchTweets();
}


void draw() {
  
  background(0);

}


// Initial connection
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


// Get your tweets
void getTimeline() {

  try {
    statuses = twitter.getUserTimeline(); 
  } catch(TwitterException e) { 
    println("Get timeline: " + e + " Status code: " + e.getStatusCode());
  }

  for(int i=0; i<statuses.size(); i++) {
    Status status = (Status)statuses.get(i);
    println(status.getUser().getName() + ": " + status.getText());
  }

}


// Search for tweets
void getSearchTweets() {

  String queryStr = "hello";

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

