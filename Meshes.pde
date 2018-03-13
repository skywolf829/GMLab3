public class Mesh {
  public int x, y, z;
  public int eulerX, eulerY, eulerZ;

  ArrayList<Face> faces = new ArrayList<Face>();
  ArrayList<PVector> vertices = new ArrayList<PVector>();
  ArrayList<Edge> edges = new ArrayList<Edge>();
  ArrayList<ArrayList<Integer>> ASCIIfaces;
  public int faceColor = color(0, 0, 255);

  public Mesh(ArrayList<PVector> vertices, ArrayList<ArrayList<Integer>> ASCIIfaces) {
    this.vertices = vertices;
    this.ASCIIfaces = ASCIIfaces;

    for (int i = 0; i < ASCIIfaces.size(); i++) {
      Face f = new Face();
      ArrayList<PVector> points = new ArrayList<PVector>();
      ArrayList<Edge> faceEdges = new ArrayList<Edge>();

      for (int j = 0; j < ASCIIfaces.get(i).size()-1; j++) {
        points.add(vertices.get(ASCIIfaces.get(i).get(j)));
        Edge e;
        e = new Edge(vertices.get(ASCIIfaces.get(i).get(j)), 
          vertices.get(ASCIIfaces.get(i).get(j+1)), true);
        Edge theEdge = null;
        for (int k = 0; k < i && theEdge == null; k++) {
          theEdge = faces.get(k).hasEdge(e);
          if (theEdge != null) {
            e = theEdge;
            e.incidentFaces.add(f);
          }
        }
        e.incidentFaces.add(f);
        faceEdges.add(e);
        edges.add(e);
      }
      points.add(vertices.get(ASCIIfaces.get(i).get(ASCIIfaces.get(i).size() - 1)));

      f.vertices = points;
      f.edges = faceEdges;

      faces.add(f);
    }
  }
  public void GenerateASCIIFile() {
    PrintWriter f = createWriter("Mesh.off");
    f.println("OFF");
    f.println(vertices.size() + " " + ASCIIfaces.size() + " 0");
    for (int i = 0; i < vertices.size(); i++) {
      f.println(vertices.get(i).x + " " + vertices.get(i).y + " " + vertices.get(i).z);
    }
    for (int i = 0; i < ASCIIfaces.size(); i++) {
      f.print(ASCIIfaces.get(i).size() + " ");
      for (int j = 0; j < ASCIIfaces.get(i).size(); j++) {
        f.print(ASCIIfaces.get(i).get(j) + " ");
      }
      f.println();
    }
    f.flush();
    f.close();
  }
  public void draw() {
    for (int i = 0; i < ASCIIfaces.size(); i++) {
      fill(faceColor);
      //stroke(255);
      beginShape();
      PVector p1 = new PVector(0, 0, 0);
      PVector p2 = new PVector(0, 0, 0);
      for (int j = 0; j < ASCIIfaces.get(i).size()-1; j++) {
        p1 = vertices.get(ASCIIfaces.get(i).get(j));
        p2 = vertices.get(ASCIIfaces.get(i).get(j+1));
        vertex((float)p1.x, (float)p1.y, (float)p1.z);
      }
      vertex((float)p2.x, (float)p2.y, (float)p2.z);
      endShape(CLOSE);
    }
  }
}