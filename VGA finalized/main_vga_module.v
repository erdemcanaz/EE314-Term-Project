//plot image
//export image
//initiliaze registers
//import data
//define start,end points and width height
//edit if condition

module main_vga_module(not_change_state_forcefully ,not_logic_0, not_logic_1, not_activity,in_shift_reg, clock_builtin_50MHZ,clock_out_25MHZ, h_sync, v_sync, red_8bit, green_8bit, blue_8bit);
input clock_builtin_50MHZ;
input not_logic_0;
input not_logic_1;
input not_activity;
input not_change_state_forcefully;

output reg [7:0] in_shift_reg; //shifts left, new bit is at the least location
reg [1:0] whose_turn;
reg [3:0] t_move_count_sig;
reg [3:0] t_move_count_lst;
reg [3:0] t_win_count_sig;
reg [3:0] t_win_count_lst;
reg [3:0] t_last_position_sig;
reg [3:0] t_last_position_lst;
reg [3:0] c_move_count_sig;
reg [3:0] c_move_count_lst;
reg [3:0] c_win_count_sig;
reg [3:0] c_win_count_lst;
reg [3:0] c_last_position_sig;
reg [3:0] c_last_position_lst;

//variables used in the game
reg [7:0] state_now; //there are 256 states to be assigned, which is far more than sufficient.
reg [7:0] state_to_be_returned; // null -> 0
reg [399:0] grid_data;

reg[4:0] game_status;// 32 game status is available
reg[3:0] triangle_x; // null -> 15
reg[3:0] triangle_y; // null -> 15
reg[3:0] circle_x; // null -> 15
reg[3:0] circle_y; // null -> 15
reg[31:0] delay_300ms_counter; // 26 bits is neccesarry to count up to 50x10^6   
reg[31:0] delay_error_blinking_1000ms_counter; // 26 bits is neccesarry to count up to 50x10^6 
reg[31:0] delay_before_new_round_blinking_10s_counter; // 26 bits is neccesarry to count up to 50x10^6 
reg[3:0] check_start_x;
reg[3:0] check_start_y; 

//state assignments
parameter setup_state = 0;
parameter triangle_inputting_state = 1;
parameter triangle_input_formatting_state= 2;
parameter triangle_input_is_correct_state = 3;
parameter triangle_input_is_wrong_state = 4;
parameter triangle_input_range_validation_state = 5;
parameter triangle_grid_availability_validation_state = 6;
parameter triangle_put_triangle_to_the_grid_state = 7;
parameter triangle_horizontal_win_check_state = 8;
parameter triangle_horizontal_increment_state = 9;
parameter triangle_vertical_win_check_state = 10;
parameter triangle_vertical_increment_state = 11;
parameter triangle_right_diagonal_win_check_state = 12;
parameter triangle_right_diagonal_increment_state = 13;
parameter triangle_left_diagonal_win_check_state = 14;
parameter triangle_left_diagonal_increment_state = 15;
parameter triangle_update_last_position_state = 16;
parameter triangle_increment_move_count_state = 17;
parameter triangle_wins_state = 18;
parameter circle_inputting_state = 19;
parameter circle_input_formatting_state= 20;
parameter circle_input_is_correct_state = 21;
parameter circle_input_is_wrong_state = 22;
parameter circle_input_range_validation_state = 23;
parameter circle_grid_availability_validation_state = 24;
parameter circle_put_circle_to_the_grid_state = 25;
parameter circle_horizontal_win_check_state = 26;
parameter circle_horizontal_increment_state = 27;
parameter circle_vertical_win_check_state = 28;
parameter circle_vertical_increment_state = 29;
parameter circle_right_diagonal_win_check_state = 30;
parameter circle_right_diagonal_increment_state = 31;
parameter circle_left_diagonal_win_check_state = 32;
parameter circle_left_diagonal_increment_state = 33;
parameter circle_update_last_position_state = 34;
parameter circle_increment_move_count_state = 35;
parameter circle_wins_state = 36;
parameter delay_before_new_round_blinking_10s = 37;
parameter delay_error_state_with_blinking_1000ms = 38;
parameter delay_state_300ms = 39;
parameter circle_wins_clear_table = 40;
parameter triangle_wins_clear_table = 41;

//game status assignments 
parameter setup_status = 0;
parameter triangle_is_inputing_status = 1;
parameter triangle_input_is_wrong = 2;

initial
	begin
		game_status <=setup_status;
		state_now <= 0;
		state_to_be_returned <= 0;
	end

always @(posedge clock_builtin_50MHZ)
	begin
		if(not_change_state_forcefully == 0)
			begin
				if(whose_turn==2)
					begin
						state_now<=triangle_inputting_state;
					end
				else	
					begin
						state_now<=circle_inputting_state;
					end
				
			end
		else
			begin
					case (state_now)
			
			setup_state: //this state is only used when FPGA is powered up. Or reset button is pressed
				begin
					// variables
					state_now <= triangle_inputting_state ; //next state 
					game_status <= triangle_is_inputing_status;
					
					state_to_be_returned <= 1;
					delay_300ms_counter <= 0;					
					
					triangle_x<= 15;
					triangle_y <= 15;
					
					check_start_x<=0;
					check_start_y<=0;
					//outputs & inputs
					in_shift_reg <=0 ;
					grid_data <=0;
					whose_turn<=0;
					t_move_count_sig<=0;
					t_move_count_lst<=0;
					t_win_count_sig<=0;
					t_win_count_lst<=0;
					t_last_position_sig<=0;
					t_last_position_lst<=10;
					c_move_count_sig<=0;
					c_move_count_lst<=0;
					c_win_count_sig<=0;
					c_win_count_lst<=0;
					c_last_position_sig<=0;
					c_last_position_lst<=10;
					
					
				end				
			
			delay_state_300ms:
				begin
					if(delay_300ms_counter <= 25000000) // each clock cycle is 20ns
						begin
							state_now <= delay_state_300ms; //continue sleeping
							delay_300ms_counter <= delay_300ms_counter+1;
						end
					else
						begin
							delay_300ms_counter <=0;
							state_now <=state_to_be_returned;
						end
				end
				
			delay_error_state_with_blinking_1000ms:
				begin
					if(delay_error_blinking_1000ms_counter < 12500000) // each clock cycle is 20ns
						begin
							in_shift_reg <=255;
							delay_error_blinking_1000ms_counter <= delay_error_blinking_1000ms_counter+1;
						end
					else if(delay_error_blinking_1000ms_counter < 25000000)
						begin
							in_shift_reg <=0;
							delay_error_blinking_1000ms_counter <= delay_error_blinking_1000ms_counter+1;
						end
					else if(delay_error_blinking_1000ms_counter < 37500000)
						begin
							in_shift_reg <=255;
							delay_error_blinking_1000ms_counter <= delay_error_blinking_1000ms_counter+1;
						end
					else if(delay_error_blinking_1000ms_counter <= 50000000)
						begin
							in_shift_reg <=0;
							delay_error_blinking_1000ms_counter <=0;
							state_now <=state_to_be_returned;
						end
					else
						begin
							in_shift_reg<=0;
							delay_error_blinking_1000ms_counter <=0;
							state_now <=state_to_be_returned;
						end
				end
			
			delay_before_new_round_blinking_10s:
				begin
					if(delay_before_new_round_blinking_10s_counter < 125000000) // each clock cycle is 20ns
						begin
							in_shift_reg <=255;
							delay_before_new_round_blinking_10s_counter <= delay_before_new_round_blinking_10s_counter+1;
						end
					else if(delay_before_new_round_blinking_10s_counter < 250000000)
						begin
							in_shift_reg <=0;
							delay_before_new_round_blinking_10s_counter <= delay_before_new_round_blinking_10s_counter+1;
						end
					else if(delay_before_new_round_blinking_10s_counter < 375000000)
						begin
							in_shift_reg <=255;
							delay_before_new_round_blinking_10s_counter <= delay_before_new_round_blinking_10s_counter+1;
						end
					else if(delay_before_new_round_blinking_10s_counter <= 500000000)
						begin
							in_shift_reg <=0;
							delay_before_new_round_blinking_10s_counter <=0;
							state_now <=state_to_be_returned;
						end
					else
						begin
							in_shift_reg<=0;
							delay_before_new_round_blinking_10s_counter <=0;
							state_now <=state_to_be_returned;
						end
				end
			
			
			//===============================================================================
			//####################### TRIANGLE RELATED TASKS ################################
			//===============================================================================
			
			triangle_inputting_state :
				begin
					whose_turn<= 2;
					game_status <= 0;//game continue
					if(not_logic_0 == 0)
						begin
							state_now <= delay_state_300ms; //next state. since button is triggered, do nothing for a 300ms (~debouncing)
							state_to_be_returned <= triangle_inputting_state ;
							in_shift_reg <= {in_shift_reg[6:0], 1'b0};  // Shift "0" data in						
						end
					else if(not_logic_1 == 0)
						begin
							state_now <= delay_state_300ms; //next state. since button is triggered, do nothing for a 300ms (~debouncing)
							state_to_be_returned <= triangle_inputting_state ;
							in_shift_reg <= {in_shift_reg[6:0], 1'b1};  // Shift "1" data in			
						end
					else if(not_activity == 0)
						begin
							state_now <= delay_state_300ms; //next state. since button is triggered, do nothing for a 300ms (~debouncing)
							state_to_be_returned <= triangle_input_formatting_state ;
						end
					else
						begin
							state_now <= triangle_inputting_state ; //next state, circulate in this state
						end
						
				end			
			//===============================================================================
			triangle_input_formatting_state:
				begin
							//in_shift_reg[7:0] , [0]-> nth input, [7]-> (n-7)th input;
							// [3]-> x_1dec, [2]->x_2_dec [1]->x_4_dec [0]->x_8_dec
							// [7]-> y_1dec, [6]->y_2dec, [5]->y_4dec, [4]->y_8dec,
							triangle_x[3] <= in_shift_reg[0] ; 
							triangle_x[2] <= in_shift_reg[1] ; 
							triangle_x[1] <= in_shift_reg[2] ; 
							triangle_x[0] <= in_shift_reg[3] ; 
							
							triangle_y[3] <= in_shift_reg[4] ; 
							triangle_y[2] <= in_shift_reg[5] ; 
							triangle_y[1] <= in_shift_reg[6] ; 
							triangle_y[0] <= in_shift_reg[7] ; 
							
							state_now <= triangle_input_range_validation_state;
				end		
			
			//===============================================================================
			triangle_input_range_validation_state:
				begin				
							if(triangle_x<=9 && triangle_y <=9)
								begin
									state_now <= triangle_grid_availability_validation_state; //next state. since button is triggered, do nothing for a 300ms (~debouncing)
								end
							else
								begin
									state_now <= triangle_input_is_wrong_state;
									game_status <= triangle_input_is_wrong;
								end					
				end		
			//===============================================================================
			triangle_grid_availability_validation_state:
				begin
					//4*(x + 10*y) is the first to check (msb bit)
					//4*(x + 10*y)+1 is the second to check
					//4*(x + 10*y)+2 is the third to check
					//4*(x + 10*y)+3 is the fourth to check (lsb bit)
					//available (empty) grid cell -> 0000					
					if( grid_data[4*(triangle_x + 10*triangle_y)]==0 && grid_data[4*(triangle_x + 10*triangle_y)+1] == 0 && grid_data[4*(triangle_x + 10*triangle_y)+2] == 0 && grid_data[4*(triangle_x + 10*triangle_y)+3] == 0)
						begin
							state_now <= triangle_put_triangle_to_the_grid_state;
						end
					else
						begin
							state_now <= triangle_input_is_wrong_state;
						end
				end
			//===============================================================================
			triangle_put_triangle_to_the_grid_state:
				begin
					//4*(x + 10*y) is the first to check (msb bit)
					//4*(x + 10*y)+1 is the second to check
					//4*(x + 10*y)+2 is the third to check
					//4*(x + 10*y)+3 is the fourth to check (lsb bit)
					//triangle grid cell -> 0010 (2)	
					grid_data[4*(triangle_x + 10*triangle_y)] <=0;
					grid_data[4*(triangle_x + 10*triangle_y)+1] <=0;
					grid_data[4*(triangle_x + 10*triangle_y)+2] <=1;
					grid_data[4*(triangle_x + 10*triangle_y)+3] <=0;					
					
					state_now <= triangle_input_is_correct_state;
				end
				
			//===============================================================================
			triangle_horizontal_win_check_state:
				begin
					//4*(check_start_x + 10*check_start_y) is the first to check (msb bit)
					//4*(check_start_x + 10*check_start_y)+1 is the second to check
					//4*(check_start_x + 10*check_start_y)+2 is the third to check
					//4*(check_start_x + 10*check_start_y)+3 is the fourth to check (lsb bit)
					//triangle grid cell -> 0010 (2)	
					
					if( 
					grid_data[4*(check_start_x + 10*check_start_y)]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+1] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+2] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+3] != 0)
						begin
							state_now <= triangle_horizontal_increment_state;
						end
					else if((
					grid_data[4*(check_start_x + 10*check_start_y)+4]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+5] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+6] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+7] != 0))
						begin
							state_now <= triangle_horizontal_increment_state;
						end
					else if((
					grid_data[4*(check_start_x + 10*check_start_y)+8]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+9] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+10] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+11] != 0))
						begin						
							state_now <= triangle_horizontal_increment_state;
						end
					else if(( grid_data[4*(check_start_x + 10*check_start_y)+12]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+13] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+14] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+15] != 0))
						begin						
							state_now <= triangle_horizontal_increment_state;
						end
					else
						begin
						//triangle wins the game
						//cell 1
						grid_data[4*(check_start_x + 10*check_start_y)  ]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+1] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+2] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+3] <=1;
						//cell 2
						grid_data[4*(check_start_x + 10*check_start_y)+4]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+5] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+6] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+7] <=1;
						//cell 3
						grid_data[4*(check_start_x + 10*check_start_y)+8]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+9] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+10] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+11] <=1;
						//cell 4
						grid_data[4*(check_start_x + 10*check_start_y)+12]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+13] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+14] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+15] <=1;
						state_now <= triangle_wins_state;
						end
				end
			//===============================================================================
			triangle_horizontal_increment_state:
				begin
				//check_start_x € {0,1,2,3,4,5,6}
				//check_start_y € {0,1,2,3,4,5,6,7,8,9}
				if(check_start_x <6)//increment x
					begin
						check_start_x <= check_start_x+1;
						state_now <= triangle_horizontal_win_check_state;
					end
				else //increment y
					begin						
					check_start_x<=0;
					if(check_start_y<9)
						begin
							check_start_y <= check_start_y +1;
							state_now <= triangle_horizontal_win_check_state;
						end
					else
						begin
							check_start_x<=0;//first x of the vertical check
							check_start_y<=0;//first y of the vertical check
							state_now<= triangle_vertical_win_check_state;
						end						
					end
					
				end
		
			//===============================================================================
			triangle_vertical_win_check_state:
				begin
					//4*(check_start_x + 10*check_start_y) is the first to check (msb bit)
					//4*(check_start_x + 10*check_start_y)+40 is the second to check
					//4*(check_start_x + 10*check_start_y)+80 is the third to check
					//4*(check_start_x + 10*check_start_y)+120 is the fourth to check (lsb bit)
					//triangle grid cell -> 0010 (2)	
					
					if( 
					grid_data[4*(check_start_x + 10*check_start_y)]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+1] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+2] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+3] != 0)
						begin
							state_now <= triangle_vertical_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+40]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+41] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+42] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+43] != 0))
						begin
							state_now <= triangle_vertical_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+80]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+81] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+82] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+83] != 0))
						begin						
							state_now <= triangle_vertical_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+120]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+121] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+122] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+123] != 0))
						begin						
							state_now <= triangle_vertical_increment_state;
						end
					else
						begin
						//triangle wins the game
						//cell 1
						grid_data[4*(check_start_x + 10*check_start_y)  ]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+1] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+2] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+3] <=0;
						//cell 2
						grid_data[4*(check_start_x + 10*check_start_y)+40]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+41] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+42] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+43] <=0;
						//cell 3
						grid_data[4*(check_start_x + 10*check_start_y)+80]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+81] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+82] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+83] <=0;
						//cell 4
						grid_data[4*(check_start_x + 10*check_start_y)+120]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+121] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+122] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+123] <=0;
						state_now <= triangle_wins_state;
						end
				end
			//===============================================================================
			triangle_vertical_increment_state:
				begin
				//check_start_x € {0,1,2,3,4,5,6,7,8,9}
				//check_start_y € {0,1,2,3,4,5,6}
				if(check_start_x <9)//increment x
					begin
						check_start_x <= check_start_x+1;
						state_now <= triangle_vertical_win_check_state;
					end
				else //increment y
					begin						
					check_start_x<=0;
					if(check_start_y<6)
						begin
							check_start_y <= check_start_y +1;
							state_now <= triangle_vertical_win_check_state;
						end
					else
						begin
							check_start_x<=3;//first x of the right diagonal check
							check_start_y<=0;//first y of the right diagonal check
							state_now<= triangle_right_diagonal_win_check_state;
						end						
					end
					
				end			
			//===============================================================================
			triangle_right_diagonal_win_check_state:
				begin
					//4*(check_start_x + 10*check_start_y) is the first to check (msb bit)
					//4*(check_start_x + 10*check_start_y)+36 is the second to check
					//4*(check_start_x + 10*check_start_y)+72 is the third to check
					//4*(check_start_x + 10*check_start_y)+108 is the fourth to check (lsb bit)
					//triangle grid cell -> 0010 (2)	
					
					if( 
					grid_data[4*(check_start_x + 10*check_start_y)]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+1] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+2] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+3] != 0)
						begin
							state_now <= triangle_right_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+36]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+37] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+38] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+39] != 0))
						begin
							state_now <= triangle_right_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+72]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+73] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+74] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+75] != 0))
						begin						
							state_now <= triangle_right_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+108]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+109] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+110] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+111] != 0))
						begin						
							state_now <= triangle_right_diagonal_increment_state;
						end
					else
						begin
						//triangle wins the game
						//cell 1
						grid_data[4*(check_start_x + 10*check_start_y)  ]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+1] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+2] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+3] <=1;
						//cell 2
						grid_data[4*(check_start_x + 10*check_start_y)+36]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+37] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+38] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+39] <=1;
						//cell 3
						grid_data[4*(check_start_x + 10*check_start_y)+72]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+73] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+74] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+75] <=1;
						//cell 4
						grid_data[4*(check_start_x + 10*check_start_y)+108]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+109] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+110] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+111] <=1;
						state_now <= triangle_wins_state;
						end
				end
			//===============================================================================
			triangle_right_diagonal_increment_state:
				begin
				//check_start_x € {3,4,5,6,7,8,9}
				//check_start_y € {0,1,2,3,4,5,6}
				if(check_start_x <9)//increment x
					begin
						check_start_x <= check_start_x+1;
						state_now <= triangle_right_diagonal_win_check_state;
					end
				else //increment y
					begin						
					check_start_x<=3;
					if(check_start_y<6)
						begin
							check_start_y <= check_start_y +1;
							state_now <= triangle_right_diagonal_win_check_state;
						end
					else
						begin
							check_start_x<=0;//first y of the left diagonal check
							check_start_y<=0;//first y of the left diagonal check
							state_now<= triangle_left_diagonal_win_check_state;
						end						
					end
					
				end	
			
			//===============================================================================
			triangle_left_diagonal_win_check_state:
				begin
					//4*(check_start_x + 10*check_start_y) is the first to check (msb bit)
					//4*(check_start_x + 10*check_start_y)+44 is the second to check
					//4*(check_start_x + 10*check_start_y)+88 is the third to check
					//4*(check_start_x + 10*check_start_y)+132 is the fourth to check (lsb bit)
					//triangle grid cell -> 0010 (2)	
					
					if( 
					grid_data[4*(check_start_x + 10*check_start_y)]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+1] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+2] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+3] != 0)
						begin
							state_now <= triangle_left_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+44]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+45] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+46] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+47] != 0))
						begin
							state_now <= triangle_left_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+88]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+89] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+90] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+91] != 0))
						begin						
							state_now <= triangle_left_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+132]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+133] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+134] != 1 ||
					grid_data[4*(check_start_x + 10*check_start_y)+135] != 0))
						begin						
							state_now <= triangle_left_diagonal_increment_state;
						end
					else
						begin
						//triangle wins the game
						//cell 1
						grid_data[4*(check_start_x + 10*check_start_y)  ]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+1] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+2] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+3] <=0;
						//cell 2
						grid_data[4*(check_start_x + 10*check_start_y)+44]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+45] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+46] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+47] <=0;
						//cell 3
						grid_data[4*(check_start_x + 10*check_start_y)+88]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+89] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+90] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+91] <=0;
						//cell 4
						grid_data[4*(check_start_x + 10*check_start_y)+132]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+133] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+134] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+135] <=0;
						state_now <= triangle_wins_state;
						end
				end
			//===============================================================================
			triangle_left_diagonal_increment_state:
				begin
				//check_start_x € {0,1,2,3,4,5,6}
				//check_start_y € {0,1,2,3,4,5,6}
				if(check_start_x <6)//increment x
					begin
						check_start_x <= check_start_x+1;
						state_now <= triangle_left_diagonal_win_check_state;
					end
				else //increment y
					begin						
					check_start_x<=0;
					if(check_start_y<6)
						begin
							check_start_y <= check_start_y +1;
							state_now <= triangle_left_diagonal_win_check_state;
						end
					else
						begin
							check_start_x<=0;//refresh before circle inputting
							check_start_y<=0;//refresh before circle inputting								
							state_now<= triangle_update_last_position_state; //TODO
						end						
					end
					
				end	
					
			
			//===============================================================================
			triangle_input_is_wrong_state:
				begin			
					in_shift_reg <= 0;
					game_status <= 3; //wrong input;
					state_now <= delay_error_state_with_blinking_1000ms; //next state. since button is triggered, do nothing for a 300ms (~debouncing)
					state_to_be_returned <= triangle_inputting_state ;
							
				end
			
			//===============================================================================
			triangle_input_is_correct_state:
				begin
							in_shift_reg[0] <=triangle_x[0]; 
							in_shift_reg[1] <=triangle_x[1];
							in_shift_reg[2] <=triangle_x[2]; 
							in_shift_reg[3] <=triangle_x[3]; 
							
							in_shift_reg[4] <=triangle_y[0];
							in_shift_reg[5] <=triangle_y[1]; 
							in_shift_reg[6] <=triangle_y[2]; 
							in_shift_reg[7] <=triangle_y[3]; 
							
							check_start_x<=0;//first x of the horizontal check
							check_start_y<=0;//first y of the horizontal check
							state_now<= triangle_horizontal_win_check_state; //TODO
							
							game_status <= 0; //TODO
				end
			
			
			triangle_update_last_position_state:
				begin
					//output reg [3:0] t_last_position_sig;
					//output reg [3:0] t_last_position_lst;
					t_last_position_sig <= triangle_x;
					t_last_position_lst <= triangle_y;
					state_now <= triangle_increment_move_count_state;
				end			
			
			//===============================================================================
			triangle_increment_move_count_state:				
				begin
					//BE AWARE THAT MOVE COUNT ASSUMED TO BE LESS THAN 99.
					//output reg [3:0] t_move_count_sig;
					//output reg [3:0] t_move_count_lst;
					if(t_move_count_lst <9)
						begin
							t_move_count_lst <= t_move_count_lst +1;
						end
					else 
						begin
							t_move_count_lst <= 0;
							t_move_count_sig <= t_move_count_sig +1;
						end
					state_now <= circle_inputting_state;
				end	
			
			//===============================================================================
			triangle_wins_state:				
				begin		
					game_status <= 2;
					state_now <= delay_before_new_round_blinking_10s;
					state_to_be_returned <= triangle_wins_clear_table;	
		
				
				end	
			//===============================================================================
				triangle_wins_clear_table:
					begin
						t_move_count_sig<= 0;
						t_move_count_lst<= 0;
						c_move_count_sig<= 0;
						c_move_count_lst<= 0;
						grid_data <= 0;
						whose_turn <= 2; //triangle's turn
						
						if(t_win_count_lst <9)
							begin
								t_win_count_lst <= t_win_count_lst +1;
							end
						else
							begin
								t_win_count_lst <= 0;
								t_win_count_sig <= t_win_count_sig+1;
							end
							
							state_now <= triangle_inputting_state;
					end
							
			
			//===============================================================================
			//####################### CIRCLE RELATED TASKS ##################################
			//===============================================================================			
			circle_inputting_state :
				begin
					whose_turn<= 1;
					game_status <= 0;//game continue
					if(not_logic_0 == 0)
						begin
							state_now <= delay_state_300ms; //next state. since button is triggered, do nothing for a 300ms (~debouncing)
							state_to_be_returned <= circle_inputting_state ;
							in_shift_reg <= {in_shift_reg[6:0], 1'b0};  // Shift "0" data in						
						end
					else if(not_logic_1 == 0)
						begin
							state_now <= delay_state_300ms; //next state. since button is triggered, do nothing for a 300ms (~debouncing)
							state_to_be_returned <= circle_inputting_state ;
							in_shift_reg <= {in_shift_reg[6:0], 1'b1};  // Shift "1" data in			
						end
					else if(not_activity == 0)
						begin
							state_now <= delay_state_300ms; //next state. since button is triggered, do nothing for a 300ms (~debouncing)
							state_to_be_returned <= circle_input_formatting_state ;
						end
					else
						begin
							state_now <= circle_inputting_state ; //next state, circulate in this state
						end
						
				end			
			//===============================================================================
			circle_input_formatting_state:
				begin
							//in_shift_reg[7:0] , [0]-> nth input, [7]-> (n-7)th input;
							// [3]-> x_1dec, [2]->x_2_dec [1]->x_4_dec [0]->x_8_dec
							// [7]-> y_1dec, [6]->y_2dec, [5]->y_4dec, [4]->y_8dec,
							circle_x[3] <= in_shift_reg[0] ; 
							circle_x[2] <= in_shift_reg[1] ; 
							circle_x[1] <= in_shift_reg[2] ; 
							circle_x[0] <= in_shift_reg[3] ; 
							
							circle_y[3] <= in_shift_reg[4] ; 
							circle_y[2] <= in_shift_reg[5] ; 
							circle_y[1] <= in_shift_reg[6] ; 
							circle_y[0] <= in_shift_reg[7] ; 
							
							state_now <= circle_input_range_validation_state;
				end		
			
			//===============================================================================
			circle_input_range_validation_state:
				begin				
							if(circle_x<=9 && circle_y <=9)
								begin
									state_now <= circle_grid_availability_validation_state; //next state. since button is triggered, do nothing for a 300ms (~debouncing)
								end
							else
								begin
									state_now <= circle_input_is_wrong_state;
									game_status <= 0;
								end					
				end		
			//===============================================================================
			circle_grid_availability_validation_state:
				begin
					//4*(x + 10*y) is the first to check (msb bit)
					//4*(x + 10*y)+1 is the second to check
					//4*(x + 10*y)+2 is the third to check
					//4*(x + 10*y)+3 is the fourth to check (lsb bit)
					//available (empty) grid cell -> 0000					
					if( grid_data[4*(circle_x + 10*circle_y)]==0 && grid_data[4*(circle_x + 10*circle_y)+1] == 0 && grid_data[4*(circle_x + 10*circle_y)+2] == 0 && grid_data[4*(circle_x + 10*circle_y)+3] == 0)
						begin
							state_now <= circle_put_circle_to_the_grid_state;
						end
					else
						begin
							state_now <= circle_input_is_wrong_state;
						end
				end
			//===============================================================================
			circle_put_circle_to_the_grid_state:
				begin
					//4*(x + 10*y) is the first to check (msb bit)
					//4*(x + 10*y)+1 is the second to check
					//4*(x + 10*y)+2 is the third to check
					//4*(x + 10*y)+3 is the fourth to check (lsb bit)
					//circle grid cell -> 0010 (2)	
					grid_data[4*(circle_x + 10*circle_y)] <=0;
					grid_data[4*(circle_x + 10*circle_y)+1] <=0;
					grid_data[4*(circle_x + 10*circle_y)+2] <=0;
					grid_data[4*(circle_x + 10*circle_y)+3] <=1;					
					
					state_now <= circle_input_is_correct_state;
				end
				
			//===============================================================================
			circle_horizontal_win_check_state:
				begin
					//4*(check_start_x + 10*check_start_y) is the first to check (msb bit)
					//4*(check_start_x + 10*check_start_y)+1 is the second to check
					//4*(check_start_x + 10*check_start_y)+2 is the third to check
					//4*(check_start_x + 10*check_start_y)+3 is the fourth to check (lsb bit)
					//circle grid cell -> 0010 (2)	
					
					if( 
					grid_data[4*(check_start_x + 10*check_start_y)]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+1] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+2] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+3] != 1)
						begin
							state_now <= circle_horizontal_increment_state;
						end
					else if((
					grid_data[4*(check_start_x + 10*check_start_y)+4]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+5] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+6] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+7] != 1))
						begin
							state_now <= circle_horizontal_increment_state;
						end
					else if((
					grid_data[4*(check_start_x + 10*check_start_y)+8]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+9] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+10] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+11] != 1))
						begin						
							state_now <= circle_horizontal_increment_state;
						end
					else if(( grid_data[4*(check_start_x + 10*check_start_y)+12]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+13] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+14] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+15] != 1))
						begin						
							state_now <= circle_horizontal_increment_state;
						end
					else
						begin
						//circle wins the game
						grid_data[4*(check_start_x + 10*check_start_y)  ]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+1] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+2] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+3] <=0;
						//cell 2
						grid_data[4*(check_start_x + 10*check_start_y)+4]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+5] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+6] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+7] <=0;
						//cell 3
						grid_data[4*(check_start_x + 10*check_start_y)+8]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+9] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+10] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+11] <=0;
						//cell 4
						grid_data[4*(check_start_x + 10*check_start_y)+12]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+13] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+14] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+15] <=0;
						state_now <= circle_wins_state;
						end
				end
			//===============================================================================
			circle_horizontal_increment_state:
				begin
				//check_start_x € {0,1,2,3,4,5,6}
				//check_start_y € {0,1,2,3,4,5,6,7,8,9}
				if(check_start_x <6)//increment x
					begin
						check_start_x <= check_start_x+1;
						state_now <= circle_horizontal_win_check_state;
					end
				else //increment y
					begin						
					check_start_x<=0;
					if(check_start_y<9)
						begin
							check_start_y <= check_start_y +1;
							state_now <= circle_horizontal_win_check_state;
						end
					else
						begin
							check_start_x<=0;//first x of the vertical check
							check_start_y<=0;//first y of the vertical check
							state_now<= circle_vertical_win_check_state;
						end						
					end
					
				end
		
			//===============================================================================
			circle_vertical_win_check_state:
				begin
					//4*(check_start_x + 10*check_start_y) is the first to check (msb bit)
					//4*(check_start_x + 10*check_start_y)+40 is the second to check
					//4*(check_start_x + 10*check_start_y)+80 is the third to check
					//4*(check_start_x + 10*check_start_y)+120 is the fourth to check (lsb bit)
					//circle grid cell -> 0010 (2)	
					
					if( 
					grid_data[4*(check_start_x + 10*check_start_y)]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+1] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+2] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+3] != 1)
						begin
							state_now <= circle_vertical_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+40]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+41] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+42] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+43] != 1))
						begin
							state_now <= circle_vertical_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+80]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+81] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+82] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+83] != 1))
						begin						
							state_now <= circle_vertical_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+120]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+121] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+122] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+123] != 1))
						begin						
							state_now <= circle_vertical_increment_state;
						end
					else
						begin
						//circle wins the game
						grid_data[4*(check_start_x + 10*check_start_y)  ]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+1] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+2] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+3] <=1;
						//cell 2
						grid_data[4*(check_start_x + 10*check_start_y)+40]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+41] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+42] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+43] <=1;
						//cell 3
						grid_data[4*(check_start_x + 10*check_start_y)+80]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+81] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+82] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+83] <=1;
						//cell 4
						grid_data[4*(check_start_x + 10*check_start_y)+120]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+121] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+122] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+123] <=1;
						state_now <= circle_wins_state;
						end
				end
			//===============================================================================
			circle_vertical_increment_state:
				begin
				//check_start_x € {0,1,2,3,4,5,6,7,8,9}
				//check_start_y € {0,1,2,3,4,5,6}
				if(check_start_x <9)//increment x
					begin
						check_start_x <= check_start_x+1;
						state_now <= circle_vertical_win_check_state;
					end
				else //increment y
					begin						
					check_start_x<=0;
					if(check_start_y<6)
						begin
							check_start_y <= check_start_y +1;
							state_now <= circle_vertical_win_check_state;
						end
					else
						begin
							check_start_x<=3;//first x of the right diagonal check
							check_start_y<=0;//first y of the right diagonal check
							state_now<= circle_right_diagonal_win_check_state;
						end						
					end
					
				end			
			//===============================================================================
			circle_right_diagonal_win_check_state:
				begin
					//4*(check_start_x + 10*check_start_y) is the first to check (msb bit)
					//4*(check_start_x + 10*check_start_y)+36 is the second to check
					//4*(check_start_x + 10*check_start_y)+72 is the third to check
					//4*(check_start_x + 10*check_start_y)+108 is the fourth to check (lsb bit)
					//circle grid cell -> 0010 (2)	
					
					if( 
					grid_data[4*(check_start_x + 10*check_start_y)]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+1] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+2] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+3] != 1)
						begin
							state_now <= circle_right_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+36]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+37] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+38] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+39] != 1))
						begin
							state_now <= circle_right_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+72]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+73] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+74] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+75] != 1))
						begin						
							state_now <= circle_right_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+108]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+109] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+110] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+111] != 1))
						begin						
							state_now <= circle_right_diagonal_increment_state;
						end
					else
						begin
						//circle wins the game
						grid_data[4*(check_start_x + 10*check_start_y)  ]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+1] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+2] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+3] <=1;
						//cell 2
						grid_data[4*(check_start_x + 10*check_start_y)+36]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+37] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+38] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+39] <=1;
						//cell 3
						grid_data[4*(check_start_x + 10*check_start_y)+72]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+73] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+74] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+75] <=1;
						//cell 4
						grid_data[4*(check_start_x + 10*check_start_y)+108]<=0;
						grid_data[4*(check_start_x + 10*check_start_y)+109] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+110] <=1;
						grid_data[4*(check_start_x + 10*check_start_y)+111] <=1;
						state_now <= circle_wins_state;
						end
				end
			//===============================================================================
			circle_right_diagonal_increment_state:
				begin
				//check_start_x € {3,4,5,6,7,8,9}
				//check_start_y € {0,1,2,3,4,5,6}
				if(check_start_x <9)//increment x
					begin
						check_start_x <= check_start_x+1;
						state_now <= circle_right_diagonal_win_check_state;
					end
				else //increment y
					begin						
					check_start_x<=3;
					if(check_start_y<6)
						begin
							check_start_y <= check_start_y +1;
							state_now <= circle_right_diagonal_win_check_state;
						end
					else
						begin
							check_start_x<=0;//first y of the left diagonal check
							check_start_y<=0;//first y of the left diagonal check
							state_now<= circle_left_diagonal_win_check_state;
						end						
					end
					
				end	
			
			//===============================================================================
			circle_left_diagonal_win_check_state:
				begin
					//4*(check_start_x + 10*check_start_y) is the first to check (msb bit)
					//4*(check_start_x + 10*check_start_y)+44 is the second to check
					//4*(check_start_x + 10*check_start_y)+88 is the third to check
					//4*(check_start_x + 10*check_start_y)+132 is the fourth to check (lsb bit)
					//circle grid cell -> 0010 (2)	
					
					if( 
					grid_data[4*(check_start_x + 10*check_start_y)]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+1] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+2] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+3] != 1)
						begin
							state_now <= circle_left_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+44]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+45] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+46] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+47] != 1))
						begin
							state_now <= circle_left_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+88]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+89] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+90] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+91] != 1))
						begin						
							state_now <= circle_left_diagonal_increment_state;
						end
					else if(( 
					grid_data[4*(check_start_x + 10*check_start_y)+132]!=0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+133] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+134] != 0 ||
					grid_data[4*(check_start_x + 10*check_start_y)+135] != 1))
						begin						
							state_now <= circle_left_diagonal_increment_state;
						end
					else
						begin
						//circle wins the game
						grid_data[4*(check_start_x + 10*check_start_y)  ]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+1] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+2] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+3] <=0;
						//cell 2
						grid_data[4*(check_start_x + 10*check_start_y)+44]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+45] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+46] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+47] <=0;
						//cell 3
						grid_data[4*(check_start_x + 10*check_start_y)+88]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+89] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+90] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+91] <=0;
						//cell 4
						grid_data[4*(check_start_x + 10*check_start_y)+132]<=1;
						grid_data[4*(check_start_x + 10*check_start_y)+133] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+134] <=0;
						grid_data[4*(check_start_x + 10*check_start_y)+135] <=0;
						state_now <= circle_wins_state;
						end
				end
			//===============================================================================
				circle_left_diagonal_increment_state:
					begin
					//check_start_x € {0,1,2,3,4,5,6}
					//check_start_y € {0,1,2,3,4,5,6}
					if(check_start_x <6)//increment x
						begin
							check_start_x <= check_start_x+1;
							state_now <= circle_left_diagonal_win_check_state;
						end
					else //increment y
						begin						
						check_start_x<=0;
						if(check_start_y<6)
							begin
								check_start_y <= check_start_y +1;
								state_now <= circle_left_diagonal_win_check_state;
							end
						else
							begin
								check_start_x<=0;//refresh before circle inputting
								check_start_y<=0;//refresh before circle inputting								
								state_now<= circle_update_last_position_state; //TODO
							end						
						end
						
					end	
						
				
				//===============================================================================
				circle_input_is_wrong_state:
					begin			
						in_shift_reg <= 0;
						game_status <= 3; //wrong input;
						state_now <= delay_error_state_with_blinking_1000ms; //next state. since button is triggered, do nothing for a 300ms (~debouncing)
						state_to_be_returned <= circle_inputting_state ;
								
					end
				
				//===============================================================================
				circle_input_is_correct_state:
					begin
								in_shift_reg[0] <=circle_x[0]; 
								in_shift_reg[1] <=circle_x[1];
								in_shift_reg[2] <=circle_x[2]; 
								in_shift_reg[3] <=circle_x[3]; 
								
								in_shift_reg[4] <=circle_y[0];
								in_shift_reg[5] <=circle_y[1]; 
								in_shift_reg[6] <=circle_y[2]; 
								in_shift_reg[7] <=circle_y[3]; 
								
								check_start_x<=0;//first x of the horizontal check
								check_start_y<=0;//first y of the horizontal check
								state_now<= circle_horizontal_win_check_state; //TODO
								
								game_status <= 0; //TODO
					end
				
				
				circle_update_last_position_state:
					begin
						//output reg [3:0] t_last_position_sig;
						//output reg [3:0] t_last_position_lst;
						c_last_position_sig <= circle_x;
						c_last_position_lst <= circle_y;
						state_now <= circle_increment_move_count_state;
					end			
				
				//===============================================================================
				circle_increment_move_count_state:				
					begin
						//BE AWARE THAT MOVE COUNT ASSUMED TO BE LESS THAN 99.
						//output reg [3:0] t_move_count_sig;
						//output reg [3:0] t_move_count_lst;
						if(c_move_count_lst <9)
							begin
								c_move_count_lst <= c_move_count_lst +1;
							end
						else 
							begin
								c_move_count_lst <= 0;
								c_move_count_sig <= c_move_count_sig +1;
							end
						state_now <= triangle_inputting_state;
					end	
				
				//===============================================================================
				circle_wins_state:				
					begin
						game_status <= 1;
						state_now <= delay_before_new_round_blinking_10s;
						state_to_be_returned <= circle_wins_clear_table;		
						
					end
					
				//===============================================================================
				circle_wins_clear_table:
					begin
						//BE AWARE THAT WIN COUNT ASSUMED TO BE LESS THAN 99.
					//output reg [3:0] t_win_count_sig;
					//output reg [3:0] t_win_count_lst;					
					c_move_count_sig<= 0;
					c_move_count_lst<= 0;
					t_move_count_sig<= 0;
					t_move_count_lst<= 0;
					
					t_last_position_sig<=0;
					t_last_position_lst<=10;
					c_last_position_sig<=0;
					c_last_position_lst<=10;
					
					grid_data <= 0;
					whose_turn <= 1; //circle's turn					
					if(c_win_count_lst <9)
						begin
							c_win_count_lst <= c_win_count_lst +1;
						end
					else
						begin
							c_win_count_lst <= 0;
							c_win_count_sig <= c_win_count_sig+1;
						end
						
						state_now <= circle_inputting_state;
					end
				
				
						
					default:
						begin
							state_now <=triangle_inputting_state;
						end
			endcase	//case logic ends here
		
	
			end
	end



output h_sync, v_sync;

//input [399:0] grid_data;// grid consists of 100 individual cells. Each cell has 12 states so that 4 bit is neccessary to express its state. MSB -> LSB
output reg [7:0] red_8bit;
output reg [7:0] green_8bit;
output reg [7:0] blue_8bit;

//grid related images
reg [2:0] dumb_wojak_r[6399:0];//80x80
reg [2:0] dumb_wojak_g[6399:0];//80x80
reg [2:0] dumb_wojak_b[6399:0];//80x80

reg [2:0] deadzone_r [1023:0];//32^2
reg [2:0] deadzone_g [1023:0];//32^2
reg [2:0] deadzone_b [1023:0];//32^2

reg [2:0] empty_grid_r [1023:0];//32^2
reg [2:0] empty_grid_g [1023:0];//32^2
reg [2:0] empty_grid_b [1023:0];//32^2

reg [2:0] triangle_r [1023:0];//32^2
reg [2:0] triangle_g [1023:0];//32^2
reg [2:0] triangle_b [1023:0];//32^2

reg [2:0] right_diagonal_triangle_r [1023:0];//32^2
reg [2:0] right_diagonal_triangle_g [1023:0];//32^2
reg [2:0] right_diagonal_triangle_b [1023:0];//32^2

reg [2:0] left_diagonal_triangle_r [1023:0];//32^2
reg [2:0] left_diagonal_triangle_g [1023:0];//32^2
reg [2:0] left_diagonal_triangle_b [1023:0];//32^2

reg [2:0] vertical_triangle_r [1023:0];//32^2
reg [2:0] vertical_triangle_g [1023:0];//32^2
reg [2:0] vertical_triangle_b [1023:0];//32^2

reg [2:0] horizontal_triangle_r [1023:0];//32^2
reg [2:0] horizontal_triangle_g [1023:0];//32^2
reg [2:0] horizontal_triangle_b [1023:0];//32^2

reg [2:0] circle_r [1023:0];//32^2
reg [2:0] circle_g [1023:0];//32^2
reg [2:0] circle_b [1023:0];//32^2

reg [2:0] right_diagonal_circle_r [1023:0];//32^2
reg [2:0] right_diagonal_circle_g [1023:0];//32^2
reg [2:0] right_diagonal_circle_b [1023:0];//32^2

reg [2:0] left_diagonal_circle_r [1023:0];//32^2
reg [2:0] left_diagonal_circle_g [1023:0];//32^2
reg [2:0] left_diagonal_circle_b [1023:0];//32^2

reg [2:0] vertical_circle_r [1023:0];//32^2
reg [2:0] vertical_circle_g [1023:0];//32^2
reg [2:0] vertical_circle_b [1023:0];//32^2

reg [2:0] horizontal_circle_r [1023:0];//32^2
reg [2:0] horizontal_circle_g [1023:0];//32^2
reg [2:0] horizontal_circle_b [1023:0];//32^2

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


initial
	begin
		// import image pixels from .mem files
		$readmemb("memb_files/dumb_wojak_r.txt",dumb_wojak_r);
		$readmemb("memb_files/dumb_wojak_g.txt",dumb_wojak_g);
		$readmemb("memb_files/dumb_wojak_b.txt",dumb_wojak_b);
		
		$readmemb("memb_files/deadzone_r.txt",deadzone_r);
		$readmemb("memb_files/deadzone_g.txt",deadzone_g);
		$readmemb("memb_files/deadzone_b.txt",deadzone_b);

		$readmemb("memb_files/circle_r.txt",circle_r);
		$readmemb("memb_files/circle_g.txt",circle_g);
		$readmemb("memb_files/circle_b.txt",circle_b);

		$readmemb("memb_files/right_diagonal_circle_r.txt",right_diagonal_circle_r);
		$readmemb("memb_files/right_diagonal_circle_g.txt",right_diagonal_circle_g);
		$readmemb("memb_files/right_diagonal_circle_b.txt",right_diagonal_circle_b);
		
		$readmemb("memb_files/left_diagonal_circle_r.txt",left_diagonal_circle_r);
		$readmemb("memb_files/left_diagonal_circle_g.txt",left_diagonal_circle_g);
		$readmemb("memb_files/left_diagonal_circle_b.txt",left_diagonal_circle_b);

		$readmemb("memb_files/vertical_circle_r.txt",vertical_circle_r);
		$readmemb("memb_files/vertical_circle_g.txt",vertical_circle_g);
		$readmemb("memb_files/vertical_circle_b.txt",vertical_circle_b);

		$readmemb("memb_files/horizontal_circle_r.txt",horizontal_circle_r);
		$readmemb("memb_files/horizontal_circle_g.txt",horizontal_circle_g);
		$readmemb("memb_files/horizontal_circle_b.txt",horizontal_circle_b);
		
		$readmemb("memb_files/empty_grid_r.txt",empty_grid_r);
		$readmemb("memb_files/empty_grid_g.txt",empty_grid_g);
		$readmemb("memb_files/empty_grid_b.txt",empty_grid_b);

		$readmemb("memb_files/triangle_r.txt",triangle_r);
		$readmemb("memb_files/triangle_g.txt",triangle_g);
		$readmemb("memb_files/triangle_b.txt",triangle_b);

		$readmemb("memb_files/right_diagonal_triangle_r.txt",right_diagonal_triangle_r);
		$readmemb("memb_files/right_diagonal_triangle_g.txt",right_diagonal_triangle_g);
		$readmemb("memb_files/right_diagonal_triangle_b.txt",right_diagonal_triangle_b);
		
		$readmemb("memb_files/left_diagonal_triangle_r.txt",left_diagonal_triangle_r);
		$readmemb("memb_files/left_diagonal_triangle_g.txt",left_diagonal_triangle_g);
		$readmemb("memb_files/left_diagonal_triangle_b.txt",left_diagonal_triangle_b);

		$readmemb("memb_files/vertical_triangle_r.txt",vertical_triangle_r);
		$readmemb("memb_files/vertical_triangle_g.txt",vertical_triangle_g);
		$readmemb("memb_files/vertical_triangle_b.txt",vertical_triangle_b);

		$readmemb("memb_files/horizontal_triangle_r.txt",horizontal_triangle_r);
		$readmemb("memb_files/horizontal_triangle_g.txt",horizontal_triangle_g);
		$readmemb("memb_files/horizontal_triangle_b.txt",horizontal_triangle_b);
	
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
							else if(game_status == 3)//dumb wojak
								begin
									//relative horizontal count -> (		(h_count-game_status_start_x)	)
									//relative vertical count   -> (		(v_count-game_status_start_y)	)
									red_8bit = 32*dumb_wojak_r[(h_count-game_status_start_x)+game_status_width*(v_count-game_status_start_y)]+31;
									green_8bit =  32*dumb_wojak_g[(h_count-game_status_start_x)+game_status_width*(v_count-game_status_start_y)]+31;
									blue_8bit =  32*dumb_wojak_b[(h_count-game_status_start_x)+game_status_width*(v_count-game_status_start_y)]+31;
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
									red_8bit = 32*letter_digits_generic_r[(h_count-circle_last_cell_start_x) +(v_count-circle_last_cell_start_y)*letter_digits_whole_data_width+(c_last_position_sig*letter_digits_generic_width)]+31;
									green_8bit =  32*letter_digits_generic_r[(h_count-circle_last_cell_start_x) +(v_count-circle_last_cell_start_y)*letter_digits_whole_data_width+(c_last_position_sig*letter_digits_generic_width)]+31;
									blue_8bit =  32*letter_digits_generic_r[(h_count-circle_last_cell_start_x) +(v_count-circle_last_cell_start_y)*letter_digits_whole_data_width+(c_last_position_sig*letter_digits_generic_width)]+31;	
								end
							else //least digit (should be number)	
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-circle_last_cell_start_x-number_digits_generic_width) +(v_count-circle_last_cell_start_y)*number_digits_whole_data_width+(c_last_position_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-circle_last_cell_start_x-number_digits_generic_width) +(v_count-circle_last_cell_start_y)*number_digits_whole_data_width+(c_last_position_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-circle_last_cell_start_x-number_digits_generic_width) +(v_count-circle_last_cell_start_y)*number_digits_whole_data_width+(c_last_position_lst*number_digits_generic_width)]+31;	
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
									red_8bit = 32*number_digits_generic_r[(h_count-circle_win_count_start_x) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(c_win_count_sig*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-circle_win_count_start_x) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(c_win_count_sig*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-circle_win_count_start_x) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(c_win_count_sig*number_digits_generic_width)]+31;	
								end
							else //least digit
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-circle_win_count_start_x-number_digits_generic_width) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(c_win_count_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-circle_win_count_start_x-number_digits_generic_width) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(c_win_count_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-circle_win_count_start_x-number_digits_generic_width) +(v_count-circle_win_count_start_y)*number_digits_whole_data_width+(c_win_count_lst*number_digits_generic_width)]+31;	
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
									red_8bit = 32*number_digits_generic_r[(h_count-circle_move_count_start_x) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(c_move_count_sig*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-circle_move_count_start_x) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(c_move_count_sig*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-circle_move_count_start_x) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(c_move_count_sig*number_digits_generic_width)]+31;	
								end
							else //least digit
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-circle_move_count_start_x-number_digits_generic_width) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(c_move_count_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-circle_move_count_start_x-number_digits_generic_width) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(c_move_count_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-circle_move_count_start_x-number_digits_generic_width) +(v_count-circle_move_count_start_y)*number_digits_whole_data_width+(c_move_count_lst*number_digits_generic_width)]+31;	
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
									red_8bit = 32*letter_digits_generic_r[(h_count-triangle_last_cell_start_x) +(v_count-triangle_last_cell_start_y)*letter_digits_whole_data_width+(t_last_position_sig*letter_digits_generic_width)]+31;
									green_8bit =  32*letter_digits_generic_r[(h_count-triangle_last_cell_start_x) +(v_count-triangle_last_cell_start_y)*letter_digits_whole_data_width+(t_last_position_sig*letter_digits_generic_width)]+31;
									blue_8bit =  32*letter_digits_generic_r[(h_count-triangle_last_cell_start_x) +(v_count-triangle_last_cell_start_y)*letter_digits_whole_data_width+(t_last_position_sig*letter_digits_generic_width)]+31;	
								end
							else //least digit (should be number)	
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-triangle_last_cell_start_x-number_digits_generic_width) +(v_count-triangle_last_cell_start_y)*number_digits_whole_data_width+(t_last_position_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-triangle_last_cell_start_x-number_digits_generic_width) +(v_count-triangle_last_cell_start_y)*number_digits_whole_data_width+(t_last_position_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-triangle_last_cell_start_x-number_digits_generic_width) +(v_count-triangle_last_cell_start_y)*number_digits_whole_data_width+(t_last_position_lst*number_digits_generic_width)]+31;	
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
									red_8bit = 32*number_digits_generic_r[(h_count-triangle_win_count_start_x) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(t_win_count_sig*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-triangle_win_count_start_x) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(t_win_count_sig*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-triangle_win_count_start_x) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(t_win_count_sig*number_digits_generic_width)]+31;	
								end
							else //least digit
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-triangle_win_count_start_x-number_digits_generic_width) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(t_win_count_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-triangle_win_count_start_x-number_digits_generic_width) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(t_win_count_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-triangle_win_count_start_x-number_digits_generic_width) +(v_count-triangle_win_count_start_y)*number_digits_whole_data_width+(t_win_count_lst*number_digits_generic_width)]+31;	
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
									red_8bit = 32*number_digits_generic_r[(h_count-triangle_move_count_start_x) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(t_move_count_sig*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-triangle_move_count_start_x) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(t_move_count_sig*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-triangle_move_count_start_x) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(t_move_count_sig*number_digits_generic_width)]+31;	
								end
							else //least digit
								begin
									red_8bit = 32*number_digits_generic_r[(h_count-triangle_move_count_start_x-number_digits_generic_width) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(t_move_count_lst*number_digits_generic_width)]+31;
									green_8bit =  32*number_digits_generic_g[(h_count-triangle_move_count_start_x-number_digits_generic_width) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(t_move_count_lst*number_digits_generic_width)]+31;
									blue_8bit =  32*number_digits_generic_b[(h_count-triangle_move_count_start_x-number_digits_generic_width) +(v_count-triangle_move_count_start_y)*number_digits_whole_data_width+(t_move_count_lst*number_digits_generic_width)]+31;	
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
							
							//x = 	(h_count-grid_start_x)/32
							//y =    (v_count-grid_start_y)/32
							//cell_index = 4(x+10y);
							//msb_digit =4*((h_count-grid_start_x)/32  + 10*(v_count-grid_start_y)/32) 
							if(grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) ] == 0 && grid_data[4*(  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+1] == 0 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+2 ] == 1 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) +3] == 0)
								begin
									red_8bit = 32*triangle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
									green_8bit =  32*triangle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
									blue_8bit =  32*triangle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
							end					
							else if(grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) ] == 0 && grid_data[4*(  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+1] == 0 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+2 ] == 0 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) +3] == 1)
								begin
									red_8bit = 32*circle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
									green_8bit =  32*circle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
									blue_8bit =  32*circle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
								end
							else if(grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) ] == 0 && grid_data[4*(  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+1] == 1 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+2 ] == 0 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) +3] == 1)
								begin
									red_8bit = 32*horizontal_triangle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
									green_8bit =  32*horizontal_triangle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
									blue_8bit =  32*horizontal_triangle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
								end
							else if(grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) ] == 0 && grid_data[4*(  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+1] == 1 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+2 ] == 1 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) +3] == 0)
								begin
									red_8bit = 32*vertical_triangle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
									green_8bit =  32*vertical_triangle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
									blue_8bit =  32*vertical_triangle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
								end
							else if(grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) ] == 0 && grid_data[4*(  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+1] == 0 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+2 ] == 1 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) +3] == 1)
								begin
									red_8bit = 32*right_diagonal_triangle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
									green_8bit =  32*right_diagonal_triangle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
									blue_8bit =  32*right_diagonal_triangle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
								end
							else if(grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) ] == 0 && grid_data[4*(  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+1] == 1 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+2 ] == 0 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) +3] == 0)
								begin
									red_8bit = 32*left_diagonal_triangle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
									green_8bit =  32*left_diagonal_triangle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
									blue_8bit =  32*left_diagonal_triangle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
								end
							else if(grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) ] == 1 && grid_data[4*(  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+1] == 0 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+2 ] == 1 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) +3] == 0)
								begin
									red_8bit = 32*horizontal_circle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
									green_8bit =  32*horizontal_circle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
									blue_8bit =  32*horizontal_circle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
								end
							else if(grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) ] == 1 && grid_data[4*(  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+1] == 0 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+2 ] == 0 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) +3] == 1)
								begin
									red_8bit = 32*vertical_circle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
									green_8bit =  32*vertical_circle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
									blue_8bit =  32*vertical_circle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
								end
							else if(grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) ] == 0 && grid_data[4*(  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+1] == 1 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+2 ] == 1 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) +3] == 1)
								begin
									red_8bit = 32*right_diagonal_circle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
									green_8bit =  32*right_diagonal_circle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
									blue_8bit =  32*right_diagonal_circle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
								end
							else if(grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) ] == 1 && grid_data[4*(  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+1] == 0 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) )+2 ] == 0 && grid_data[4* (  ((h_count-grid_start_x)/32)  + (10*((v_count-grid_start_y)/32)) ) +3] == 0)
								begin
									red_8bit = 32*left_diagonal_circle_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
									green_8bit =  32*left_diagonal_circle_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
									blue_8bit =  32*left_diagonal_circle_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
								end		
							else							
								begin
									red_8bit = 32*empty_grid_r[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	) ]+31;
									green_8bit =  32*empty_grid_g[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
									blue_8bit =  32*empty_grid_b[(		(h_count-grid_start_x) % cell_width		) + cell_width*(		(v_count-grid_start_y) % cell_height	)]+31;
								end
		
																		
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

