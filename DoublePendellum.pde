//First pendelums position
float p1x;
float p1y;

//Second pendelums position
float p2x;
float p2y;

//Second pendelums previous position
float pp2x;
float pp2y;

//Length of the pendelums
float r1 = 200;
float r2 = 200;

//Angles of the pendelums
float a1 = PI/2;
float a2 = PI/2;

//Masses of the pendelums
float m1 = 20;
float m2 = 20;

//Velocities of the pedelums
float v1 = 0;
float v2 = 0;

//Accelerations of the pendelums
float acc1;
float acc2;

//My Guy GRAVITY
float g = 1;

PGraphics lines;

float cx, cy;

boolean isStarted;
int ytranslate = 180;
float ia1;
float ia2;

boolean hide;
float[] ellipseX;
//after seing this equation I wonder why it is chaotic

//θ1'' =    −g (2 m1 + m2) sin θ1 − m2 g sin(θ1 − 2 θ2) − 2 sin(θ1 − θ2) m2 (θ2'2 r2 + θ1'2 r1 cos(θ1 − θ2))/
//r1 (2 m1 + m2 − m2 cos(2 θ1 − 2 θ2))

//θ2'' =    2 sin(θ1 − θ2) (θ1'2 r1 (m1 + m2) + g(m1 + m2) cos θ1 + θ2'2 r2 m2 cos(θ1 − θ2))/
//r2 (2 m1 + m2 − m2 cos(2 θ1 − 2 θ2))


void setup() {
  size(800, 600);
  background(255);
  cx = width/2;
  cy = 200;
  lines = createGraphics(width, height);
  lines.beginDraw();
  lines.background(255);
  lines.endDraw();
  ellipseX = new float[4];
  calculatePendelumPosition();
}

float slider(float x, float y, float l, float r, int p) {
  if (mousePressed && dist(mouseX-width/2, mouseY-ytranslate, ellipseX[p], y+2.5)<= 20 && 
    mouseX-width/2>x && mouseX-width/2<x+l) {
    ellipseX[p] = mouseX-width/2;
  } else if (ellipseX[p] == 0) {
    ellipseX[p]= x+l/2;
  }
  fill(50);
  rect(x, y, l, 5);
  fill(200);
  ellipse(ellipseX[p], y+2.5, 20, 20);

  return map(ellipseX[p], x, x+l, 0, r);
}
void showMenu() {
  text("Press space to start/pause", -380, height - ytranslate-25);
  text("Press s to save", -380, height - ytranslate-40);
  text("Press r to reset", -380, height - ytranslate-55);
  text("Press h to hide/show", -380, height - ytranslate-70);


  textAlign(CORNER, CENTER);
  text("M1:", -380, height -ytranslate-110-15);
  text("M2:", -380, height -ytranslate-80-15);
  text("R1:", -380, height -ytranslate-170-15);
  text("R2:", -380, height -ytranslate-140-15);

  m1 = slider(-350, height - ytranslate-110-15, 150, 50, 0);
  m2 = slider(-350, height - ytranslate-80-15, 150, 50, 1);
  r1 = slider(-350, height - ytranslate-170-15, 150, 200, 2);
  r2 = slider(-350, height - ytranslate-140-15, 150, 200, 3);

  text(m1, -190, height -ytranslate-110-15);
  text(m2, -190, height -ytranslate-80-15);
  text(r1, -190, height -ytranslate-170-15);
  text(r2, -190, height -ytranslate-140-15);
}


void draw() {
  background(255);


  createCanvasForLine();
  translate(width/2, ytranslate);
  if (!hide) {
    showMenu();
  }



  calculatePendelumPosition();

  drawPendelums();
  if (isStarted) {


    evolveTimeForPhysics();

    calculatePendelumMovement();

    drawLine();
  }
}
void keyPressed() {
  if (key == ' ') {
    if (!isStarted) {
      ia1 = degrees(a1);
      ia2 = degrees(a2);
    }

    frameCount = 0;
    isStarted = !isStarted;
  }
  if (key == 'r') {
    restart();
  }
  if (key == 's') {
    saveImage();
  }
  if (key == 'h') {
    hide = !hide;
  }
}
void saveImage() {
  saveFrame("a1:"+ia1+"_a2:"+ia2+"m1:"+m1+"_m2:"+m2+"r1:"+r1+"_r2:"+r2+".png");
}

void mouseDragged() {

  if (dist(mouseX, mouseY, p1x+width/2, p1y+ytranslate)<=m1 && mouseY-ytranslate !=0) {

    a1 = atan2((mouseX-(width/2)), ( mouseY - ytranslate));
  } else if (dist(mouseX, mouseY, p2x+width/2, p2y+ytranslate)<=m2 && mouseY-ytranslate != 0) {
    a2 = atan2(((mouseX-p1x)-(width/2)), ( (mouseY-p1y) - ytranslate));
  }
}
void calculatePendelumMovement() {
  float num1 = (-g * (2 * m1 + m2) * sin(a1)) + (-m2 * g * sin(a1-2*a2)) + (-2*sin(a1-a2)*m2) * (v2*v2*r2+v1*v1*r1*cos(a1-a2));
  float den1 = r1 * (2*m1+m2-m2*cos(2*a1-2*a2));
  acc1 = num1 / den1;

  float num2 = (2 * sin(a1-a2))*(((v1*v1*r1*(m1+m2)))+(g * (m1 + m2) * cos(a1))+(v2*v2*r2*m2*cos(a1-a2)));
  float den2 = r2 * (2*m1+m2-m2*cos(2*a1-2*a2));
  acc2 = num2 / den2;
}

void calculatePendelumPosition() {
  p1x = sin(a1)*r1;
  p1y = (cos(a1)*r1);



  p2x = p1x + sin(a2)*r2;
  p2y = (p1y + cos(a2)*r2);
}
color pendelumColor() {
  float r;
  float g;
  float b;

  r = map(p2y, 0, height, 0, 255);
  g = map(p2x, 0, width, 0, 255);
  b = map(noise(p2x+p2y, 1), 0, 1, 0, 255);

  return color(r, g, b);
}

void drawPendelums() {
  line(0, 0, p1x, p1y);
  line(p1x, p1y, p2x, p2y);
  fill(0);
  ellipse(p1x, p1y, m1, m1);
  fill(0);
  ellipse(p2x, p2y, m2, m2);
}

void evolveTimeForPhysics() {
  v1 += acc1;
  v2 += acc2;

  a1 += v1;
  a2 += v2;
}
void createCanvasForLine() {
  imageMode(CORNER);
  image(lines, 0, -ytranslate+150, width, height);
}

void drawLine() {

  translate(cx, cy);

  lines.beginDraw();
  lines.translate(cx, cy);
  lines.stroke(pendelumColor());
  lines.fill(50);




  if (frameCount > 1) {
    lines.line(pp2x, pp2y, p2x, p2y);
  }
  lines.endDraw();


  pp2x = p2x;
  pp2y = p2y;
}
void restart() {
  p1x = 0;
  p1y = 0;

  //Second pendelums position
  p2x =0;
  p2y =0;

  //Second pendelums previous position
  pp2x =0;
  pp2y =0;

  //Length of the pendelums
  r1 = 200;
  r2 = 200;

  //Angles of the pendelums
  a1 = PI/2;
  a2 = PI/2;

  //Masses of the pendelums
  m1 = 20;
  m2 = 20;

  //Velocities of the pedelums
  v1 = 0;
  v2 = 0;

  //Accelerations of the pendelums
  acc1 = 0;
  acc2 = 0;

  //My Guy GRAVITY

  lines.background(0, 1);

  cx = width/2;
  cy = 200;

  isStarted = false;
}
