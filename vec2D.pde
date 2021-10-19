//basic 
class vec2D {
  float x, y, L;

  vec2D(float x1, float y1) {
    x = x1;
    y = y1;
    L = sqrt(x*x+y*y);
  }

  vec2D getRotated(float angle) {
    return new vec2D(cos(angle)*x-sin(angle)*y, sin(angle)*x+cos(angle)*y);
  }

  vec2D getNormalized() {
    return new vec2D(x/L, y/L);
  }

  void printVec() {
    print(vecToText()+"\n");
  }

  String vecToText() {
    return "("+str(x)+", "+str(y)+")";
  }
}

//checks if three vectors are in counterclockwise order--used to identify line intersections
//https://bryceboe.com/2006/10/23/line-segment-intersection-algorithm/ Bryce Boe
boolean ccw(vec2D A, vec2D B, vec2D C) {
  return (C.y-A.y)*(B.x-A.x) > (B.y-A.y)*(C.x-A.x);
}

//checks if two vectors are equal
boolean vec2DsEqual(vec2D v1, vec2D v2) {
  return (v1.x == v2.x && v1.y == v2.y);
}
