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
  
  float wanderR = 25;         // Radius for our "wander circle"
  float wanderD = 80;         // Distance for our "wander circle"
  float change = 0.3;

  private float maxspeed;

  private PVector initialTarget;

  //Checks if angents have arrived to the ring
  private boolean arrived = false;

  private int flashFadeSpeed;

  private float ringRadius;
  
  float angleSwimgAround;
  PVector swimAround;
  
  Particle(PVector origin) {
    
    location = origin.copy();
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    swimAround= new PVector(0, 0);

    positions = new PVector[10];
    angleSwimgAround = 0;

    fillColor = 0;
    intensity = 1.0;

    boidSize = 10.0;

    //Wandering State intializations of variables
    radiusLoc = 6;
    distanceWander = 100;
    smallChange = 0.003;
    //wandertheta += random(-smallChange, smallChange);
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

  Particle() {
      this(new PVector(random(width), random(height)));
    
  }

  void setIntensity(float intensity) {
    this.intensity = intensity;
  }
  
 void setArrivedToFalse() {
   arrived = false;
 }

  PVector centro = new PVector(width/2, height/2);

  void display() {

    offset = SIZE_SEG;

    if(!arrived)
      angleHead = velocity.heading2D()+ PI/2;
    else 
       angleHead = PVector.sub(centro, location).heading2D() + PI/2; 

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
      
      if(!arrived)
        makeSegment(i+1, positions[i].x, positions[i].y);
      else
        makeSegmentRing(i+1, positions[i].x, positions[i].y);

      offset += SIZE_SEG/2;
    }
  }

  void makeSegmentRing(int index, float prevX, float prevY) {
    
    float x = width/2 - positions[index].x;
    float y = height/2 - positions[index].y;
    
    leAngle = atan2(y, x);
    
    positions[index].x = prevX - cos(leAngle)*offset;
    positions[index].y = prevY - sin(leAngle)*offset;
    segment(positions[index].x, positions[index].y, leAngle);
    
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
    
    stroke(255);
    noFill();
    ellipse(circlepos.x, circlepos.y, radiusLoc, radiusLoc);

    // Make it relative to boid's position
    float h = velocity.heading2D();

    PVector circleOffSet = new PVector(radiusLoc*cos(wandertheta+h), radiusLoc*sin(wandertheta+h));
    PVector target = PVector.add(circlepos, circleOffSet);
    
     //stroke(255);
    fill(255, 0, 0);
    ellipse(target.x, target.y, radiusLoc/5, radiusLoc/5);
    
    //apply to seeking method
    moveTowards(target);
  }

  void moveTowards(PVector target) {

    PVector desiredLoc = PVector.sub(target, location);
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
      
    } else {
      desiredLoc.mult(maxspeed);
    }

    PVector seek = PVector.sub(desiredLoc, velocity);
    seek.limit(maxForce);
    applyForce(seek);
  }
  
  void seekRing() {
    
    PVector desiredLoc = PVector.sub(initialTarget, location);
    float dist = desiredLoc.mag();
    desiredLoc.normalize();
    
    if (dist < 10) {
      
      float ease = map(dist, 0, 10, 0, maxspeed);
      desiredLoc.mult(ease);
      
      if (!arrived && dist< 0.5) arrived = true;
      
    } else {
      desiredLoc.mult(maxspeed);
    }

    PVector seek = PVector.sub(desiredLoc, velocity);
    seek.limit(maxForce);
    applyForce(seek);
  }
  
  boolean swimArrive = false;
  
   void swimAround() {
   
     if(!swimArrive) seekSwim();
     
     else 
       {
          swimAround.x = ringRadius * cos(angleSwimgAround) + width/2;
          swimAround.y =  ringRadius * sin(angleSwimgAround) + height/2;
          
          println(ringRadius);
          
          //PVector desiredLoc = PVector.sub(swimAround, location);
          //desiredLoc.normalize();
          //desiredLoc.mult(ringRadius/700);
          
          seek(swimAround);
          angleSwimgAround += 0.01;
       }
  }
  
   void seekSwim() {
    
    PVector desiredLoc = PVector.sub(initialTarget, location);
    float dist = desiredLoc.mag();
    desiredLoc.normalize();
    
    if (dist < 10) {
      
      float ease = map(dist, 0, 10, 0, maxspeed);
      desiredLoc.mult(ease);
      
      if (!swimArrive && dist< 0.5) swimArrive = true;
      
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

    ringRadius = radius;
    angleSwimgAround = anglePos;
    initialTarget.x = radius * cos(anglePos) + width/2;
    initialTarget.y =  radius * sin(anglePos) + height/2;
    
    swimAround = initialTarget.copy();
  }

  //set the position within the ring based
  void setAnglePos(float newAngle) {
    anglePos = newAngle;
  }

  //pulse away from center when firefly fires
  void particleResponse(float action) {

    PVector awayFromCenter = PVector.sub(location, centro);
    awayFromCenter.normalize();
    awayFromCenter.mult(0.6);

    if (action > 0 && arrived) {
      applyForce(awayFromCenter);
    }
  }
}