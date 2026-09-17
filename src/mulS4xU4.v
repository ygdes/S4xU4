// mulS4xU4.v
// a small multiplier
// © 2026 Yann Guidon

module mulS4xU4(
  input  wire Clk,
  input  wire Rst_n,
  input  wire Sen,
  input  wire Uen,
  input  wire [3:0] S,
  input  wire [3:0] U,
  output wire [7:0] P
);

  // The synchronous input latches:
  wire[3:0] mxS, mxU,
             lS,  lU;
             lSn, lUn;

//  sg13_sdfrbp_1 DffMx(.Q(lS[]), .Q_N(lSn[]), .D(lS[]), .SCD(Sen), .SCE(Phase0), .RESET_B(rst), .CLK(clk));

  // The easy one:
  // P[0] = S[0] & U[0]
  sg13_and2_2 a(.A(S[0]), .B(U[0]), .X(P[0]));

  // 
endmodule
