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
             
//state assignments
parameter setup_state = 0;
parameter triangle_inputting_state = 1;
parameter triangle_input_formatting_state= 2;
parameter triangle_input_is_correct_state = 3;
parameter triangle_input_is_wrong_state = 60;
parameter triangle_input_range_validation_state = 61;


parameter delay_error_state_with_blinking_1000ms = 254;
parameter delay_state_300ms = 255;


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
			
			setup_state: //this state is only used when FPGA is powered up.
				begin
					// variables
					state_now <= triangle_inputting_state ; //next state 
					game_status <= triangle_is_inputing_status;
					
					state_to_be_returned <= 0;
					delay_300ms_counter <= 0;					
					
					triangle_x<= 15;
					triangle_y <= 15;
					//outputs & inputs
					in_shift_reg <=0 ;
					grid_data <=0;
					whose_turn<=0;
					t_move_count_sig<=0;
					t_move_count_lst<=0;
					t_win_count_sig<=0;
					t_win_count_lst<=0;
					t_last_position_sig<=0;
					t_last_position_lst<=0;
					c_move_count_sig<=0;
					c_move_count_lst<=0;
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
			//===============================================================================
			triangle_inputting_state :
				begin
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
									state_now <= delay_state_300ms; //next state. since button is triggered, do nothing for a 300ms (~debouncing)
									state_to_be_returned <= triangle_input_is_correct_state;
								end
							else
								begin
									state_now <= triangle_input_is_wrong_state;
									game_status <= triangle_input_is_wrong;
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
							
							state_now<= triangle_inputting_state; //TODO
							game_status <= 0; //TODO
				end
			
			
			
			//===============================================================================
			//===============================================================================
			test_state:
				begin
							
				end
			
		endcase	//case logic ends here
	
	end

endmodule

































