abstract class Curve {
  public boolean closed = false;
  public ArrayList<PVector> controlPoints;
  public ArrayList<PVector> approximatePoints;
  public abstract void approximateCurve(double[] args);
  public void draw() {
    for (int i = 0; i < approximatePoints.size() - 1; i++) {
      //println(approximatePoints.get(i).v);
      fill(100, 155, 0);
      stroke(100, 155, 0);
      line((int)approximatePoints.get(i).x, (int)approximatePoints.get(i).y, (int)approximatePoints.get(i).z, 
        (int)approximatePoints.get(i+1).x, (int)approximatePoints.get(i+1).y, 
        (int)approximatePoints.get(i+1).z);
    }
    stroke(255);
  }
}


//Bezier curve - one curve for all the points
class BezierCurve extends Curve {

  public BezierCurve() {
    controlPoints = new ArrayList<PVector>();
    approximatePoints = new ArrayList<PVector>();
  }
  public PVector SolveAtParameterBernstein(float u) {
    PVector p = new PVector(0, 0, 0);
    for (int i = 0; i < controlPoints.size(); i++) {
      p.x += controlPoints.get(i).x * nChoosek(controlPoints.size() - 1, i) * 
        pow(u, i) * pow(1 - u, controlPoints.size() - i - 1);
      p.y += controlPoints.get(i).y * nChoosek(controlPoints.size() - 1, i) * 
        pow(u, i) * pow(1 - u, controlPoints.size() - i - 1);
      p.z += controlPoints.get(i).z * nChoosek(controlPoints.size() - 1, i) * 
        pow(u, i) * pow(1 - u, controlPoints.size() - i - 1);
    }

    return p;
  }
  void closeCurve() {
    if (controlPoints.size() > 2) {
      PVector first = controlPoints.get(0);
      PVector second = controlPoints.get(1);
      controlPoints.add(new PVector(lerp(first.x, second.x, -1.5), 
        lerp(first.y, second.y, -1.5), lerp(first.z, second.z, -1.5)));
      controlPoints.add(first);
    }
  }

  public void approximateCurve(double[] args) {
    approximatePoints = new ArrayList<PVector>();
    if (closed) closeCurve();
    for (float i = 0.0; i <= 1; i += 1.0 / args[0]) {
      approximatePoints.add(SolveAtParameterBernstein(i));
    }
  }

  public boolean selfIntersects() {
    boolean intersects = false;
    for (int i = 0; i < approximatePoints.size() - 1 && !intersects; i++) {
      PVector a1 = approximatePoints.get(i);
      PVector a2 = approximatePoints.get(i+1);
      for (int j = i + 1; j < approximatePoints.size() - 1 && !intersects; j++) {
        PVector b1 = approximatePoints.get(j);
        PVector b2 = approximatePoints.get(j+1);
        intersects = intersects(a1, a2, b1, b2);
      }
    }
    return intersects;
  }
}
public static ArrayList<PVector> elevateDegree(ArrayList<PVector> controlPoints) {
  ArrayList<PVector> newPoints = new ArrayList<PVector>();
  newPoints.add(controlPoints.get(0));
  for (int i = 1; i < controlPoints.size()-1; i++) {
    newPoints.add(
      PVector.add(PVector.mult(controlPoints.get(i-1), i / (controlPoints.size() + 1)), 
      PVector.mult(controlPoints.get(i), 1 - (i / (controlPoints.size() + 1))))
      );
  }
  newPoints.add(controlPoints.get(controlPoints.size() - 1));
  return newPoints;
}
public static ArrayList<PVector> reduceDegree(ArrayList<PVector> controlPoints) {
  ArrayList<PVector> newPoints = new ArrayList<PVector>();
  newPoints.add(controlPoints.get(0));
  for (int i = 2; i < controlPoints.size()-1; i++) {
    newPoints.add(controlPoints.get(i));
  }
  newPoints.add(controlPoints.get(controlPoints.size() - 1));
  return newPoints;
}
//Cubic B-spline with uniform knot vector.
class BSpline extends Curve {
  int D;
  public BSpline() {
    controlPoints = new ArrayList<PVector>();
    approximatePoints = new ArrayList<PVector>();
  }
  public void approximateCurve(double[] args) {
    D = (int)args[1];
    approximatePoints = new ArrayList<PVector>();

    for (float i = 0.0; i <= controlPoints.size() - D + 1; i += (controlPoints.size() - D + 1) / args[0]) {
      approximatePoints.add(SolveAt(i, D));
    }
  }
  public PVector SolveAt(double u, int D) {
    PVector p = new PVector(0, 0, 0);
    for (int i = 0; i < controlPoints.size(); i++) {
      p.x += controlPoints.get(i).x * bsplineBasisFunction(i, D, u, controlPoints.size(), D);
      p.y += controlPoints.get(i).y * bsplineBasisFunction(i, D, u, controlPoints.size(), D);
      p.z += controlPoints.get(i).z * bsplineBasisFunction(i, D, u, controlPoints.size(), D);
    }
    return p;
  }
  public float getT(int j) {
    if (D <= j && j <= controlPoints.size()-1) {
      return j-D+1;
    }
    if (controlPoints.size() - 1 < j && j <= controlPoints.size()-1+D) {
      return controlPoints.size()-D+1;
    } else {
      return 0;
    }
  }
  double basisFunction(int i, int d, double u) {
    if (d == 1) {
      if (getT(i) <= u && 
        u < getT(i+1)) return 1;
      else return 0;
    } else {
      double leftSide, rightSide;
      if (getT(i+d-1) == 
        getT(i)) {
        leftSide = 0;
      } else {
        leftSide = ((u - getT(i)) * basisFunction(i, d-1, u)) /
          (getT(i+d-1) - getT(i));
      }
      if (getT(i+d) == 
        getT(i+1)) {
        rightSide = 0;
      } else {
        rightSide = ((getT(i+d) - u) * basisFunction(i+1, d-1, u) /
          (getT(i+d) - getT(i+1)));
      }
      return leftSide + rightSide;
    }
  }
}
public Mesh BezierSurface(ArrayList<ArrayList<Vertex>> points, int resolution) {
  ArrayList<Vertex> vertices = new ArrayList<Vertex>();
  ArrayList<ArrayList<Integer>> ASCIIfaces = new ArrayList<ArrayList<Integer>>();

  for (float i = 0; i <= resolution; i++) {
    for (float j = 0; j <= resolution; j++) {
      PVector v = new PVector();
      for (int k = 0; k < points.size(); k++) {
        for (int l = 0; l < points.get(k).size(); l++) {
          v.add(PVector.mult(points.get(k).get(l).position, 
            (float)(bernstein(k, points.size(), i / resolution) * 
            bernstein(l, points.get(k).size(), j / resolution))));
        }
      }
      vertices.add(new Vertex(v));
    }
  }
  for (int i = 0; i < resolution; i++) {
    for (int j = 0; j < resolution; j++) {    
      int base = (int)(i * (resolution+1));
      ArrayList<Integer> temp = new ArrayList<Integer>();
      temp.add(base + j);
      temp.add(base + j + 1);
      temp.add(base + j + 1 + (int)(resolution+1));
      temp.add(base + j + (int)(resolution+1));
      ASCIIfaces.add(temp);
    }
  }
  return new Mesh(vertices, ASCIIfaces);
}

public static double bernstein(int i, int n, float u) {
  return nChoosek(n - 1, i) * 
    pow(u, i) * pow(1 - u, n - i - 1);
}

public static float getT(int j, int numControlPoints, int D) {
  if (D <= j && j <= numControlPoints-1) {
    return j-D+1;
  }
  if (numControlPoints - 1 < j && j <= numControlPoints-1+D) {
    return numControlPoints-1-D+2;
  } else {
    return 0;
  }
}
public static double bsplineBasisFunction(int i, int d, double u, int controlPointSize, int D) {
  if (d == 1) {
    if (getT(i, controlPointSize, D) <= u && 
      u < getT(i+1, controlPointSize, D)) return 1;
    else return 0;
  } else {
    double leftSide, rightSide;
    if (getT(i+d-1, controlPointSize, D) == 
      getT(i, controlPointSize, D)) {
      leftSide = 0;
    } else {
      leftSide = ((u - getT(i, controlPointSize, D)) * 
      bsplineBasisFunction(i, d-1, u, controlPointSize, D)) /
        (getT(i+d-1, controlPointSize, D) - getT(i, controlPointSize, D));
    }
    if (getT(i+d, controlPointSize, D) == 
      getT(i+1, controlPointSize, D)) {
      rightSide = 0;
    } else {
      rightSide = ((getT(i+d, controlPointSize, D) - u) * 
      bsplineBasisFunction(i+1, d-1, u, controlPointSize, D) /
        (getT(i+d, controlPointSize, D) - getT(i+1, controlPointSize, D)));
    }
    return leftSide + rightSide;
  }
}


Mesh BSplineSurface(ArrayList<ArrayList<Vertex>> points, int resolution, int D) {
  ArrayList<Vertex> vertices = new ArrayList<Vertex>();
  ArrayList<ArrayList<Integer>> ASCIIfaces = new ArrayList<ArrayList<Integer>>();
  
  for (float i = 0; i <= (points.size() - D + 1) * (resolution); i += (points.size() - D + 1)) {
    for (float j = 0; j <= (points.get(0).size() - D + 1) * (resolution); j += (points.get(0).size() - D + 1)) {
      PVector v = new PVector();
      for (int k = 0; k < points.size(); k++) {
        for (int l = 0; l < points.get(k).size(); l++) {
          v.add(PVector.mult(points.get(k).get(l).position, 
            (float)bsplineBasisFunction(k, D, i / ((float)resolution+1), points.size(), D)
            * (float)bsplineBasisFunction(l, D, j / ((float)resolution+1), points.get(k).size(), D)));
        }
      }
      vertices.add(new Vertex(v));
    }
  }
  for (int i = 0; i < resolution; i++) {
    for (int j = 0; j < resolution; j++) {    
      int base = (int)(i * (resolution+1));
      ArrayList<Integer> temp = new ArrayList<Integer>();
      temp.add(base + j);
      temp.add(base + j + 1);
      temp.add(base + j + 1 + (int)(resolution+1));
      temp.add(base + j + (int)(resolution+1));
      ASCIIfaces.add(temp);
    }
  }
  return new Mesh(vertices, ASCIIfaces);
}