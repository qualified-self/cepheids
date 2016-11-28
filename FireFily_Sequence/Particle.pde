class Particle {

  private PVector location;
  private PVector velocity;
  private PVector acceleration;

  ArrayList <TraceParticles> traceParticles = new ArrayList<TraceParticles>();

  private float boidSize;
  
  //Setting location within ring
  private float angle;
  private float anglePos;

  //Flashing color
  private float fillColor;

  //Wandering fornce
  private float wandertheta;
  private float maxForce;     
  private float limit;
  private float wanderSpeed;

  //Wandering variables
  private float radiusLoc;
  private float distanceWander;  
  private float smallChange;

  private float maxspeed; 

  private PVector initialTarget;

  //Checks if angents have arrived to the ring
  private boolean arrived = false;

  //Allows for trace to happen only when firefly flashes (optimization trick)
  private boolean startLeavingTrace = false;

  private int traceTimer;
  private int traceCurrentTimer;

  private float wingFlapScale;
  private float wingFlapSpeed;
  private float wingFlapPulse;

  private boolean pulseFromPlace;
  private int pulseTimer;
  private int pulseCurrentTimer;


  Particle() {

    location = new PVector(random(width), random(height));
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);

    fillColor = 0;

    boidSize = 10.0;

    radiusLoc = 20;
    distanceWander = 80; 
    smallChange = 0.008;

    wandertheta = 0;
    wanderSpeed = random(0.4, 1);
    maxspeed = 0.9;
    limit = 1.2;    
    maxForce = 0.05;

    initialTarget = new PVector();

    anglePos = 0;

    traceTimer = millis();

    wingFlapScale = 90;
    wingFlapSpeed = random(0.2, 0.4);
    wingFlapPulse = random(0, 1);

    pulseFromPlace = false;
  }

  void display() {

    fill(fillColor);
    noStroke();

    angle = velocity.heading2D() + radians(90);

    pushMatrix();
    translate(location.x, location.y);
    rotate(angle);
    ellipse(0, 0, boidSize/2, boidSize);
    //fill(255, 0, 0);
    fill(fillColor, 150);
    arc(0, 0-boidSize/2, boidSize*2, boidSize, radians(sin(wingFlapPulse)*wingFlapScale), radians(90));
    arc(0, 0-boidSize/2, boidSize*2, boidSize, radians(90), radians(180-sin(wingFlapPulse)*wingFlapScale));
    popMatrix();
  }

  void run(Firefly f, Environment env) {

    action(f);
    leaveTrace(f);
    update(env);
    display();
  }

  public void leaveTrace(Firefly f) {

    if (f.lastAction() > 0) {

      startLeavingTrace = true;
    } 


    if (startLeavingTrace) {
      addParticleTrace();

      updateTraceParticles();
    }
  }

  private void updateTraceParticles() {

    for (int i = traceParticles.size()-1; i > 0; i--) {

      TraceParticles t = traceParticles.get(i);
      t.drawParticle();
      t.fadeAway();

      if (t.isFaded()) {
        traceParticles.remove(i);
        if (traceParticles.size() < 2) {
          startLeavingTrace = false;
        }
      }
    }
  }

  private void addParticleTrace() {

    traceCurrentTimer = millis() - traceTimer;

    if (traceCurrentTimer%3 == 0) {

      traceParticles.add(new TraceParticles(location, boidSize/2, fillColor));
    }
  }

  void action(Firefly f) {

    if (f.lastAction()> 0) 
      fillColor = 255;
    else
      if (fillColor > 0)
        fillColor -= 3;
      else
        fillColor = 0;
  }

  void update(Environment env) {

    if (arrived) maxForce = 0.1;

    // Update velocity
    velocity.add(acceleration);
    // Limit speed

    if (env.getState() == 0)
      limit = 1;
    else 
      limit = 1.2;

    velocity.limit(limit);

    location.add(velocity);

    // Reset accelertion to 0 each cycle
    acceleration.mult(0);

    wingFlapPulse += wingFlapSpeed;
  }

  void applyForce(PVector force) {
    PVector f = force.get();
    acceleration.add(f);
  }

  void wander() {
    
    // Randomly change wander theta
    wandertheta += random(-smallChange, smallChange);

    // Start with velocity
    PVector circlepos = velocity.get();    
    // Normalize to get heading
    circlepos.normalize();            
     // Multiply by distance
    circlepos.mult(distanceWander);      
    // Make it relative to boid's position
    circlepos.add(location);             

    // Make it relative to boid's position
    float h = velocity.heading2D();

    PVector circleOffSet = new PVector(radiusLoc*cos(wandertheta+h), radiusLoc*sin(wandertheta+h));
    PVector target = PVector.add(circlepos, circleOffSet);
    //apply to seeking method
    moveTowards(target);
    
  }

  void moveTowards(PVector target) {

    PVector desiredLoc = PVector.sub(target, location);

    //float dist = desiredLoc.mag();

    desiredLoc.normalize();

    desiredLoc.mult(wanderSpeed);
    PVector seek = PVector.sub(desiredLoc, velocity);
    seek.limit(maxForce);
    applyForce(seek);
  }


  //Seek force for seeking ring target (it has arrival and steer)

  void seek(PVector target) {

    PVector desiredLoc = PVector.sub(target, location);

    float dist = desiredLoc.mag();

    desiredLoc.normalize();
    if (dist < 10) {

      float ease = map(dist, 0, 10, 0, maxspeed);
      desiredLoc.mult(ease);

      if (dist< 0.5) arrived = true;
    } else {

      desiredLoc.mult(maxspeed);
    }

    PVector seek = PVector.sub(desiredLoc, velocity);
    seek.limit(maxForce);
    applyForce(seek);
  }


  PVector getTarget() {
    return initialTarget;
  }

  //Make a target within a ring
  void makeTarget(int radius) {

    initialTarget.x = radius * cos(anglePos) + width/2;
    initialTarget.y =  radius * sin(anglePos) + height/2;
  }

  //set the position within the ring based
  void setAnglePos(float newAngle) {
    anglePos = newAngle;
  }

  //pulse away from center when firefly fiers
  void particleResponse(float action) {

    PVector awayFromCenter = new PVector(width/2, height/2);
    awayFromCenter = PVector.sub(awayFromCenter, location);
    awayFromCenter.mult(-1);
    awayFromCenter.normalize();
    awayFromCenter.mult(0.9);

    if (action > 0 && arrived) {  
      pulseFromPlace = true;
      pulseTimer = millis();
    }

    if (pulseFromPlace) {
      applyForce(awayFromCenter);
      pulseCurrentTimer = millis() - pulseTimer;
      if (pulseCurrentTimer > 100)
        pulseFromPlace = false;
    }
  }
}