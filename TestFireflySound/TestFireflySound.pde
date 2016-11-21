import beads.*;

// Number of firefly agents.
final int N_AGENTS = 1000;

// Oscillation period (in seconds).
final float PERIOD = 5.0f;

Environment env;


final String AUDIO_FILE_NAME = "heartbeat.wav";
final int   N_TRACKS  = 50;

AudioContext ac;
SoundBeatManager manager;

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
  ac = new AudioContext();
  manager = new SoundBeatManager(ac, PERIOD, N_TRACKS, AUDIO_FILE_NAME);

  // Start audio.
  ac.start();
}

void draw() {
  // Step environment.
  env.step();

  // Compute total of all flash values.
  float average = env.getLastActionAverage();

  // Update sound manager.
  manager.update(average);

  // Set background lightness to the sum of all flashes.
  background(round(average * 255));
}
