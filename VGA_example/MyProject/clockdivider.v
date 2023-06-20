module clockdivider (clk, clk_25, clk3, clk_bounce);

input wire clk;  //50MHZ

output reg clk_25 =0;  //25MHZ

output reg clk3=0;
output reg clk_bounce =0;

parameter div_value1 =0;
parameter div_value2 =150000000;
parameter div_value3 =25000;

integer counter_value1 =0;
integer counter_value2 =0;
integer counter_value3 =0;



always @(posedge clk)
	begin 
	if (counter_value1 == div_value1)
		counter_value1 <=0;
		
	else
		counter_value1 <= counter_value1 +1;
end

always @(posedge clk) clk_25 <= ~clk_25;
		






always @(posedge clk)
	begin 
	if (counter_value2 == div_value2)
		counter_value2 <=0;
		
	else
		counter_value2 <= counter_value2 +1;
end

always @(posedge clk)
begin 
	if(counter_value2== div_value2)
		clk3 <= ~clk3;
	end
	
	
	
	always @(posedge clk)
	begin 
	if (counter_value3 == div_value3)
		counter_value3 <=0;
		
	else
		counter_value3 <= counter_value3 +1;
end

always @(posedge clk)
begin 
	if(counter_value3== div_value3)
		clk_bounce <= ~clk_bounce;
	end
endmodule