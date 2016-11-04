
// Number of firefly agents.
final int N_AGENTS = 100;

// Oscillation period (in seconds).
final float PERIOD = 5.0f;

Environment env;

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
}

void draw() {
  // Step environment.
  env.step();
  
  // Compute total of all flash values.
  float sum = 0;
  int nAgents = env.getFireflies().size();
  for (Firefly agent : env.getFireflies()) {
    sum += agent.lastAction() / nAgents;
  }
  
  // Set background lightness to the sum of all flashes.
  background(round(sum * 255));
}