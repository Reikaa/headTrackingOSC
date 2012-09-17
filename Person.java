import javax.xml.bind.annotation.*;

public class Person{
        int x,y;
  
	@XmlAttribute
	String name;

	@XmlAttribute
	String group;

	@XmlAttribute
	String visibility;

        int getVisibility(){
          int v=0;
          
          if(visibility.equals("far")) v=2;
          else if(visibility.equals("medium")) v=1;
          else if(visibility.equals("near")) v=0;
          
          return(v);
        }
}
