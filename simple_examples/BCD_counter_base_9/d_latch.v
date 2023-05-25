// This module is a simple D-Latch with level triggering

// D  CLK  Q(t+1)
// 0   0    Q(t)
// 1   0    Q(t)
// 1   1    1
// 0   1    0 

module d_latch(D,CLK,Q,NQ);

input D,CLK;
output Q, NQ;
wire w1,w2,w3;


nand G1(w1,D,CLK);
not  G3(w3,D);
nand G2(w2,w3,CLK);
nand G4(Q,w1,NQ);
nand G5(NQ,w2,Q);

endmodule

