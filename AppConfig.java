/////////////////////////////////////////////////////////////////
// IMPORTANT: In the Processing PDE this class needs to be stored
// in its own tab and named "AppConfig.java"
/////////////////////////////////////////////////////////////////

import java.util.*;
import javax.xml.bind.annotation.*;

// this annoation marks the AppConfig class to be able to act as
// an XML root element. The name parameter is only needed since
// our XML element name is different from the class name:
// <config> vs. AppConfig

@XmlRootElement(name="config")
public class AppConfig {

  // now we simply annotate the different variables
  // depending if they are XML elements/nodes or node attributes
  // the mapping to the actual data type is done automatically
  @XmlAttribute(name="version")
    float versionID;

  // here we also specify default values, which are used
  // if there's no matching data for this variable in the XML
  @XmlElement
    int width=320;

  @XmlElement
    int height=240;

  @XmlElement
    String bg;
    
  @XmlElement
    String mebg;
  
  @XmlElement
    String shadow;
    
  @XmlElement
    String metxt;
    
  @XmlElement
    String labeltxt;
    
  @XmlElement
    Distance far;
    
  @XmlElement
    Distance medium;
    
  @XmlElement
    Distance near;
    
  int getMeBoxSize(int range){
    int meBoxSize=0;
    
    switch(range){
      case 0: meBoxSize=near.mesize; break;
      case 1: meBoxSize=medium.mesize; break;
      case 2: meBoxSize=far.mesize; break;
    }
    
    return(meBoxSize);
  }

  @XmlElement(name="group")
    List<Group> groups=new ArrayList<Group>();
    
    Group getGroupByName(String name){
      Group result=null;
      
      for(Group g:groups){
        if(g.name.equals(name)) result=g;
      }
      
      return(result);
    }

  @XmlElement(name="person")
    List<Person> people=new ArrayList<Person>();
}

