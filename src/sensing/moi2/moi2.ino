void setup() {
  Serial.begin(9600);
}

void loop() {
  int val;
  val = analogRead(A2);
  
  Serial.print(val);
  Serial.print(",");
  Serial.println(val);
  delay(1000);
}

