
module main_vga_module(clock_builtin_50MHZ,clock_out_25MHZ, h_sync, v_sync,v_sync_led, red_8bit, green_8bit, blue_8bit);
input clock_builtin_50MHZ;
output h_sync, v_sync;

output reg [7:0] red_8bit;
output reg [7:0] green_8bit;
output reg [7:0] blue_8bit;

output reg v_sync_led;
reg [31:0] led_counter;

output clock_out_25MHZ;
wire [10:0] h_count, v_count;

clock_divider instance_1(.clk(clock_builtin_50MHZ), .clk_25(clock_out_25MHZ));
horizontal_and_vertical_counter instance_2(.clk_25(clock_out_25MHZ),.h_count(h_count), .h_sync(h_sync), .v_count(v_count), .v_sync(v_sync));

parameter H_VISIBLE_AREA = 640;
parameter V_VISIBLE_AREA = 480;


always @(h_count, v_count)
	begin
		if(h_count<H_VISIBLE_AREA && v_count<V_VISIBLE_AREA) 
			begin
				//TODO: this values should be decided considering the relative pixel
				//BE AWARE: due to <= operator, the values are assigned at the next cycle.
				
				red_8bit <= 8'hFF;
				green_8bit <=  8'hFF;
				blue_8bit <=  8'hFF;	  
			end 
		else
			begin 
			red_8bit <=  8'h00; //Be sure that this is zero, otherwise an error occurs ?
			green_8bit <= 8'h00;//Be sure that this is zero, otherwise an error occurs ?
			blue_8bit <=  8'h00;//Be sure that this is zero, otherwise an error occurs ?
			end
	end

endmodule

