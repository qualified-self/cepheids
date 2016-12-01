import beads.*;

// Number of firefly agents.
final int N_AGENTS = 1000;

// Oscillation period (in seconds).
final float PERIOD = 5.0f;

// N. audio tracks for the beat generator.
final int N_TRACKS  = 50;

final int OSC_SEND_PORT = 12000;
final int OSC_RECV_PORT = 14000;
final String OSC_IP     = "127.0.0.1";
//final String OSC_IP     = "192.168.1.100";

Environment env;

OscManager oscManager;
SoundManager soundManager;

void setup() {
  size(500, 500);

  // Create environment with all fireflies.
  env = new Environment();
  for (int i=0; i<N_AGENTS; i++) {
    env.getFireflies().add(new Firefly(PERIOD));
  }

  // Init environment.
  env.init();
  env.start();

  // Initialize audio.
  soundManager = new SoundManager();
  soundManager.start();

  // Create OSC manager.
  oscManager = new OscManager(this);
  oscManager.build();
}

void draw() {
  // Step environment.
  env.step();

  // Compute total of all flash values.
  float average = env.getActionAverage();

  // Update sound manager.
  soundManager.update(average);

  // Set background lightness to the sum of all flashes.
  background(round(average * 255));
}


void oscEvent(OscMessage msg) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
}
