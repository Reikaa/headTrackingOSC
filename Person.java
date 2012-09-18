import javax.xml.bind.annotation.*;

public class Person{
  int x,y;
  
  @XmlAttribute
  String name;

  @XmlAttribute
  String group;

  @XmlElement
  Box far;
  
  @XmlElement
  Box medium;
  
  @XmlElement
  Box near;
  
  Box getBoxN(int n){
    Box boxN=null;
    
    switch(n){
      case 0: boxN=near; break;
      case 1: boxN=medium; break;
      case 2: boxN=far; break;
    }
    
    return(boxN);
  }
  
  int getVisibility(){
    int v=-1;
    
    if(far!=null){
      if(medium!=null){
        if(near!=null){
          v=0;
        }
        else v=1;
      }
      else v=2;
    }
    
    return(v);
  }
  
  boolean isVisible(int range){
    return(getVisibility()<=range);
  }
}
