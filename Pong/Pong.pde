// Basic test of sound on android using soundPool for short FX
// based on code by <a href="/two/profile/chrisgoc">@chrisgoc</a> 
// See <a href="https://forum.processing.org/two/discussion/comment/53262" target="_blank" rel="nofollow">https://forum.processing.org/two/discussion/comment/53262</a>
// and <a href="https://github.com/chris0/FloodGate/blob/Android/floodit/floodit.pde" target="_blank" rel="nofollow">https://github.com/chris0/FloodGate/blob/Android/floodit/floodit.pde</a>
 
 
import android.app.Activity;
import android.content.res.AssetFileDescriptor;
import android.content.Context;
import android.media.MediaPlayer;
import android.media.SoundPool;
import android.media.AudioManager;
 
/////////////////////////////////////////////////////////
 
SoundPool soundPool;
HashMap<Object, Object> soundPoolMap;
Activity act;
Context cont;
AssetFileDescriptor afd1;
int s1;
int streamId;

// Source code from tekgad's GitHub: https://github.com/tekgadg/Pong_sept_20_2D/blob/master/Pong_sept_20_2D.pde
//PVector contains x, y, z components for each of the elements listed. Used for positioning.
PVector player, enemy, ball;

//speeds for things that are moving automatically (the ball and the enemy)
float ballSpeedX, ballSpeedY, enemySpeed;

//declare and initializing scores
int playerScore = 0;
int enemyScore = 0;

//declaring ball size
float ballSize;

float rate = 60;

void playSound(int soundID)
{
  // play(int soundID, float leftVolume, float rightVolume, int priority, int loop, float rate)
 
  soundPool.stop(streamId); // kill previous sound - quick hack to void mousePressed triggering twice
  streamId = soundPool.play(soundID, 1.0, 1.0, 1, 0, 1f);
}

void setup()
{

    /*
    For Android devices, you'll want to set the sketch window size as below to take the full screen.
    If you don't set the orientation, your app will have auto-rotate enabled.
    */
    orientation(LANDSCAPE);
    size(displayWidth, displayHeight);
   
    
    /*
    Instead of using actual numbers, we're using ratios of width and height for different objects here. 
    This is to ensure that visual elements retain their relative sizes when running on multiple resolutions.
    */
    ball = new PVector(width/2, height/2);
    player = new PVector(width, height/2);
    enemy = new PVector(0, height/2);
    
    /*
    Same idea as using ratios for sizes. We want the ball to move at relatively same speed across multiple resolutions, so we're using ratios.
    */
    ballSpeedX = width/100;
    ballSpeedY = width/100;
    
    
    enemySpeed = width/150;
    
    ballSize = width/20;
    
    
    rectMode(CENTER);
    
    act = this.getActivity();
   cont = act.getApplicationContext();
 
  // load up the files
  try {
    afd1 = cont.getAssets().openFd("ps.wav");
  } 
  catch(IOException e) {
    println("error loading files:" + e);
  }
 
  soundPool = new SoundPool(12, AudioManager.STREAM_MUSIC, 0);
  soundPoolMap = new HashMap<Object, Object>(1);
  soundPoolMap.put(s1, soundPool.load(afd1, 1));
    
    
}

void draw()
{
    //background is important for clearing the frame every frame, so that there is nothing remaining from the previous frame drawn
    background(0); 
    frameRate(rate);
    
    //calling methods for drawing the ball, the player, the enemy, and the scores
    drawBall();
    drawPlayer();
    drawEnemy();
    scoreText();
    fpsText();
    fpsButton();

}

void drawBall()
{
    pushMatrix();
      translate(ball.x, ball.y);
      fill(255);
      noStroke();
      ellipse(0, 0, width/20, width/20);
    popMatrix();
    
    ball.x += ballSpeedX;
    ball.y += ballSpeedY;
    
    ballBoundary();
}

void ballBoundary()
{
   //top
   if (ball.y < 0) {
      ball.y = 0;
      ballSpeedY *= -1; 
      playSound(1);
   }
  
   //bottom
   if (ball.y > height) {
      ball.y = height;
      ballSpeedY *= -1; 
      playSound(1);
   }
      
    
    if (ball.x > width) {
       ball.x = width/2;
       ballSpeedX *= -1;
       enemyScore ++;
    }
    
    if (ball.x < 0) {
       ball.x = width/2; 
       ballSpeedX *= -1;
       playerScore ++;
    }
    
    //player
    if (ball.x > width - width/40 - ballSize && ball.x < width && Math.abs(ball.y - player.y) < width/10) {
       ball.x = width - width/40 - ballSize;
       ballSpeedX *= -1;
       playSound(1);
    }
    
    //enemy
    if (ball.x < width/40 + ballSize && ball.x > 0 && Math.abs(ball.y - enemy.y) < width/10) {
       ball.x = width/40 + ballSize;
       ballSpeedX *= -1; 
       playSound(1);
    }
    
    
 
}

void drawPlayer()
{  
   player.y = mouseY;
  
   pushMatrix();
     translate(player.x - width/20, player.y);
     stroke(0);
     fill(0, 0, 128);
     rect(0, 0, width/20, width/5);
   popMatrix();
    
}

void drawEnemy()
{
    enemy.y += enemySpeed;
  
    pushMatrix();
      translate(enemy.x + width/20, enemy.y);
      fill(255, 128, 0);
      rect(0, 0, width/20, width/5);
    popMatrix();
    
    enemyAI();  
}

void enemyAI()
{
    if (enemy.y < ball.y) {
      enemySpeed = width/150;
    }
    
    if (enemy.y > ball.y) {
      enemySpeed = - width/150; 
    }
    
    if (enemy.y == ball.y) {
      enemySpeed = 0; 
    }
    
    if (ball.x > width/2) {
      enemySpeed = 0; 
    }
}

void scoreText()
{
    fill(255, 128, 0);
    textSize(width/20);
    text(enemyScore, width/10 * 3, height/5);
    fill(0, 0, 128);
    text(playerScore, width/10 * 7, height/5);  
}

void fpsText(){
 if (rate == 60 || rate == 90) {
  fill(0,255,0);
  textAlign(CENTER, BOTTOM);
  textSize(width/50);
  text(rate + " FPS", width/4*2, height/10);
 }
 
}

// Press that text if you want to swap FPS
void fpsButton() {
  fill(0);
  rect(width/4*2 - 100, height/10-128, 200, 50);
  fill(0,255,0);
  textAlign(CENTER, BOTTOM);
  textSize(width/50);
  text("FPS Changer", width/4*2, height/10-75);
  
  float leftEdge = width/4*2 - 100;
  float rightEdge = width/4*2 + 100;
  float topEdge = height/10-128;
  float bottomEdge = height/10 - 68;
  
  
  if (mousePressed == true && 
      mouseX > leftEdge &&
      mouseX < rightEdge &&
      mouseY > topEdge && 
      mouseY < bottomEdge) {
    rate = 90;
  }
}
