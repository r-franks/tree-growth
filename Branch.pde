/*Branches are simple extensions of the Line class
which represent linear branches of a tree. The difference
is two additional fields which contain the unique (ideally)
name of the tree that the branch is a part of and the path
of indices that must be taken down the Tree to arrive at
the branch _in_ the tree
*/
class Branch extends Line {
  int[] path; //array describing how to access a Branch in a tree
  String treeName; //name of tree that a branch is part of
  Branch(float xStart, float yStart, float xEnd, float yEnd, int[] p, String n) {
    super(xStart, yStart, xEnd, yEnd);
    path = p;
    treeName = n;
  }
}

//checks if branches come from trees with same name
boolean branchesSameTree(Branch b1, Branch b2) {
  String tree1 = b1.treeName;
  String tree2 = b2.treeName;
  return tree1.equals(tree2);
}

//calculates distance between two branches based on the path one must
//take to move from one branch to the other
int getBranchDistance(Branch b1, Branch b2) {
  if (branchesSameTree(b1, b2)) {
    //maximum number of split-offs in common
    int maxi = min(b1.path.length, b2.path.length)-1;

    //start out assuming completely different branches so traveling from one to the other
    //requires backtracking all the way down b1's path and then going through all of b2's path
    int distance = b1.path.length+b2.path.length;
    int i = 0;

    //so long as branches diverge somewhere, each branch can be treated as a terminating node
    //thus, each path selection the branches have in common reduce the distance by 2
    while (distance > 0) {
      //if paths are identical except one ends before the other, return difference in the lengths of their paths
      if (i > maxi) {
        return max(b1.path.length, b2.path.length)-min(b1.path.length, b2.path.length);
      } else if (b1.path[i]!=b2.path[i]) {
        //if paths diverge, the branches cannot get closer together
        break;
      }
      //if paths are equal, remove 2 steps (one backward and one forward) from distance
      distance -= 2;
      //increment i
      i += 1;
    }
    return distance;
  } else {
    return -1;
  }
}

//simple function for printing path arrays as a sequence
void printPath(int[] path) {
  print(pathToText(path)+"\n");
}

//simple function for converting the path array to a string
String pathToText(int[] path) {
  int i = 0;
  String str = "";
  while (i<path.length) {
    str = str+"-"+str(path[i]);
    i +=1;
  }
  return str;
}
