module main_game_logic_module(not_logic_0, not_logic_1, not_activity, clock_builtin_50MHZ, in_shift_reg, whose_turn,t_move_count_sig, t_move_count_lst, t_win_count_sig, t_win_count_lst, t_last_position_sig, t_last_position_lst, c_move_count_sig, c_move_count_lst, c_win_count_sig, c_win_count_lst, c_last_position_sig, c_last_position_lst);

//input and output port definitions
input not_logic_0;
input not_logic_1;
input not_activity;
input clock_builtin_50MHZ;
output reg [7:0] in_shift_reg; //shifts left, new bit is at the least location
output reg [1:0] whose_turn;
output reg [3:0] t_move_count_sig;
output reg [3:0] t_move_count_lst;
output reg [3:0] t_win_count_sig;
output reg [3:0] t_win_count_lst;
output reg [3:0] t_last_position_sig;
output reg [3:0] t_last_position_lst;
output reg [3:0] c_move_count_sig;
output reg [3:0] c_move_count_lst;
output reg [3:0] c_win_count_sig;
output reg [3:0] c_win_count_lst;
output reg [3:0] c_last_position_sig;
output reg [3:0] c_last_position_lst;

//variables used in the game
reg [7:0] state_now; //there are 256 states to be assigned, which is far more than sufficient.
reg [7:0] state_to_be_returned; // null -> 0
reg [399:0] grid_data;

reg[4:0] game_status;// 32 game status is available
reg[3:0] triangle_x; // null -> 15
reg[3:0] triangle_y; // null -> 15
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
parameter delay_before_new_round_blinking_10s = 19;
parameter delay_error_state_with_blinking_1000ms = 20;
parameter delay_state_300ms = 21;


parameter test_state = 129;

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
		case (state_now)
			
			setup_state: //this state is only used when FPGA is powered up. Or reset button is pressed
				begin
					// variables
					state_now <= triangle_inputting_state ; //next state 
					game_status <= triangle_is_inputing_status;
					
					state_to_be_returned <= 0;
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
					c_move_count_lst<=10;
					c_win_count_sig<=0;
					c_win_count_lst<=0;
					c_last_position_sig<=0;
					c_last_position_lst<=0;
					
					
				end				
			
			delay_state_300ms:
				begin
					if(delay_300ms_counter <= 15000000) // each clock cycle is 20ns
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
					game_status <= triangle_is_inputing_status;
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
					state_now <= triangle_inputting_state;//TODOOOOOO- should go with circle
				end	
			
			//===============================================================================
			triangle_wins_state:				
				begin
					//BE AWARE THAT WIN COUNT ASSUMED TO BE LESS THAN 99.
					//output reg [3:0] t_win_count_sig;
					//output reg [3:0] t_win_count_lst;					
					t_move_count_sig<= 0;
					t_move_count_lst<= 10;
					c_move_count_sig<= 0;
					c_move_count_lst<= 10;
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
						
						state_now = delay_before_new_round_blinking_10s;
						state_to_be_returned <= triangle_inputting_state;
						
				end	
				
				
				//10 saniye delay
			
			
			//===============================================================================
			//####################### CIRCLE RELATED TASKS ##################################
			//===============================================================================
		
	
				
				
		
			
		endcase	//case logic ends here
	
	end

endmodule

































