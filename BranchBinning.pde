/*
class that takes a 2d slice of the coordinate system
 and assigns bins to rectangular subsections of it.
 these bins contain lists of Branches so that 
 the neighbors of a given branch can be quickly
 found without having to loop through all of them
 */

class BinGrid {
  ArrayList[][] Grid; //2d array representing ArrayLists of branches
  int xmin, xmax, ymin, ymax; //defining the window of coordinates that bins are assigned to
  int xbins, ybins; //defines the number of rows and columns of bins 
  float xspace, yspace; //defines the width and height of every bin 

  int BranchCount = 0;

  BinGrid(int x1, int y1, int x2, int y2, int xb, int yb) {
    xmin = x1;
    xmax = x2;
    ymin = y1;
    ymax = y2;
    xbins = xb;
    ybins = yb;

    //calculates width and height assuming bins are equal in size
    xspace = (xmax-xmin)/xbins;
    yspace = (ymax-ymin)/ybins;

    //instantiate grid by looping through it and making an array at every index
    Grid = new ArrayList[xbins][ybins];
    for (int i=0; i<xbins; i++) {
      for (int j=0; j<ybins; j++) {
        Grid[i][j] = new ArrayList<Branch>();
      }
    }
  }

  //return x index corresponding to x-coord
  int xToIndex(float x) {
    return max(min(floor((x-xmin)/xspace), xbins-1), 0);
  }

  //return y index corresponding to y-coord
  int yToIndex(float y) {
    return max(min(floor((y-ymin)/yspace), ybins-1), 0);
  }

  //adds a branch to all of the bins that cover ranges
  //it might intersect with
  void addBranch(Branch b) {
    //increment number of branches
    BranchCount += 1;

    //get indices of any bins that might hold the branch
    ArrayList<vec2D> binIndexes = supercover(b);
    //add branch to all bins that might hold it
    for (vec2D v : binIndexes) {
      Grid[int(v.x)][int(v.y)].add(b);
    }
  }

  //given a line (or a Branch), return an ArrayList of all
  //Branches that share a bin with it
  ArrayList<Branch> getBranches(Line b) {
    //instantiate ArrayList containing branches
    ArrayList<Branch> branches = new ArrayList<Branch>();

    //identify the x,y indices of the bins corresponding to the
    //input line b
    ArrayList<vec2D> binIndexes = supercover(b);

    //loop through all bins that line b might be in
    for (vec2D v : binIndexes) {
      //add all branches from each bin to a list of branches
      branches.addAll(Grid[int(v.x)][int(v.y)]);
    }
    return branches;
  }

  //returns ArrayList of x-y indices in vec2D format
  //that correspond to all bins that may include the input
  //line l
  ArrayList<vec2D> supercover(Line l) {
    vec2D p1 = new vec2D(l.p1.x, l.p1.y);
    vec2D p2 = new vec2D(l.p2.x, l.p2.y);

    //remap line to real-extended bin space
    p1.y = (p1.y-ymin)/yspace;
    p2.y = (p2.y-ymin)/yspace;
    p1.x = (p1.x-xmin)/xspace;
    p2.x = (p2.x-xmin)/xspace;
    Line lremap = new Line(p1, p2);

    //all bins have integer indexes so calculating
    //the bins of individual points along the line
    //that are each unit length (1) apart will fully
    //sample all unique bins the line might fall in

    //calculate length of line to identify number of
    //samples needed
    int samples = ceil(lremap.getLength());
    float dy = (p2.y - p1.y)/samples; //dy step needed for next sample
    float dx = (p2.x - p1.x)/samples; //dx step needed for next sample

    float x = p1.x;
    float y = p1.y;

    int xindprev = int(x);
    int yindprev = int(y);

    ArrayList<vec2D> bins = new ArrayList<vec2D>();

    //only add bin if it is in range
    if (xInRange(xindprev) && yInRange(yindprev)) {
      bins.add(new vec2D(xindprev, yindprev));
    }
    for (int i = 0; i < samples; i++) {
      //take step
      x += dx;
      y += dy;

      //convert to integer values to get bin indices
      int xind = int(x);
      int yind = int(y);
      //only add to list if it's in range
      if (xInRange(xind) && yInRange(yind)) {
        bins.add(new vec2D(xind, yind));
      }
      //if step is not directly horizontal or vertical
      //also add the horizntal and vertical steps that
      //someone in the previous index could travel along
      //to reach the new step if they only traveled
      //horizontally or vertically
      if (xind != xindprev && yind != yindprev) {
        //only add to list if it's in range
        if (xInRange(xindprev) && yInRange(yind)) {
          bins.add(new vec2D(xindprev, yind));
        }
        //only add to list if it's in range
        if (xInRange(xind) && yInRange(yindprev)) {
          bins.add(new vec2D(xind, yindprev));
        }
      }
      //update previous index
      xindprev = xind;
      yindprev = yind;
    }
    return bins;
  }

  //loop through all bins and display each as a rectangle
  //with color determined by how populated it is
  void displayBins() {
    for (int i=0; i<xbins; i++) {
      for (int j=0; j<ybins; j++) {
        fill(10*Grid[i][j].size());
        stroke(0);
        rect(xmin+i*xspace, ymin+j*yspace, xspace, yspace);
      }
    }
  }

  void emptyBins() {
    for (int i=0; i<xbins; i++) {
      for (int j=0; j<ybins; j++) {
        Grid[i][j].clear();
      }
    }
  }

  //displays only the bins that a given line may intersect with
  void displayBins(Line l) {
    ArrayList<vec2D> bins = supercover(l);
    for (vec2D b : bins) {
      int i = int(b.x);
      int j = int(b.y);
      rect(xmin+i*xspace, ymin+j*yspace, xspace, yspace);
    }
  } 

  //checks if integer value is between zero and number of columns
  boolean xInRange(int val) {
    return val >= 0 && val < xbins;
  }

  //checks if integer value is between zero and number of rows
  boolean yInRange(int val) {
    return val >= 0 && val < ybins;
  }
}
