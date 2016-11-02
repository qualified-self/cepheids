class MyNode extends ParentNode {

  MyNode(PVector loc) {

    super(loc);

    nodeColor = color(200, 143, 89);
    mass = 40;
  }

  void run() {
    super.run();
    ring_1();
    iniRing();
  }

  void ring_1() {

    noFill();
    stroke(255);
    ellipse(location.x, location.y, ringOneRadius, ringOneRadius);
  }

  void iniRing() {

    noFill();
    stroke(255);
    ellipse(location.x, location.y,  initialRing ,  initialRing );
  }
}