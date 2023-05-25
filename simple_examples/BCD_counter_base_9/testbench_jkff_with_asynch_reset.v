module testbench_4();
   reg J,K,R,CLK;
	wire Q,NQ;
	parameter half_of_clock_period_ns = 5; 
	parameter initial_period= 50;
	jkff_with_asynch_reset  jkff_with_asynch_reset(.J(J),.K(K),.R(R),.CLK(CLK),.Q(Q),.NQ(NQ));
		
		
	//run clock  ALWAYS
	initial CLK = 0;
	
	always
		begin
			#half_of_clock_period_ns;
			CLK = ~CLK;
		end

	initial
		begin
		J=0;K=0;R=1;//reset	
		#initial_period;
		J=1;K=0;R=0;//set1
		#initial_period;	
		J=0;K=0;R=0;//idle
		#initial_period;	
		J=1;K=1;R=0;//invert (set0)
		#initial_period;	
		J=1;K=0;R=0;//set1
		#initial_period;	
		J=0;K=0;R=0;//idle
		#initial_period;	
		R=1;//reset output
		#initial_period;
		J=0;K=0;R=0;//idle
		
		end
		
		
endmodule









