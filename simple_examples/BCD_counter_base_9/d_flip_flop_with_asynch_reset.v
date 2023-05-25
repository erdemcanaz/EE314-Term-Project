

module d_flip_flop_with_asynch_reset(D,R,CLK,Q,NQ);
input D,R,CLK;
output Q,NQ;
wire w1,w2,w3;

d_latch_with_asynch_reset G2(.D(D),.R(0),.CLK(CLK),.Q(w1),.NQ(w2));
not                       G1(w3,CLK);
d_latch_with_asynch_reset G3(.D(w1),.R(R),.CLK(w3),.Q(Q),.NQ(NQ));

endmodule
