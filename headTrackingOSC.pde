import oscP5.*;
import netP5.*;

import de.looksgood.ani.*;
import java.awt.Rectangle;

import javax.xml.bind.*;

//int boxWidth=10;
Rectangle r=new Rectangle(100,100,10,10);
int currentRange=2;

OscP5 oscP5;

float headRoll=0.0f;
float headPitch=0.0f;
float headYaw=0.0f;
float headX=0.0f;
float headY=0.0f;
float headZ=0.0f;

int headLostInterval=5000;
long lastTimeDataSeen=0;

PFont font;

AppConfig config;
Box people[];

void setup() {
   try {
    JAXBContext context = JAXBContext.newInstance(AppConfig.class);
    config = (AppConfig) context.createUnmarshaller().unmarshal(createInput("config.xml"));
    
    size(config.width,config.height,P3D);
    frameRate(25);
    
    font = loadFont("Helvetica-48.vlw");
    
    oscP5 = new OscP5(this,8338);
    Ani.init(this);
    
    people=new Box[config.people.size()];
    for(int n=0;n<config.people.size();++n){
      people[n]=new Box();
      people[n].text=config.people.get(n).name;
      people[n].fillColour=config.getGroupByName(config.people.get(n).group).colour;
      people[n].textColour=config.labeltxt;
      people[n].shadowColour=config.shadow;
    }
    
    noCursor();
  }
  catch(JAXBException e) {
    e.printStackTrace();
    System.exit(1);
  }
}

void draw() {
  background(unhex(config.bg));
  stroke(255);
  noFill();
  
  int targetBoxWidth=0;
  int targetRange=2;
  if((millis()-lastTimeDataSeen)>headLostInterval){
    //head lost
    rectMode(CENTER);
    ellipse(10,10,10,10);
    targetBoxWidth=config.far.mesize;
    targetRange=2;
  }
  else{
    float distanceFromScreenInCm=getDistanceFromScreenInCm(headZ);
    if(distanceFromScreenInCm>config.far.threshold){
      targetBoxWidth=config.far.mesize;
      targetRange=2;
    }
    else if(distanceFromScreenInCm>config.medium.threshold){
      targetBoxWidth=config.medium.mesize;
      targetRange=1;
    }
    else if(distanceFromScreenInCm>config.near.threshold){
      targetBoxWidth=config.near.mesize;
      targetRange=0;
    }
  }
  
  if(targetRange!=currentRange){ 
    animateTransition(targetRange);
    currentRange=targetRange;
  }
  
  rectMode(CENTER);
  noStroke();
  fill(unhex(config.shadow));
  rect((width/2)+2,(height/2)+2,r.width,r.height);
  fill(unhex(config.mebg));
  rect(width/2,height/2,r.width,r.height);
  
  textFont(font,48);
  fill(unhex(config.metxt));
  textAlign(CENTER,CENTER);
  text("ME",width/2,height/2,r.width,r.height);
  
  drawPeople(targetRange);
}

void animateTransition(int targetRange){
  Ani.to(r, 1.5, "width", config.getMeBoxSize(targetRange));
  Ani.to(r, 1.5, "height", config.getMeBoxSize(targetRange));
  
  Box targetBox=null;
  for(int n=0;n<config.people.size();++n){
    targetBox=config.people.get(n).getBoxN(targetRange);
    
    if(targetBox!=null){
      if(people[n].alpha==0){
        //was previously invisible => just appear
        people[n].x=targetBox.x;
        people[n].y=targetBox.y;
        people[n].width=targetBox.width;
        people[n].height=targetBox.height;
      }
      else{
        Ani.to(people[n], 1.5, "x", targetBox.x);
        Ani.to(people[n], 1.5, "y", targetBox.y);
        Ani.to(people[n], 1.5, "width", targetBox.height);
        Ani.to(people[n], 1.5, "height", targetBox.height);
      }
      
      people[n].alpha=255;
    }
    else{
      people[n].alpha=0;
    }
  }
}

void drawPeople(int range){
  for(Box p : people) {
    rectMode(CORNER);
    noStroke();
    
    color shadowColour=unhex(p.shadowColour);
    fill(red(shadowColour),green(shadowColour),green(shadowColour),p.alpha);
    rect(p.x+2,p.y+2,p.width-2,p.height-2);
    
    color fillColour=unhex(p.fillColour);
    fill(red(fillColour),green(fillColour),green(fillColour),p.alpha);
    rect(p.x,p.y,p.width-2,p.height-2);
    
    textFont(font,12);
    color textColour=unhex(p.textColour);
    fill(red(textColour),green(textColour),green(textColour),p.alpha);
    textAlign(CENTER,CENTER);
    text(p.text,p.x,p.y,p.width,p.height);
  }
}

void drawHead(){
  camera();
  
  beginCamera();
  camera();
  translate(headX,headY,headZ);
  rotateX(headPitch);
  rotateY(headYaw);
  rotateZ(headRoll);
  endCamera();
  
  box(45);
}

void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.addrPattern().startsWith("/pose/")){
    if(theOscMessage.checkAddrPattern("/pose/scale")) {
      headZ=theOscMessage.get(0).floatValue();
    }
    
    if(theOscMessage.checkAddrPattern("/pose/orientation")) {
      headRoll=theOscMessage.get(2).floatValue();
      headPitch=-theOscMessage.get(0).floatValue();
      headYaw=-theOscMessage.get(1).floatValue();
    }
    
    if(theOscMessage.checkAddrPattern("/pose/position")) {
      headX=theOscMessage.get(0).floatValue();
      headY=theOscMessage.get(1).floatValue();
    }
    lastTimeDataSeen=millis();
  }
}

//Cailbrated for MacBook 13" internal isight camera
float getDistanceFromScreenInCm(float v){
  float m=-15.8f;
  float c=130.0f;
  
  return((v*m)+c);
}
