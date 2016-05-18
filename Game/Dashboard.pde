class Dashboard {
  
  private PGraphics background;
  private PGraphics topView;
  private PGraphics textView;
  private PGraphics barChart;
  
  private static final int BG_HEIGHT = 200;
  private static final int TP_SIDE = 180;
  private static final int SC_WIDTH = 150;
  private static final int BC_WIDTH = 600;
  private static final int BC_HEIGHT = 130;
  
  private float totalScore;
  private float velocity;
  private float lastScore;
  
  private PFont font;
    
  private float[] graphList = new float[200];

  
  public Dashboard() {
    this.background = createGraphics(width, BG_HEIGHT, P2D);
    this.topView = createGraphics(TP_SIDE, TP_SIDE, P2D);
    this.textView = createGraphics(SC_WIDTH, TP_SIDE, P2D);
    this.barChart = createGraphics(BC_WIDTH, BC_HEIGHT, P2D);
    
    this.totalScore = 0;
    this.velocity = 0;
    this.lastScore = 0;
    
    this.font = createFont("Helvetica", 14);
  }
  
  public void drawBackground() {
    background.beginDraw();
    background.fill(230, 226, 175);
    background.noStroke();
    background.rect(0, 0, width, BG_HEIGHT);
    background.endDraw();
    image(background, 0, height - 200);
  }
  
  public void drawTopView(ArrayList<PVector> cylinders, float cylinderRadius,
                         float ballRadius, PVector ball, float boxSide) {
   topView.beginDraw();
   topView.background(6, 100, 130);
   topView.noStroke();
   topView.fill(255, 0, 0);
   topView.ellipse(map(ball.x, 0, boxSide, 0, TP_SIDE) + TP_SIDE / 2,
                   -map(ball.y, 0, boxSide, 0, TP_SIDE) + TP_SIDE / 2,
                   map(ballRadius, 0, boxSide, 0, TP_SIDE) * 2,
                   map(ballRadius, 0, boxSide, 0, TP_SIDE) * 2);
      
   topView.fill(230, 226, 175);
   for (int i = 0; i < cylinders.size(); i++) {
     
     topView.ellipse(map(cylinders.get(i).x, 0, boxSide, 0, TP_SIDE) + TP_SIDE / 2,
                     -map(cylinders.get(i).y , 0, boxSide, 0, TP_SIDE) + TP_SIDE / 2,
                   map(cylinderRadius, 0, boxSide, 0, TP_SIDE) * 2,
                   map(cylinderRadius, 0, boxSide, 0, TP_SIDE) * 2);
   }
   topView.endDraw();
   image(topView, 10, height - 190);
  }
  
  public void drawTextView() {
   textView.beginDraw();
   textView.noStroke();
   textView.background(255);
   textView.fill(230, 226, 175);
   textView.rect(3, 3, SC_WIDTH - 6, TP_SIDE - 6);
   textView.fill(0);
   textView.textFont(font);
   textView.text("Total Score:\n" + totalScore + "\n\nVelocity:\n" + velocity + "\n\nLast Score:\n" + lastScore, 30, 30);
   textView.endDraw();
   image(textView, 220, height - 190);
  }
  
  public void drawBarChart() {
    barChart.beginDraw(); 
    barChart.noStroke();
    barChart.background(255);
    barChart.endDraw();
    image(barChart, 400, height - 190);
  }
  
  public void drawStat() {
    int x = 405;
    int y = height - 80;
    for (int i = 0; i < graphList.length && x < BC_WIDTH + 390; i++) {
      for (int j = 0; j < graphList[i] && y > height - 180; j += 3) {
        fill(6, 100, 130);
        rect(x, y, 8 * scrollbar.getPos(), 8 * scrollbar.getPos());
        y -= 12 * scrollbar.getPos();
      }
      x += (12 * scrollbar.getPos());
      y = height - 80;
    }
  }
  
  private void copyGraphList() {
    if (frameCount % 50 == 0) {
    float[] cpy = new float[graphList.length];
    System.arraycopy(graphList, 0, cpy, 1, graphList.length - 1);
    cpy[0] = totalScore;    
    graphList = cpy;
    }
  }
  
  public void setScore(float score) {
    totalScore += score;
    lastScore = score;
  }
  
  public void setVelocity(float v) {
    velocity = v;
  }
}