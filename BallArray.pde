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
  
  float angleto(float x1,float y1, float x2,float y2) {
    float dx = x1-x2;
    float dy = y1-y2;
    return atan2(dy,dx);
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
