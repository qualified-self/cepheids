class ParentNode {

  PVector location;
  PVector velocity;
  PVector acceleration;

  float mass;
  color nodeColor;

  float innerRingAlpha;
  float outerRingAlpha;

  float stepSize;

  float ringOneRadius;

  float initialRing;


  ParentNode(PVector loc) {

    location = loc.get();
    velocity = new PVector();
    acceleration = new PVector();

    innerRingAlpha = 255;
    outerRingAlpha = 255;
    stepSize = 6;

    ringOneRadius= 150;

    initialRing = 300;
  }


  void run() {

    update();
    drawNode();
  }

  void drawNode() {

    strokeWeight(8);
    noFill();
    stroke(nodeColor, innerRingAlpha);
    ellipse(location.x, location.y, mass, mass);

    strokeWeight(1);
    fill(nodeColor, outerRingAlpha);
    stroke(0);
    ellipse(location.x, location.y, mass*0.6, mass*0.6);
  }

  void update() {

    velocity.add(acceleration);
    location.add(velocity);

    acceleration.mult(0);
    velocity.limit(mass/10);
  }

  void applyForce(PVector force) {

    PVector f = force.get();
    f.div(mass);
    acceleration.add(f);
  }
}