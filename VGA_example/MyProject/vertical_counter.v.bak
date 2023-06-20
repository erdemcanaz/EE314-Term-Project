module vertical_counter (clk_25, enable_v, v_count);
	input clk_25, enable_v;
	output reg [15:0] v_count=0;
	
always @(posedge(clk_25)) begin          
	
	if(enable_v==1'b1) begin
		if(v_count<524) 
			v_count<=v_count+1;
		else v_count<=0;
		end
	end
endmodule
