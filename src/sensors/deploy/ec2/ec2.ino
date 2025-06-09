 /* Serial Commands:
 *   enterec -> enter the calibration mode
 *   calec -> calibrate with the standard buffer solution, one buffer solutions(12.88ms/cm) will be automaticlly recognized
 *   exitec -> save the calibrated parameters and exit from calibration mode
 *
 */

#include "DFRobot_EC10.h"
#include <EEPROM.h>

#define EC_PIN A2
float voltage,ecValue,temperature = 32;
DFRobot_EC10 ec;

void setup()
{
  Serial.begin(9600);  
  ec.begin();
}

void loop()
{
    static unsigned long timepoint = millis();
    if(millis()-timepoint>1000U)  //time interval: 1s
    {
      timepoint = millis();
      voltage = analogRead(EC_PIN)/1024.0*5000;  // read the voltage
      Serial.print("voltage:");
      Serial.print(voltage);
      //temperature = readTemperature();  // read your temperature sensor to execute temperature compensation
      ecValue =  ec.readEC(voltage,temperature);  // convert voltage to EC with temperature compensation
      Serial.print("  temperature:");
      Serial.print(temperature,1);
      Serial.print("^C  EC:");
      Serial.print(ecValue,1);
      Serial.println("ms/cm");
    }
    ec.calibration(voltage,temperature);  // calibration process by Serail CMD
}

float readTemperature()
{
  //add your code here to get the temperature from your temperature sensor
}
