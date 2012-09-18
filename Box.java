import javax.xml.bind.annotation.*;

public class Box{
  @XmlAttribute
  int x;

  @XmlAttribute
  int y;
  
  @XmlAttribute
  int width;

  @XmlAttribute
  int height;
  
  String shadowColour;
  String fillColour;
  String textColour;
  String text;
  
  float alpha=0;
}  
