void draw_path() {

  pointPaths = grp.getPointsInPaths();
  for (int i = 0; i<pointPaths.length; i++) {
    if (pointPaths[i] != null) {
      strokeWeight(.1);
      stroke(#FF0000);

      beginShape();
      for (int j = 0; j<pointPaths[i].length; j++) {
        vertex(pointPaths[i][j].x, pointPaths[i][j].y);
        fill(#FF0000);
        ellipse(pointPaths[i][j].x, pointPaths[i][j].y, 2, 2);
        noFill();
      }
      endShape();
    }
  }
}