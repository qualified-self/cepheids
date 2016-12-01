/**
 * Environment class containing everything in the world.
 * The class also acts as an interface to manipulate the world
 * and get information out of it.
 */
class Environment {
  ArrayList<Firefly> fireflies;
  float firefliesDefaultPeriod;

  boolean started;

  int[] rings = new int[30];
  int numberOfParticles;

  int timeStage, currentTimeStage;

  private int state;

  Environment(int setNumberOfParticles) {
    fireflies = new ArrayList<Firefly>();
    firefliesDefaultPeriod = PERIOD;

    this.numberOfParticles = setNumberOfParticles;

    for (int i = 0; i < rings.length; i++)
      rings[i] = (70*i);

    timeStage = millis();

    state = 0;
  }

  public int getState(){
   return state;
  }

  void init() {
    for (Firefly f : fireflies)
      f.init();
    started = false;
    initialize();
  }

  void start() {
    for (Firefly f : fireflies)
      f.start(this);
    started = true;
  }

  void step() {
    for (Firefly f : fireflies)
      f.step(this);

    drawParticle();

    currentTimeStage =millis() - timeStage;

    for (Firefly f : fireflies) {
      PVector target = f.fireParticle.getTarget();

      //Wander for a cerain amount of time
      if(currentTimeStage < 20000){

        if(currentTimeStage%15 == 0)
          f.getFireParticle().seek(target);
        else
          f.getFireParticle().wander();
      }

      else {
        state = 1;
        f.getFireParticle().seek(target);
        f.pulseAway();
      }
    }
  }

  void drawParticle() {
    for (Firefly f : fireflies)
      f.displayParticle(this);
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

      numParticlesPerLevel = int(circum / 20);

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
