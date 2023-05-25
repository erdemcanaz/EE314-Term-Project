
module testbench_2();
	reg D,R, CLK;
	wire Q,NQ;
	
	
	d_latch_with_asynch_reset  d_latch_with_asynch_reset(.D(D),.R(R),.CLK(CLK),.Q(Q),.NQ(NQ));
	initial
		begin
		R=0; D=0;CLK =0;
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
		
		
		#100;
		D=1;CLK = 1;
		#10;
		D=1; CLK = 0;
		#10;
		R=1;
		
		#100;
		
		R=1; D=0;CLK =0;
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
