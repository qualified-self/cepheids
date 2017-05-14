import beads.*;

// Number of firefly agents.
final int MAX_NUM_AGENTS = 100;

// Oscillation period (in seconds).
final float INIT_BPM    = 80.0f; // normal BPM at rest is 60-100 BPM
final float PERIOD      = 60.0 / INIT_BPM;    
final float FLASH_ADJUST = 0.1f;   //how much each firefly adjust based on each other
final float HEART_BEAT_ADUST_FACTOR = 2.0f;  //

// N. audio tracks for the beat generator.
final int N_TRACKS  = 50;

final int OSC_SEND_PORT = 12000;
final int OSC_RECV_PORT = 14000;
final String OSC_IP     = "127.0.0.1";
//final String OSC_IP     = "192.168.1.100";

final int BORDER = 100;

Environment env;

OscManager oscManager;
SoundManager soundManager;

void setup() {
  //size(1280, 720);
  fullScreen(1);

  // Create environment with all fireflies.
  env = new Environment(MAX_NUM_AGENTS);
  
//  for (int i=0; i<MAX_NUM_AGENTS; i++) {
//    env.addFirefly();
//  }


  // Initialize audio.
  soundManager = new SoundManager();
  soundManager.start();

  // Create OSC manager.
  oscManager = new OscManager(this);
  oscManager.build();
  oscManager.reset();

  // Init environment.
  env.init();
  env.start();
}

void draw() {
  background(0);

  // Step environment.
  env.step();

  // Compute total of all flash values.
  float average = env.getActionAverage();

  // Update sound manager.
  soundManager.update(average);
  //
  // // Set background lightness to the sum of all flashes.
  // background(round(average * 255));
}

void keyPressed(){

  env.keyPressed();

}


void oscEvent(OscMessage msg) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
}