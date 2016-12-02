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

  Heart heart;

  boolean started;

  int[] rings = new int[30];
  int numberOfParticles;

  int timeStage, currentTimeStage;

  private int state;

  // This is used to maintain a copy of next fireflies array
  // in order to allow for concurrent add/remove of fireflies.
  ArrayList<Firefly> nextFireflies;


  Environment() {
    fireflies = new ArrayList<Firefly>();

    firefliesDefaultPeriod = PERIOD;
    flashAdjust = FLASH_ADJUST;
    heartBeatAdjustFactor = HEART_BEAT_ADUST_FACTOR;

    nextFireflies = new ArrayList<Firefly>();

    //this.numberOfParticles = setNumberOfParticles;

    heart = new Heart();

    for (int i = 0; i < rings.length; i++)
      rings[i] = (70*i);

    timeStage = millis();

    state = 0;
  }

  public int getState() {
    return state;
  }

  void init() {
    fireflies = new ArrayList<Firefly>(nextFireflies);

    for (Firefly f : fireflies)
      f.init();
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

    currentTimeStage =millis() - timeStage;

    for (Firefly f : fireflies) {
      PVector target = f.fireParticle.getTarget();

      //Wander for a cerain amount of time
      if (currentTimeStage < 20000) {

        if (currentTimeStage%15 == 0)
          f.getFireParticle().seek(target);
        else
          f.getFireParticle().wander();
      } else {
        changeToRingState(f, target);
      }
    }

    heart.reset();
  }


  void changeToRingState(Firefly f, PVector target) {
    state = 1;
    initialize();
    f.getFireParticle().seek(target);
    f.pulseAway();
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
  void dePhase(int nFireflies) {
    ArrayList<Firefly> randomFireflies = getRandomFireflies(nextFireflies, nFireflies);

    for (Firefly f : randomFireflies)
      f.dePhase();
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

  /// Adds firefly with specific period.
  Firefly addFirefly(float period) {
    return addFirefly(new Firefly(period, flashAdjust, heartBeatAdjustFactor));
  }

  /// Adds firefly.
  Firefly addFirefly(Firefly f) {
    nextFireflies.add(f);
    f.init();
   numberOfParticles+=1;
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
  
  void keyPressed(){
   
    if(key == 32){
      addFirefly();
    }
    
  }
  
}