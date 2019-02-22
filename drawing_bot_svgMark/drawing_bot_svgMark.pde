import geomerative.*;
import processing.serial.*;
import static javax.swing.JOptionPane.*;

RShape grp, temp;
RPoint[][] pointPaths;
Serial myPort;

boolean debug = true;
float scale=1, scale_start=0, moveX, moveY, xOffset, yOffset;
boolean locked;
String[] gcodes, setting;
boolean oked = true;
PrintWriter output, conf;
boolean posMoved = false;
boolean serial_out=false;
int forLoop = 0;
float angle=0;
boolean file_selected=false;
String COMx, COMlist = "";
boolean GRBL=true;
int page=0;
int button_width = 150, button_height = 50;
boolean first_run = false;
boolean invert_x=false, invert_y=false;
int pen_up = 190, pen_down = 160, feed_rate=8000;


void setup() {
  size(620, 760);
  RG.init(this);
  RG.setDpi(300);
  RG.ignoreStyles(true);
  frameRate(500);

  output = createWriter("positions.txt");
  setting = loadStrings("configuration.txt");

  pen_up = int(setting[0]);
  pen_down = int(setting[1]);
  feed_rate = int(setting[2]);
  invert_x = boolean(setting[3]);
  invert_y = boolean(setting[4]);
  serial_select();
}

void draw() {
  if (page == 0) {    //welcom page
    background(204);
    textAlign(LEFT);
    textSize(12);
    draw_grid();

    textAlign(CENTER, CENTER);
    textSize(52);
    fill(0);
    text("DXF to GCODE \n sender and maker", width/2, height/3);
    rectMode(CENTER);
    stroke(#89A3FF);
    strokeWeight(6);
    
    textAlign(LEFT, LEFT);
    textSize(20);
    fill(#06554A);
    text("Optimized by Mark Lam", 3, 20);
    
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    stroke(#89A3FF);
    strokeWeight(6);

    button_width = 150; 
    button_height = 50;
    fill(overRect(width/2, int((float)height*.7), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(width/2, (float)height*.7, button_width, button_height, 0, 10, 0, 10);
    fill(overRect(width/2, int((float)height*.8), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(width/2, (float)height*.8, button_width, button_height, 0, 10, 0, 10);

    textSize(14);
    fill(0);
    text("SETTING", width/2, (float)height*.8);
    text("START", width/2, (float)height*.7);
  } else if (page ==1) {    //load and display the dxf, ready to print
    if (!file_selected) {
      if (!first_run) {
        selectInput("Select a file to process:", "fileSelected");
        first_run = true;
      }
    } else {
      background(204);
      textAlign(LEFT);
      textSize(12);
      fill(#009900);
      text("Drag the mouse to move and zoom, use R or r to rotate", 0, 24);
      draw_grid();
      draw_path();
      rectMode(CENTER);
      stroke(#89A3FF);
      strokeWeight(6);
      button_width = 80; 
      button_height = 50;
      fill(overRect(int((float)width*.9), int((float)height*.9), button_width, button_height)?#D6CF49:color(#FFFCA7));
      rect(int((float)width*.9), (float)height*.9, button_width, button_height, 0, 10, 0, 10);
      textSize(14);
      textAlign(CENTER, CENTER);
      fill(0);
      text("BACK", int((float)width*.9), (float)height*.9);
    }
  }
  if (page == 2) {    //setting
    background(204);
    textAlign(LEFT);
    textSize(12);
    draw_grid();

    rectMode(CENTER);
    stroke(#89A3FF);
    strokeWeight(6);

    button_width = 80; 
    button_height = 50;
    fill(overRect(int((float)width*.5), int((float)height*.1), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(int((float)width*.5), (float)height*.1, button_width, button_height, 0, 10, 0, 10);
    fill(overRect(int((float)width*.5), int((float)height*.2), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(int((float)width*.5), (float)height*.2, button_width, button_height, 0, 10, 0, 10);
    fill(overRect(int((float)width*.5), int((float)height*.3), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(int((float)width*.5), (float)height*.3, button_width, button_height, 0, 10, 0, 10);

    fill(overRect(int((float)width*.7), int((float)height*.1), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(int((float)width*.7), (float)height*.1, button_width, button_height, 0, 10, 0, 10);
    fill(overRect(int((float)width*.7), int((float)height*.2), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(int((float)width*.7), (float)height*.2, button_width, button_height, 0, 10, 0, 10);
    fill(overRect(int((float)width*.7), int((float)height*.3), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(int((float)width*.7), (float)height*.3, button_width, button_height, 0, 10, 0, 10);

    fill(overRect(int((float)width*.9), int((float)height*.9), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(int((float)width*.9), (float)height*.9, button_width, button_height, 0, 10, 0, 10);

    button_width = 50; 
    button_height = 50;
    fill(overRect(int((float)width*.3), int((float)height*.5), button_width, button_height)?#D6CF49:color(#FFFCA7));
    stroke(invert_x?0:#89A3FF );
    rect(int((float)width*.3), (float)height*.5, button_width, button_height, 0, 10, 0, 10);
    fill(overRect(int((float)width*.3), int((float)height*.6), button_width, button_height)?#D6CF49:color(#FFFCA7));
    stroke(invert_y?0:#89A3FF );
    rect(int((float)width*.3), (float)height*.6, button_width, button_height, 0, 10, 0, 10);

    stroke(#89A3FF);
    fill(overRect(int((float)width*.5), int((float)height*.7), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(int((float)width*.5), (float)height*.7, button_width, button_height, 0, 10, 0, 10);
    fill(overRect(int((float)width*.5), int((float)height*.8), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(int((float)width*.5), (float)height*.8, button_width, button_height, 0, 10, 0, 10);
    fill(overRect(int((float)width*.4), int((float)height*.8), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(int((float)width*.4), (float)height*.8, button_width, button_height, 0, 10, 0, 10);
    fill(overRect(int((float)width*.6), int((float)height*.8), button_width, button_height)?#D6CF49:color(#FFFCA7));
    rect(int((float)width*.6), (float)height*.8, button_width, button_height, 0, 10, 0, 10);


    textSize(18);
    textAlign(CENTER, CENTER);
    fill(0);
    text("pen up\n"+pen_up, int((float)width*.3), (float)height*.1);
    text("pen down\n"+pen_down, int((float)width*.3), (float)height*.2);
    text("feed rate\n"+feed_rate, int((float)width*.3), (float)height*.3);

    text("+", int((float)width*.5), (float)height*.1);
    text("+", int((float)width*.5), (float)height*.2);
    text("+", int((float)width*.5), (float)height*.3);

    text("-", int((float)width*.7), (float)height*.1);
    text("-", int((float)width*.7), (float)height*.2);
    text("-", int((float)width*.7), (float)height*.3);

    text("BACK", int((float)width*.9), (float)height*.9);

    text("Invert X axis", int((float)width*.45), (float)height*.5);
    text("Invert Y axis", int((float)width*.45), (float)height*.6);

    textSize(12);
    text("Y+", int((float)width*.5), (float)height*.7);
    text("Y-", int((float)width*.5), (float)height*.8);
    text("X-", int((float)width*.4), (float)height*.8);
    text("X+", int((float)width*.6), (float)height*.8);
  } else if (page == 3 ){
    to_serial_output();   //printing
    println(nf(float(forLoop)/float(gcodes.length-1)*100)+"% Fr.:"+frameRate);
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    if (debug) println("Window was closed or the user hit cancel.");
  } else {
    if (debug) println("User selected " + selection.getAbsolutePath());
  }
  grp = RG.loadShape(selection.getAbsolutePath());
  file_selected = true;
}

void mousePressed() {
  if (page == 0) {
    if (overRect(width/2, int((float)height*.7), button_width, button_height)) page =1;
    if (overRect(width/2, int((float)height*.8), button_width, button_height)) page =2;
  } else if (page == 1) {
    locked = true;
    xOffset = mouseX-moveX; 
    yOffset = mouseY-moveY;
    if (overRect(int((float)width*.9), int((float)height*.9), button_width, button_height) && file_selected && first_run) page = 0;
  } else if (page == 2) {
    if (overRect(int((float)width*.5), int((float)height*.1), button_width, button_height)) {
      pen_up+=3; 
      if (oked) {
        myPort.write("M03 S"+ pen_up +'\n');
        println("M03 S"+ pen_up +'\n');
        oked = false;
      }
    }
    if (overRect(int((float)width*.5), int((float)height*.2), button_width, button_height)) {
      pen_down+=3;
      if (oked) {
        myPort.write("M03 S"+ pen_down +'\n');
        println("M03 S"+ pen_down +'\n');
        oked = false;
      }
    }
    if (overRect(int((float)width*.5), int((float)height*.3), button_width, button_height)) feed_rate+=200;

    if (overRect(int((float)width*.7), int((float)height*.1), button_width, button_height)) {
      pen_up-=3;
      if (oked) {
        myPort.write("M03 S"+ pen_up +'\n');
        println("M03 S"+ pen_up +'\n');
        oked = false;
      }
    }
    if (overRect(int((float)width*.7), int((float)height*.2), button_width, button_height)) {
      pen_down-=3;
      if (oked) {
        myPort.write("M03 S"+ pen_down +'\n');
        println("M03 S"+ pen_down +'\n');
        oked = false;
      }
    }
    if (overRect(int((float)width*.7), int((float)height*.3), button_width, button_height)) feed_rate-=200;

    if (overRect(int((float)width*.9), int((float)height*.9), button_width, button_height)) {
      conf = createWriter("configuration.txt");
      conf.println(pen_up);
      conf.println(pen_down);
      conf.println(feed_rate);
      conf.println(invert_x);
      conf.println(invert_y);
      conf.flush();
      conf.close();
      page = 0;
    }

    if (overRect(int((float)width*.3), int((float)height*.5), button_width, button_height)) { 
      invert_x = !invert_x;
      if (!invert_x && !invert_y) myPort.write("$3 = " + 0 + '\n');
      if (!invert_x && invert_y) myPort.write("$3 = " + 2+ '\n');
      if (invert_x && !invert_y) myPort.write("$3 = " + 1+ '\n');
      if (invert_x && invert_y) myPort.write("$3 = " + 3+ '\n');
    }

    if (overRect(int((float)width*.3), int((float)height*.6), button_width, button_height)) {
      invert_y = !invert_y;
      if (!invert_x && !invert_y) myPort.write("$3 = " + 0+ '\n');
      if (!invert_x && invert_y) myPort.write("$3 = " + 2+ '\n');
      if (invert_x && !invert_y) myPort.write("$3 = " + 1+ '\n');
      if (invert_x && invert_y) myPort.write("$3 = " + 3+ '\n');
    }

    if (overRect(int((float)width*.5), int((float)height*.7), button_width, button_height)) {
      myPort.write("G91 \n G0 Y10 \n G90 \n");
      println("G91 \n G0 Y10 \n G90 \n");
    }
    if (overRect(int((float)width*.5), int((float)height*.8), button_width, button_height)) {
      myPort.write("G91 \n G0 Y-10 \n G90 \n");
      println("G91 \n G0 Y-10 \n G90 \n");
    }
    if (overRect(int((float)width*.4), int((float)height*.8), button_width, button_height)) {
      myPort.write("G91 \n G0 X-10 \n G90 \n");
      println("G91 \n G0 X-10 \n G90 \n");
    }
    if (overRect(int((float)width*.6), int((float)height*.8), button_width, button_height)) {
      myPort.write("G91 \n G0 X10 \n G90 \n");
      println("G91 \n G0 X10 \n G90 \n");
    }
  }
}

void mouseDragged() {
  if (page == 1) {
    if (locked) {
      moveX = mouseX-xOffset; 
      moveY = mouseY-yOffset;
    }
  }
}

void mouseReleased() {
  if (page == 1) {
    locked = false;
    if (file_selected)grp.translate(moveX, moveY);
    moveX=0;
    moveY=0;
  }
}


void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scale=1+0.05*e;
  grp.scale(scale, grp.getBottomLeft().x, grp.getBottomLeft().y);
}

void keyPressed() {
  if (page == 1) {
    if (keyCode == ENTER) {
      output_gcode();
      forLoop = 0;
      page = 3;
    }
    if (key =='R' || key == 'r') {
      angle = (angle>=3)?0:angle+1;
      grp.rotate(PI/2, grp.getCenter());
    }
  }
}

void draw_grid() {
  stroke(0);
  for (int x=1; x<=37; x++) {
    strokeWeight(0.3);
    if (x %5 ==0) {
      strokeWeight(1);
      fill(0);
      text(x, 0, x*height/38);
    }
    line(0, x*height/38, width, x*height/38);
  }

  for (int y=1; y<=30; y++) {
    strokeWeight(0.3);
    if (y %5 ==0) {
      strokeWeight(1);
      fill(0);
      text(y, y*width/31, 12);
    }
    line( y*width/31, 0, y*width/31, height);
  }
  noFill();
  strokeWeight(2);
  stroke(#00CB23);
  rectMode(LEFT);
  rect(0, 0, 210*2, 297*2);
  rect(0, 0, 297*2, 210*2);
  stroke(#00AAFC);
  rect(0, 0, 297/2*2, 210*2);
  rect(0, 0, 210*2, 297/2*2);
}


boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x-width/2 && mouseX <= x+width/2 && 
    mouseY >= y-height/2 && mouseY <= y+height/2) {
    return true;
  } else {
    return false;
  }
}