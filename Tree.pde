//recursive tree class 
//each tree is either a:
//--line that can be drawn to canvas starting at a base of xpos1, ypos1 and ending at xpos2, ypos2
//--line that can be drawn to canvas starting at a base of xpos1, ypos1 and ending at xpos2, ypos2
//  and a list of trees with bases at xpos2, ypos2
class Tree { 
  float xpos1, ypos1, xpos2, ypos2;
  float psplit; //probability that a growing tree will stop growing and produce two trees that start growing from xpos2,ypos2
  float thetaDeviation; //how much the direction of any trees growing off this tree will vary from the direction of this tree
  int[] path; //depth of tree branch
  String name; //name of tree
  vec2D growthDir; //direction tree branch will grow in
  boolean isGrown; //whether the tree branch has finished growing
  ArrayList<Tree> Trees; //list of trees starting at xpos2,ypos2

  Tree (float x, float y, float p, vec2D direction, float thetaDev, int[] ph, String n) {      
    //set base of tree (point from which the trunk/branch will grow)
    xpos1 = x; //xcoord tree base
    ypos1 = y; //ycoord tree base
    xpos2 = x; //start end of the tree at its base
    ypos2 = y;

    thetaDeviation = thetaDev; //set variation in angle
    direction = direction.getNormalized(); //normalize to unit length
    growthDir = direction; //set growth direction

    //all trees start out ungrown
    isGrown = false;

    psplit = p;

    //path to current branch
    path = ph;
    //name of tree--all branches of this tree will inherit this name
    name = n;

    //instantiate empty arraylist of more trees
    Trees = new ArrayList<Tree>();
  } 

  //method for growing the tree
  void grow(float delta) {
    //probability of tree splitting into 2 more
    //psplit is chance of a split after traveling distance of 1
    //p is chance of split after traveling delta
    //1-(1-psplit)^delta
    
    float p = 1-pow(1-psplit, delta);

    //if tree has not finished growing
    if (!isGrown) {
      //if we randomly find that the tree branch should split into two, set this tree branch to grown and add two growing trees to list
      if (random(1) < p) {
        //set tree to grown
        isGrown = true;
        
        //update CollisionCount for data recording
        CollisionCount += 1;
        
        //since this Branch is grown now and will never change, we can put in bins
        //without having to update later
        GrownBranches.addBranch(new Branch(xpos1, ypos1, xpos2, ypos2, path, name));
        
        //add two ungrown trees that start where this tree stops
        
        //randomly pick number of branches that should grow out of this branch
        int branches = round(random(1,5)); 
        
        //angles are chosen so all will be at most 90 degree turns from
        //this Branches' growth direction and all will also be evenly spaced
        //angles
        float angleSpacing;
        float startAngle;
        if (branches%2==0) {
          //if even number of branches
          angleSpacing = PI/(branches-1);
          startAngle = -PI/2;
        } else if (branches > 1) {
          //if odd number of branches >1
          int halfbranch = (branches+1)/2;
          angleSpacing = (PI/2)/(halfbranch-1);
          startAngle = -PI/2;
        } else {
          //if one branch
          angleSpacing = 0;
          startAngle = 0;
        }

        //randomly change forward-going base direction with some gaussian noise
        //this allows all branches to systematically curve away from the direction
        //of the currrent branch
        float angle = thetaDeviation*randomGaussian();
        vec2D noisyGrowthDir = growthDir.getRotated(angle);

        //loop through all evenly spaced angles and add a Branch for each
        for (int i = 0; i < branches; i++) {
          //calculate ideal branch direction (where branches maximize separation)
          float ang = startAngle + i*angleSpacing;
          //add noise
          ang = ang + thetaDeviation*randomGaussian();

          //rotate base direction 
          vec2D direction = noisyGrowthDir.getRotated(ang);

          //nice shattered-glass results for binary tree at thetaDeviation=PI/4
          ang = round(random(1, 3)-2)*thetaDeviation+0.2*thetaDeviation*randomGaussian(); //pick angle with some noise
          direction = growthDir.getRotated(ang); //rotate growth direction by that angle

          //calculate the path taken down the tree to reach the Branch that is about to be added
          int[] newpath = new int[path.length+1];
          System.arraycopy(path, 0, newpath, 0, path.length);
          newpath[newpath.length-1] = i;

          //create new Tree starting with just the one branch
          Tree newTree = new Tree(xpos2, ypos2, psplit, direction, thetaDeviation, newpath, name);
          
          //note that the new trees just start with length delta and have no chance of splitting off
          //if p=1, this avoids growing an infinite number of branches before checking for collisions
          newTree.xpos2 += delta*newTree.growthDir.x;
          newTree.ypos2 += delta*newTree.growthDir.y;
          Trees.add(newTree);
        }
      } else {
        //if tree is not splitting into 2 more, just let it grow in the growth direction
        xpos2 += delta*growthDir.x;
        ypos2 += delta*growthDir.y;
        //update total length
        TotalLength += delta;
        
        //if tree branch has reached edge of screen, stop it from growing
        if (xpos2<0 | xpos2>width | ypos2<0 | ypos2>height) {
          isGrown = true;
          
          //since the branch is static now, it can be binned
          GrownBranches.addBranch(new Branch(xpos1, ypos1, xpos2, ypos2, path, name));
          CollisionCount += 1;
        }
      }
    } else {
      //if tree has finished growing, grow any branches attached to it
      for (Tree t : Trees) {
        t.grow(delta);
      }
    }
  }

  //detects intersections between branches in lines and the most recently grown branches and ungrows them if collision
  void ungrow(float delta, BinGrid GrownBranchBins, BinGrid UngrownBranchBins) {
    //if tree would grow, check to see if it would've collided on the last growth iteration of step delta
    if (!isGrown) {
      //intersections along the whole line do not need to be checked since most of the line was checked at the last step
      //only the line describing the new growth needs to be checked
      float xpos2prev = xpos2 - delta*growthDir.x;
      float ypos2prev = ypos2 - delta*growthDir.y;
      
      //convert the Line described in this part of the tree to a Branch
      Branch b1 = new Branch(xpos2prev, ypos2prev, xpos2, ypos2, path, name);
      
      //use the binned Branches to get a neighborhood list for this Branch
      ArrayList<Branch> branches = GrownBranchBins.getBranches(b1);
      ArrayList<Branch> branches2 = UngrownBranchBins.getBranches(b1);
      branches.addAll(branches2);

      for (Branch b2 : branches) {
        //does not check the ungrowing line against a line that ends where the ungrowing line starts
        //prevents collisions between a branch and the branch it just grew off of

        //check bounding box
        if (boundingBoxOverlap(b1, b2)) {
          //check for intersection
          if (linesIntersect(b1, b2)) {
            //check if one branch grows from the other (distance=1) or if they are identical (distance=0) and ignores collision
            int distance = getBranchDistance(b1, b2);
            if (distance > 2 | distance < 0) {
              
              //update distances for this collision for later analysis
              Distances.add(str(distance));

              //set branch end-points to their positions prior to growth by delta*growthDir
              xpos2 = xpos2prev;
              ypos2 = ypos2prev;
              
              //update total length
              TotalLength -= delta;
              isGrown = true;
              
              //since the branch is static now, it can be binned
              GrownBranches.addBranch(new Branch(xpos1, ypos1, xpos2, ypos2, path, name));
              //break loop once a collision has been found
              break;
            }
          }
        }
      }
    } else {
      //if tree cannot grow, recursively check any trees attached to it
      for (Tree t : Trees) {
        t.ungrow(delta, GrownBranchBins, UngrownBranchBins);
      }
    }
  }

  //recursively display all growths on last turn
  void displayGrowths(float delta) {   
    if(!isGrown){
      line(xpos2-delta*growthDir.x, ypos2-delta*growthDir.y, xpos2, ypos2);
    }else{
      for (Tree t : Trees) {
        //otherwise check if any of the Trees branching from this tree have growing branches to display
        t.displayGrowths(delta);
      }
    }
  }
  
  //returns all growing branches (i.e. anything that would've been incremented during a grow() iteration)
  ArrayList<Branch> getGrowingBranches() {   
    ArrayList<Branch> allBranches = new ArrayList<Branch>();
    if(!isGrown){
      //if this part of tree is not grown, add it to list
      allBranches.add(new Branch(xpos1, ypos1, xpos2, ypos2, path, name));
    }
    for (Tree t : Trees) {
      //otherwise check if any of the Trees branching from this tree have growing branches
      allBranches.addAll(t.getGrowingBranches());
    }
    return allBranches;
  }
  
  //returns all grown branches
  ArrayList<Branch> getGrownBranches() {   
    ArrayList<Branch> allBranches = new ArrayList<Branch>();
    if(isGrown){
      //if this part of tree is not grown, add it to list
      allBranches.add(new Branch(xpos1, ypos1, xpos2, ypos2, path, name));
    }
    for (Tree t : Trees) {
      //otherwise check if any of the Trees branching from this tree have growing branches
      allBranches.addAll(t.getGrownBranches());
    }
    return allBranches;
  }
  
  //get all branches in tree recursively and make them a list
  ArrayList<Branch> getBranches() {
    ArrayList<Branch> allBranches = new ArrayList<Branch>();
    allBranches.add(new Branch(xpos1, ypos1, xpos2, ypos2, path, name));
    for (Tree t : Trees) {
      allBranches.addAll(t.getBranches());
    }
    return allBranches;
  }
  
  //recursively check to see if any parts of a tree are growing
  //if none are growing, return true
  boolean isDead() {
    if(isGrown){
      //if this part of the tree is not growing
      //start off assuming tree is dead
      boolean isDead = true;
      for (Tree t: Trees){
        //if any of the other parts of this tree are not dead, update isDead to false
        isDead = isDead && t.isDead();
      }
      return isDead;
    }else{
      //if this part of the tree is growing, it's not dead
      return false;
    }
  }
  
  //display this tree using lines
  void display() {  
    //display this part of the tree
    line(xpos1, ypos1, xpos2, ypos2);
    //recursively display the branches of trees connected to this branch
    for (Tree t : Trees) {
      t.display();
    }
  }
}
