module testbench_jkff_chatgpt;

  // Parameters
  parameter PERIOD = 52;  // Clock period in time units
  parameter HALF_PERIOD = 50;  // Clock period in time units
  
  // Signals
  reg J;
  reg K;
  reg RST;
  reg CLK;

  wire Q;
  wire NQ;

  // Instantiate the JKFlipFlop module
  jkff_chatgpt jkff_chatgpt (
    .J(J),
    .K(K),
    .RST(RST),
    .CLK(CLK),
    .Q(Q),
    .NQ(NQ)
  );

  // Clock generation
  always begin
    CLK = 0;
    #HALF_PERIOD;
    CLK = 1;
    #HALF_PERIOD;
  end

  // Stimulus
  initial begin
    // Reset
    RST = 1;
    #PERIOD;
    RST = 0;
    #PERIOD;

    // Toggle Q
    J = 1;
    K = 1;
    #PERIOD;
    J = 0;
    K = 1;
    #PERIOD;
    J = 1;
    K = 0;
    #PERIOD;
    J = 1;
    K = 1;
    #PERIOD;
	 J = 1;
    K = 0;
    #PERIOD;
	 RST = 1;

    // Finish simulation
    // $finish;
  end

  // Display output
  always @(posedge CLK) begin
    $display("Q = %b, Qbar = %b", Q, NQ);
  end

endmodule
