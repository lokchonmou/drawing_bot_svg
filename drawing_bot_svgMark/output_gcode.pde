void output_gcode() {
  draw_path();

  //output.println("$X");
  output.println("G90");
  output.println("$120=1000");
  output.println("$121=1000");
  output.println("M03 S"+pen_up);
  
  output.println("$30=255");
  output.println("$32=0");
  output.println("$31=0");
  output.println("$100=78.740");
  output.println("$101=78.740");
  output.println("$102=78.740");
  output.println("$110=8000.000");
  output.println("$111=8000.000");
  output.println("$112=3000.000");
  output.println("$120=500.000");
  output.println("$121=500.000");

  moveX = grp.getBottomLeft().x; 
  moveY = grp.getBottomLeft().y;
  grp.translate(-moveX, moveY);
  grp.scale(11.81, grp.getBottomLeft().x, grp.getBottomLeft().y);

  pointPaths = grp.getPointsInPaths();
  for (int i = 0; i<pointPaths.length; i++) {
    if (pointPaths[i] != null) {
      for (int j = 0; j<pointPaths[i].length; j++) {
        pointPaths[i][j].x = (pointPaths[i][j].x)/2.0/11.81+moveX/2.0;
        pointPaths[i][j].y = (pointPaths[i][j].y)/2.0/11.81+moveY/2.0;
        
        output.println("G1 " + "X"+ pointPaths[i][j].x + " Y" +pointPaths[i][j].y + " F"+feed_rate); // Write the coordinate to the file
        if (j == 0) output.println("M03 S"+pen_down);
        posMoved = true;
      }
    }

    output.println("M03 S"+pen_up);
    posMoved = false;
  }
  output.println("G1 X0 Y0 F2500");
  output.flush();
  output.close();
  if (debug) println("SAVED");
  grp.scale(1.0/11.81, grp.getBottomLeft().x, grp.getBottomLeft().y);
  grp.translate(moveX, -moveY);
}
