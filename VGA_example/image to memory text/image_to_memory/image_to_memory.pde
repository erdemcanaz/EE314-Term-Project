

PImage img;
PrintWriter output_writer_txt_red, output_writer_txt_green, output_writer_txt_blue;

void setup() {
  frameRate(1);
  size(640, 480);

  int image_width = 90;
  int image_height = 140;
  String file_name = "triangle_turn_active";
  img = loadImage("triangle_turn_pasive_90_140.png");
  image(img, 0, 0);

  //generate row array

  output_writer_txt_red = createWriter(file_name+"_r.txt");
  output_writer_txt_green = createWriter(file_name+"_g.txt");
  output_writer_txt_blue = createWriter(file_name+"_b.txt");

  for (int y = 0; y<image_height; y++) {
    for (int x = 0; x < image_width; x++) {

      float red = red(get(x, y));
      float green = green(get(x, y));
      float blue = blue(get(x, y));

      int red_3_bit = int(floor(red/32.05));
      String red_3_bit_string = binary(red_3_bit, 3);

      int green_3_bit = int(floor(green/32.05));
      String green_3_bit_string = binary(green_3_bit, 3);

      int blue_3_bit = int(floor(blue/32.05));
      String blue_3_bit_string = binary(blue_3_bit, 3);

      int pixel_no = x+y*image_width;
      String unprocessed_str_hex = hex(pixel_no).toLowerCase();
      String processed_str_hex = "";
      boolean start_appending = false;


      for (int i = 0; i< unprocessed_str_hex.length(); i++) {

        if (unprocessed_str_hex.charAt(i) != '0') {
          start_appending = true;
        }

        if (start_appending) {
          processed_str_hex = processed_str_hex+unprocessed_str_hex.charAt(i);
        }
      }

      if (pixel_no == 0 ) {
        processed_str_hex = "0";
      }

      output_writer_txt_red.println("@"+processed_str_hex);
      output_writer_txt_green.println("@"+processed_str_hex);
      output_writer_txt_blue.println("@"+processed_str_hex);

      output_writer_txt_red.println(red_3_bit_string);
      output_writer_txt_green.println(green_3_bit_string);
      output_writer_txt_blue.println(blue_3_bit_string);
    }
  }

  //save row array as .txt
  output_writer_txt_red.flush(); // Writes the remaining data to the file
  output_writer_txt_red.close(); // Finishes the file

  output_writer_txt_green.flush(); // Writes the remaining data to the file
  output_writer_txt_green.close(); // Finishes the file

  output_writer_txt_blue.flush(); // Writes the remaining data to the file
  output_writer_txt_blue.close(); // Finishes the file

  exit(); // Stops the program
}


void draw() {
}
