
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

output clock_out_25MHZ;
wire [10:0] h_count, v_count;

clock_divider instance_1(.clk(clock_builtin_50MHZ), .clk_25(clock_out_25MHZ));
horizontal_and_vertical_counter instance_2(.clk_25(clock_out_25MHZ),.h_count(h_count), .h_sync(h_sync), .v_count(v_count), .v_sync(v_sync));

parameter H_VISIBLE_AREA = 640;
parameter V_VISIBLE_AREA = 480;

//parameters used in testing 
parameter whose_turn = 2;

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


always @(h_count, v_count)
	begin
		if(h_count<H_VISIBLE_AREA && v_count<V_VISIBLE_AREA) 
			begin
					//triangle turn checks
					if( ( triangle_turn_start_x<= h_count && h_count <= triangle_turn_end_x) && ( triangle_turn_start_y<= v_count && v_count <= triangle_turn_start_y+triangle_turn_height-1) )
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
									red_8bit = 32*triangle_turn_pasive_r[(h_count-triangle_turn_start_x) + triangle_turn_width*(v_count-triangle_turn_start_y)+31];
									green_8bit =  32*triangle_turn_pasive_r[(h_count-triangle_turn_start_x) + triangle_turn_width*(v_count-triangle_turn_start_y)+31];
									blue_8bit =  32*triangle_turn_pasive_r[(h_count-triangle_turn_start_x) + triangle_turn_width*(v_count-triangle_turn_start_y)+31];
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

