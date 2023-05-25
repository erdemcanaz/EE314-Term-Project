
module testbench();
	reg D, CLK;
	wire Q,NQ;
	
	
	d_latch  d_latch_1(.D(D),.CLK(CLK),.Q(Q),.NQ(NQ));
	initial
		begin
		D=0;CLK =0;
		#10;
		D=1;CLK = 0;
		#10;
		D=1; CLK = 1;
		#10;
		D=1; CLK = 0;
		#10;
		D=0; CLK = 0;
		#10;
		D=1; CLK = 0;
		#10;
		D=0; CLK = 0;
		#10;
		D=0; CLK = 1;
		#10;
		D=0; CLK = 0;
		
		end

endmodule
