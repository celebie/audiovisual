import java.util.Collections;
import ddf.minim.*;
import ddf.minim.analysis.*;

Client client;
Minim minim;

static final float sum(float... arr) {
  float sum = 0;
  for (float f: arr)  sum += f;
  return sum;
}

void recurseDirMP3(ArrayList<String> a, String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] subfiles = file.listFiles();
    for (int i = 0; i < subfiles.length; i++) {
      recurseDirMP3(a, subfiles[i].getAbsolutePath());
    }
  } else if (file.getAbsolutePath().indexOf(".mp3") != -1) {
    a.add(file.getAbsolutePath());
  }
}

void folderSelected(File selection) {
  if (selection == null) {
    exit();
  } else {
    client.selectMusicFolder(selection);
  }
}


void setup() {
  minim = new Minim(this);
  client = new Client();
  
  fullScreen(P2D);
  //frameRate(60);
  
  selectFolder("Select song folder to visualize:", "folderSelected");
}

void keyPressed() {
  if (client != null) {
    client.keyPress();
  }
}

void draw() {
  background(0);
  if (client != null) {
    client.step();
  }
}
