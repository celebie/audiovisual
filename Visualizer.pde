
class Visualizer {
  
  float idx;
  int idxi;
  
  BallArray balla = new BallArray(60);
  
  float sensitivity;
  
  boolean done = false;
  
  AudioPlayer song;
  FFT fft;
  
  Visualizer() {
    sensitivity = 1;
    idx = 0;
    idxi = 0;
  }
  
  void init(String songfp) {
    if (song != null) {
      song.close();
    }
    
    sensitivity = 1;
    idx = 0;
    idxi = 0;
    
    song = minim.loadFile(songfp);
    fft = new FFT(song.bufferSize(), song.sampleRate());
    fft.linAverages(int(fft.specSize()/2));
    
    song.play();
    done = false;
  }
  
  void pause() {
    if (song != null) {
      if (song.isPlaying()) {song.pause();}
      else {song.play();}
    }
  }
  void skip(int milli) {
    if (song != null) {
      song.skip(milli);
    }
  }
  
  void step() {
    if (song != null && song.isPlaying()) {
      fft.forward(song.mix);
      
      background(0);
      
      int len = fft.avgSize();
      float[] avgs = new float[len];
      for(int i = 0; i < len; i++) {
        avgs[i] = fft.getAvg(i)*sensitivity;
      }
      balla.params.update(avgs);
      
      for(int i = avgs.length/2;i > 0; i--) {
        float r = (avgs[i]*avgs[i])/1000;
        
        stroke(balla.params.red,balla.params.green,balla.params.blue,balla.params.avg/2+r*5*i);
        strokeWeight((4+balla.params.avg)*height/len);
        float a = (idx/400)+(balla.params.avg)+(2*PI*float(i)/len);
        translate(random(-r,r),random(-r,r));
        line(balla.sun.x,balla.sun.y,balla.sun.x+cos(a)*width*2,balla.sun.y+sin(a)*height*2);
        translate(random(-r,r),random(-r,r));
        line(balla.sun.x,balla.sun.y,balla.sun.x-cos(a)*width*2,balla.sun.y-sin(a)*height*2);
        
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
  }
}
