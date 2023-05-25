

module jkff_with_asynch_reset(J,K,R,CLK,Q,NQ);

input J,K,R,CLK;
output Q,NQ;
wire w1,w2,w3,w4;

and G1(w1, J, NQ);
not G2(w3, K);
or  G4(w4,w1,w2);
and G3(w2,w3,Q);
d_flip_flop_with_asynch_reset G5(.D(w4),.R(R),.CLK(CLK),.Q(Q),.NQ(NQ));

endmodule

