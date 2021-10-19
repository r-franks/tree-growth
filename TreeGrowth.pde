//define width, height and background color
int w = 1000;
int h = 800;
int bg = 102;

//list of trees
int TreeCount = 0;
ArrayList<Tree> Trees = new ArrayList<Tree>();

//list of distances between branches that have collided
//is updated every  time  Tree.grow() identifies a collision between two branches
ArrayList<String> Distances = new ArrayList<String>();

//increments every time a line collides with another line
int CollisionCount = 0;
//updates every step to give iteration series of produced collisions
ArrayList<String> Collisions = new ArrayList<String>();

//updates every step to give iteration series of produced branches
ArrayList<String> Branches = new ArrayList<String>();

//records the time it took to achieve each iteration
ArrayList<String> Time = new ArrayList<String>();

//total length covered by branches
float TotalLength = 0;
//records length covered by branches so far
ArrayList<String> Coverage = new ArrayList<String>();

Tree tree; 

BinGrid GrownBranches;
BinGrid UngrownBranches;

float delta = 1.0;

//set up the screen size
void settings() {
  //use given width and height
  size(w, h);
  //fullScreen();

  GrownBranches = new BinGrid(0, 0, width, height, floor(width/(2*delta)), floor(height/(5*delta)));
  UngrownBranches = new BinGrid(0, 0, width, height, floor(width/(2*delta)), floor(height/(5*delta)));
}

//set background color
void setup() {
  background(bg); 
  //start out with one tree right in the middle of the screen
  //I like the name "Henry"

  //update TreeCount
  TreeCount += 1;
}

//draw stuff
void draw() {
  //fill(bg, 1);
  //rect(0,0,width,height);

  //stroke color 255
  stroke(255);

  int m1 = millis();
  //loop through all trees and grow them a tiny amount 
  for (Tree t : Trees) {
    t.grow(delta);
  }

  int m2 = millis();

  //bin growing trees
  //instantiate bins to put put growing branches in by position

  //loop through all trees and get only the growing ones
  ArrayList<Branch> growingBranches = new ArrayList<Branch>();
  for (Tree t : Trees) {
    //get all growing branches in tree
    growingBranches.addAll(t.getGrowingBranches());
  }

  UngrownBranches.emptyBins();
  //put all branches in bins
  for (Branch b : growingBranches) {
    UngrownBranches.addBranch(b);
  }  

  int m3 = millis();
  //loop through all trees and check for collisions
  for (Tree t : Trees) {
    //check collisions and backtrack branches that had collisions
    t.ungrow(delta, GrownBranches, UngrownBranches);
  }

  int m4 = millis();

  /*only draw the branches that have changed
   since no branches ever shrink after display,
   the drawing from the last draw() can be used
   for all grown branches
   */
  for (Tree t : Trees) {
    t.displayGrowths(delta);
  }    

  int m5 = millis();

  //record collision so far
  Collisions.add(str(CollisionCount));
  //record branches produced so far
  Branches.add(str(UngrownBranches.BranchCount+GrownBranches.BranchCount));
  //record time it took
  Time.add(str(m2-m1)+","+str(m3-m2)+","+str(m4-m3)+","+str(m5-m4));
  //record length
  Coverage.add(str(TotalLength));

  //show all bins colored by number of trees in them
  //GrownBranches.displayBins();

  //stop and write data if all trees are no longer growing
  boolean allTreesDead = true;
  for (Tree t : Trees) {
    allTreesDead = allTreesDead && t.isDead();
  }

  //write data and end process if all trees die (for later analysis)
  if (allTreesDead) {
    background(bg); 
    redisplay();
    noLoop();
    writeArrayList(Distances, "distances.txt");
    writeArrayList(Collisions, "collisions.txt");
    writeArrayList(Branches, "branches.txt");
    writeArrayList(Time, "time.txt");
    writeArrayList(Coverage, "length.txt");

    /*display all tree
     as lines grow, their slopes are drawn at slightly different
     angles, making them thicker than ideal as they are redrawn again
     and again. Once the growth process is finished, this redraws it
     one last time from scratch so everything is thin
     */
  }
}

//add trees at a point if the mouse is clicked

void mouseClicked() {
  loop();
  Trees.add(new Tree(mouseX, mouseY, 0.2, new vec2D(0, -1), PI/8, new int[0], str(TreeCount)));
  //update TreeCount
  TreeCount += 1;
}

void keyPressed() {
  if (keyCode == BACKSPACE) {
    background(bg); 
    TreeCount = 0;
    Trees = new ArrayList<Tree>();
    Distances = new ArrayList<String>();
    CollisionCount = 0;
    Collisions = new ArrayList<String>();
    Branches = new ArrayList<String>();
    Time = new ArrayList<String>();
    TotalLength = 0;
    Coverage = new ArrayList<String>();
    GrownBranches = new BinGrid(0, 0, width, height, floor(width/(2*delta)), floor(height/(5*delta)));
    GrownBranches = new BinGrid(0, 0, width, height, floor(width/(2*delta)), floor(height/(5*delta)));
  } else if (key == ' ') {
    background(bg); 
    redisplay();
  }
}

//redisplays trees without fuzzy aliasing issues
void redisplay() {
  for (Tree t : Trees) {
    t.display();
  }
}

//simple function for writing an array list to a file for analysis
void writeArrayList(ArrayList<String> l, String filename) {
  String[] list = new String[l.size()];
  list = l.toArray(list);
  saveStrings(filename, list);
}
