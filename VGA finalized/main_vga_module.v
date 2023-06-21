
module main_vga_module(clock_builtin_50MHZ,clock_out_25MHZ, h_sync, v_sync,v_sync_led, red_8bit, green_8bit, blue_8bit);
input clock_builtin_50MHZ;
output h_sync, v_sync;

//input [399:0] grid_data;// grid consists of 100 individual cells. Each cell has 12 states so that 4 bit is neccessary to express its state. MSB -> LSB
output reg [7:0] red_8bit;
output reg [7:0] green_8bit;
output reg [7:0] blue_8bit;

output reg v_sync_led;

reg [2:0] triangle_r [1023:0];//32^2
reg [2:0] triangle_g [1023:0];//32^2
reg [2:0] triangle_b [1023:0];//32^2

reg [2:0] triangle_turn_active_r [12599:0];//90x140
reg [2:0] triangle_turn_active_g [12599:0];//90x140
reg [2:0] triangle_turn_active_b [12599:0];//90x140

output clock_out_25MHZ;
wire [10:0] h_count, v_count;

clock_divider instance_1(.clk(clock_builtin_50MHZ), .clk_25(clock_out_25MHZ));
horizontal_and_vertical_counter instance_2(.clk_25(clock_out_25MHZ),.h_count(h_count), .h_sync(h_sync), .v_count(v_count), .v_sync(v_sync));

parameter H_VISIBLE_AREA = 640;
parameter V_VISIBLE_AREA = 480;

integer i,j;//dummy variables to be used in for loops


//test registers 
parameter whose_turn = 2;

//parameters used in testing 


initial
	begin
		// import image pixels from .mem files
		$readmemb("memb_files/triangle_dummy_r.txt",triangle_r);
		$readmemb("memb_files/triangle_dummy_g.txt",triangle_g);
		$readmemb("memb_files/triangle_dummy_b.txt",triangle_b);
		
		$readmemb("memb_files/triangle_turn_active_r.txt",triangle_turn_active_r);
		$readmemb("memb_files/triangle_turn_active_g.txt",triangle_turn_active_g);
		$readmemb("memb_files/triangle_turn_active_b.txt",triangle_turn_active_b);
	end	

//grid parameters
parameter grid_start_x = 160; // pixel is included
parameter grid_start_y = 30; // pixel is included
parameter cell_width = 32;
parameter cell_height = 32;
parameter grid_end_x = grid_start_x+(cell_width*10) -1; //pixel is included
parameter grid_end_y = grid_start_y+(cell_height*10) -1; //pixel is included

//triangle turn parameters
parameter triangle_turn_start_x = 10;
parameter triangle_turn_start_y = 130;
parameter triangle_turn_width = 90;
parameter triangle_turn_height = 140;


always @(h_count, v_count)
	begin
		if(h_count<H_VISIBLE_AREA && v_count<V_VISIBLE_AREA) 
			begin
						//triangleturn checks
						if( ( triangle_turn_start_x<= h_count && h_count <= triangle_turn_start_x) && ( triangle_turn_start_y<= v_count && v_count <= triangle_turn_start_y) )
							begin
								//relative horizontal count -> (		(h_count-triangle_turn_start_x) % triangle_turn_width		)
								//relative vertical count   -> (		(v_count-triangle_turn_start_y) % triangle_turn_height	)
								if (whose_turn == 2)//10
									begin
										red_8bit <= 32*triangle_turn_active_r[(		(h_count-triangle_turn_start_x) % triangle_turn_width		) + triangle_turn_width*(		(v_count-triangle_turn_start_y) % triangle_turn_height	) ];
										green_8bit <=  32*triangle_turn_active_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)];
										blue_8bit <=  32*triangle_turn_active_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)];
									end
							end
						
						
						//grid related checks
						if( ( grid_start_x<= h_count && h_count <= grid_end_x) && ( grid_start_y<= v_count && v_count <= grid_end_y) ) // the related pixel is inside the grid.
							begin
								//relative horizontal count -> (		(h_count-grid_start_x) % cell_width		)
								//relative vertical count   -> (		(v_count-grid_start_y) % cell_height	)
								//relative cell -> {(relative horizontal count)+cell_width*(relative vertical count)}/cell_width €[0,99]																
								red_8bit <= 32*triangle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ];
								green_8bit <=  32*triangle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)];
								blue_8bit <=  32*triangle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)];											
							end
						else //default case -> set pixel to white
							begin
								red_8bit <= 8'hFF;
								green_8bit <=  8'hFF;
								blue_8bit <=  8'hFF;
							end					
					end			
		else
			begin 
			red_8bit <=  8'h00; //Be sure that this is zero, otherwise an error occurs ?
			green_8bit <= 8'h00;//Be sure that this is zero, otherwise an error occurs ?
			blue_8bit <=  8'h00;//Be sure that this is zero, otherwise an error occurs ?
			end
	end

endmodule

