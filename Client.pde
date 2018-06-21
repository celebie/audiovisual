class Client {
  
  String songfolder;
  ArrayList<String> songfiles;
  int sidx;
  
  String title = "";
  boolean hide = false;
  
  Visualizer visualizer;
  
  Client() {
    visualizer = new Visualizer();
  }
  
  void selectMusicFolder(File selection) {
    songfolder = selection.getAbsolutePath();
    
    songfiles = new ArrayList<String>();
    recurseDirMP3(songfiles,songfolder);
    Collections.shuffle(songfiles);
    
    sidx = -1;
    next();
  }
  
  void step() {
    visualizer.step();
    
    if (!hide) {
      text(title,20,20);
    }
    
    if (visualizer.done) {
      next();
    }
  }
  
  void next() {
    sidx = (sidx+1) % songfiles.size();
    visualizer.init(songfiles.get(sidx));
    
    AudioMetaData metadata = visualizer.song.getMetaData();
    String t = metadata.title();
    String a = metadata.author();
    
    if (t != "" && a != "") {
      title = t+"\n"+a;
    } else {
      String[] splt = split(songfiles.get(sidx),'/');
      title = splt[splt.length-1];
    }
  }
  
  void keyPress() {
    if (key==CODED) {
      if (keyCode == LEFT) { visualizer.skip(-10000); }
      else if (keyCode == RIGHT) { visualizer.skip(10000); }
      if (keyCode == UP) { visualizer.sensitivity += .1; }
      if (keyCode == DOWN) { visualizer.sensitivity -= .1; }
    }
    if (key == ' ') {
      visualizer.pause();
    }
    if (key == TAB) {
      next();
    }
    if (key == 'h') {
      hide = !hide;
    }
  }
}  
