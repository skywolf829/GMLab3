public class Mesh {
  public int x, y, z;
  public int eulerX, eulerY, eulerZ;

  public ArrayList<Face> faces = new ArrayList<Face>();
  public ArrayList<Vertex> vertices = new ArrayList<Vertex>();
  public ArrayList<Edge> edges = new ArrayList<Edge>();
  public ArrayList<ArrayList<Integer>> ASCIIfaces = new ArrayList<ArrayList<Integer>>();
  public int faceColor = color(0, 0, 255);



  public Mesh(ArrayList<Vertex> vertices, ArrayList<ArrayList<Integer>> ASCIIfaces) {
    this.vertices = vertices;
    this.ASCIIfaces = ASCIIfaces;
    for (int i = 0; i < ASCIIfaces.size(); i++) {
      Face f = new Face();
      ArrayList<Vertex> facePoints = new ArrayList<Vertex>();
      ArrayList<Edge> faceEdges = new ArrayList<Edge>();
      for (int j = 0; j < ASCIIfaces.get(i).size()-1; j++) {
        facePoints.add(vertices.get(ASCIIfaces.get(i).get(j)));
        Edge e = new Edge(vertices.get(ASCIIfaces.get(i).get(j)), 
          vertices.get(ASCIIfaces.get(i).get(j+1)), false);
        for (int k = 0; k < edges.size(); k++) {
          if (edges.get(k).equals(e)) {
            e = edges.get(k);
          }
        }
        e.incidentFaces.add(f);
        faceEdges.add(e);
        if (!edges.contains(e))
          edges.add(e);
        if (!vertices.get(ASCIIfaces.get(i).get(j)).connectedEdges.contains(e)) {
          vertices.get(ASCIIfaces.get(i).get(j)).connectedEdges.add(e);
        }
        if (!vertices.get(ASCIIfaces.get(i).get(j+1)).connectedEdges.contains(e)) {
          vertices.get(ASCIIfaces.get(i).get(j+1)).connectedEdges.add(e);
        }
      }
      Vertex v = vertices.get(ASCIIfaces.get(i).get(ASCIIfaces.get(i).size() - 1));
      facePoints.add(v);      
      Edge e = new Edge(v, vertices.get(ASCIIfaces.get(i).get(0)), false);
      for (int k = 0; k < edges.size(); k++) {
        if (edges.get(k).equals(e)) {
          e = edges.get(k);
        }
      }
      e.incidentFaces.add(f);
      if (!edges.contains(e))
        edges.add(e);
      faceEdges.add(e);
      if (!v.connectedEdges.contains(e)) {
        v.connectedEdges.add(e);
      }
      if (!vertices.get(ASCIIfaces.get(i).get(0)).connectedEdges.contains(e)) {
        vertices.get(ASCIIfaces.get(i).get(0)).connectedEdges.add(e);
      }
      f.vertices = facePoints;
      f.edges = faceEdges;
      faces.add(f);
    }
   
  }
  public void GenerateASCIIFile() {
    PrintWriter f = createWriter("Mesh.off");
    f.println("OFF");
    f.println(vertices.size() + " " + ASCIIfaces.size() + " 0");
    for (int i = 0; i < vertices.size(); i++) {
      f.println(vertices.get(i).position.x + " " + 
        vertices.get(i).position.y + " " + vertices.get(i).position.z);
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
    /*
    for (int i = 0; i < vertices.size(); i++) {     
     PVector p1 = vertices.get(i).position;
     fill(255);
     text(i, p1.x, p1.y, p1.z);
     }
     */
    for (int i = 0; i < ASCIIfaces.size(); i++) {
      //noFill();
      fill(faceColor);
      stroke(255);
      beginShape();
      PVector p1 = new PVector(0, 0, 0);
      PVector p2 = new PVector(0, 0, 0);
      for (int j = 0; j < ASCIIfaces.get(i).size()-1; j++) {
        fill(faceColor);
        p1 = vertices.get(ASCIIfaces.get(i).get(j)).position;
        p2 = vertices.get(ASCIIfaces.get(i).get(j+1)).position;
        vertex((float)p1.x, (float)p1.y, (float)p1.z);
      }
      vertex((float)p2.x, (float)p2.y, (float)p2.z);
      endShape(CLOSE);
    }
  }
}

Mesh dooSabin(Mesh m) {
  HashMap<Vertex, ArrayList<Vertex>> vertsToNewVerts = new HashMap<Vertex, ArrayList<Vertex>>();
  HashMap<Edge, ArrayList<Vertex>> edgesToNewVerts = new HashMap<Edge, ArrayList<Vertex>>();
  HashMap<Vertex, Face> ogFaces = new HashMap<Vertex, Face>();

  ArrayList<Vertex> newVertices = new ArrayList<Vertex>();
  ArrayList<Face> newFaces = new ArrayList<Face>();
  // Face faces
  for (int i = 0; i < m.edges.size(); i++) {
    edgesToNewVerts.put(m.edges.get(i), new ArrayList<Vertex>());
  }
  for (int i = 0; i < m.vertices.size(); i++) {
    vertsToNewVerts.put(m.vertices.get(i), new ArrayList<Vertex>());
  }
  for (int i = 0; i < m.faces.size(); i++) {
    Face f = m.faces.get(i);
    Face fCopy = f.clone();

    for (int j = 0; j < fCopy.vertices.size(); j++) {
      Vertex v = f.vertices.get(j);
      Vertex v_F = fCopy.vertices.get(j);
      //println(v.position);
      v_F.removeEdgesNotIn(fCopy);
      ArrayList<Edge> edgesInF = new ArrayList<Edge>();// = f.edgesIncidentOn(v);
      for (int k = 0; k < mesh.edges.size(); k++) {
        if (mesh.edges.get(k).incidentFaces.contains(f) && mesh.edges.get(k).has(v)) {
          edgesInF.add(mesh.edges.get(k));
        }
      }
      //println(f.edges.size() + " " + f.vertices.size() + " " + edgesInF.size());
      PVector e1Center = edgesInF.get(0).center();
      PVector e2Center = edgesInF.get(1).center();
      edgesToNewVerts.get(edgesInF.get(0)).add(v_F);
      edgesToNewVerts.get(edgesInF.get(1)).add(v_F);
      vertsToNewVerts.get(v).add(v_F);
      v_F.position.add(PVector.add(f.center(), PVector.add(e1Center, e2Center)));
      v_F.position.mult(0.25);      
      ogFaces.put(v_F, f);
      newVertices.add(v_F);
    }
    //println(vertsToNewVerts.size());
    //println("OG Face has " + f.vertices.size() + " vertices and " + f.edges.size() + " edges");

    //println("Face has " + fCopy.vertices.size() + " vertices and " + fCopy.edges.size() + " edges");
    //println();
    newFaces.add(fCopy);
  }

  for (int i = 0; i < m.vertices.size(); i++) {
    ArrayList<Vertex> v_Fs = vertsToNewVerts.get(m.vertices.get(i));
    //println("Vertex made " + v_Fs.size() + " new vertices");
    if (v_Fs.size() > 2) {
      Face f = new Face();
      for (int j = 0; j < v_Fs.size()-1; j++) {
        Vertex v_F1 = v_Fs.get(j);
        for (int k = j+1; k < v_Fs.size(); k++) {
          Vertex v_F2 = v_Fs.get(k);
          if (ogFaces.get(v_F1).sharesEdgeWith(ogFaces.get(v_F2))) {
            Edge e = new Edge(v_F1, v_F2, false); 
            v_F1.connectedEdges.add(e);
            v_F2.connectedEdges.add(e);
            if (!f.edges.contains(e))
              f.edges.add(e);
            if (!f.vertices.contains(v_F1))
              f.vertices.add(v_F1);
            if (!f.vertices.contains(v_F2))
              f.vertices.add(v_F2);
          }
        }
      }
      newFaces.add(f);
    }
  }
  // edge faces

  for (int i = 0; i < mesh.edges.size(); i++) {
    Edge e = mesh.edges.get(i);
    if (edgesToNewVerts.containsKey(e)) {
      if (edgesToNewVerts.get(e).size() == 4) {
        Face f = new Face();
        for (int j = 0; j < edgesToNewVerts.get(e).size(); j++) {
          f.vertices.add(edgesToNewVerts.get(e).get(j));
        }
        for (int j = 0; j < f.vertices.size()-1; j++) {
          for (int k = j+1; k < f.vertices.size(); k++) {
            Vertex v1 = f.vertices.get(j);
            Vertex v2 = f.vertices.get(k);
            if (!v1.equals(v2)) {
              if (ogFaces.get(v1).equals(ogFaces.get(v2))) {
                //println(v1 + " " + v2 + " share an og face");
                Edge edge = new Edge(v1, v2, false);
                if (!f.edges.contains(edge)) {
                  f.edges.add(edge);
                }
                if (!v1.connectedEdges.contains(edge)) {
                  v1.connectedEdges.add(edge);
                }
                if (!v2.connectedEdges.contains(edge)) {
                  v2.connectedEdges.add(edge);
                }
              }
              for (int l = 0; l < mesh.vertices.size(); l++) {
                if (vertsToNewVerts.get(mesh.vertices.get(l)).contains(v1) && 
                  vertsToNewVerts.get(mesh.vertices.get(l)).contains(v2)) {
                  //println(v1 + " " + v2 + " share an og vertex");
                  Edge edge = new Edge(v1, v2, false);
                  if (!f.edges.contains(edge)) {
                    f.edges.add(edge);
                    //println("adding that edge");
                  }
                  if (!v1.connectedEdges.contains(edge)) {
                    v1.connectedEdges.add(edge);
                  }
                  if (!v2.connectedEdges.contains(edge)) {
                    v2.connectedEdges.add(edge);
                  }
                }
              }
            }
          }
        }
        //println(f.vertices.size() + " " +  f.edges.size());
        newFaces.add(f);
      }
    }
  }
  ArrayList<ArrayList<Integer>> ASCIIfaces = new ArrayList<ArrayList<Integer>>();
  for (int i = 0; i < newFaces.size(); i++) {
    ArrayList<Integer> asciiface = new ArrayList<Integer>();
    Face f = newFaces.get(i);    
    Edge e = f.edges.get(0);
    if(f.vertices.size() != f.edges.size()) continue;
    asciiface.add(newVertices.indexOf(e.p1));
    asciiface.add(newVertices.indexOf(e.p2));
    Vertex nextV, last = e.p1, current = e.p2;
    //println(i + " " +f.vertices.size() + " " + f.edges.size());
    while (!(nextV = f.getNextPoint(last, current)).equals(e.p1)) {
      last= current;
      current= nextV;
      asciiface.add(newVertices.indexOf(nextV));
    }
    ASCIIfaces.add(asciiface);
  }
  //println(newFaces.size());
  return new Mesh(newVertices, ASCIIfaces);
}
public Mesh createFromFile(String fileName, float scale) {
  ArrayList<Vertex> vertices = new ArrayList<Vertex>();
  ArrayList<ArrayList<Integer>> ASCIIFaces = new ArrayList<ArrayList<Integer>>();
  String line;          
  StringTokenizer st;
  int lineNum = 0;
  int numVertices;
  try {
    FileReader file = new FileReader(fileName);
    BufferedReader fileReader = new BufferedReader(file);

    fileReader.readLine();
    line = fileReader.readLine();
    st = new StringTokenizer(line);
    numVertices = Integer.parseInt(st.nextToken());

    while ((line = fileReader.readLine()) != null) {
      st = new StringTokenizer(line);
      if (lineNum < numVertices) {
        Vertex v = new Vertex(Float.parseFloat(st.nextToken()) * scale, 
          Float.parseFloat(st.nextToken()) * scale, Float.parseFloat(st.nextToken()) * scale);
        vertices.add(v);
      } else {
        st.nextToken();
        ArrayList<Integer> asciiface = new ArrayList<Integer>();
        while (st.hasMoreTokens()) {
          asciiface.add(Integer.parseInt(st.nextToken()));
        }
        ASCIIFaces.add(asciiface);
      }
      lineNum++;
    }
    fileReader.close();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  return new Mesh(vertices, ASCIIFaces);
}