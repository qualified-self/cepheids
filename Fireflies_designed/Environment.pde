// Environment class containing everything in the world.
class Environment {
  ArrayList<Firefly> fireflies;

  int[] rings = new int[30];
  int numberOfParticles;

  int timeStage, currentTimeStage;
  
  private int state;

  Environment(int setNumberOfParticles) {
    fireflies = new ArrayList<Firefly>();

    this.numberOfParticles = setNumberOfParticles;

    for (int i = 0; i < rings.length; i++)
      rings[i] = (70*i);
      
    timeStage = millis();
    
    state = 0;
  }
  
  public int getState(){
   return state; 
  }

  void runEnv() {

    step();
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

  ArrayList<Firefly> getFireflies() { 
    return fireflies;
  }
}