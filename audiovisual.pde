import ddf.minim.*;
import ddf.minim.analysis.*;

boolean listen;
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
  
  fullScreen(P2D);
  //frameRate(60);
  background(0);
  
  selectInput("Select song file to visualize:", "fileSelected");
}

void init() {
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
    } else if (song != null) {
      if (key == ' ') {
        if (song.isPlaying()) {song.pause();}
        else {song.play();}
      } else if (key == 'r') {
        song.pause();
        setup();
      }
    }
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
      
      int len = fft.avgSize();
      float[] avgs = new float[len];
      for(int i = 0; i < len; i++) {
        avgs[i] = fft.getAvg(i)*sensitivity;
      }
      balla.params.update(avgs);
      
      for(int i = avgs.length/2;i > 0; i--) {
        if (true) {
          float neigha;
          if (i > 0) {
            neigha = (avgs[i]+avgs[i-1]+avgs[i+1])/3;
          } else {
            neigha = (avgs[i]+avgs[i+1])/2;
          }
          //float red = ((1-i/len)*avgs[i]);
          //float green = ((i/len)*avgs[i]);
          //float blue = (neigha*(1+(i*i)/len));
          float r = pow(avgs[i]/50,2);
          
          stroke(balla.params.red,balla.params.green,balla.params.blue,balla.params.avg/2+neigha/2);
          strokeWeight((4+balla.params.avg)*height/len);
          float a = (idx/400)+(balla.params.avg)+(2*PI*float(i)/len);
          translate(random(-r,r),random(-r,r));
          line(balla.sun.x,balla.sun.y,balla.sun.x+cos(a)*width*2,balla.sun.y+sin(a)*height*2);
          translate(random(-r,r),random(-r,r));
          line(balla.sun.x,balla.sun.y,balla.sun.x-cos(a)*width*2,balla.sun.y-sin(a)*height*2);
          //line(0,height-(float(i-1)/len)*height,width,height-(float(i)/len)*height);
        }
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
  }
}


class BallArray {
  float speed = 1;
  float size = 1;
  int shades = 4;
  float a = random(2*PI);
  float rad, b;
  float rpow = 2;
  Params params;
  ArrayList<Ball> balls;
  Ball sun = new Ball(width/2,height/2,this);
  BallArray(int count) {
    params = new Params();
    balls = new ArrayList<Ball>();
    
    sun.speed = .01;
    sun.size = 5;
    sun.shades = shades*2;
    balls.add(sun);
    
    for (int i=0; i<count; i++) {
      Ball b = new Ball(random(0,width),random(0,height),this);
      b.shades = shades;
      balls.add(b);
    }
  }
  
  void update() {
    for (int i = 0; i < balls.size(); i++) {
      //int nxti = i+1;
      //if (nxti > balls.length-1) {nxti = 0;}
      //balls[i].x += (right-left)/.1;
      Ball b = balls.get(i);
      
      b.update();
      
      if (params.avg <= 1) {
        for (int i2 = 0; i2 < balls.size(); i2++) {
          Ball b2 = balls.get(i2);
          if (i != i2) { // & d < (2+balls[i2].m/2)*balls[i2].size*40
            float d = dist(b.x,b.y,b2.x,b2.y);
            float t = angleto(b.x,b.y,b2.x,b2.y);
            float sp = (pow(b2.size,2)*b.speed*(params.avg1-params.avg3))/(200+d/4);
            b.vx -= cos(t)*b.gx*sp;
            b.vy -= sin(t)*b.gy*sp;
          }
        }
      }
      
      //balls[i].move();
      //balls[i].display();
    }
  }
  
  void move() {
    for (int i=0; i<balls.size(); i++) {
      Ball b = balls.get(i);
      if (b != null) {
        b.move();
      }
    }
  }
  
  void display() {
    for (int i=0; i<balls.size(); i++) {
      Ball b = balls.get(i);
      if (b != null) {
        b.display();
      }
    }
  }
}


class Params {
  float rpow, m;
  float[] avgs;
  float avg;
  float avg1,avg2,avg3,avg4;
  float red,green,blue;
  
  Params() {
    rpow = 2;
  }
  
  void update(float[] avgst) {
    avgs = avgst;
    avg = sum(avgs)/avgs.length;
    
    int interval = floor(float(avgs.length)/4);
    avg1 = sum(subset(avgs,0,interval))/interval;
    avg2 = sum(subset(avgs,interval,interval))/interval;
    avg3 = sum(subset(avgs,interval*2,interval))/interval;
    avg4 = sum(subset(avgs,interval*3))/(avgs.length-interval*3);
    float max = max(avg1,avg2,avg3);
    
    red = avg1*(255/(1+max*.1));
    green = avg2*(255/(1+max*.1));
    blue = avg3*(255/(1+max*.1));
    
    rpow = 1.5-(avgs[0]-avg1-avg2-avg3-avg4)/100;
    if(rpow < 0.3){rpow = 0.3;}
    m = avg+pow(constrain(avg*1.5,0,7),2.5); //pow(constrain(avg,0,12)*.7,3)*2;
    
  }
}


class Ball {
  float vx,vy,x,y;
  float gx;
  float gy;
  float speed = 1;
  float size = 1;
  float age = 0;
  int shades;
  float a = random(2*PI);
  float rad;
  BallArray parent;
  Ball(float xt, float yt, BallArray parentt) {
    x = xt;
    y = yt;
    parent = parentt;
    shades = parent.shades;
    gx = random(.25,1.5);
    gy = random(.25,1.5);
  }
  
  void update() {
    //if (parent.params.avg1 > 50) {
    //  float r = (parent.params.avg1/200)*speed;
    //  x += random(-r,r);
    //  y += random(-r,r);
    //}
    vx *= .9;
    vy *= .9;
    vx -= cos(a)*parent.params.m*speed/15;
    vy -= sin(a)*parent.params.m*speed/15;
    rad = 2+(2+parent.params.m/2)*size;
    if (x+rad > width) {a = -a+PI; x = width-rad; vx *= -.9;}
    else if (x-rad < 0) {a = -a+PI; x = rad; vx *= -.9;}
    if (y+rad > height) {a *= -1; y = height-rad; vy *= -.9;}
    else if (y-rad < 0) {a *= -1; y = rad; vy *= -.9;}
    age += 1;
  }
  
  void move() {
    x += vx;
    y += vy;
  }
  
  void display() {
    rad = 2+(2+parent.params.m)*size;
    //strokeWeight(rad/2);
    //stroke(RED*b,GREEN*b,BLUE*b);
    //line(x,y,x+vx*2,y+vy*2);
    noStroke();
    for (float i=shades; i>0; i--) {
      fill(parent.params.red,parent.params.green,parent.params.blue,255/pow(i,1.5)); // 255/(1+10*pow(i,rpow)/shades)
      float d = pow(i/shades,parent.params.rpow); // i/shades+pow(i,rpow)/shades
      ellipse(x,y,rad*2*d+abs(vx*i/10),rad*2*d+abs(vy*i/10));
    }
  }
  
}

// TODO
// make some cool visual indication effect for how much sound is coming from the left versus right speakers (maybe fluid background gradient)
