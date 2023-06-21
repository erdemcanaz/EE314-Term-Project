module clock_divider(clk, clk_25);

input clk;  //50MHZ hardware clock
output reg clk_25;  //25MHZ clock

initial
	begin
		clk_25 <= 0;
	end
	
always @(posedge clk)
	begin 
	clk_25 <= ~clk_25;
	
	
end

endmodule

