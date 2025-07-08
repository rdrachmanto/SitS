////////////////////////////////////////
// This is the information on the sensor being used. 
// See the www.vernier.com/products/sensors.
#include <VernierLib.h>
VernierLib Vernier;
char Sensor[]="ORP";
float Intercept = -559.793;
float Slope = 466.875;
int TimeBetweenReadings = 500; // in ms
int ReadingNumber=0;

/////////////////////////////////////////
void setup() 
{
	Serial.begin(9600); //initialize serial communication at 9600 baud
	Serial.println("SensorID: orp1 Vernier Format 2");
	//Serial.print(Sensor);
	//Serial.print(" ");
	//Serial.println("Readings taken using Ardunio");
	//Serial.println("Data Set");
	//Serial.print("Time");//long name
	//Serial.print("\t"); //tab character
	//Serial.println ("Voltage"); //change to match sensor
	//Serial.print("time");//short name
	//Serial.print("\t"); //tab character
	//Serial.println ("mV"); //short name, change to match sensor 
	//Serial.print("seconds");//units
	//Serial.print("\t"); // tab character
	//Serial.println ("millivolts"); //change to match sensor
}
void loop() 
{
	float Time;

	//the print below does the division first to avoid overflows
	//Serial.print(ReadingNumber/1000.0*TimeBetweenReadings); 
	float Count = analogRead(A0);
	Serial.print("ori:");
	Serial.print(Count);
	float Voltage = Count / 1023 * 5.0;// convert from count to raw voltage
	float SensorReading= Intercept + Voltage * Slope; //converts voltage to sensor reading
	//Serial.print("\t"); // tab character
	Serial.print(", post:");
	Serial.println(SensorReading);
	delay(TimeBetweenReadings);// delay in between reads for stability
	ReadingNumber++;
}
