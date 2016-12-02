class Particle {

  PVector positions[];
  private PVector location;
  private PVector velocity;
  private PVector acceleration;

  float offset, angleTail, angleHead;

  ArrayList <TraceParticles> traceParticles = new ArrayList<TraceParticles>();

  private float boidSize;

  float leAngle;
  float headSize;

  //Initial size of the first part of the tail.
  final float SIZE_SEG = 1.2;

  //Setting location within ring
  private float angle;
  private float anglePos;

  //Flashing color
  private float fillColor;
  private float intensity; // multiplier for the color in [0, 1] to allow for fadings
  private float adjustedFillColor; // = fillColor * intensity

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

  private int flashFadeSpeed;


  Particle() {

    location = new PVector(random(width), random(height));
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);

    positions = new PVector[10];

    fillColor = 0;
    intensity = 1.0;

    boidSize = 10.0;

    //Wandering State intializations of variables
    radiusLoc = 20;
    distanceWander = 80;
    smallChange = 0.008;
    wandertheta += random(-smallChange*10, smallChange*10);
    wanderSpeed = random(0.4, 1);
    limit = 1.2;
    maxspeed = 0.9;
    maxForce = 0.05;

    //Vector that sets the position of the particle within the ring
    initialTarget = new PVector();

    anglePos = 0;

    offset = SIZE_SEG;
    headSize = SIZE_SEG*4;
    leAngle = 0;

    flashFadeSpeed = 6;

    for (int i =0; i < positions.length; i++) {
      positions[i] = new PVector(location.x, location.y);
    }
  }

  void setIntensity(float intensity) {
    this.intensity = intensity;
  }

  void display() {

    offset = SIZE_SEG;

    angleHead = velocity.heading2D()+ PI/2;

    stroke(255, adjustedFillColor);
    strokeWeight(0.5);
    pushMatrix();
    translate(positions[0].x, positions[0].y);
    rotate(angleHead);
    fill(adjustedFillColor);
    arc(0, headSize, headSize*2, headSize*2.5, PI, 2*PI);
    popMatrix();

    positions[0] = location;
    for (int i =positions.length-2; i >= 0; i--) {
      makeSegment(i+1, positions[i].x, positions[i].y);
      offset += SIZE_SEG/2;
    }
  }

  void makeSegment(int index, float xIn, float yIn) {

    float x = xIn - positions[index].x;
    float y = yIn - positions[index].y;

    leAngle = atan2(y, x);

    positions[index].x = xIn - cos(leAngle)*offset;
    positions[index].y = yIn - sin(leAngle)*offset;
    segment(positions[index].x, positions[index].y, leAngle);
  }

  void segment(float x, float y, float angler) {
    stroke(255, adjustedFillColor);
    strokeWeight(0.5);
    pushMatrix();
    translate(x, y);
    rotate(angler+PI/2);
    fill(adjustedFillColor);
    beginShape();
    vertex(0-offset, 0);
    vertex(0+offset, 0);
    vertex(0+offset, 0+offset);
    vertex(0, 0+offset*2);
    vertex(0-offset, 0+offset);
    endShape(CLOSE);
    noStroke();
    fill(255, adjustedFillColor);
    ellipse(0, offset, offset/3, offset/3);
    popMatrix();
  }


  void run(Firefly f, Environment env) {

    action(f);
    //leaveTrace(f);
    update(env);
    display();
  }

  void action(Firefly f) {

    if (f.getAction()> 0)
      fillColor = 255;
    else if (fillColor > 0)
      fillColor -= flashFadeSpeed;
    else
      fillColor = 0;

    adjustedFillColor = intensity * fillColor;
  }


  //-----------Setter and Getter for flashing speed-------------//
  public int getFlashFadeSpeed() {
    return flashFadeSpeed;
  }

  public void setflashFadeSpeed(int newFadeSpeed) {
    flashFadeSpeed = newFadeSpeed;
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

  //pulse away from center when firefly fires
  void particleResponse(float action) {

    PVector awayFromCenter = new PVector(width/2, height/2);
    awayFromCenter = PVector.sub(awayFromCenter, location);
    awayFromCenter.mult(-1);
    awayFromCenter.normalize();
    awayFromCenter.mult(0.9);

    if (action > 0 && arrived) {
      applyForce(awayFromCenter);
    }
  }
}