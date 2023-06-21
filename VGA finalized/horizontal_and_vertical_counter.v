//=================================================
//"VGA Signal 640 x 480 @ 60 Hz Industry standard timing" standarts are used
//=================================================
//General timing
//Screen refresh rate	60 Hz
//Vertical refresh      31.46875 kHz
//Pixel freq.	         25.175 MHz
//=================================================
//Horizontal timing (line)
//Scanline part	Pixels	Time [µs]
//Visible area	640	      25.422045680238
//Front porch	16	         0.63555114200596
//Sync pulse	96				3.8133068520357
//Back porch	48				1.9066534260179
//Whole line	800			31.777557100298
//=================================================
//Vertical timing (frame)
//Frame part	Lines	 	 	Time [ms]
//Visible area	480			15.253227408143
//Front porch	10				0.31777557100298
//Sync pulse	2				0.063555114200596
//Back porch	33				1.0486593843098
//Whole frame	525			16.683217477656
//=================================================

module horizontal_and_vertical_counter(clk_25,h_count,h_sync, v_count, v_sync);
input clk_25; //25 MHZ clock input

output reg [10:0] v_count; //y coordinate of the current pixel
output reg [10:0] h_count; //x coordinate of the current pixel

output h_sync, v_sync;

parameter H_VISIBLE_AREA = 640;//640
parameter H_FRONT_PORCH = 16;//16
parameter H_SYNC_WIDTH = 96;//96
parameter H_BACK_PORCH = 48;//48
parameter H_ROW_LENGTH = H_VISIBLE_AREA+H_FRONT_PORCH+H_SYNC_WIDTH+H_BACK_PORCH;


parameter V_VISIBLE_AREA = 480;//480
parameter V_FRONT_PORCH = 10;//10
parameter V_SYNC_WIDTH = 2; //2
parameter V_BACK_PORCH = 33; //3
parameter V_COLUMN_LENGTH = V_VISIBLE_AREA+ V_FRONT_PORCH+ V_SYNC_WIDTH + V_BACK_PORCH;

//============================================HORIZONTAL=================================================
//||  visible area (0,639) | front porch (640,655) | horizontal sync. (656,751) | back porch (752,799) ||
//=======================================================================================================
assign h_sync = (656<=h_count && h_count <=751) ? 1'b0 : 1'b1;
//============================================VERTICAL===================================================
//||  visible area (0,479) | front porch (480,489) | vertical sync. (490,491) | back porch (492,524)   ||
//=======================================================================================================
assign v_sync = (490<=v_count && v_count <=491) ? 1'b0 : 1'b1;

initial 
	begin
		h_count <=0;
		v_count<= 0;
	end
	
always @(posedge(clk_25)) 
	begin	
		//Increment h_count and v_count----------------------------------
		if(h_count < (H_ROW_LENGTH-1)) 
			begin
				h_count <= h_count +1; // shift pixel to right
			end
		else 
			begin
				h_count <= 0; // start from next row 			
				if(v_count < (V_COLUMN_LENGTH-1))
					begin
						v_count <= v_count + 1; // shift pixel to down
					end
				else
					begin
						v_count <= 0; // start from first row
					end
			end

	end

endmodule
