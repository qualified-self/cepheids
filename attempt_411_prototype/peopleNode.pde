class PeopleNode extends ParentNode {

  int time;
  int currentTime;

  PVector futureLocation;
  PVector desiredLocation;

  boolean startMoving, setPosition;
  float numberPassed;
  float maxSpeed;

  float maxSpeedIntial;

  MyNode centerNode;

  float degrees;
  float x;
  float y;

  PVector ringLocation;

  boolean inInitialPostion = false;

  int stepIndex;

  int loadingTime;

  float clockX, clockY, orbitDegrees, speedOfDegrees;

  boolean orbit0 = false;
  boolean comeToMeStop = false;

  PeopleNode(PVector loc) {

    super(loc);

    nodeColor = color(random(255), random(255), random(255));
    mass = 30;

    time = millis();
    currentTime = millis() - time;

    startMoving = false;
    setPosition = true;

    numberPassed = 2;
    maxSpeed = 0.09;

    maxSpeedIntial =2;

    degrees = random(0, 360);
    x = (initialRing/2)*cos(degrees)+loc.x;
    y = (initialRing/2)*sin(degrees)+loc.y;

    ringLocation =  new PVector(x, y);

    stepIndex = 0;
  }


  void run() {

    super.run();
    currentTime = millis() - time;
  }


  void goAway(PVector myloc) {
    PVector meloc = myloc.get();
    PVector awayFromMe = PVector.sub(meloc, location);
    awayFromMe.mult(-1);
    awayFromMe.normalize();
    awayFromMe.mult(0.01);


    if (startMoving == false) {
      applyForce(awayFromMe);
    }
  }

  void comeToMe(PVector myloc, int[] stepsToTake) {

    if (stepIndex == stepsToTake.length) {
      comeToMeStop = true;
    }

    if (comeToMeStop == false) {

      PVector myLocForDist = myloc.get();
      //boolean ring1 = amIinRingOne(myLocForDist);

      //println("am I in ring one? : " + ring1);
      clockX = (mass)*cos(orbitDegrees)+location.x;
      clockY = (mass)*sin(orbitDegrees)+location.y;

      //if(){}
      if (stepsToTake[stepIndex] == 0) {
        loadingTime = 4000;
      } else {
        loadingTime = 2000;
      } 

      if (currentTime > loadingTime && setPosition) {

        println(stepsToTake[stepIndex]);
        if (stepsToTake[stepIndex] == 0) {
          orbit0 = true;
          //speedOfDegrees = 0.1;
        } else 
        if (stepsToTake[stepIndex] == 1) {

          speedOfDegrees = 0.065;
        } else if (stepsToTake[stepIndex] == 2) {

          speedOfDegrees = 0.008;
        } else if (stepsToTake[stepIndex] == 3) {

          speedOfDegrees = 0.03;
        } else if (stepsToTake[stepIndex] == 4) {

          speedOfDegrees = 0.02;
        }

        futureLocation = myloc.get();
        futureLocation.sub(location);
        futureLocation.normalize();
        futureLocation.mult(stepSize*stepsToTake[stepIndex]);
        futureLocation.add(location);


        if (stepIndex < stepsToTake.length) {
          stepIndex++;
        }

        startMoving = true;
        setPosition = false;
      }

      noStroke();
      fill(155);
      ellipse(clockX, clockY, 5, 5);

      if (orbit0 == true) {
        speedOfDegrees = 0.1;
        orbitDegrees += speedOfDegrees;

        if (orbitDegrees>(2*PI)) {
          orbit0 = false;
        }
      }

      //println("Orbit degrees: " + orbitDegrees);
      if (startMoving) {
        orbitDegrees += speedOfDegrees;


        //Target position
        fill(255, 100);
        ellipse(futureLocation.x, futureLocation.y, 10, 10);

        PVector desired = PVector.sub(futureLocation, location);
        float distance = desired.mag();
        desired.normalize();

        if (distance < 5) {

          float ease = map(distance, 0, 5, 0, maxSpeed);
          desired.mult(ease);
        } else {

          desired.mult(maxSpeed);
        }

        //Steer force, makes sure that if I overshoot, I can come back to the right point quickly.
        PVector steer = PVector.sub(desired, velocity);
        steer.mult(4);
        applyForce(steer);

        if (distance < 0.9) {
          setPosition = true;
          time = millis();
          startMoving = false;
        }
      }
    }
  }

  boolean amIinRingOne(PVector loc) {

    PVector myLoc = loc.get();

    PVector distance = PVector.sub(myLoc, location);

    float dist = distance.mag();

    if (dist < (ringOneRadius/2)) {

      return true;
    }
    return false;
  }


  void reppelEachOther(PeopleNode pn) {
    PVector distance = PVector.sub(location, pn.location);
    float d = distance.mag();
    distance.mult(1);
    distance.normalize(); 

    if (d < pn.mass) {
      distance.mult(0.01);
      applyForce(distance);
    }
  }

  void initialPositionUpdate() {

    if (inInitialPostion == false) {
      PVector desired = PVector.sub(ringLocation, location);
      float dist = desired.mag();
      desired.normalize();

      if (dist < 20) {
        float ease = map(dist, 0, 20, 0, maxSpeedIntial);
        desired.mult(ease);
      } else {
        desired.mult(maxSpeedIntial);
      }

      PVector seekRing = PVector.sub(desired, velocity);

      if (dist < 0.1) {
        acceleration.mult(0);
        velocity.mult(0);
        inInitialPostion = true;
      }
      applyForce(seekRing);
    }
  }

  void setOtherForce(boolean setForce) {
    setPosition = setForce;
  }

  boolean getInitialPositionFlag() {
    return inInitialPostion;
  }

  void setBooleanToStartComingToMe(boolean set) {
    setPosition = set;
  }

  boolean getStopBoolean() {
    return comeToMeStop;
  }
}