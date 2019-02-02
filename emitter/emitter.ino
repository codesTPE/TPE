/*
  DATME (Demande l'Acceleration et Transmet au Module Emetteur)
  
  Demande L'accéleration au module accelerometre MPU6050 connecté par le bus I2C puis emet les données reçues par un module RF connecté en pin 4

  Crée le 11 Dec. 2018
  par Léo Lemaire

  A l'aide des bibliothéques : 
  -
  -
  -

  Circuit : 
  Un module MPU6050 connecté au pins SDA et SCL (pins 5 et 7 sur l'attiny85)
  un module emetteur RF 433MHz connecté à l'I/O 4 de l'attiny
  
 */

//import des librairies
#include <tinysnore.h>
#include <Manchester.h>
#include <TinyWireM.h>

//definition des I/O
#define pin 4 //emetteur rf
#define addr 0x68 //addresse I2c de l'accelerometre

uint16_t data=1234;

void setup() {
  TinyWireM.begin(); //demarrage du bus I2c
  writeRegister(addr,0x6B,0); //démarrage de l'accelerometre
  man.setupTransmit(pin,MAN_1200); //demarage de la librarie contrôlant l'emetteur rf
}

void loop() {
  byte data[9];
  data[0]=9;
  readRegister(addr,0x3B,8,&data[1]); //lecture des donnees d'accelerations
  
  man.transmitArray(9,data); //envoie de l'acceleration au module rf
  snore(1000); //on patiente pdt 10sec
}

//fonction pour lire un registre d'un appareil connecté en I2c
void readRegister(byte address,byte reg,byte nbByte,byte* out){
  TinyWireM.beginTransmission(address);
  TinyWireM.send(reg);
  TinyWireM.endTransmission(false);
  TinyWireM.requestFrom(address,nbByte);
  int i=0;
  while(TinyWireM.available()){
    out[i]=TinyWireM.receive();
    i++;
  }
}

//fonction pour ecrire un registre d'un appareil connecté en I2c
void writeRegister(byte address,byte reg,byte data){
  TinyWireM.beginTransmission(address);
  TinyWireM.send(reg);
  TinyWireM.send(data);
  TinyWireM.endTransmission();
}
