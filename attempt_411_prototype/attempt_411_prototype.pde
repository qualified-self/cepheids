MyNode me;

ArrayList<PeopleNode> people = new ArrayList<PeopleNode>();

int numberOfFiles = 20;
String peopleFiles[][] = new String[numberOfFiles][];

String dan[];

void setup() {
  size(700, 700);

  dan = loadStrings("person4.txt");

  for (int i = 0; i < numberOfFiles; i++) {
    people.add(new PeopleNode(new PVector(width/2, height/2)));
    peopleFiles[i] = loadStrings("person"+i+".txt");
  }

  me =  new MyNode(new PVector(width/2, height/2));
}


void draw() {
  background(0);
  me.run();

  //println(dan[0]);

  //for(int k = 0; k < dan.length; k ++){
  //println(dan[k]); 
  //}



    for (int i = 0; i < people.size(); i++) {
         PeopleNode pl = people.get(i);
      if (pl.getStopBoolean() == false) {


      pl.run();

      pl.initialPositionUpdate();

      if (pl.getInitialPositionFlag() == true) {

        //println(peopleFiles[0][1]); 
        pl.goAway(me.location);

        pl.comeToMe(me.location, sortNumberArray(peopleFiles[i][1]));


        //pl.comeToMe(me.location, sortNumberArray(dan[1]));

        for (int j = 0; j < people.size(); j++) {

          PeopleNode rp = people.get(j);

          if (i != j) {
            pl.reppelEachOther(rp);
          }
        }
      }
    }
  }
}


int[] sortNumberArray(String numbersList) {

  String[]tempStringArray = numbersList.split(",");
  int[] numbersArray = new int[tempStringArray.length];

  for (int i =0; i < tempStringArray.length; i ++) {
    String numberAsString = tempStringArray[i];
    //println(numberAsString.trim());
    numbersArray[i] = Integer.parseInt(numberAsString.trim());
    //print(numbersArray[i]);
  }

  return numbersArray;
}