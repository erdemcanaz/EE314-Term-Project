module horizontal_counter (clk_25, enable_v, h_count);
	input clk_25;
	output reg enable_v=0;
	output reg [15:0] h_count=0;
	
always @(posedge(clk_25)) begin
	
	if (h_count<799) begin
		h_count<=h_count+1;
		enable_v<=0;
		end
	else begin
		h_count<=0;
		enable_v<=1;
		end
	end
endmodule 