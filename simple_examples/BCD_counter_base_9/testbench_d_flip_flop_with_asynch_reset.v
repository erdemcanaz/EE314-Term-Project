

module testbench_3();
   reg D,R,CLK;
	wire Q,NQ;
	parameter half_of_clock_period_ns = 5; 
	parameter initial_period= 45;
	d_flip_flop_with_asynch_reset  d_flip_flop_with_asynch_reset(.D(D),.R(R),.CLK(CLK),.Q(Q),.NQ(NQ));
		
		
	//run clock  ALWAYS
	always
		begin
			#half_of_clock_period_ns;
			CLK = ~CLK;
		end

	initial
		begin
		R=0; D=0; CLK =0;		
		#initial_period;
		R=0; D=1;	
		#initial_period;
		R=0; D=1;	
		#initial_period;
		R=1; D=1;
		end
		
endmodule
