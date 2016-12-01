class TraceParticles{
  
  private PVector location;
  
  private float positionOffset;
  
  private float fade = 255;
  
  private int particleSize = 2;
  
  private float particleWidth;
  
  //Constructor takes into account the main particle's location, its width and current fill color
  public TraceParticles(PVector makerLocation, float particleWidth, float fillColor){
    
    this.location = makerLocation.get();
    
    fade = fillColor;
    //so that the trace starts at the tail
    positionOffset = random(-particleWidth/2, particleWidth/2);
    
    this.particleWidth = particleWidth;
  }
  
  
  public void drawParticle(){
    
    noStroke();
    fill(255, fade);
    ellipse(location.x-(particleWidth/2)+positionOffset, location.y, particleSize, particleSize);
    
  }
  
  //quick fade
  public void fadeAway(){
    fade -= 6;
    
  }
 
  //Once faded it will be removed
  public boolean isFaded(){
    return (fade < 0);
  }
  
  
  
}