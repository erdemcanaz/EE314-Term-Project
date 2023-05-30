//`timescale 1ns/1ps

module tb_clock_module();

reg hardware_clk_dummy;
wire clock_module_output;

initial
	begin
		hardware_clk_dummy = 0;
	end

clock_module tested_clock_module(.clk_in(hardware_clk_dummy), .clk_out(clock_module_output));	
	
 initial begin
  // Initialize Inputs
  hardware_clk_dummy = 0;
  // create input clock 50MHz
        forever #10 hardware_clk_dummy = ~hardware_clk_dummy;
 end
 
endmodule











