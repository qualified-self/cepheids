
// Number of firefly agents.
final int N_AGENTS = 1000;

// Oscillation period (in seconds).
final float PERIOD = 10.0f;

Environment env;

void setup() {
  size(600, 600);
  
  // Create environment with all fireflies.
  env = new Environment(N_AGENTS);
  
  for (int i=0; i<N_AGENTS; i++) {
    env.getFireflies().add(new Firefly(PERIOD));
  }
  
  // Init environment.
  env.init();
  env.start();
}

void draw() {
  background(0);
  
  // Step environment.
  env.step();
  env.runEnv();

}