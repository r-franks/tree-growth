//basic class containing a line
//a Line is two points (vec2Ds)
//with some other features
class Line {
  vec2D p1, p2;
   //precalculate details for Line bounding boxes
  float minx, maxx, miny, maxy;

  //instantiate with coordinates
  Line(float xStart, float yStart, float xEnd, float yEnd) {
    minx = min(xStart, xEnd);
    maxx = max(xStart, xEnd);
    miny = min(yStart, yEnd);
    maxy = max(yStart, yEnd);

    //convert coordinates to vec2D
    p1 = new vec2D(xStart, yStart);
    p2 = new vec2D(xEnd, yEnd);
  }

  //instantiate with vectors
  Line(vec2D start, vec2D end) {
    minx = min(start.x, end.x);
    maxx = max(start.x, end.x);
    miny = min(start.y, end.y);
    maxy = max(start.y, end.y);
    p1 = start;
    p2 = end;
  }

  //calculate Euclidean length of vector
  float getLength() {
    return sqrt((p2.x-p1.x)*(p2.x-p1.x)+(p2.y-p1.y)*(p2.y-p1.y));
  }

  //draws line
  void display(){
    line(p1.x, p1.y, p2.x, p2.y);
  }
  
  //prints line in readable format
  void printLine() {
    print(lineToText()+"\n");
  }

  //simple function to convert a line to a readable format
  String lineToText() {
    return "["+p1.vecToText()+", "+p2.vecToText()+"]";
  }
}

//checks if two lines are equal--lines are sensitive to order of points
boolean linesEqual(Line l1, Line l2) {
  return vec2DsEqual(l1.p1, l2.p1) && vec2DsEqual(l1.p2, l2.p2);
}

//returns true if lines have overlapping bounding boxes
boolean boundingBoxOverlap(Line l1, Line l2) {
  return !(l1.minx > l2.maxx || l1.maxx < l2.minx || l1.miny > l2.maxy || l1.maxy < l2.miny);
}

//checks if lines intersect, ignoring colinearity
//https://bryceboe.com/2006/10/23/line-segment-intersection-algorithm/ Bryce Boe
boolean linesIntersect(Line l1, Line l2) {
  return ccw(l1.p1, l2.p1, l2.p2) != ccw(l1.p2, l2.p1, l2.p2) && ccw(l1.p1, l1.p2, l2.p1) != ccw(l1.p1, l1.p2, l2.p2);
}
