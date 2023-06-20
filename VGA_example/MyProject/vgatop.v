module vgatop (clock, Hsynq, Vsynq,clk_25,red, green, blue);
  input clock;
  output Hsynq, Vsynq, clk_25;
  output [7:0] red, green, blue;
   reg redT=0, greenT=0, blueT=0;
	reg redB=0, greenB=0, blueB=0;
	wire clk_25, enable_v;
	wire [15:0] h_count, v_count;
   wire[0:639] templatex;
	reg [10:0] templatey=0;
	
   parameter H_FRONT_PORCH = 16;  // Yatay ön aralık
   parameter H_SYNC_WIDTH = 96;   // Yatay senkronizasyon genişliği
   parameter H_BACK_PORCH = 48;   // Yatay arka aralık
   parameter V_FRONT_PORCH = 10;  // Dikey ön aralık
   parameter V_SYNC_WIDTH = 2;    // Dikey senkronizasyon genişliği
   parameter V_BACK_PORCH = 33;   // Dikey arka aralık
	

	clockdivider u1(clock, clk_25, clk3, clk_bounce);
	horizontal_counter u2(clk_25, enable_v, h_count);
	vertical_counter u3(clk_25, enable_v, v_count);
   fulltemplate u4(templatey, templatex); //combinationally sets 
	
	
  //assign Hsynq = (h_count >= (640 + H_FRONT_PORCH)) && (h_count < (640 + H_FRONT_PORCH + H_SYNC_WIDTH));
  // assign Vsynq = (v_count >= (480 + V_FRONT_PORCH)) && (v_count < (480 + V_FRONT_PORCH + V_SYNC_WIDTH));
	assign Hsynq = (h_count<96) ? 1'b1 : 1'b0;
	assign Vsynq = (v_count<2) ? 1'b1 : 1'b0;
	
	
	assign red = (redT | redB) ? 8'hFF: 8'h00;
	assign green = (greenB | greenT) ? 8'hFF: 8'h00;
	assign blue = (blueB | blueT) ? 8'hFF: 8'h00;
	
	//assign BOX_1 =(h_count<143+81 && h_count>143+58 && v_count<34+320 && v_count>34+296);
	
	always @(h_count, v_count)	begin
	  if((h_count<784 && h_count>143 && v_count<515 && v_count>34)) 
			begin
				 templatey = v_count-35;
				 redT =  templatex[(h_count-144)];
				 greenT = templatex[(h_count-144)];
				 blueT = templatex[(h_count-144)];
	  
			end
	  else 
			begin 
			redT<=0; 
			greenT<=0; 
			blueT<=0; 
			end
	 
	end
	
endmodule 
