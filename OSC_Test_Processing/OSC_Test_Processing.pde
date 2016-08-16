/**
 * oscP5bundle by andreas schlegel
 * an osc broadcast server.
 * example shows how to create and send osc bundles. 
 * oscP5 website at http://www.sojamo.de/oscP5
 */
import ddf.minim.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
Minim minim;
AudioInput in;

void setup() {
  size(512, 200, P3D);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  minim = new Minim(this);
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("192.168.1.24",8888);
  in = minim.getLineIn();
}


void draw() {
  background(0);
  stroke(255);
  // draw the waveforms so we can see what we are monitoring
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line( i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50 );
    line( i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50 );
  }
  float val=map(in.left.get(1),-1,7,0,255);
  float sound=map(val,28,35,0,255);
  println(sound);
  String monitoringState = in.isMonitoring() ? "enabled" : "disabled";
  text( "Input monitoring is currently " + monitoringState + ".", 5, 15 );
 
  OscBundle myBundle = new OscBundle(); 
  OscMessage myMessage = new OscMessage("/led");
  myMessage.add(5);
  myBundle.add(myMessage);
  myMessage.clear();
  oscP5.send(myBundle, myRemoteLocation);
}


void mousePressed() {
  /* create an osc bundle */
  OscBundle myBundle = new OscBundle();
  
  /* createa new osc message object */
  OscMessage myMessage = new OscMessage("/led");
  myMessage.add(123);
  
  /* add an osc message to the osc bundle */
  myBundle.add(myMessage);
  
  /* reset and clear the myMessage object for refill. */
  myMessage.clear();
  
  /* refill the osc message object again */
  myMessage.setAddrPattern("/test2");
  myMessage.add("defg");
  myBundle.add(myMessage);
  
  myBundle.setTimetag(myBundle.now() + 10000);
  /* send the osc bundle, containing 2 osc messages, to a remote location. */
  oscP5.send(myBundle, myRemoteLocation);
}



/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  print(" typetag: "+theOscMessage.typetag());
  println(" timetag: "+theOscMessage.timetag());
}

void keyPressed()
{
  if ( key == 'm' || key == 'M' )
  {
    if ( in.isMonitoring() )
    {
      in.disableMonitoring();
    }
    else
    {
      in.enableMonitoring();
    }
  }
}