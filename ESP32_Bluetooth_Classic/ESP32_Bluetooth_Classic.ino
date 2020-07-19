#include "BluetoothSerial.h"

//Bluetooth classic
BluetoothSerial SerialBT;

//Relay
int relay=26;
char kondisi;

void setup() {
  Serial.begin(115200);
  pinMode(relay, OUTPUT); //inisiasi relay
  SerialBT.begin("ESP32Rozin"); //Bluetooth device name
}

void loop() {
  kondisi=(char)SerialBT.read();
  Serial.println(kondisi);
  if (SerialBT.available()) {
    if(kondisi=='a'){
      digitalWrite(relay,LOW);
    }else if(kondisi=='b'){
      digitalWrite(relay,HIGH);
    }
  }
  delay(1000);
}
