void setup() {
  Serial.begin(9600);
}

void loop() {
  int val;
  val = analogRead(A3);
  String message = String(val) + "," + String(val);

  Serial.println(message);
  delay(100);
}

