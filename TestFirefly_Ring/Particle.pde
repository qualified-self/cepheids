class Particle {

  PVector location, velocity, acceleration;
  
  float anglePos;
  
  float particleSize;

  float maxspeed, maxForce;

  PVector initialTarget;
  
  boolean arrived = false;
  
  int light = 155;

  Particle() {

    location = new PVector(width/2, height/2);
    velocity = new PVector();
    acceleration = new PVector();
    initialTarget = new PVector();

    anglePos = 0;
    
    particleSize = 10; 

    maxspeed = 4;
    maxForce = 0.4;
  }


  void run() {

    display();
    update();
  }

  void display() {

    fill(255, light);
    ellipse(location.x, location.y, particleSize, particleSize);
  }


  PVector getTarget() {
    return initialTarget;
  }

  void makeTarget(int radius) {

    initialTarget.x = radius * cos(anglePos) + location.x;
    initialTarget.y =  radius * sin(anglePos) + location.y;

  }

  void setAnglePos(float newAngle) {
    anglePos = newAngle;
  }


  void seek(PVector target) {
    PVector desiredLoc = PVector.sub(target, location);
    
    float dist = desiredLoc.mag();
    
    desiredLoc.normalize();

    if (dist < 10) {

      float ease = map(dist, 0, 10, 0, maxspeed);
      desiredLoc.mult(ease);
      if(dist< 0.5) arrived = true;
    } else {

      desiredLoc.mult(maxspeed);
    }

    PVector seek = PVector.sub(desiredLoc, velocity);
    seek.limit(maxForce);
    applyForce(seek);
  }
  
  void particleResponse(float action){
    
    PVector awayFromCenter = new PVector(width/2, height/2);
    awayFromCenter = PVector.sub(awayFromCenter, location);
    awayFromCenter.mult(-1);
    awayFromCenter.normalize();
    awayFromCenter.mult(0.4);
    
    if(action == 1 && arrived){
      applyForce(awayFromCenter);
      
      if(light < 255)
      light ++;
      
    } else {
      
      if(light > 0)
      light --;
      
    }
    
  }

  void update() {

    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
  }

  void applyForce(PVector force) {
    PVector f = force.get();
    acceleration.add(f);
  }
}