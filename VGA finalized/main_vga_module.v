//plot image
//export image
//initiliaze registers
//import data
//define start,end points and width height
//edit if condition

module main_vga_module(clock_builtin_50MHZ,clock_out_25MHZ, h_sync, v_sync,v_sync_led, red_8bit, green_8bit, blue_8bit);
input clock_builtin_50MHZ;
output h_sync, v_sync;

//input [399:0] grid_data;// grid consists of 100 individual cells. Each cell has 12 states so that 4 bit is neccessary to express its state. MSB -> LSB
output reg [7:0] red_8bit;
output reg [7:0] green_8bit;
output reg [7:0] blue_8bit;

output reg v_sync_led;

//grid related images
reg [2:0] triangle_r [1023:0];//32^2
reg [2:0] triangle_g [1023:0];//32^2
reg [2:0] triangle_b [1023:0];//32^2

reg [2:0] grid_letters_r [7999:0];//320x25
reg [2:0] grid_letters_g [7999:0];//320x25
reg [2:0] grid_letters_b [7999:0];//320x25

reg [2:0] grid_numbers_r [7999:0];//25x320
reg [2:0] grid_numbers_g [7999:0];//25x320
reg [2:0] grid_numbers_b [7999:0];//25x320

//triangle turn related images
reg [2:0] triangle_turn_active_r [12599:0];//90x140
reg [2:0] triangle_turn_active_g [12599:0];//90x140
reg [2:0] triangle_turn_active_b [12599:0];//90x140

reg [2:0] triangle_turn_pasive_r [12599:0];//90x140
reg [2:0] triangle_turn_pasive_g [12599:0];//90x140
reg [2:0] triangle_turn_pasive_b [12599:0];//90x140

//circle turn related images
reg [2:0] circle_turn_active_r [12599:0];//90x140
reg [2:0] circle_turn_active_g [12599:0];//90x140
reg [2:0] circle_turn_active_b [12599:0];//90x140

reg [2:0] circle_turn_pasive_r [12599:0];//90x140
reg [2:0] circle_turn_pasive_g [12599:0];//90x140
reg [2:0] circle_turn_pasive_b [12599:0];//90x140

//informative symbols
reg [2:0] informative_symbols_r [6999:0];//50x140
reg [2:0] informative_symbols_g [6999:0];//50x140
reg [2:0] informative_symbols_b [6999:0];//50x140

//number digits generic
reg [2:0] number_digits_generic_r [8249:0];//275x30
reg [2:0] number_digits_generic_g [8249:0];//275x30
reg [2:0] number_digits_generic_b [8249:0];//275x30

//letter digits generic
reg [2:0] letter_digits_generic_r [7499:0];//250x30
reg [2:0] letter_digits_generic_g [7499:0];//250x30
reg [2:0] letter_digits_generic_b [7499:0];//250x30

//triangle winner
reg [2:0] triangle_winner_r [6399:0];//80x80
reg [2:0] triangle_winner_g [6399:0];//80x80
reg [2:0] triangle_winner_b [6399:0];//80x80

//circle winner
reg [2:0] circle_winner_r [6399:0];//80x80
reg [2:0] circle_winner_g [6399:0];//80x80
reg [2:0] circle_winner_b [6399:0];//80x80

output clock_out_25MHZ;
wire [10:0] h_count, v_count;

clock_divider instance_1(.clk(clock_builtin_50MHZ), .clk_25(clock_out_25MHZ));
horizontal_and_vertical_counter instance_2(.clk_25(clock_out_25MHZ),.h_count(h_count), .h_sync(h_sync), .v_count(v_count), .v_sync(v_sync));

parameter H_VISIBLE_AREA = 640;
parameter V_VISIBLE_AREA = 480;

//parameters used in testing 
parameter game_status = 2;// 2-> triangle wins, 1-> circle wins
parameter whose_turn = 2;

parameter triangle_move_count_sig = 0;
parameter triangle_move_count_lst = 1;
parameter triangle_win_count_sig = 2;
parameter triangle_win_count_lst = 3;
parameter triangle_last_cell_sig =4; //x
parameter triangle_last_cell_lst = 5; //y

parameter circle_move_count_sig = 6;
parameter circle_move_count_lst = 7;
parameter circle_win_count_sig = 8;
parameter circle_win_count_lst = 9;
parameter circle_last_cell_sig =0; //x
parameter circle_last_cell_lst = 1; //y

initial
	begin
		// import image pixels from .mem files
		$readmemb("memb_files/triangle_dummy_r.txt",triangle_r);
		$readmemb("memb_files/triangle_dummy_g.txt",triangle_g);
		$readmemb("memb_files/triangle_dummy_b.txt",triangle_b);
		
		$readmemb("memb_files/triangle_turn_active_r.txt",triangle_turn_active_r);
		$readmemb("memb_files/triangle_turn_active_g.txt",triangle_turn_active_g);
		$readmemb("memb_files/triangle_turn_active_b.txt",triangle_turn_active_b);
		
		$readmemb("memb_files/triangle_turn_pasive_r.txt",triangle_turn_pasive_r);
		$readmemb("memb_files/triangle_turn_pasive_g.txt",triangle_turn_pasive_g);
		$readmemb("memb_files/triangle_turn_pasive_b.txt",triangle_turn_pasive_b);
		
		$readmemb("memb_files/circle_turn_active_r.txt",circle_turn_active_r);
		$readmemb("memb_files/circle_turn_active_g.txt",circle_turn_active_g);
		$readmemb("memb_files/circle_turn_active_b.txt",circle_turn_active_b);
		
		$readmemb("memb_files/circle_turn_pasive_r.txt",circle_turn_pasive_r);
		$readmemb("memb_files/circle_turn_pasive_g.txt",circle_turn_pasive_g);
		$readmemb("memb_files/circle_turn_pasive_b.txt",circle_turn_pasive_b);
		
		$readmemb("memb_files/grid_letters_r.txt",grid_letters_r);
		$readmemb("memb_files/grid_letters_g.txt",grid_letters_g);
		$readmemb("memb_files/grid_letters_b.txt",grid_letters_b);
		
		$readmemb("memb_files/grid_numbers_r.txt",grid_numbers_r);
		$readmemb("memb_files/grid_numbers_g.txt",grid_numbers_g);
		$readmemb("memb_files/grid_numbers_b.txt",grid_numbers_b);
		
		$readmemb("memb_files/informative_symbols_r.txt",informative_symbols_r);
		$readmemb("memb_files/informative_symbols_g.txt",informative_symbols_g);
		$readmemb("memb_files/informative_symbols_b.txt",informative_symbols_b);
		
		$readmemb("memb_files/number_digits_generic_r.txt",number_digits_generic_r);
		$readmemb("memb_files/number_digits_generic_g.txt",number_digits_generic_g);
		$readmemb("memb_files/number_digits_generic_b.txt",number_digits_generic_b);		
		
		$readmemb("memb_files/letter_digits_generic_r.txt",letter_digits_generic_r);
		$readmemb("memb_files/letter_digits_generic_g.txt",letter_digits_generic_g);
		$readmemb("memb_files/letter_digits_generic_b.txt",letter_digits_generic_b);
		
		$readmemb("memb_files/circle_winner_r.txt",circle_winner_r);
		$readmemb("memb_files/circle_winner_g.txt",circle_winner_g);
		$readmemb("memb_files/circle_winner_b.txt",circle_winner_b);
		
		$readmemb("memb_files/triangle_winner_r.txt",triangle_winner_r);
		$readmemb("memb_files/triangle_winner_g.txt",triangle_winner_g);
		$readmemb("memb_files/triangle_winner_b.txt",triangle_winner_b);
	end	

//grid parameters
parameter grid_start_x = 160; // pixel is included
parameter grid_start_y = 60; // pixel is included
parameter cell_width = 32;
parameter cell_height = 32;
parameter grid_end_x = grid_start_x+(cell_width*10) -1; //pixel is included
parameter grid_end_y = grid_start_y+(cell_height*10) -1; //pixel is included

parameter grid_letters_start_x = 160;//pixel is included
parameter grid_letters_start_y = 25;//pixel is included
parameter grid_letters_width = 320;
parameter grid_letters_height = 25;
parameter grid_letters_end_x =  grid_letters_start_x + grid_letters_width-1;
parameter grid_letters_end_y =  grid_letters_start_y + grid_letters_height-1;

parameter grid_numbers_start_x = 125;//pixel is included
parameter grid_numbers_start_y = 60;//pixel is included
parameter grid_numbers_width = 25;
parameter grid_numbers_height = 320;
parameter grid_numbers_end_x =  grid_numbers_start_x + grid_numbers_width-1;
parameter grid_numbers_end_y =  grid_numbers_start_y + grid_numbers_height-1;

//triangle turn parameters
parameter triangle_turn_start_x = 10;//pixel is included
parameter triangle_turn_start_y = 130;//pixel is included
parameter triangle_turn_width = 90;
parameter triangle_turn_height = 140;
parameter triangle_turn_end_x = triangle_turn_start_x + triangle_turn_width -1;//pixel is included
parameter triangle_turn_end_y = triangle_turn_start_y+triangle_turn_height - 1;//pixel is included

//circle turn parameters
parameter circle_turn_start_x = 540;//pixel is included
parameter circle_turn_start_y = 130;//pixel is included
parameter circle_turn_width = 90;
parameter circle_turn_height = 140;
parameter circle_turn_end_x = circle_turn_start_x + circle_turn_width -1;//pixel is included
parameter circle_turn_end_y = circle_turn_start_y+circle_turn_height - 1;//pixel is included

//informative symbols
parameter informative_symbols_1_start_x = 10;//pixel is included
parameter informative_symbols_1_start_y = 330;//pixel is included
parameter informative_symbols_1_end_x = informative_symbols_1_start_x + informative_symbols_width -1;//pixel is included
parameter informative_symbols_1_end_y = informative_symbols_1_start_y+ informative_symbols_height - 1;//pixel is included

parameter informative_symbols_2_start_x = 515;//pixel is included
parameter informative_symbols_2_start_y = 330;//pixel is included
parameter informative_symbols_2_end_x = informative_symbols_2_start_x + informative_symbols_width -1;//pixel is included
parameter informative_symbols_2_end_y = informative_symbols_2_start_y+ informative_symbols_height - 1;//pixel is included

parameter informative_symbols_width = 50;
parameter informative_symbols_height = 140;

//number digits generic
parameter number_digits_generic_width = 25;
parameter number_digits_whole_data_width = 275;
parameter number_digits_generic_height = 30;
//letter digits generic
parameter letter_digits_generic_width = 25;
parameter letter_digits_whole_data_width = 250;
parameter letter_digits_generic_height = 30;


//digit cells start and end cordinates (top left point)
parameter triangle_move_count_start_x = 65;//pixel is included
parameter triangle_move_count_start_y = 330;//pixel is included
parameter triangle_move_count_end_x = triangle_move_count_start_x + (2*number_digits_generic_width) -1;//pixel is included
parameter triangle_move_count_end_y = triangle_move_count_start_y + (number_digits_generic_height) -1;//pixel is included

parameter triangle_win_count_start_x = 65;//pixel is included
parameter triangle_win_count_start_y = 380;//pixel is included
parameter triangle_win_count_end_x = triangle_win_count_start_x + (2*number_digits_generic_width) -1;//pixel is included
parameter triangle_win_count_end_y = triangle_win_count_start_y + (number_digits_generic_height) -1;//pixel is included

parameter triangle_last_cell_start_x =65; //pixel is included
parameter triangle_last_cell_start_y = 430; //pixel is included
parameter triangle_last_cell_end_x = triangle_last_cell_start_x + (2*number_digits_generic_width) -1;//pixel is included
parameter triangle_last_cell_end_y = triangle_last_cell_start_y + (number_digits_generic_height) -1;//pixel is included

parameter circle_move_count_start_x = 570;//pixel is included
parameter circle_move_count_start_y = 330;//pixel is included
parameter circle_move_count_end_x = circle_move_count_start_x + (2*number_digits_generic_width) -1;//pixel is included
parameter circle_move_count_end_y = circle_move_count_start_y + (number_digits_generic_height) -1;//pixel is included

parameter circle_win_count_start_x = 570;//pixel is included
parameter circle_win_count_start_y = 380;//pixel is included
parameter circle_win_count_end_x = circle_win_count_start_x + (2*number_digits_generic_width) -1;//pixel is included
parameter circle_win_count_end_y = circle_win_count_start_y + (number_digits_generic_height) -1;//pixel is included

parameter circle_last_cell_start_x =570; //pixel is included
parameter circle_last_cell_start_y = 430; //pixel is included
parameter circle_last_cell_end_x = circle_last_cell_start_x + (2*number_digits_generic_width) -1;//pixel is included
parameter circle_last_cell_end_y = circle_last_cell_start_y + (number_digits_generic_height) -1;//pixel is included

//game_status parameters
parameter game_status_start_x = 280;//pixel is included
parameter game_status_start_y = 390;//pixel is included
parameter game_status_width = 80;
parameter game_status_height = 80;
parameter game_status_end_x = game_status_start_x + game_status_width -1;//pixel is included
parameter game_status_end_y = game_status_start_y+game_status_height - 1;//pixel is included


always @(h_count, v_count)
	begin
		if(h_count<H_VISIBLE_AREA && v_count<V_VISIBLE_AREA) 
			begin
					//game status checks 
					if(( game_status_start_x<= h_count && h_count <= game_status_end_x) && ( game_status_start_y<= v_count && v_count <= game_status_end_y))
						begin
							if(game_status == 1)//circle wins
								begin
									//relative horizontal count -> (		(h_count-game_status_start_x)	)
									//relative vertical count   -> (		(v_count-game_status_start_y)	)
									red_8bit = 32*circle_winner_r[(h_count-game_status_start_x)+game_status_width*(v_count-game_status_start_y)]+31;
									green_8bit =  32*circle_winner_g[(h_count-game_status_start_x)+game_status_width*(v_count-game_status_start_y)]+31;
									blue_8bit =  32*circle_winner_b[(h_count-game_status_start_x)+game_status_width*(v_count-game_status_start_y)]+31;
								end
							else if(game_status == 2)//triangle wins
								begin
									//relative horizontal count -> (		(h_count-game_status_start_x)	)
									//relative vertical count   -> (		(v_count-game_status_start_y)	)
									red_8bit = 32*triangle_winner_r[(h_count-game_status_start_x)+game_status_width*(v_count-game_status_start_y)]+31;
									green_8bit =  32*triangle_winner_g[(h_count-game_status_start_x)+game_status_width*(v_count-game_status_start_y)]+31;
									blue_8bit =  32*triangle_winner_b[(h_count-game_status_start_x)+game_status_width*(v_count-game_status_start_y)]+31;
								end
							else
								begin
									red_8bit = 8'hFF;
									green_8bit =  8'hFF;
									blue_8bit =  8'hFF;
								end
								
						end
					//TODO
					//circle last cell checks
					else if( ( circle_last_cell_start_x<= h_count && h_count <= circle_last_cell_end_x) && ( circle_last_cell_start_y<= v_count && v_count <= circle_last_cell_end_y) )
						begin
							//relative horizontal count -> (		(h_count-circle_last_cell_start_x)	)
							//relative vertical count   -> (		(v_count-circle_last_cell_start_y)	)
							//relative horizontal count -> (		(h_count-circle_last_cell_start_x-number_digits_generic_width)	)
							//relative vertical count   -> (		(v_count-circle_last_cell_start_y)	)			
							if( (h_count-circle_last_cell_start_x)<number_digits_generic_width ) //significant digit (should be letter)						
								begin
									red_8bit = 32*letter_digits_generic_r[(h_count-circle_last_cell_start_x) +(v_count-circle_last_cell_start_y)*letter_digits_whole_data_width+(circle_last_cell_sig*letter_digits_generic_width)]+31;
									green_8bit =  32*letter_digits_generic_r[(h_count-circle_last_cell_start_x) +(v_count-circle_last_cell_start_y)*letter_digits_whole_data_width+(circle_last_cell_sig*letter_digits_generic_width)]+31;
									blue_8bit =  32*letter_digits_generic_r[(h_count-circle_last_cell_start_x) +(v_count-circle_last_cell_start_y)*letter_digits_whole_data_width+(circle_last_cell_sig*letter_digits_generic_width)]+31;	
								end
							else //least digit (should be number)	
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-circle_last_cell_start_x-number_digits_generic_width) +(v_count-circle_last_cell_start_y)*number_digits_whole_data_width+(circle_last_cell_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-circle_last_cell_start_x-number_digits_generic_width) +(v_count-circle_last_cell_start_y)*number_digits_whole_data_width+(circle_last_cell_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-circle_last_cell_start_x-number_digits_generic_width) +(v_count-circle_last_cell_start_y)*number_digits_whole_data_width+(circle_last_cell_lst*number_digits_generic_width)]+31;	
								end
								
						end
					//circle win count checks
					else if( ( circle_win_count_start_x<= h_count && h_count <=circle_win_count_end_x) && ( circle_win_count_start_y<= v_count && v_count <= circle_win_count_end_y) )
						begin
							//relative horizontal count -> (		(h_count-circle_win_count_start_x)	)
							//relative vertical count   -> (		(v_count-circle_win_count_start_y)	)
							//relative horizontal count -> (		(h_count-circle_win_count_start_x-number_digits_generic_width)	)
							//relative vertical count   -> (		(v_count-circle_win_count_start_y)	)			
							if( (h_count-circle_win_count_start_x)<number_digits_generic_width ) //significant digit						
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-circle_win_count_start_x) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(circle_win_count_sig*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-circle_win_count_start_x) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(circle_win_count_sig*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-circle_win_count_start_x) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(circle_win_count_sig*number_digits_generic_width)]+31;	
								end
							else //least digit
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-circle_win_count_start_x-number_digits_generic_width) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(circle_win_count_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-circle_win_count_start_x-number_digits_generic_width) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(circle_win_count_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-circle_win_count_start_x-number_digits_generic_width) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(circle_win_count_lst*number_digits_generic_width)]+31;	
								end
								
						end
					//circle move count checks
					else if( ( circle_move_count_start_x<= h_count && h_count <= circle_move_count_end_x) && ( circle_move_count_start_y<= v_count && v_count <= circle_move_count_end_y) )
						begin
							//relative horizontal count -> (		(h_count-triangle_move_count_start_x)	)
							//relative vertical count   -> (		(v_count-triangle_move_count_start_y)	)
							//relative horizontal count -> (		(h_count-triangle_move_count_start_x-number_digits_generic_width)	)
							//relative vertical count   -> (		(v_count-triangle_move_count_start_y)	)			
							if( (h_count-circle_move_count_start_x)<number_digits_generic_width ) //significant digit						
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-circle_move_count_start_x) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(circle_move_count_sig*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-circle_move_count_start_x) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(circle_move_count_sig*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-circle_move_count_start_x) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(circle_move_count_sig*number_digits_generic_width)]+31;	
								end
							else //least digit
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-circle_move_count_start_x-number_digits_generic_width) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(circle_move_count_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-circle_move_count_start_x-number_digits_generic_width) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(circle_move_count_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-circle_move_count_start_x-number_digits_generic_width) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(circle_move_count_lst*number_digits_generic_width)]+31;	
								end
								
						end
						
					//triangle last cell checks
					else if( ( triangle_last_cell_start_x<= h_count && h_count <= triangle_last_cell_end_x) && ( triangle_last_cell_start_y<= v_count && v_count <= triangle_last_cell_end_y) )
						begin
							//relative horizontal count -> (		(h_count-triangle_last_cell_start_x)	)
							//relative vertical count   -> (		(v_count-triangle_last_cell_start_y)	)
							//relative horizontal count -> (		(h_count-triangle_last_cell_start_x-number_digits_generic_width)	)
							//relative vertical count   -> (		(v_count-triangle_last_cell_start_y)	)			
							if( (h_count-triangle_last_cell_start_x)<number_digits_generic_width ) //significant digit (should be letter)						
								begin
									red_8bit = 32*letter_digits_generic_r[(h_count-triangle_last_cell_start_x) +(v_count-triangle_last_cell_start_y)*letter_digits_whole_data_width+(triangle_last_cell_sig*letter_digits_generic_width)]+31;
									green_8bit =  32*letter_digits_generic_r[(h_count-triangle_last_cell_start_x) +(v_count-triangle_last_cell_start_y)*letter_digits_whole_data_width+(triangle_last_cell_sig*letter_digits_generic_width)]+31;
									blue_8bit =  32*letter_digits_generic_r[(h_count-triangle_last_cell_start_x) +(v_count-triangle_last_cell_start_y)*letter_digits_whole_data_width+(triangle_last_cell_sig*letter_digits_generic_width)]+31;	
								end
							else //least digit (should be number)	
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-triangle_last_cell_start_x-number_digits_generic_width) +(v_count-triangle_last_cell_start_y)*number_digits_whole_data_width+(triangle_last_cell_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-triangle_last_cell_start_x-number_digits_generic_width) +(v_count-triangle_last_cell_start_y)*number_digits_whole_data_width+(triangle_last_cell_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-triangle_last_cell_start_x-number_digits_generic_width) +(v_count-triangle_last_cell_start_y)*number_digits_whole_data_width+(triangle_last_cell_lst*number_digits_generic_width)]+31;	
								end
								
						end
					//triangle win count checks
					else if( ( triangle_win_count_start_x<= h_count && h_count <= triangle_win_count_end_x) && ( triangle_win_count_start_y<= v_count && v_count <= triangle_win_count_end_y) )
						begin
							//relative horizontal count -> (		(h_count-triangle_win_count_start_x)	)
							//relative vertical count   -> (		(v_count-triangle_win_count_start_y)	)
							//relative horizontal count -> (		(h_count-triangle_win_count_start_x-number_digits_generic_width)	)
							//relative vertical count   -> (		(v_count-triangle_win_count_start_y)	)			
							if( (h_count-triangle_win_count_start_x)<number_digits_generic_width ) //significant digit						
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-triangle_win_count_start_x) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(triangle_win_count_sig*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-triangle_win_count_start_x) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(triangle_win_count_sig*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-triangle_win_count_start_x) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(triangle_win_count_sig*number_digits_generic_width)]+31;	
								end
							else //least digit
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-triangle_win_count_start_x-number_digits_generic_width) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(triangle_win_count_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-triangle_win_count_start_x-number_digits_generic_width) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(triangle_win_count_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-triangle_win_count_start_x-number_digits_generic_width) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(triangle_win_count_lst*number_digits_generic_width)]+31;	
								end
								
						end
					//triangle move count checks
					else if( ( triangle_move_count_start_x<= h_count && h_count <= triangle_move_count_end_x) && ( triangle_move_count_start_y<= v_count && v_count <= triangle_move_count_end_y) )
						begin
							//relative horizontal count -> (		(h_count-triangle_move_count_start_x)	)
							//relative vertical count   -> (		(v_count-triangle_move_count_start_y)	)
							//relative horizontal count -> (		(h_count-triangle_move_count_start_x-number_digits_generic_width)	)
							//relative vertical count   -> (		(v_count-triangle_move_count_start_y)	)			
							if( (h_count-triangle_move_count_start_x)<number_digits_generic_width ) //significant digit						
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-triangle_move_count_start_x) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(triangle_move_count_sig*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-triangle_move_count_start_x) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(triangle_move_count_sig*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-triangle_move_count_start_x) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(triangle_move_count_sig*number_digits_generic_width)]+31;	
								end
							else //least digit
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-triangle_move_count_start_x-number_digits_generic_width) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(triangle_move_count_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-triangle_move_count_start_x-number_digits_generic_width) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(triangle_move_count_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-triangle_move_count_start_x-number_digits_generic_width) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(triangle_move_count_lst*number_digits_generic_width)]+31;	
								end
								
						end
						
					//informative symbol checks
					//informative symbols for triangle (1)
					else if( ( informative_symbols_1_start_x<= h_count && h_count <= informative_symbols_1_end_x) && ( informative_symbols_1_start_y<= v_count && v_count <= informative_symbols_1_end_y) )
						begin
							//relative horizontal count -> (		(h_count-informative_symbols_1_start_x)	)
							//relative vertical count   -> (		(v_count-informative_symbols_1_end_y)	)							
							red_8bit = 32*informative_symbols_r[(h_count-informative_symbols_1_start_x) + informative_symbols_width*(v_count-informative_symbols_1_start_y)]+31;
							green_8bit =  32*informative_symbols_g[(h_count-informative_symbols_1_start_x) + informative_symbols_width*(v_count-informative_symbols_1_start_y)]+31;
							blue_8bit =  32*informative_symbols_b[(h_count-informative_symbols_1_start_x) + informative_symbols_width*(v_count-informative_symbols_1_start_y)]+31;		
						end
					//informative symbols for circle (2)
					else if( ( informative_symbols_2_start_x<= h_count && h_count <= informative_symbols_2_end_x) && ( informative_symbols_2_start_y<= v_count && v_count <= informative_symbols_2_end_y) )
						begin
							//relative horizontal count -> (		(h_count-informative_symbols_2_start_x)	)
							//relative vertical count   -> (		(v_count-informative_symbols_2_end_y)	)							
							red_8bit = 32*informative_symbols_r[(h_count-informative_symbols_2_start_x) + informative_symbols_width*(v_count-informative_symbols_2_start_y)]+31;
							green_8bit =  32*informative_symbols_g[(h_count-informative_symbols_2_start_x) + informative_symbols_width*(v_count-informative_symbols_2_start_y)]+31;
							blue_8bit =  32*informative_symbols_b[(h_count-informative_symbols_2_start_x) + informative_symbols_width*(v_count-informative_symbols_2_start_y)]+31;		
						end
						
					//triangle turn checks
					else if( ( triangle_turn_start_x<= h_count && h_count <= triangle_turn_end_x) && ( triangle_turn_start_y<= v_count && v_count <= triangle_turn_end_y) )
						begin
							//relative horizontal count -> (		(h_count-triangle_turn_start_x)	)
							//relative vertical count   -> (		(v_count-triangle_turn_start_y)	)
							if (whose_turn == 2)//10 triangle's turn
								begin
									red_8bit = 32*triangle_turn_active_r[(h_count-triangle_turn_start_x) + triangle_turn_width*(v_count-triangle_turn_start_y)]+31;
									green_8bit =  32*triangle_turn_active_g[(h_count-triangle_turn_start_x) + triangle_turn_width*(v_count-triangle_turn_start_y)]+31;
									blue_8bit =  32*triangle_turn_active_b[(h_count-triangle_turn_start_x) + triangle_turn_width*(v_count-triangle_turn_start_y)]+31;
								end
							else// not triangle's turn
								begin
									red_8bit = 32*triangle_turn_pasive_r[(h_count-triangle_turn_start_x) + triangle_turn_width*(v_count-triangle_turn_start_y)]+31;
									green_8bit =  32*triangle_turn_pasive_g[(h_count-triangle_turn_start_x) + triangle_turn_width*(v_count-triangle_turn_start_y)]+31;
									blue_8bit =  32*triangle_turn_pasive_b[(h_count-triangle_turn_start_x) + triangle_turn_width*(v_count-triangle_turn_start_y)]+31;
								end
						end
						
					//circle turn checks						
					else if (( circle_turn_start_x<= h_count && h_count <= circle_turn_end_x) && ( circle_turn_start_y<= v_count && v_count <= circle_turn_start_y+circle_turn_height-1) )
						begin
							//relative horizontal count -> (		(h_count-circle_turn_start_x)	)
							//relative vertical count   -> (		(v_count-circle_turn_start_y)	)
							if (whose_turn == 1)//01 circle's turn
								begin
									red_8bit = 32*circle_turn_active_r[(h_count-circle_turn_start_x) +circle_turn_width*(v_count-circle_turn_start_y)]+31;
									green_8bit =  32*circle_turn_active_g[(h_count-circle_turn_start_x) + circle_turn_width*(v_count-circle_turn_start_y)]+31;
									blue_8bit =  32*circle_turn_active_b[(h_count-circle_turn_start_x) + circle_turn_width*(v_count-circle_turn_start_y)]+31;
								end
							else// not circle's turn
								begin
									red_8bit = 32*circle_turn_pasive_r[(h_count-circle_turn_start_x) +circle_turn_width*(v_count-circle_turn_start_y)]+31;
									green_8bit =  32*circle_turn_pasive_g[(h_count-circle_turn_start_x) + circle_turn_width*(v_count-circle_turn_start_y)]+31;
									blue_8bit =  32*circle_turn_pasive_b[(h_count-circle_turn_start_x) + circle_turn_width*(v_count-circle_turn_start_y)]+31;
								end
						end						
						
					// grid letters related checks
					else if( ( grid_letters_start_x<= h_count && h_count <= grid_letters_end_x) && ( grid_letters_start_y<= v_count && v_count <= grid_letters_end_y) )
						begin
							//relative horizontal count -> (		(h_count-grid_letters_start_x) 		)
							//relative vertical count   -> (		(v_count-grid_letters_start_y)		)
							red_8bit = 32*grid_letters_r[(h_count-grid_letters_start_x)+ grid_letters_width*(v_count-grid_letters_start_y) ]+31;
							green_8bit =  32*grid_letters_g[(h_count-grid_letters_start_x)+ grid_letters_width*(v_count-grid_letters_start_y)]+31;
							blue_8bit =  32*grid_letters_b[(h_count-grid_letters_start_x)+ grid_letters_width*(v_count-grid_letters_start_y)]+31;	
						end
					// grid numbers related checks
					else if( ( grid_numbers_start_x<= h_count && h_count <= grid_numbers_end_x) && ( grid_numbers_start_y<= v_count && v_count <= grid_numbers_end_y) )
						begin
							//relative horizontal count -> (		(h_count-grid_numbers_start_x) 		)
							//relative vertical count   -> (		(v_count-grid_numbers_start_y)		)
							red_8bit = 32*grid_numbers_r[(h_count-grid_numbers_start_x)+ grid_numbers_width*(v_count-grid_numbers_start_y) ]+31;
							green_8bit =  32*grid_numbers_g[(h_count-grid_numbers_start_x)+ grid_numbers_width*(v_count-grid_numbers_start_y)]+31;
							blue_8bit =  32*grid_numbers_b[(h_count-grid_numbers_start_x)+ grid_numbers_width*(v_count-grid_numbers_start_y)]+31;	
						end	
					//grid related checks
					else if( ( grid_start_x<= h_count && h_count <= grid_end_x) && ( grid_start_y<= v_count && v_count <= grid_end_y) ) // the related pixel is inside the grid.
						begin
							//relative horizontal count -> (		(h_count-grid_start_x) % cell_width		)
							//relative vertical count   -> (		(v_count-grid_start_y) % cell_height	)
							//relative cell -> {(relative horizontal count)+cell_width*(relative vertical count)}/cell_width €[0,99]							
							red_8bit = 32*triangle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
							green_8bit =  32*triangle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
							blue_8bit =  32*triangle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;											
						end
					else //default case -> set pixel to white
						begin
							red_8bit = 8'hFF;
							green_8bit =  8'hFF;
							blue_8bit =  8'hFF;
						end					
			end			
		else
			begin 
			red_8bit =  8'h00; //Be sure that this is zero, otherwise an error occurs ?
			green_8bit = 8'h00;//Be sure that this is zero, otherwise an error occurs ?
			blue_8bit =  8'h00;//Be sure that this is zero, otherwise an error occurs ?
			end
	end

endmodule

