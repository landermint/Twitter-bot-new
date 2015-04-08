import processing.serial.*;

float humidityValue = 0;        // red value
float temperatureValue = 0;      // green value
float lightValue = 0;
float pressureValue = 0;
Serial myPort;

void setup() {
  size(200, 200);
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[2], 9600);
  myPort.bufferUntil('\n');
}

void draw() {
  println(humidityValue+" , "+temperatureValue+" , "+lightValue + " , "+pressureValue);
}

void serialEvent(Serial myPort) {
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    inString = trim(inString);
    float[] colors = float(split(inString, ","));
    if (colors.length >=2) {
      // map them to the range 0-255:
      humidityValue = colors[0];
      temperatureValue = colors[1];
      lightValue = colors[2];
      pressureValue = colors[3];
    }
  }
}

