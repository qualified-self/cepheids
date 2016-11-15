// Environment class containing everything in the world.
class Environment {
  ArrayList<Firefly> fireflies;

  int[] rings = new int[30];
  int numberOfParticles;

  Environment(int setNumberOfParticles) {

    this.numberOfParticles = setNumberOfParticles;
    
    fireflies = new ArrayList<Firefly>();

    for (int i = 0; i < rings.length; i++)
      rings[i] = (50*i);
  }

  void runEnv() {

    //displayRings();
    
    for (Firefly f : fireflies) {
      
      f.displayParticle();
      //f.getFireParticle().run();
      PVector target = f.fireParticle.getTarget();
      f.getFireParticle().seek(target);
      f.pulseAway();
    }
  }

  void init() {
    for (Firefly f : fireflies)
      f.init();
      initialize();
  }

  void start() {
    for (Firefly f : fireflies)
      f.start(this);
  }

  void step() {
    for (Firefly f : fireflies)
      f.step(this);
  }

  ArrayList<Firefly> getFireflies() { 
    return fireflies;
  }

  void initialize() {

    int ringIndex = 0;
    int numParticlesPerLevel = 0;
    int stopIndex = 0;
    int particleCounter = numberOfParticles;
    int indexed = 0;

    while (ringIndex < rings.length) {

      float angleStep = radians(360); 
      float angle= 0;

      particleCounter = numberOfParticles - indexed;

      int radious = rings[ringIndex] / 2;
      float circum = 2*PI*radious;

      numParticlesPerLevel = int(circum / 12);

      if (particleCounter >= numParticlesPerLevel) {

        angleStep /= numParticlesPerLevel;
        stopIndex = numParticlesPerLevel + indexed;
      } else {
        angleStep = angleStep/particleCounter;
        stopIndex = numberOfParticles;
      }

      for (int i = indexed; i < stopIndex; i++) {

        Firefly f = fireflies.get(i);
        angle += angleStep;
        f.getFireParticle().setAnglePos(angle);
        f.getFireParticle().makeTarget(radious);
        indexed = i+1;
      }

      ringIndex ++;
    }
  }

  void displayRings() {

    for (int i = 0; i < rings.length; i ++) {
      noFill();
      stroke(255);
      ellipse(width/2, height/2, rings[i], rings[i]);
    }
  }
}