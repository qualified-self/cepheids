/**
 * Environment class containing everything in the world.
 * The class also acts as an interface to manipulate the world
 * and get information out of it.
 */
class Environment {
  ArrayList<Firefly> fireflies;
  float firefliesDefaultPeriod;

  /// Adjustment to power when a neighbor flashes as a proportion of flashPeriod (should be in [0,1]).
  float flashAdjust;

  // Adjustment multiplier for heartbeat.
  float heartBeatAdjustFactor;

  float firefliesColorIntensity;

  Heart heart;

  boolean started;

  int[] rings = new int[30];
  int numberOfParticles;

  private int state;

  int[] ringRadiusForParticles;
  float[] ringAngles;

  int indexOfAddedAgents;

  // This is used to maintain a copy of next fireflies array
  // in order to allow for concurrent add/remove of fireflies.
  ArrayList<Firefly> nextFireflies;


  Environment(int maxNumberOfAgents) {
    fireflies = new ArrayList<Firefly>();

    firefliesDefaultPeriod = PERIOD;
    flashAdjust = FLASH_ADJUST;
    heartBeatAdjustFactor = HEART_BEAT_ADUST_FACTOR;
    firefliesColorIntensity = 0;

    numberOfParticles = maxNumberOfAgents;

    nextFireflies = new ArrayList<Firefly>();

    heart = new Heart();

    indexOfAddedAgents = 0;

    //So that when added, the index becomes 0;
    indexOfAddedAgents = -1;

    ringRadiusForParticles = new int[numberOfParticles];
    ringAngles = new float[numberOfParticles];

    for (int i = 0; i < rings.length; i++)
      rings[i] = (320*i);

    state = 0;
  }

  public int getState() {
    return state;
  }

  void init() {
    fireflies = new ArrayList<Firefly>(nextFireflies);

    for (Firefly f : fireflies)
      f.init();

    initialize();
    started = false;

    heart.reset();
  }

  void start() {
    fireflies = new ArrayList<Firefly>(nextFireflies);
    for (Firefly f : fireflies)
      f.start(this);
    started = true;

    heart.reset();
  }

  void step() {
    fireflies = new ArrayList<Firefly>(nextFireflies);

    for (Firefly f : fireflies)
      f.step(this);

    drawParticle();

    if (state == 0) {
      wanderState();
    } else if (state == 1) {
      ringState();
      //swimAroundState();
    } else if(state == 2) {
      swimAroundState();
    }

    heart.reset();
  }

  void wanderState() {

    for (Firefly f : fireflies) {
      f.getFireParticle().wander();
      f.getFireParticle().setArrivedToFalse();
    }
  }

  void ringState() {

    for (Firefly f : fireflies) {
      f.getFireParticle().seekRing();
      f.pulseAway();
    }
  }
  
  void swimAroundState() {
    for (Firefly f : fireflies) {
      f.getFireParticle().swimAround();
      f.getFireParticle().setArrivedToFalse();
    }
  }

  void setStateToWander() {
    state = 0;
  }

  void setStateToRing() {
    state = 1;
  }
  
  void setStateSwimAround() {
    state = 2;
  }

  void setState(int stateSet) {
    state = stateSet;
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

      numParticlesPerLevel = int(circum / 30);

      if (particleCounter >= numParticlesPerLevel) {

        angleStep /= numParticlesPerLevel;
        stopIndex = numParticlesPerLevel + indexed;
      } else {
        angleStep = angleStep/particleCounter;
        stopIndex = numberOfParticles;
      }

      for (int i = indexed; i < stopIndex; i++) {

        angle += angleStep;

        ringRadiusForParticles[i] = radious;
        ringAngles[i] = angle;

        indexed = i+1;
      }

      ringIndex ++;
    }
  }

  void stateTwoTarget() {

    if (indexOfAddedAgents >= 0) {

      Firefly f = nextFireflies.get(indexOfAddedAgents);

      f.getFireParticle().setAnglePos(ringAngles[indexOfAddedAgents]);
      f.getFireParticle().makeTarget( ringRadiusForParticles[indexOfAddedAgents]);
    }
  }

  /// Adjusts period of all fireflies.
  void setPeriod(float period) {
    firefliesDefaultPeriod = period;
    for (Firefly f : nextFireflies)
      f.setPeriod(firefliesDefaultPeriod);
  }

  /// De-synchronize by changing to random phase.
  void dePhaseAll() {
    for (Firefly f : nextFireflies)
      f.dePhase();
  }

  /// De-synchronize a certain number of fireflies.
  void dePhase(float nFireflies) {
    dePhase(int(nFireflies));
  }
  
  void dePhase(int nFireflies) {
    ArrayList<Firefly> randomFireflies = getRandomFireflies(nextFireflies, nFireflies);

    for (Firefly f : randomFireflies)
      f.dePhase();
  }
  
    /// De-synchronize by changing to random phase.
  void syncWithHeart(float every) {
    syncWithHeart((int)every);
  }
  
  void syncWithHeart(int every) {
    for (Firefly f : nextFireflies)
      f.syncWithHeart(every);
  }

  void unsyncWithHeart() {
    for (Firefly f : nextFireflies)
      f.unsyncWithHeart();
  }
  
  void setMaxForce(float force) {
    for (Firefly f : nextFireflies)
      f.getFireParticle().setMaxForce(force);
  }

  /// Sets adjustment factor for all fireflies.
  void setFlashAdjust(float flashAdjust) {
    this.flashAdjust = flashAdjust;
    for (Firefly f : nextFireflies)
      f.setFlashAdjust(flashAdjust);
  }

  /// Sets heartbeat adjustment factor for all fireflies.
  void setHeartBeatAdjustFactor(float heartBeatAdjustFactor) {
    this.heartBeatAdjustFactor = heartBeatAdjustFactor;
    for (Firefly f : nextFireflies)
      f.setHeartBeatAdjustFactor(heartBeatAdjustFactor);
  }

  void setIntensity(float intensity) {
    this.firefliesColorIntensity = intensity;
    for (Firefly f : nextFireflies)
      f.getFireParticle().setIntensity(firefliesColorIntensity);
  }

  /// Registers heart beat.
  void registerBeat() {
    heart.beat();
  }

  float getBeat() {
    return heart.getAction();
  }

  int nFireflies() {
    return fireflies.size();
  }
  
  boolean hasFireflies() {
    return !fireflies.isEmpty();
  }
  
  Firefly getFirefly(int i) {
    return fireflies.get(i);
  }

  ArrayList<Firefly> getFireflies() {
    return fireflies;
  }

  ArrayList<Firefly> getRandomFireflies(ArrayList<Firefly> orig, int n) {
    // Generate shuffled list of all indices.
    ArrayList<Integer> range = new ArrayList<Integer>();
    for (int i = 0; i < orig.size(); i++)
      range.add(i);
    Collections.shuffle(range);

    // Pick subsample.
    ArrayList<Firefly> randomFireflies = new ArrayList<Firefly>();
    for (int i=0; i<n; i++)
      randomFireflies.add(orig.get(range.get(i)));
    return randomFireflies;
  }

  /// Adds firefly with default period.
  Firefly addFirefly() {
    return addFirefly(firefliesDefaultPeriod);
  }

  /// Adds firefly with default period.
  Firefly addSpecialFirefly() {
    Firefly f = addFirefly(firefliesDefaultPeriod);
    f.getFireParticle().setBaseColor(color(#FFA600));
    return f;
  }

  /// Adds firefly with specific period.
  Firefly addFirefly(float period) {
    return addFirefly(new Firefly(period, flashAdjust, heartBeatAdjustFactor, new PVector(width/2, height/2)));
  }

  /// Adds firefly with specific period.
  Firefly addRandomFirefly(float period) {
    return addFirefly(new Firefly(period, flashAdjust, heartBeatAdjustFactor, new PVector(random(BORDER +20, width- BORDER - 20), random(BORDER + 20, height - BORDER - 20))));
  }

  /// Adds firefly.
  Firefly addFirefly(Firefly f) {
    nextFireflies.add(f);
    f.init();
    f.getFireParticle().setIntensity(firefliesColorIntensity);
    indexOfAddedAgents++;
    stateTwoTarget();
    //numberOfParticles++;
    if (started)
      f.start(this);
    return f;
  }

  /// Removes random firefly.
  Firefly removeFirefly() {
    if (!nextFireflies.isEmpty())
      return removeFirefly(
        nextFireflies.get((int)random(nextFireflies.size())));
    else
      return null;
  }

  /// Removes firefly.
  Firefly removeFirefly(Firefly f) {
    return (nextFireflies.remove(f) ? f : null);
  }

  /// Returns the average of all last actions of agents (after a call to step()).
  float getActionAverage() {
    float sum = 0;
    for (Firefly agent : fireflies) {
      sum += agent.getAction();
    }
    return sum / fireflies.size();
  }

  void keyPressed() {
    
    switch(key) {
     
      case 32:
        addFirefly();
        break;
      case 'i':
        setIntensity(0);
        break;
      case 'I':
        setIntensity(1);
        break;
      case 'r':
        setStateToRing();
        break;
      case 'w':
        setStateToWander();
        break;
      case 's':
        setStateSwimAround();
        break;
        default:;
    }
  }
}