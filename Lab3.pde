import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

import java.io.*;
import java.util.*;
PeasyCam cam;

final int numApproxPoints = 100;
final int pointDistance = 150;

ArrayList<Curve> curves = new ArrayList<Curve>();
Mesh mesh;

double[] currentCurveArgs;

Rectangle goButton;
Rectangle reset;
Rectangle addRow, removeRow, addCol, removeCol;
Rectangle loadCube, loadCone, loadLastSurface, loadSphere, loadTetrahedron;
Rectangle catmullClark, loop, dooSabin;

RadioButtons operations;
RadioButtons curveType;

TextInput uvResolution;

CheckBox close1, close2;

boolean adjustingPoint = false;
boolean holding = false;
int lastPointSelected = 0;

ArrayList<ArrayList<MoveablePoint>> points = new ArrayList<ArrayList<MoveablePoint>>();

void start() {
  operations = new RadioButtons(new String[] {"Generate surface", "Load .OFF"}, 
    width - 210, 20, 20, 10);
  reset = new Rectangle(width - 110, 20, 100, 30);  
  catmullClark = new Rectangle(width - 210, 130, 150, 50);
  loop = new Rectangle(width - 210, 190, 150, 50);
  dooSabin = new Rectangle(width - 210, 250, 150, 50);

  curveType = new RadioButtons(new String[] {"Bezier", "Cubic BSpline"}, 
    width - 210, 100, 20, 10);
  uvResolution = new TextInput(width - 210, 180, 200, 30);
  close1 = new CheckBox(width - 210, 260, 20);
  close2 = new CheckBox(width - 210, 300, 20);
  addRow = new Rectangle(width - 210, 350, 80, 40);
  addCol = new Rectangle(width - 120, 350, 80, 40);
  removeRow = new Rectangle(width - 210, 400, 80, 40);
  removeCol = new Rectangle(width - 120, 400, 80, 40);
  goButton = new Rectangle(width - 170, 450, 100, 50);
  loadCube = new Rectangle(width - 210, 180, 100, 30);  
  loadCone = new Rectangle(width - 105, 180, 100, 30);
  loadSphere = new Rectangle(width - 210, 220, 100, 30);
  loadTetrahedron = new Rectangle(width - 105, 220, 100, 30);
  loadLastSurface = new Rectangle(width - 210, 260, 100, 30);
  currentCurveArgs = new double[]{numApproxPoints, 4};
  populatePoints(4, 4);
  if (curveType.selectedIndex == 0)
    populateCurvesBezier();
  else if (curveType.selectedIndex == 1)
    populateCurvesBSpline();
  approximateCurves();
}

void setup() {
  size(1000, 600, P3D);
  cam = new PeasyCam(this, 200, 0, -200, 350);
  cam.setActive(true);
  cam.reset();
  cam.setMinimumDistance(350);
  cam.setMaximumDistance(350); 
  surface.setResizable(true);
  noSmooth();
  background(0);
}

void mousePressed() {
  holding = true;
  if (mesh != null) {
    CheckReset();
    if (catmullClark.contains(mouseX, mouseY)) {
      mesh = catmullClark(mesh);
    } else if (dooSabin.contains(mouseX, mouseY)) {
      mesh = dooSabin(mesh);
    } else if (loop.contains(mouseX, mouseY)) {
      mesh = loop(mesh);
    }
  } else {
    operations.mousePressed();  
    if (operations.selectedIndex == 0) {
      int lastCurveSelected = curveType.selectedIndex;
      curveType.mousePressed();
      if (curveType.selectedIndex != lastCurveSelected) {
        populateCurvesBSpline();
        approximateCurves();
      }
      uvResolution.mousePressed();
      boolean beforeClose1 = close1.checked;
      boolean beforeClose2 = close2.checked;
      close1.mousePressed();
      close2.mousePressed();
      if(close1.checked && close2.checked) close2.checked = false;
      if(beforeClose1 != close1.checked || beforeClose2 != close2.checked){
        if(curveType.selectedIndex == 0)
          populateCurvesBezier();
        else if(curveType.selectedIndex == 1)
          populateCurvesBSpline();
        approximateCurves();
      }
      if (addCol.contains(mouseX, mouseY)) {
        close1.checked = false;
        close2.checked = false;
        AddCol();
      }
      if (addRow.contains(mouseX, mouseY)) {
        close1.checked = false;
        close2.checked = false;
        AddRow();
      }
      if (removeRow.contains(mouseX, mouseY)) {
        close1.checked = false;
        close2.checked = false;
        RemoveRow();
      }
      if (removeCol.contains(mouseX, mouseY)) {
        close1.checked = false;
        close2.checked = false;
        RemoveCol();
      }   
      CheckPointsClicked();
      CheckGo();
    } else if (operations.selectedIndex == 1) {
      if (loadCube.contains(mouseX, mouseY)) {
        mesh = createFromFile(sketchPath("") + "cube.off", 100);
      }
      if (loadCone.contains(mouseX, mouseY)) {
        mesh = createFromFile(sketchPath("") + "cone.off", 100);
      }
      if (loadLastSurface.contains(mouseX, mouseY)) {
        mesh = createFromFile(sketchPath("") + "mesh.off", 1);
      }
      if (loadSphere.contains(mouseX, mouseY)) {
        mesh = createFromFile(sketchPath("") + "sphere2.off", 100);
      }
      if (loadTetrahedron.contains(mouseX, mouseY)) {
        mesh = createFromFile(sketchPath("") + "tetrahedron.off", 100);
      }
    }
  }
}
void mouseDragged() {
  if (operations.selectedIndex == 0) {
    boolean changed = false;
    for (int i = 0; i < points.size(); i++) {
      for (int j = 0; j < points.get(i).size(); j++) {
        PVector oldv = points.get(i).get(j).v;
        points.get(i).get(j).mouseDragged();
        if (oldv != points.get(i).get(j).v) changed = true;
      }
    }

    if (changed) {
      if (curveType.selectedIndex == 0)
        populateCurvesBezier();
      else if (curveType.selectedIndex == 1)
        populateCurvesBSpline();
      approximateCurves();
    }
  }
}

void mouseReleased() {
  if (operations.selectedIndex == 0) {
    holding = false;
    adjustingPoint = false;
    cam.setActive(true);
    for (int i = 0; i < points.size(); i++) {
      for (int j = 0; j < points.get(i).size(); j++) {
        points.get(i).get(j).mouseReleased();
      }
    }
  }
}

void draw() {
  lights();
  background(0);
  stroke(255, 0, 0);
  line(-1000, 0, 0, 1000, 0, 0);
  stroke(0, 255, 0);
  line(0, -1000, 0, 0, 1000, 0);
  stroke(0, 0, 255);
  line(0, 0, -1000, 0, 0, 1000);


  if (mesh != null) {
    //stroke(255);
    noStroke();
    mesh.draw();
  } else if (operations.selectedIndex == 0) {
    for (int i = 0; i < points.size(); i++) {
      for (int j = 0; j < points.get(i).size(); j++) {
        noStroke();
        points.get(i).get(j).draw();  
        stroke(0, 0, 255);
        fill(255);
        textSize(20);
        if (points.get(i).get(j).selected) lastPointSelected = i;
      }
    }

    stroke(130, 170, 0);
    for (int i = 0; i < curves.size(); i++) {
      curves.get(i).draw();
    }
  }

  cam.beginHUD();
  if (mesh == null) {
    fill(255);
    operations.draw();
    if (operations.selectedIndex == 0) {
      curveType.draw();
      fill(255);
      uvResolution.draw();
      fill(255);
      stroke(0);
      close1.draw();
      close2.draw();
      addCol.draw();
      addRow.draw();
      removeRow.draw();
      removeCol.draw();    
      goButton.draw();    

      textSize(22);
      fill(255);    
      text("UV resolution", width - 170, 170);
      text("Close one dir", width - 185, 280);
      text("Close other dir", width - 185, 320);
      fill(0);
      text("row++", width - 205, 380);
      text("row--", width - 205, 430);
      text("col++", width - 110, 380);
      text("col--", width - 110, 430);
      textSize(36);
      text("Go", width - 150, 490);
    } else if (operations.selectedIndex == 1) {
      fill(255);
      stroke(0);
      loadCube.draw();
      loadCone.draw();
      loadSphere.draw();
      loadTetrahedron.draw();
      loadLastSurface.draw();

      textSize(22);
      fill(0);
      text("Cube", width - 190, 205);
      text("Cone", width - 80, 205);
      text("Sphere", width - 190, 245);
      text("Tetrahedron", width - 104, 245);
      text("Surface", width - 205, 285);
    }
  } else {
    fill(255);
    stroke(0);
    reset.draw();
    catmullClark.draw();
    loop.draw();
    dooSabin.draw();
    fill(0);
    textSize(28);
    text("Reset", width - 100, 45);
    textSize(20);
    text("Catmull-", width - 180, 155);
    text("Clark", width - 170, 175);
    textSize(36);
    text("Loop", width - 175, 230);
    textSize(30);
    text("DooSabin", width - 204, 290);
  }
  cam.endHUD();
}


void CheckPointsClicked() {
  for (int i = 0; i < points.size(); i++) {
    for (int j = 0; j < points.get(i).size(); j++) {
      points.get(i).get(j).mousePressed(cam);
    }
  }
}

void CheckGo() {
  if (goButton.contains(mouseX, mouseY)) {
    if (curveType.selectedIndex == 0)
      mesh = BezierSurface(toVertices(points), Integer.parseInt(uvResolution.text), 
        close1.checked, close2.checked);
    else if (curveType.selectedIndex == 1)
      mesh = BSplineSurface(toVertices(points), Integer.parseInt(uvResolution.text), (int)currentCurveArgs[1], 
        close1.checked, close2.checked);

    mesh.GenerateASCIIFile();
  }
}
void CheckReset() {
  if (reset.contains(mouseX, mouseY)) {
    mesh = null;
  }
}
void keyPressed() {
  if ((key == 'x' || key == 'y' || key == 'z') && holding) {
    adjustingPoint = true;
    cam.setActive(false);
  }
  if (mesh == null && operations.selectedIndex == 0) {
    for (int i = 0; i < points.size(); i++) {
      for (int j = 0; j < points.get(i).size(); j++) {
        points.get(i).get(j).keyPressed();
      }
    }
    uvResolution.keyPressed();
  }
}
ArrayList<Vertex> toVertex(ArrayList<MoveablePoint> p) {
  ArrayList<Vertex> l = new ArrayList<Vertex>();
  for (int i = 0; i < p.size(); i++) {
    l.add(new Vertex(p.get(i).v));
  }
  return l;
}
ArrayList<ArrayList<Vertex>> toVertices(ArrayList<ArrayList<MoveablePoint>> points) {
  ArrayList<ArrayList<Vertex>> p = new ArrayList<ArrayList<Vertex>>();
  for (int i = 0; i < points.size(); i++) {
    p.add(new ArrayList<Vertex>());
    for (int j = 0; j < points.get(i).size(); j++) {
      p.get(i).add(new Vertex(points.get(i).get(j).v));
    }
  } 
  return p;
}
void populatePoints(int w, int h) {
  points = new ArrayList<ArrayList<MoveablePoint>>();
  for (int i = 0; i < w; i++) {
    points.add(new ArrayList<MoveablePoint>());
    for (int j = 0; j < h; j++) {
      points.get(i).add(new MoveablePoint(i * pointDistance, 0, j * -pointDistance));
    }
  }
}
void populateCurvesBezier() {
  curves = new ArrayList<Curve>();
  for (int i = 0; i < points.size(); i++) {
    Curve c = new BezierCurve();
    for (int j = 0; j < points.get(i).size(); j++) {
      c.controlPoints.add(points.get(i).get(j).v);
    }
    c.closed = close1.checked;
    curves.add(c);
  }
  for (int i = 0; i < points.get(0).size(); i++) {
    Curve c = new BezierCurve();
    for (int j = 0; j < points.size(); j++) {
      c.controlPoints.add(points.get(j).get(i).v);
    }
    c.closed = close2.checked;
    curves.add(c);
  }
}
void populateCurvesBSpline() {
  curves = new ArrayList<Curve>();
  for (int i = 0; i < points.size(); i++) {
    Curve c = new BSpline();
    for (int j = 0; j < points.get(i).size(); j++) {
      c.controlPoints.add(points.get(i).get(j).v);
    }
    c.closed = close1.checked;
    curves.add(c);
  }
  for (int i = 0; i < points.get(0).size(); i++) {
    Curve c = new BSpline();
    for (int j = 0; j < points.size(); j++) {
      c.controlPoints.add(points.get(j).get(i).v);
    }
    c.closed = close2.checked;
    curves.add(c);
  }
}
void approximateCurves() {
  for (int i = 0; i < curves.size(); i++) {
    curves.get(i).approximateCurve(currentCurveArgs);
  }
}
void drawCurves() {
  for (int i = 0; i < curves.size(); i++) {
    curves.get(i).draw();
  }
}
void AddRow() {
  for (int i = 0; i < points.size(); i++) {
    points.get(i).add(new MoveablePoint(i * pointDistance, 0, points.get(i).size() * -pointDistance));
  }
  if (curveType.selectedIndex == 0)
    populateCurvesBezier();
  else if (curveType.selectedIndex == 1)
    populateCurvesBSpline();
  approximateCurves();
}
void RemoveRow() {
  if (points.get(0).size() <= 4) return;
  for (int i = 0; i < points.size(); i++) {
    points.get(i).remove(points.get(i).size() - 1);
  }
  if (curveType.selectedIndex == 0)
    populateCurvesBezier();
  else if (curveType.selectedIndex == 1)
    populateCurvesBSpline();
  approximateCurves();
}
void AddCol() {
  points.add(new ArrayList<MoveablePoint>());
  for (int i = 0; i < points.get(0).size(); i++) {
    points.get(points.size() - 1).add(new MoveablePoint((points.size() - 1) * pointDistance, 0, i * -pointDistance));
  }
  if (curveType.selectedIndex == 0)
    populateCurvesBezier();
  else if (curveType.selectedIndex == 1)
    populateCurvesBSpline();
  approximateCurves();
}
void RemoveCol() {
  if (points.size() <= 4) return;
  points.remove(points.size() - 1);
  if (curveType.selectedIndex == 0)
    populateCurvesBezier();
  else if (curveType.selectedIndex == 1)
    populateCurvesBSpline();
  approximateCurves();
}