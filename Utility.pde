class Vertex {
  public PVector position;
  public ArrayList<Edge> connectedEdges = new ArrayList<Edge>();
  public ArrayList<Face> adjacentFaces = new ArrayList<Face>();

  public Vertex() {
  }
  public Vertex(float x, float y, float z) {
    position = new PVector(x, y, z);
  }
  public Vertex(PVector p) {
    position = p;
  }
  public Vertex clone() {
    Vertex v = new Vertex(new PVector(position.x, position.y, position.z));
    return v;
  }
  public void removeEdgesNotIn(Face f) {
    for (int i = 0; i < connectedEdges.size(); i++) {
      if (f.hasEdge(connectedEdges.get(i)) == null) {
        connectedEdges.remove(connectedEdges.get(i));
        i--;
      }
    }
  }
  @Override
    public boolean equals(Object o) {
    return position.equals(((Vertex)o).position);
  }
}
class Edge {
  public boolean orientation;
  public Vertex p1, p2;
  public ArrayList<Face> incidentFaces = new ArrayList<Face>();
  public Edge() {
  }
  public Edge(Vertex p1, Vertex p2, boolean o) {
    this.p1 = p1;
    this.p2 = p2;
    this.orientation = o;
  }
  @Override
    public boolean equals(Object e) {    
    return (p1.equals(((Edge)e).p1) && p2.equals(((Edge)e).p2)) || 
      (p1.equals(((Edge)e).p2) && p2.equals(((Edge)e).p1));
  }
  @Override
    public String toString() {
    return "Edge: " + p1.position + " to " + p2.position;
  }
  public PVector center() {
    return PVector.mult(PVector.add(p1.position, p2.position), 0.5);
  }
  public boolean has(Vertex v) {
    return v.equals(p1) || v.equals(p2);
  }
  public Vertex other(Vertex v) {
    if (v.equals(p1)) return p2;
    if (v.equals(p2)) return p1;
    else return null;
  }
}
class Face {
  public ArrayList<Vertex> vertices = new ArrayList<Vertex>();
  public ArrayList<Edge> edges = new ArrayList<Edge>();
  public Face() {
  }
  public Face(ArrayList<Vertex> vertices) {
    this.vertices = vertices;
  }
  public Face clone() {
    Face f = new Face();
    ArrayList<Vertex> newVerts = new ArrayList<Vertex>();
    ArrayList<Edge> newEdges = new ArrayList<Edge>();
    for (int i = 0; i < vertices.size(); i++) {
      newVerts.add(vertices.get(i).clone());
    }
    for (int i = 0; i < edges.size(); i++) {
      Edge e = new Edge(newVerts.get(vertices.indexOf(edges.get(i).p1)), 
        newVerts.get(vertices.indexOf(edges.get(i).p2)), false);
      newEdges.add(e);
      newVerts.get(vertices.indexOf(edges.get(i).p1)).connectedEdges.add(e);
      newVerts.get(vertices.indexOf(edges.get(i).p2)).connectedEdges.add(e);
    }
    f.vertices = newVerts;
    f.edges = newEdges;
    return f;
  }
  public boolean sharesEdgeWith(Face f) {
    for (int i = 0; i < edges.size(); i++) {
      for (int j = 0; j < f.edges.size(); j++) {
        if (edges.get(i).equals(f.edges.get(j))) return true;
      }
    }
    return false;
  }
  public PVector center() {
    PVector c = new PVector();
    for (Vertex v : vertices) {
      c.add(v.position);
    }
    c.mult(1.0 / vertices.size());
    return c;
  }
  public Edge hasEdge(Edge e) {
    for (int i = 0; i < edges.size(); i++) {
      if (e.equals(edges.get(i))) return edges.get(i);
    }
    return null;
  }
  public ArrayList<Edge> edgesIncidentOn(Vertex v) {
    ArrayList<Edge> e = new ArrayList<Edge>();
    for (Edge edge : edges) {
      if (edge.has(v) && !e.contains(edge)) e.add(edge);
    }
    return e;
  }
  public Vertex getNextPoint(Vertex v1, Vertex v2) {
    Edge e = new Edge(v1, v2, false);
    e = hasEdge(e);
    Edge next = null;
    for (int i = 0; i < edges.size(); i++) {
      if (!edges.get(i).equals(e))
        if (edges.get(i).has(v2)) {
          next = edges.get(i); 
          break;
        }
    }
    if (next == null) return null;
    else {
      Vertex other = next.other(v2);
      return other;
    }
  }
}

public static double ccw(PVector a, PVector b, PVector c) {
  return (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y);
}
public boolean intersects(PVector a1, PVector a2, PVector b1, PVector b2) {
  double r = ((a1.y - b1.y) * (b2.x - b1.x) - (a1.x - b1.x) *(b2.y - b1.y)) / 
    ((a2.x - a1.x) * (b2.y - b1.y) - (a2.y - a1.y) * (b2.x - b1.x));
  double s = ((a1.y - b1.y) * (a2.x - a1.x) - (a1.x - b1.x) *(a2.y - a1.y)) / 
    ((a2.x - a1.x) * (b2.y - b1.y) - (a2.y - a1.y) * (b2.x - b1.x));

  return r > 0 && r < 1 && s > 0 && s < 1;
}
static double distance(PVector p1, PVector p2) {
  return Math.pow(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2)
    + Math.pow(p1.z - p2.z, 2), 0.5);
}
static float distance(float x1, float y1, float x2, float y2) {
  return pow(pow(x1 - x2, 2) + pow(y1 - y2, 2), 0.5);
}
static double nChoosek(int n, int k) {
  return fact(n) / (fact(k) * fact(n - k));
}
static final double fact(int num) {
  double i = 1;
  while (num > 0) {
    i *= num;
    num--;
  }
  return i;
}

static double lerp(double a, double b, double l) {
  return a + (b - a) * l;
}
/***************************************************************************
 * Quaternion class written by BlackAxe / Kolor aka Laurent Schmalen in 1997
 * Translated to Java(with Processing) by RangerMauve in 2012
 * this class is freeware. you are fully allowed to use this class in non-
 * commercial products. Use in commercial environment is strictly prohibited
 */

public class Quaternion {
  public  float W, X, Y, Z;      // components of a quaternion

  // default constructor
  public Quaternion() {
    W = 1.0;
    X = 0.0;
    Y = 0.0;
    Z = 0.0;
  }

  // initialized constructor

  public Quaternion(float w, float x, float y, float z) {
    W = w;
    X = x;
    Y = y;
    Z = z;
  }

  // quaternion multiplication
  public Quaternion mult (Quaternion q) {
    float w = W*q.W - (X*q.X + Y*q.Y + Z*q.Z);

    float x = W*q.X + q.W*X + Y*q.Z - Z*q.Y;
    float y = W*q.Y + q.W*Y + Z*q.X - X*q.Z;
    float z = W*q.Z + q.W*Z + X*q.Y - Y*q.X;

    W = w;
    X = x;
    Y = y;
    Z = z;
    return this;
  }

  // conjugates the quaternion
  public Quaternion conjugate () {
    X = -X;
    Y = -Y;
    Z = -Z;
    return this;
  }

  // inverts the quaternion
  public Quaternion reciprical () {
    float norme = sqrt(W*W + X*X + Y*Y + Z*Z);
    if (norme == 0.0)
      norme = 1.0;

    float recip = 1.0 / norme;

    W =  W * recip;
    X = -X * recip;
    Y = -Y * recip;
    Z = -Z * recip;

    return this;
  }

  // sets to unit quaternion
  public Quaternion normalize() {
    float norme = sqrt(W*W + X*X + Y*Y + Z*Z);
    if (norme == 0.0)
    {
      W = 1.0; 
      X = Y = Z = 0.0;
    } else
    {
      float recip = 1.0/norme;

      W *= recip;
      X *= recip;
      Y *= recip;
      Z *= recip;
    }
    return this;
  }
  // makes quaternion from yaw pitch roll
  public void toQuaternion(float pitch, float roll, float yaw)
  {
    // Abbreviations for the various angular functions
    float cy = cos(yaw * 0.5);
    float sy = sin(yaw * 0.5);
    float cr = cos(roll * 0.5);
    float sr = sin(roll * 0.5);
    float cp = cos(pitch * 0.5);
    float sp = sin(pitch * 0.5);

    this.W = cy * cr * cp + sy * sr * sp;
    this.X = cy * sr * cp - sy * cr * sp;
    this.Y = cy * cr * sp + sy * sr * cp;
    this.Z = sy * cr * cp - cy * sr * sp;
  }

  // Makes quaternion from axis
  public Quaternion fromAxis(float Angle, float x, float y, float z) { 
    float omega, s, c;
    s = sqrt(x*x + y*y + z*z);

    if (abs(s) > Float.MIN_VALUE)
    {
      c = 1.0/s;

      x *= c;
      y *= c;
      z *= c;

      omega = -0.5f * Angle;
      s = (float)sin(omega);

      X = s*x;
      Y = s*y;
      Z = s*z;
      W = (float)cos(omega);
    } else
    {
      X = Y = 0.0f;
      Z = 0.0f;
      W = 1.0f;
    }
    normalize();
    return this;
  }

  public Quaternion fromAxis(float Angle, PVector axis) {
    return this.fromAxis(Angle, axis.x, axis.y, axis.z);
  }

  // Rotates towards other quaternion
  public void slerp(Quaternion a, Quaternion b, float t)
  {
    float omega, cosom, sinom, sclp, sclq;


    cosom = a.X*b.X + a.Y*b.Y + a.Z*b.Z + a.W*b.W;


    if ((1.0f+cosom) > Float.MIN_VALUE)
    {
      if ((1.0f-cosom) > Float.MIN_VALUE)
      {
        omega = acos(cosom);
        sinom = sin(omega);
        sclp = sin((1.0f-t)*omega) / sinom;
        sclq = sin(t*omega) / sinom;
      } else
      {
        sclp = 1.0f - t;
        sclq = t;
      }

      X = sclp*a.X + sclq*b.X;
      Y = sclp*a.Y + sclq*b.Y;
      Z = sclp*a.Z + sclq*b.Z;
      W = sclp*a.W + sclq*b.W;
    } else
    {
      X =-a.Y;
      Y = a.X;
      Z =-a.W;
      W = a.Z;

      sclp = sin((1.0f-t) * PI * 0.5);
      sclq = sin(t * PI * 0.5);

      X = sclp*a.X + sclq*b.X;
      Y = sclp*a.Y + sclq*b.Y;
      Z = sclp*a.Z + sclq*b.Z;
    }
  }

  public Quaternion exp()
  {                               
    float Mul;
    float Length = sqrt(X*X + Y*Y + Z*Z);

    if (Length > 1.0e-4)
      Mul = sin(Length)/Length;
    else
      Mul = 1.0;

    W = cos(Length);

    X *= Mul;
    Y *= Mul;
    Z *= Mul; 

    return this;
  }

  public Quaternion log()
  {
    float Length;

    Length = sqrt(X*X + Y*Y + Z*Z);
    Length = atan(Length/W);

    W = 0.0;

    X *= Length;
    Y *= Length;
    Z *= Length;

    return this;
  }
  PVector vectorMult(PVector vector) {
    float num = this.X * 2;
    float num2 = this.Y * 2;
    float num3 = this.Z * 2;
    float num4 = this.X * num;
    float num5 = this.X * num2;
    float num6 = this.Z * num3;
    float num7 = this.X * num2;
    float num8 = this.X * num3;
    float num9 = this.Y * num3;
    float num10 = this.W * num;
    float num11 = this.W * num2;
    float num12 = this.W * num3;

    return new PVector(
      (1 - (num5 + num6)) * vector.x + (num7 - num12) * vector.y + (num8 + num11) * vector.z, 
      (num7 + num12) * vector.x + (1 - (num4 + num6)) * vector.y + (num9 - num10) * vector.z, 
      (num8 - num11) * vector.x + (num9 + num10) * vector.y + (1 - (num4 + num5)) * vector.z);
  }
}

boolean lineSphereIntersection(PVector p, PVector ray, PVector o, float r) {
  //println(pow(PVector.dot(ray, PVector.sub(o, p.v)), 2));
  float d1 = pow(PVector.dot(ray, PVector.sub(o, p)), 2) - 
    pow((PVector.sub(o, p)).mag(), 2) + pow(r, 2); 
  //println(d1);
  return d1 >= 0;
}

PVector createRaycast(PeasyCam cam) {
  float x = mouseX;
  float y = mouseY;

  PVector cameraLookAt = new PVector(cam.getLookAt()[0], 
    cam.getLookAt()[1], cam.getLookAt()[2]);
  PVector cameraPosition = new PVector(cam.getPosition()[0], 
    cam.getPosition()[1], cam.getPosition()[2]);
  PVector view = PVector.sub(cameraLookAt, cameraPosition);
  view.normalize();


  Quaternion rot2 = new Quaternion();
  rot2.toQuaternion((float)cam.getRotations()[1], 
    (float)cam.getRotations()[0], (float)cam.getRotations()[2]);

  Vector3D up = cam.rotation.applyTo(new Vector3D(0, 1, 0));

  PVector cameraUp = new PVector((float)up.getX(), (float)up.getY(), (float)up.getZ());
  //print(cameraUp + " " + cameraUp2 + " " );
  cameraUp.normalize();

  PVector h = view.cross(cameraUp);
  h.normalize();


  //v.mult(vLength);
  //h.mult(hLength);
  cameraUp.mult(height / 3.0);
  h.mult(width / 3.0);

  x -= width / 2.0;
  y -= height / 2.0;

  y /= height / 2.0;
  x /= width / 2.0;

  PVector pos = PVector.add(PVector.add(cameraPosition, PVector.mult(view, (float)cam.getDistance())), 
    PVector.add(h.mult(x), cameraUp.mult(y)));
  PVector dir = PVector.sub(pos, cameraPosition);
  return dir.normalize();
}