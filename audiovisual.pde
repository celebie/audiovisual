import ddf.minim.*;
import ddf.minim.analysis.*;

boolean listen;
//ArrayList<String> songfiles;
String songfile;

float sensitivity;

float idx;
int idxi;

boolean shiftPressed;
int arrowPressed;

Minim minim;
AudioPlayer song;
FFT fft;
AudioInput in;

boolean initialized;

BallArray balla;

float angleto(float x1,float y1, float x2,float y2) {
  float dx = x1-x2;
  float dy = y1-y2;
  return atan2(dy,dx);
}

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

//void folderSelected(File selection) {
//  if (selection == null) {
//    listen = true;
//  } else {
//    recurseDirMP3(songfiles,selection.getAbsolutePath());
//  }
//  init();
//}

void fileSelected(File selection) {
  if (selection == null) {
    listen = true;
  } else {
    songfile = selection.getAbsolutePath();
  }
  init();
}

void setup() {
  listen = false;
  sensitivity = 1;
  idx = 0;
  idxi = 0;
  shiftPressed = false;
  arrowPressed = -1;
  initialized = false;
  //songfiles = new ArrayList<String>();
  
  fullScreen(P2D);
  //frameRate(60);
  background(0);
  
  selectInput("Select song file to visualize:", "fileSelected");
  //selectFolder("Select song folder to visualize:", "folderSelected");
}

void init() {
  idx = 0;
  idxi = 0;
  
  minim = new Minim(this);
  if (listen) {
    in = minim.getLineIn(); 
    fft = new FFT(in.bufferSize(), in.sampleRate());
  } else {
    song = minim.loadFile(songfile);
    fft = new FFT(song.bufferSize(), song.sampleRate());
  }
  fft.linAverages(int(fft.specSize()/2));
  
  if (listen) {} else {
    song.play();
  }
  
  balla = new BallArray(60);
  
  initialized = true;
}

void keyPressed() {
  if (initialized) {
    if (key==CODED) {
      if (keyCode == LEFT) {arrowPressed = 0;}
      else if (keyCode == RIGHT) {arrowPressed = 1;}
      if (keyCode == SHIFT) {shiftPressed = true;}
      if (keyCode == UP) {sensitivity += .1;}
      if (keyCode == DOWN) {sensitivity -= .1;}
    } else {
      if (song != null) {
        if (key == ' ') {
          if (song.isPlaying()) {song.pause();}
          else {song.play();}
        }
      }
    }
  }
  if (key == 'r') {
    if (song != null) {song.pause();}
    setup();
  } else if (key == 'f') {
    if (song != null) {song.pause();}
    setup();
    selectFolder("Select song folder to visualize:", "folderSelected");
  }
}
 
void keyReleased() {
  if (initialized) {
    if (key==CODED) {
      if (keyCode == LEFT) {arrowPressed = -1;}
      else if (keyCode == RIGHT) {arrowPressed = -1;}
      if (keyCode == SHIFT) {shiftPressed = false;}
    }
  }
}

void draw() {
  if (initialized) {
    if (song != null) {
      if (arrowPressed == 0 & shiftPressed) {
        song.skip(-120000);
      } else if (arrowPressed == 1 & shiftPressed) {
        song.skip(120000);
      } else if (arrowPressed == 0) {
        song.skip(-10000);
      } else if (arrowPressed == 1) {
        song.skip(10000);
      }
      
    }
    
    if (listen) {
      fft.forward(in.mix);
    } else {
      fft.forward(song.mix);
    }
    
    if (listen || song.isPlaying()) {
      background(0);
      //if (song != null && idxi < 64) {
      //  String[] path = split(songfile,'/');
      //  String name = path[path.length-1];
      //  textSize(36);
      //  fill(255,255,255,(1-idx/64)*255);
      //  textAlign(CENTER);
      //  text(name,0,height/10,width,height);
      //}
      
      int len = fft.avgSize();
      float[] avgs = new float[len];
      for(int i = 0; i < len; i++) {
        avgs[i] = fft.getAvg(i)*sensitivity;
      }
      balla.params.update(avgs);
      
      for(int i = avgs.length/2;i > 0; i--) {
        //float r = pow(avgs[i]/50,2);
        float r = (avgs[i]*avgs[i])/1000;
        
        //stroke(balla.params.red,balla.params.green,balla.params.blue,balla.params.avg/2+neigha/2);
        stroke(balla.params.red,balla.params.green,balla.params.blue,balla.params.avg/2+r*5*i);
        strokeWeight((4+balla.params.avg)*height/len);
        float a = (idx/400)+(balla.params.avg)+(2*PI*float(i)/len);
        translate(random(-r,r),random(-r,r));
        line(balla.sun.x,balla.sun.y,balla.sun.x+cos(a)*width*2,balla.sun.y+sin(a)*height*2);
        translate(random(-r,r),random(-r,r));
        line(balla.sun.x,balla.sun.y,balla.sun.x-cos(a)*width*2,balla.sun.y-sin(a)*height*2);
        //line(0,height-(float(i-1)/len)*height,width,height-(float(i)/len)*height);
        
        //if (r*10*i >= 1) {
        //  //stroke(balla.params.red,balla.params.green,balla.params.blue,r*10*i);
        //  line((float(i)/len)*width,0,(float(i)/len)*width,height);
        //  line(width-(float(i)/len)*width,0,width-(float(i)/len)*width,height);
        //}
      }
      
      if (balla.params.avg <= 1) {
        for (int b=0;b<balla.balls.size();b++) {
          Ball ball = balla.balls.get(b);
          
          stroke(balla.params.red,balla.params.green,balla.params.blue,balla.params.avg*3);
          strokeWeight((4+balla.params.avg*8)*height/len);
          line(ball.x,ball.y,balla.sun.x,balla.sun.y);
        }
      }
      
      balla.update();
      balla.move();
      balla.display();
      
      idx += balla.params.avg;
      idxi += 1;
    }
    //} else if (!song.isPlaying() && !listen && song.position() >= song.length()-1) {
    //  songfiles.remove(0);
    //  init();
    //}
  }
}

// TODO
// make some cool visual indication effect for how much sound is coming from the left versus right speakers (maybe fluid background gradient)
