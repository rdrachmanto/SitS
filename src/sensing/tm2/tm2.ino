
#include <Wire.h>
#include "DFRobot_SHT20.h"

DFRobot_SHT20    sht20;

void setup()
{
    Serial.begin(9600);
    Serial.println("SensorID: tm2 SHT20 Tmpr:^C Hu:%");
    sht20.initSHT20();                                  // Init SHT20 Sensor
    delay(100);
    //sht20.checkSHT20();                                 // Check SHT20 Sensor
}

void loop()
{
    // float humd = sht20.readHumidity();                  // Read Humidity
    float temp = sht20.readTemperature();               // Read Temperature
    // Serial.print("ori: ");
    //Serial.print("Time:");
    //Serial.print(millis());
    // Serial.print("Tmpr-");
    // Serial.print(temp, 1);
    // Serial.print("C");
    // Serial.print(" Hu-");
    // Serial.print(humd, 1);
    //Serial.print("%");
    String message = String(temp) + "," + String(temp);
    Serial.println(message);
    delay(500);
}
