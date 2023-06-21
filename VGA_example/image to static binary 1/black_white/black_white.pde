PImage img;
PrintWriter output_writer_txt;

String[] rowArray = new String[480];   //Declarartion by specifying the size  



void setup() {
  frameRate(1);
  size(640,480);
  img = loadImage("image_2.png");
  
  for ( int row_index = 0; row_index<480;row_index++){
    rowArray[row_index] = "";
  }
  
  image(img, 0, 0);
  
  //generate row array
  for (int y = 0; y<480; y++){
    for (int x = 0; x < 640; x++) {
      float red = red(get(x,y));
      float green = green(get(x,y));
      float blue = blue(get(x,y));
      
      float average = (red+green+blue)/3;
      
      
      String bit_value = "1";
      if (average <125){
         bit_value = "0";
      }
      rowArray[y] = rowArray[y]+bit_value;      
    }
  }
  
  //save row array as .txt
  output_writer_txt = createWriter("binary_static_image.txt"); 
  for( int y = 0; y<480; y++){
     output_writer_txt.println(String.valueOf(y)+":templatex=640'b"+rowArray[y]+";");    
  }
  output_writer_txt.flush(); // Writes the remaining data to the file
  output_writer_txt.close(); // Finishes the file
  exit(); // Stops the program

}


void draw() {
  
    
}
