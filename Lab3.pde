import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

PeasyCam cam;

final int numApproxPoints = 100;
final int pointDistance = 150;

ArrayList<Curve> curves = new ArrayList<Curve>();
Mesh mesh;

double[] currentCurveArgs;

Rectangle goButton;
Rectangle reset;
Rectangle addRow, removeRow, addCol, removeCol;

RadioButtons operations;
RadioButtons curveType;

TextInput uvResolution;

CheckBox close1, close2;

//MoveablePoint p = new MoveablePoint(0, 0, 0);
boolean adjustingPoint = false;
boolean holding = false;
int lastPointSelected = 0;

ArrayList<ArrayList<MoveablePoint>> points = new ArrayList<ArrayList<MoveablePoint>>();

void start() {
  operations = new RadioButtons(new String[] {"Generate surface", "Subdivice surface"}, 
    width - 210, 20, 20, 10);
  reset = new Rectangle(width - 110, 20, 100, 30);
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

  currentCurveArgs = new double[]{numApproxPoints, 100};
  populatePoints(4, 4);
  populateCurves();
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
  } else {
    operations.mousePressed();  
    curveType.mousePressed();
    uvResolution.mousePressed();
    close1.mousePressed();
    close2.mousePressed();
    if (addCol.contains(mouseX, mouseY)) {
      AddCol();
    }
    if (addRow.contains(mouseX, mouseY)) {
      AddRow();
    }
    if (removeRow.contains(mouseX, mouseY)) {
      RemoveRow();
    }
    if (removeCol.contains(mouseX, mouseY)) {
      RemoveCol();
    }   
    CheckPointsClicked();
    CheckGo();
    if (operations.selectedIndex == 0) {
    } else if (operations.selectedIndex == 1) {
    } else if (operations.selectedIndex == 2) {
    }
  }
}
void mouseDragged() {
  boolean changed = false;
  for (int i = 0; i < points.size(); i++) {
    for (int j = 0; j < points.get(i).size(); j++) {
      PVector oldv = points.get(i).get(j).v;
      points.get(i).get(j).mouseDragged(cam);
      if (oldv != points.get(i).get(j).v) changed = true;
    }
  }

  if (changed) {
    populateCurves();
    approximateCurves();
  }
}

void mouseReleased() {
  holding = false;
  adjustingPoint = false;
  cam.setActive(true);
  for (int i = 0; i < points.size(); i++) {
    for (int j = 0; j < points.get(i).size(); j++) {
      points.get(i).get(j).mouseReleased();
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
  } else {
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
    //p.draw();
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
    }
  } else {
    fill(255);
    stroke(0);
    reset.draw();
    fill(0);
    textSize(28);
    text("Reset", width - 100, 45);
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
    mesh = BezierSurface(toPVectors(points), 100);
    mesh.GenerateASCIIFile();
    if (operations.selectedIndex == 0) {
    } else if (operations.selectedIndex == 1) {
    } else if (operations.selectedIndex == 2) {
    }
  }
}
void CheckReset() {
  if (reset.contains(mouseX, mouseY)) {
    cam.reset();
    cam.setActive(false);
    mesh = null;
  }
}
void keyPressed() {
  if ((key == 'x' || key == 'y' || key == 'z') && holding) {
    adjustingPoint = true;
    cam.setActive(false);
  }
  if (mesh == null) {
    for (int i = 0; i < points.size(); i++) {
      for (int j = 0; j < points.get(i).size(); j++) {
        points.get(i).get(j).keyPressed();
      }
    }
    uvResolution.mousePressed();
    if (operations.selectedIndex == 0) {
    } else if (operations.selectedIndex == 1) {
    }
  }
}
ArrayList<PVector> toPVector(ArrayList<MoveablePoint> p) {
  ArrayList<PVector> l = new ArrayList<PVector>();
  for (int i = 0; i < p.size(); i++) {
    l.add(p.get(i).v);
  }
  return l;
}
ArrayList<ArrayList<PVector>> toPVectors(ArrayList<ArrayList<MoveablePoint>> points) {
  ArrayList<ArrayList<PVector>> p = new ArrayList<ArrayList<PVector>>();
  for (int i = 0; i < points.size(); i++) {
    p.add(new ArrayList<PVector>());
    for (int j = 0; j < points.get(i).size(); j++) {
      p.get(i).add(points.get(i).get(j).v);
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
void populateCurves() {
  curves = new ArrayList<Curve>();
  for (int i = 0; i < points.size(); i++) {
    Curve c = new BezierCurve();
    for (int j = 0; j < points.get(i).size(); j++) {
      c.controlPoints.add(points.get(i).get(j).v);
    }
    curves.add(c);
  }
  for (int i = 0; i < points.get(0).size(); i++) {
    Curve c = new BezierCurve();
    for (int j = 0; j < points.size(); j++) {
      c.controlPoints.add(points.get(j).get(i).v);
    }
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
  populateCurves();
  approximateCurves();
}
void RemoveRow() {
  if (points.get(0).size() <= 4) return;
  for (int i = 0; i < points.size(); i++) {
    points.get(i).remove(points.get(i).size() - 1);
  }
  populateCurves();
  approximateCurves();
}
void AddCol() {
  points.add(new ArrayList<MoveablePoint>());
  for (int i = 0; i < points.get(0).size(); i++) {
    points.get(points.size() - 1).add(new MoveablePoint((points.size() - 1) * pointDistance, 0, i * -pointDistance));
  }
  populateCurves();
  approximateCurves();
}
void RemoveCol() {
  if (points.size() <= 4) return;
  points.remove(points.size() - 1);
  populateCurves();
  approximateCurves();
}