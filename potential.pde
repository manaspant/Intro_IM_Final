//1: import libraries:: -> sketch ->Import Library
import SimpleOpenNI.*;
import processing.sound.*;

//2: make a variable to to hold the SimpleOpenNI object (to be able to access data from the kinect)
SimpleOpenNI kinect;

//3: declare PImage variable to hold and display the pixel data from the kinect

PImage depthCam;
PImage depthCam2;
PImage colorCam;

//variables to store closest x and closest y;
float closestX=0;
float closestY=0;
float closestX2=0;
float closestY2=0;
float previousX;
float previousY;

//sound files

SoundFile file1;
SoundFile file2;
SoundFile file3;
SoundFile file4;


color currentLocColor;

int[] depthVals2;
//float[] avgSubtract = new float [0];
int avgSub = 0;
int counter;
int xVals;
int yVals;
int avgSumX;
int avgSumY;
int counterX = 0;
int counterY;


float locFirst;
float locChange;
float locFirst1;
int locChange1;
float frameDifference;

//3:: setup
void setup()
{

  // make the sketch size a that of kinect sample
  size(640, 480);
  // set a background color
  background(0);
  // instantatiate the SimpleOpenNI object
  //paremeter : is the current context
  kinect  = new SimpleOpenNI(this);
  //put this in setup so that we can tell the lib in advance what type of data we want

  //invoke the method from the lib to allow access to the depth camera
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.update();
  depthCam2 = kinect.depthImage();
  depthVals2 = kinect.depthMap();

  //for(int i = 0 ; i< depthVals2.length; i++){
  //  println(depthVals2[i]);
  //}


  int currentMin = 8000;
  depthCam = kinect.depthImage();
  for (int y=0; y<depthCam.height; y++)
  {
    yVals += 1;
    //go through each col
    for (int x =0; x<depthCam.width; x++)
    {
      // get the location in the depthVals array
      int loc = x+(y*depthCam.width);
      counter += 1;

      // if that pixel is the closest one we've seen so far (min)
      // extension::****
      // only look for the closestValue within a range
      // 610 (or 2 feet) is the minimum
      // 1525 (or 5 feet) is the maximum
      if (depthVals2[loc] > 400 && depthVals2[loc]< 1000 && depthVals2[loc] < currentMin)
      {
        //if the condition is true then assign current val to current min
        currentMin = depthVals2[loc];
        // and becuase this is the current min we need to assign the current x and y
        //to the closestX and closestY
        closestX2 =x;
        closestY2= y;
      }
    }
  }


  locFirst = currentMin/25.4;
  locFirst1 = currentMin;
  println("setup distance from kinect  " + locFirst);
  print("totall pixels " + counter);
  print("totall y values " + yVals);

  file1 = new SoundFile(this, "track1.wav");
  file2 = new SoundFile(this, "track2.wav");
  file3 = new SoundFile(this, "track2.wav");
  file4 = new SoundFile(this, "track4.wav");
}

//our drawing loop
void draw()
{
  //reset the background
  background(0);
  // get the next frame from the kinect
  kinect.update();
  // get the depth image and assign to the PImage var (using the lib)
  depthCam = kinect.depthImage();
  colorCam = kinect.rgbImage();

  // get the depthMap (mm) values
  int[] depthVals = kinect.depthMap();
  //set the current min to the highest possible val...
  int currentMin = 8000;

  //go through the matrix - for each row go through every column
  for (int y=0; y<depthCam.height; y++)
  {
    if (y > 60 && y < 375) {
      //go through each col
      for (int x =0; x<depthCam.width; x++)
      {

        if (x > 170 && x < 495) {
          // get the location in the depthVals array
          int loc = x+(y*depthCam.width);
          //currentLocColor = colorCam.pixels[loc];

          // if that pixel is the closest one we've seen so far (min)
          // extension::****
          // only look for the closestValue within a range
          // 610 (or 2 feet) is the minimum
          // 1525 (or 5 feet) is the maximum
          if (depthVals[loc] > 800 && depthVals[loc]< 1100 && depthVals[loc] < currentMin && 
            red(colorCam.pixels[loc]) >=180 && red(colorCam.pixels[loc]) <=200 && green(colorCam.pixels[loc]) >=180 && green(colorCam.pixels[loc]) <=200
            && blue(colorCam.pixels[loc]) >=170 && blue(colorCam.pixels[loc])<=190)

          {
            //if the condition is true then assign current val to current min
            currentMin = depthVals[loc];
            //println("colors  " + "r:: "+red(colorCam.pixels[loc])+ " g:: "+ green(colorCam.pixels[loc])+ " b:: "+ blue(colorCam.pixels[loc]));

            // and becuase this is the current min we need to assign the current x and y
            //to the closestX and closestY
            closestX =x;
            closestY= y;
            locChange1 = loc;
          }
        }
      }
    }
  }

  locChange = currentMin/25.4;

  currentLocColor = colorCam.pixels[locChange1];

  //println("draw distance from kinect  " + locChange);
  //println("r:: "+red(currentLocColor)+ " g:: "+ green(currentLocColor)+ " b:: "+ blue(currentLocColor));

  // "linear interpolation", i.e.
  // smooth transition between last point
  // and new closest point
  // a third of the way between previous and closest
  float interpolatedX = lerp(previousX, closestX, 0.5f); 
  float interpolatedY = lerp(previousY, closestY, 0.5f);

  // update the previous vals
  previousX = interpolatedX;
  previousY= interpolatedY;

  //display depth image - give borders around
  image(depthCam, 0, 0);
  //lets display the closest tracked point
  fill(255, 0, 0);
  ellipse(interpolatedX, interpolatedY, 10, 10);

  //frame difference
  if (frameCount % 60 == 0) {
    //frameDifference = locFirst - locChange;
    println("frame difference  ");

    //calculating average values of closes x and y in 10 seconds

    avgSumX += closestX;
    avgSumY += closestY;
    counterX += 1;

    print(counterX);

    if (counterX == 5) {
      println("counterX ");

      int avgX = avgSumX / 5;
      int avgY = avgSumY / 5;


      if (avgX < 337 && avgY < 224) {
        println("In first quad");
        println("AvgX = " + avgX);
        println("AvgY = " + avgY);
        avgSumX = 0;
        avgSumY = 0;
        if (file1.isPlaying() == false) {
          file2.pause();
          file3.pause();
          file4.pause();
          file1.play();
        }
      }

      if (avgX > 337 && avgY < 224) {
        println("in second quaddd");
        println("AvgX = " + avgX);
        println("AvgY = " + avgY);
        avgSumX = 0;
        avgSumY = 0;
        if (file2.isPlaying() == false) {
          file1.pause();
          file3.pause();
          file4.pause();
          file2.play();
        }
      }

      if (avgX < 337 && avgY > 224) {
        println("in third quad");
        println("AvgX = " + avgX);
        println("AvgY = " + avgY);
        avgSumX = 0;
        avgSumY = 0;
        if (file3.isPlaying() == false) {
          file1.pause();
          file2.pause();
          file4.pause();
          file3.play();
        }
      }

      if (avgX > 337 && avgY > 224) {
        println("in 4th quad");
        println("AvgX = " + avgX);
        println("AvgY = " + avgY);
        avgSumX = 0;
        avgSumY = 0;
        if (file4.isPlaying() == false) {
          file1.pause();
          file2.pause();
          file3.pause();
          file4.play();
        }
      }
      counterX = 0;
    }
  }

  if (frameCount % 600 == 0) {
    //println("printing list");
  }

  stroke(204, 102, 0);
  noFill();
  quad(170, 60, 495, 60, 495, 375, 170, 375);
}

void mousePressed() {
  println("the position of the pixel iss" + (mouseX) + " " + (mouseY));
}