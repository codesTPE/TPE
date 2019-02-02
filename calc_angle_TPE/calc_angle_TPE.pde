/*
  Code pour mesurer l’angle de pousse des plantes puis le compare avec l’angle theorique calculé.

  Clic droit pour placer les deux points qui servent d’échelle pour les calculs (la distance entre les deuc marquers est égale à la variable distBetweenTheTwoMarkers).
  Clic gauche pour placer les point à mesurer (deux points suivant la plante a mesurer).
  F1 pour enregistrer l’image et les données à l’emplacement specifié à la variable pathToSave.
*/

//var pour stocker l'image à analyser
PImage in;
//var pour compter le nombre de clicks
int Rclk,Lclk;
//var stockant la position des point de reference
PVector[] markers=new PVector[2];
//var des points a mesurer
mark points[]=new mark[1];


//distance entre les deux points de reference pour l'echelle (m)
float distBetweenTheTwoMarkers=0.14;
//vitesse de rotation (t/mn)
int tpm=88;

//var stockant les valeurs calculées
String out="";

//emplacement de stockage des résultats
String pathToSave="";
//emplacement de l'image a analyser
String imgPath="img.jpg";

void setup(){
  size(100,100);
  in=loadImage(imgPath);
  
  surface.setResizable(true);
  surface.setSize(displayWidth/2,displayHeight/2);
  
  in.resize(displayWidth/2,displayHeight/2);
  
  points[0]=new mark();
}
void draw(){
  image(in,0,0);
  noStroke();
  fill(255,0,0);
  //on dessine les points avec les lignes theoriques et les legendes
  for(int i=0;i<markers.length;i++) if(markers[i]!=null) ellipse(markers[i].x,markers[i].y,10,10);
  for(int i=0;i<points.length;i++) if(points[i]!=null){
    noStroke();
    fill(0,255,0);
    points[i].drawPoints();
    stroke(255);
    points[i].drawLine();
    fill(255);
    points[i].dispNb(i);
  }
}

void mousePressed(){
  //definition des points de reference
  if(mouseButton==RIGHT){
    if(Rclk>=2) Rclk-=2;
    markers[Rclk]=new PVector(mouseX,mouseY);
    Rclk++;
  }
  
  //definition des points a mesurer
  if(mouseButton==LEFT){
    //si on as déjà defini deux points on en crée un nouveau
    if(Lclk>=2){
      Lclk-=2;
      points=(mark[])append(points,new mark());
    }
    
    //on defini la position du point à celui de la souris
    points[points.length-1].pos[Lclk]=new PVector(mouseX,mouseY);
    
    //si on as déjà défini 1 point on calcule les angles et on les envoie sur la console et dans la variable de sortie
    if(Lclk==1){
      points[points.length-1].calcAngle();
      points[points.length-1].calcAcc(markers,distBetweenTheTwoMarkers);
      mark cur=points[points.length-1];
      println(cur.rayon+":"+cur.acc+":"+cur.angleth+":"+cur.angle);
      out+=cur.rayon+":"+cur.acc+":"+cur.angleth+":"+cur.angle+"\n";
    }
    Lclk++;
  }
}

void keyPressed(){
  //si F1 est presseé on enregistre
  if(keyCode==112){
    println("saving...");
    save(pathToSave+"out#.png");
    PrintWriter o=createWriter(pathToSave+"data#.txt");
    o.print(out);
    o.flush();
    o.close();
    println("saved!");
  }
}

//class des points à calculer
class mark{
  float angle,acc;
  float angleth,rayon;
  PVector[] pos;
  
  mark(){
    pos=new PVector[2];
  }
  
  void calcAngle(){
    //           C
    //          /|
    //         / |
    //        /  |
    //       /   |
    //      /____|
    //     A     B
    //
    //On calcule l'angle BAC grâce à la relation cos=adjacent/hypothenuse et on donc BAC=arccos(AB/AC)
    angle=degrees(acos((pos[1].x-pos[0].x)/dist(pos[0].x,pos[0].y,pos[1].x,pos[1].y)));
  }
  
  void calcAcc(PVector[] marks,float ref){
    //on calcule l'acceleration grâce a la formule Acc=V²/r
    //on trouve la distance au centre grâce aux points de reference
    rayon=map(pos[0].x,marks[0].x,marks[1].x,0,ref);
    //on en déduit la vitesse
    float v=(rayon*2*PI)*(tpm/60.0);
    //puis l'acceleration
    acc=(sq(v)/rayon)/9.8;
    //et l'angle théorique de pousse de la plante
    angleth=90-degrees(atan(acc));
  }
  
  //fonction pour afficher les points
  void drawPoints(){
    for(int i=0;i<2;i++) if(pos[i]!=null) ellipse(pos[i].x,pos[i].y,10,10);
  }
  
  //fonction pour afficher les lignes entre les deux points et selon l'angle theorique
  void drawLine(){
    if(pos[0]!=null&&pos[1]!=null) line(pos[0].x,pos[0].y,pos[1].x,pos[1].y);
    if(pos[1]!=null){
      pushMatrix();
      translate(pos[0].x,pos[0].y);
      rotate(-radians(angleth));
      line(0,0,100,0);
      popMatrix();
    }
  }
  
  //fonction affichant les information sur ce point (rayon,acc,angle theorique et angle mesuré)
  void dispInfos(){
    if(pos[0]!=null){
      String out="";
      out+="angle : "+nfc((90-angle),2)+"°";
      float m=textWidth(out);
      String n="acc th : "+nfc(acc,2)+"G";
      m=max(textWidth(n),m);
      out+="\n"+n;
      n="angle th : "+nfc((90-angleth),2)+"°";
      m=max(textWidth(n),m);
      out+="\n"+n;
      n="dist. au centre: "+nfc(rayon,2)+"m";
      m=max(textWidth(n),m);
      out+="\n"+n;
      pushMatrix();
      translate(-rayon*600,0);
      fill(255,100);
      rect(pos[0].x,pos[0].y+10,m+10,55);
      fill(0);
      text(out,pos[0].x,pos[0].y+20);
      popMatrix();
    }
  }
  
  //function affichant la reference de ce point
  void dispNb(int ind){
    if(pos[0]!=null){
       text("("+ind+")",pos[0].x,pos[0].y+20);
    }
  }
}
