// This module is a simple D-Latch with level triggering

// D  CLK  Q(t+1)
// 0   0    Q(t)
// 1   0    Q(t)
// 1   1    1
// 0   1    0 

module d_latch_with_asynch_reset(D,R,CLK,Q,NQ);

input D,R,CLK;
output Q, NQ;
wire w1,w2,w3,w4,w5,w6;


not  G1(w1,D);
nand G2(w3,w1,CLK);
nand G3(w2,D,CLK);
or   G4(w6,w2,R);
not  G6(w4,R);
and  G5(w5,w3,w4);
nand G7(NQ,w5,Q);
nand G8(Q,w6,NQ);


endmodule

