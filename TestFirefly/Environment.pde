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
}