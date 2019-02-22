boolean last_code;
String display_text;
void to_serial_output() {
  gcodes = loadStrings("positions.txt");
  if (oked) {
    if (!last_code) {
      if (debug) println(gcodes[forLoop]);
      if (gcodes[forLoop].equals("G1 X0 Y0 F2500")) last_code = true;

      myPort.write(gcodes[forLoop]+'\n');
      oked=false;
    }


    if (forLoop == 0 || last_code) {
      background(204);
      textAlign(LEFT);
      textSize(12);
      draw_grid();
      draw_path();
      textAlign(LEFT, TOP);
      textSize(24);
      if (forLoop == 0) text("Printing....", 0, 0);
      else if (last_code) text("Finished", 0, 0);
    }
  }
}

void serial_select() {
  //selectInput("Select a file to process:", "fileSelected");
  try {
    if (debug) printArray(Serial.list());
    int i = Serial.list().length;
    if (i != 0) {
      if (i >= 2) {
        // need to check which port the inst uses -
        // for now we'll just let the user decide
        for (int j = 0; j < i; ) {
          COMlist += char(j+'0') + " = " + Serial.list()[j];
          if (++j < i) COMlist += ",  ";
        }
        COMx = showInputDialog("Which COM port is correct? (0,1,..):\n"+COMlist);
        if (COMx == null) exit();
        if (COMx.isEmpty()) exit();
        i = int(COMx.toLowerCase().charAt(0) - '0') + 1;
      }
      String portName = Serial.list()[i-1];
      if (debug) println(portName);
      myPort = new Serial(this, portName, 115200); // change baud rate to your liking
      myPort.bufferUntil('\n'); // buffer until CR/LF appears, but not required..
    } else {
      showMessageDialog(frame, "Device is not connected to the PC");
      exit();
    }
  }
  catch (Exception e)
  { //Print the type of error
    showMessageDialog(frame, "COM port is not available (may\nbe in use by another program)");
    println("Error:", e);
    exit();
  }
}

void serialEvent(Serial p) {
  if (p.available()>0) {
    String myString = p.readStringUntil('\n');
    if (myString != null) {
      myString = trim(myString);
      if (debug) println(myString);
      String rec_common;

      if (!GRBL) rec_common="OK";
      else rec_common="ok";

      if (myString.equals(rec_common) ) {
        oked = true;
        if (!last_code) {
          forLoop++;
        }
      }
    }
  }
}
