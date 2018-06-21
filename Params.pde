class Params {
  float rpow, m;
  float[] avgs;
  float avg;
  float avg1,avg2,avg3,avg4;
  float red,green,blue;
  
  Params() {
    rpow = 2;
  }
  
  void update(float[] avgs_) {
    avgs = avgs_;
    avg = sum(avgs)/avgs.length;
    
    int interval = floor(float(avgs.length)/4);
    avg1 = sum(subset(avgs,0,interval))/interval;
    avg2 = sum(subset(avgs,interval,interval))/interval;
    avg3 = sum(subset(avgs,interval*2,interval))/interval;
    avg4 = sum(subset(avgs,interval*3))/(avgs.length-interval*3);
    float max = max(avg1,avg2,avg3);
    
    red = avg1*(255/(1+max*.2));
    green = avg2*(255/(1+max*.2));
    blue = avg3*(255/(1+max*.2));
    
    rpow = 1.5-(avgs[0]-avg1-avg2-avg3-avg4)/100;
    if(rpow < 0.3){rpow = 0.3;}
    m = avg+pow(constrain(avg*1.5,0,7),2.5); //pow(constrain(avg,0,12)*.7,3)*2;
    
  }
}
