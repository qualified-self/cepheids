// Environment class containing everything in the world.
class Environment {
  ArrayList<Firefly> fireflies;

  Environment() {
    fireflies = new ArrayList<Firefly>();
  }

  void init() {
    for (Firefly f : fireflies)
      f.init();
  }

  void start() {
    for (Firefly f : fireflies)
      f.start(this);
  }

  void step() {
    for (Firefly f : fireflies)
      f.step(this);
  }

  ArrayList<Firefly> getFireflies() { return fireflies; }

  /// Returns the average of all last actions of agents (after a call to step()).
  float getLastActionAverage() {
    float sum = 0;
    for (Firefly agent : fireflies) {
      sum += agent.lastAction();
    }

    return sum / fireflies.size();
  }
}
