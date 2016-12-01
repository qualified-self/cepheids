/**
 * Environment class containing everything in the world.
 * The class also acts as an interface to manipulate the world
 * and get information out of it.
 */
class Environment {
  ArrayList<Firefly> fireflies;
  float firefliesDefaultPeriod;

  boolean started;

  Environment() {
    fireflies = new ArrayList<Firefly>();
    firefliesDefaultPeriod = PERIOD;
  }

  void init() {
    for (Firefly f : fireflies)
      f.init();
    started = false;
  }

  void start() {
    for (Firefly f : fireflies)
      f.start(this);
    started = true;
  }

  void step() {
    for (Firefly f : fireflies)
      f.step(this);
  }

  // Adjust period of all fireflies.
  void setPeriod(float period) {
    firefliesDefaultPeriod = period;
    for (Firefly f : fireflies)
      f.setPeriod(firefliesDefaultPeriod);
  }

  int nFireflies() { return fireflies.size(); }
  boolean hasFireflies() { return !fireflies.isEmpty(); }
  Firefly getFirefly(int i) { return fireflies.get(i); }

  ArrayList<Firefly> getFireflies() { return fireflies; }

  // Add firefly with default period.
  Firefly addFirefly() {
    return addFirefly(firefliesDefaultPeriod);
  }

  // Add firefly with specific period.
  Firefly addFirefly(float period) {
    return addFirefly(new Firefly(period));
  }

  // Add firefly.
  Firefly addFirefly(Firefly f) {
    fireflies.add(f);
    f.init();
    if (started)
      f.start(this);
    return f;
  }

  // Remove random firefly.
  Firefly removeFirefly() {
    if (hasFireflies())
      return removeFirefly(getFirefly((int)random(nFireflies())));
    else
      return null;
  }

  // Remove firefly.
  Firefly removeFirefly(Firefly f) {
    return (fireflies.remove(f) ? f : null);
  }

  /// Returns the average of all last actions of agents (after a call to step()).
  float getActionAverage() {
    float sum = 0;
    for (Firefly agent : fireflies) {
      sum += agent.getAction();
    }
    return sum / fireflies.size();
  }
}
