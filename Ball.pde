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
