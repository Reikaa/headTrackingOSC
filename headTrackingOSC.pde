import oscP5.*;
import netP5.*;

import de.looksgood.ani.*;
import java.awt.Rectangle;

import javax.xml.bind.*;

int boxWidth=10;
Rectangle r=new Rectangle(100,100,boxWidth,boxWidth);

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

void setup() {
   try {
    JAXBContext context = JAXBContext.newInstance(AppConfig.class);
    config = (AppConfig) context.createUnmarshaller().unmarshal(createInput("config.xml"));
    
    size(config.width,config.height,P3D);
    frameRate(25);
    
    font = loadFont("Helvetica-48.vlw");
    
    oscP5 = new OscP5(this,8338);
    Ani.init(this);
    
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
  int range=2;
  if((millis()-lastTimeDataSeen)>headLostInterval){
    //head lost
    rectMode(CENTER);
    ellipse(10,10,10,10);
    targetBoxWidth=config.far.mesize;
    range=2;
  }
  else{
    float distanceFromScreenInCm=getDistanceFromScreenInCm(headZ);
    if(distanceFromScreenInCm>config.far.threshold){
      targetBoxWidth=config.far.mesize;
      range=2;
    }
    else if(distanceFromScreenInCm>config.medium.threshold){
      targetBoxWidth=config.medium.mesize;
      range=1;
    }
    else if(distanceFromScreenInCm>config.near.threshold){
      targetBoxWidth=config.near.mesize;
      range=0;
    }
  }
   
  if(targetBoxWidth!=boxWidth){
    boxWidth=targetBoxWidth;
    Ani.to(r, 1.5, "width", boxWidth);
    Ani.to(r, 1.5, "height", boxWidth);
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
  
  drawPeople(range);
}

void drawPeople(int range){
  for(Person p : config.people) {
    if(p.getVisibility()<=range) {
      Box thisBox=p.getBoxN(range);
      
      if(thisBox!=null){
        rectMode(CORNER);
        noStroke();
        
        fill(unhex(config.shadow));
        rect(thisBox.x+2,thisBox.y+2,thisBox.width-2,thisBox.height-2);
        
        fill(unhex(config.getGroupByName(p.group).colour));
        rect(thisBox.x,thisBox.y,thisBox.width-2,thisBox.height-2);
        
        textFont(font,12);
        fill(unhex(config.labeltxt));
        textAlign(CENTER,CENTER);
        text(p.name,thisBox.x,thisBox.y,thisBox.width,thisBox.height);
      }
    }
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
