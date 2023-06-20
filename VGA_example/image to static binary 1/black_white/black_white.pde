PImage img;
String[] rowArray = new String[480];   //Declarartion by specifying the size  



void setup() {
  size(640,480);
  img = loadImage("image_1.png");
  
  for ( int row_index = 0; row_index<480;row_index++){
    rowArray[row_index] = "";
  }
  
}


void draw() {
  image(img, 0, 0);
  for (int y = 0; y<480; y++){
    for (int x = 0; x < 480; x++) {
      float red = red(get(x,y));
      float green = green(get(x,y));
      float blue = blue(get(x,y));
      
      float average = (red+green+blue)/3;
      
      
    }
    print("\n");
  }
  
}
