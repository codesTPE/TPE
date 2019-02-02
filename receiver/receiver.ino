/*
  RecoDeR (Reçoit Decode Renvoit)
  
  Reçoit les données emises par le module accelrometre grâce à un récepteur RF connecté en pin 2, puis les renvoie à un ordinateur par une connection série (via USB)
  Ce code mesure aussi la vitesse de rotation de la platine grâce à un capteur magnétique (fixe) et un aimant (tournant).

  Crée le 11 Dec. 2018
  par Léo Lemaire

  A l'aide des bibliothéques : 
  - 

  Circuit : 
  Un module recepteur RF connecté en pin 2
  Un capteur magnétique connecté entre le pin 3 et la masse 
  
 */

//import des lib.
#include <Manchester.h>

//def des I/O
#define pin 2 //recepteur rf
#define capt 3 //capteur magnetique compte-tour
int rate,lapTime;
unsigned long milli,millii;
uint8_t buff[9];

void setup() {
  Serial.begin(9600); //demarrage d'un commmunication serie
  pinMode(capt,INPUT_PULLUP); //definition du pin connecté au compte tour comme entrée
  attachInterrupt(digitalPinToInterrupt(capt),onLap,RISING); //definition du pin connecté au compte tour comme interrupt
  man.setupReceive(pin, MAN_1200); //demarage de la librarie contrôlant le recepteur rf
  man.beginReceiveArray(9,buff); //en attente de la reception de données par rf
}

void loop() {
  if (man.receiveComplete()) { //quand on recoit des données
    rate=millis()-milli;
    milli=millis();
    int ax=rawTomG((buff[1]<<8)|buff[2]);//conversion des données brutes en accéleration+temp
    int ay=rawTomG((buff[3]<<8)|buff[4]);
    int az=rawTomG((buff[5]<<8)|buff[6]);
    float Tacc=((buff[7]<<8)|buff[8])/340+36.53;

    float Tmotor=26;
    float Tdriver=25;
    float Tqi=24;
    
    String out="";
    /*out+=Tmotor;
    out+=",";
    out+=Tdriver;
    out+=",";
    out+=Tqi;
    out+=",";
    out+=Tacc;
    out+=",";*/
    out+=ax;
    out+=",";
    out+=ay;
    out+=",";
    out+=az;
    out+=",";
    out+=Tacc;
    out+=",";
    out+=lapTime;
    out+=",";
    out+=rate;
    Serial.println(out+";"); //envoie de l'acceleration reçu par le port série 
    man.beginReceiveArray(9,buff); //on attend l'envoie de nouvelles données par rf
  }
}

//fonction pour convertir l'acceleration brute (10bits/G) en acceleration lisible (1u=1mG)
int rawTomG(int raw){
  return map(raw,0,pow(2,14),0,1000);
}

//fonction pour convertir la rotation brute en degrées/sec
int rawToDS(int raw){
  return map(raw,0,131,0,1000);
}

//fonction executé quand le compte tour est activé, sert a enregister le temps/tour
void onLap(){
  int time=millis()-millii;
  if(time>30){
    lapTime=millis()-millii;
    millii=millis();
  }
}
