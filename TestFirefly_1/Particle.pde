class Particle {

  //ArrayList <Firefly> fireParticle;
  PVector location;
  PVector velocity;
  PVector acceleration;

  float boidSideSize;

  float angle;

  float limitForce = 0.5;

  float fillColor;

  float wandertheta;
  float maxForce;    
  float maxspeed;    

  float radiusLoc;
  float distanceWander;  
  float smallChange;

  Particle(PVector location) {

    this.location = location;

    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);

    fillColor = 0;

    boidSideSize = 10.0;

    radiusLoc = 25;
    distanceWander = 80; 
    smallChange = 0.3;

    wandertheta = 0;
    maxspeed = 0.5;
    maxForce = 0.05;
  }

  void display() {

    fill(fillColor);
    angle = velocity.heading2D() + radians(90);
    pushMatrix();
    translate(location.x, location.y);
    rotate(angle);
    ellipse(0, 0, boidSideSize/2, boidSideSize);
    popMatrix();
  }

  void run(Firefly f) {
    display();
    action(f);
    update();
    wander();
  }

  void action(Firefly f) {

    if (f.lastAction()> 0) 
      fillColor = 255;
    else
      fillColor = 0;
  }

  void update() {

    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  void applyForce(PVector force) {
    PVector f = force.get();
    acceleration.add(f);
  }

  void wander() {
    
    wandertheta += random(-smallChange, smallChange);     // Randomly change wander theta

    // Now we have to calculate the new position to steer towards on the wander circle
    PVector circlepos = velocity.get();    // Start with velocity
    circlepos.normalize();            // Normalize to get heading
    circlepos.mult(distanceWander);          // Multiply by distance
    circlepos.add(location);               // Make it relative to boid's position

    float h = velocity.heading2D();        // We need to know the heading to offset wandertheta

    PVector circleOffSet = new PVector(radiusLoc*cos(wandertheta+h), radiusLoc*sin(wandertheta+h));
    PVector target = PVector.add(circlepos, circleOffSet);
    moveTowards(target);
  }



  void moveTowards(PVector target) {

    //println("Hello I'm here!!");

    PVector desiredLoc = PVector.sub(target, location);

    float dist = desiredLoc.mag();

    desiredLoc.normalize();

    //if (dist < 10) {

    //  float ease = map(dist, 0, 10, 0, maxForce);
    //  desiredLoc.mult(ease);
    //} else {
    //  desiredLoc.mult(maxForce);
    //}

    desiredLoc.mult(maxspeed);
    PVector seek = PVector.sub(desiredLoc, velocity);
    seek.limit(maxForce);
    applyForce(seek);
  }
}