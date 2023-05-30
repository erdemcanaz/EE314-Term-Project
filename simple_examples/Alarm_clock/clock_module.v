// Clock module that generates 1Hz clock signal
module clock_module(clk_in, clk_out);
input clk_in;
output reg clk_out;

reg [31:0] counter_reg;

parameter clock_counter_max_val = 50000000; //50000000 -> 1Hz
 
initial 
	begin
	counter_reg <= 0;	
	clk_out <= 0;
	end
	
	
//increment counter until 50000000 (50Mhz -> 1 HZ)
always @(posedge clk_in)
	begin
	if(counter_reg == 5)
		begin
		counter_reg <=0;
		clk_out = ~clk_out;
		end
	else
		counter_reg <= counter_reg+1;	
		
	end
endmodule







