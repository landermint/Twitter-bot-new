/* SFE_BMP180 library example sketch

This sketch shows how to use the SFE_BMP180 library to read the
Bosch BMP180 barometric pressure sensor.
https://www.sparkfun.com/products/11824

Like most pressure sensors, the BMP180 measures absolute pressure.
This is the actual ambient pressure seen by the device, which will
vary with both altitude and weather.

Before taking a pressure reading you must take a temparture reading.
This is done with startTemperature() and getTemperature().
The result is in degrees C.

Once you have a temperature reading, you can take a pressure reading.
This is done with startPressure() and getPressure().
The result is in millibar (mb) aka hectopascals (hPa).

If you'll be monitoring weather patterns, you will probably want to
remove the effects of altitude. This will produce readings that can
be compared to the published pressure readings from other locations.
To do this, use the sealevel() function. You will need to provide
the known altitude at which the pressure was measured.

If you want to measure altitude, you will need to know the pressure
at a baseline altitude. This can be average sealevel pressure, or
a previous pressure reading at your altitude, in which case
subsequent altitude readings will be + or - the initial baseline.
This is done with the altitude() function.

Hardware connections:

- (GND) to GND
+ (VDD) to 3.3V

(WARNING: do not connect + to 5V or the sensor will be damaged!)

You will also need to connect the I2C pins (SCL and SDA) to your
Arduino. The pins are different on different Arduinos:

Any Arduino pins labeled:  SDA  SCL
Uno, Redboard, Pro:        A4   A5
Mega2560, Due:             20   21
Leonardo:                   2    3

Leave the IO (VDDIO) pin unconnected. This pin is for connecting
the BMP180 to systems with lower logic levels such as 1.8V

Have fun! -Your friends at SparkFun.

The SFE_BMP180 library uses floating-point equations developed by the
Weather Station Data Logger project: http://wmrx00.sourceforge.net/

Our example code uses the "beerware" license. You can do anything
you like with this code. No really, anything. If you find it useful,
buy me a beer someday.

V10 Mike Grusin, SparkFun Electronics 10/24/2013
*/

// Your sketch must #include this library, and the Wire library.
// (Wire is a standard library included with Arduino.):

#include <SFE_BMP180.h>
#include <Wire.h>

#include <dht.h>

dht DHT;


#define DHT22_PIN 5
// You will need to create an SFE_BMP180 object, here called "pressure":

SFE_BMP180 pressure;

#define ALTITUDE 1655.0 // Altitude of SparkFun's HQ in Boulder, CO. in meters

void setup()
{
  Serial.begin(9600);
  //Serial.println("REBOOT");

  // Initialize the sensor (it is important to get calibration values stored on the device).

  if (pressure.begin())
  delay(0);
    //Serial.println("");
  else
  {
    // Oops, something went wrong, this is usually a connection problem,
    // see the comments at the top of this sketch for the proper connections.

    //Serial.println("BMP180 init fail\n\n");
    while(1); // Pause forever.
  }
 
}

void loop()
{
      int chk = DHT.read22(DHT22_PIN);
    switch (chk)
    {
        case DHTLIB_OK: 
            //Serial.print("OK,\t"); 
            break;
        case DHTLIB_ERROR_CHECKSUM: 
            //Serial.print("Checksum error,\t"); 
            break;
        case DHTLIB_ERROR_TIMEOUT: 
            //Serial.print("Time out error,\t"); 
            break;
        default: 
            //Serial.print("Unknown error,\t"); 
            break;
    }
          int sensorValue = analogRead(A0);

    ////
  char status;
  double T,P,p0,a;

  status = pressure.startTemperature();
  if (status != 0)
  {
    // Wait for the measurement to complete:
    delay(status);

    // Retrieve the completed temperature measurement:
    // Note that the measurement is stored in the variable T.
    // Function returns 1 if successful, 0 if failure.

    status = pressure.getTemperature(T);
    if (status != 0)
    {

      status = pressure.startPressure(3);
      if (status != 0)
      {
        
        delay(status);
        
        status = pressure.getPressure(P,T);
        if (status != 0)
        {
              Serial.print(DHT.humidity, 1);
    Serial.print(",");
    Serial.print(DHT.temperature, 1);
    Serial.print(",");
    Serial.print(sensorValue);
        Serial.print(",");
          Serial.println(P,2);
        }
        else Serial.println("error retrieving pressure measurement\n");
      }
      else Serial.println("error starting pressure measurement\n");
    }
    else Serial.println("error retrieving temperature measurement\n");
  }
  else Serial.println("error starting temperature measurement\n");

  delay(1000);  // Pause for 5 seconds.
}
