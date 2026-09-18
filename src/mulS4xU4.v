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
  // uses the "scan" version for the integrated MUX, and complementary output.
  // (though some negative outputs are not necessary and will be trimmed later)
  wire[3:0] lS, lSn;
  sg13_sdfrbp_1 DffMx(.Q(lS[0]), .Q_N(lSn[0]), .D(lS[0]), .SCD(S[0]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx(.Q(lS[1]), .Q_N(lSn[1]), .D(lS[1]), .SCD(S[1]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx(.Q(lS[2]), .Q_N(lSn[2]), .D(lS[2]), .SCD(S[2]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx(.Q(lS[3]), .Q_N(lSn[3]), .D(lS[3]), .SCD(S[3]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));

  wire[3:0] lU, lUn;
  sg13_sdfrbp_1 DffMx(.Q(lU[0]), .Q_N(lUn[0]), .D(lU[0]), .SCD(U[0]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx(.Q(lU[1]), .Q_N(lUn[1]), .D(lU[1]), .SCD(U[1]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx(.Q(lU[2]), .Q_N(lUn[2]), .D(lU[2]), .SCD(U[2]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx(.Q(lU[3]), .Q_N(lUn[3]), .D(lU[3]), .SCD(U[3]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));

  // The easy one:
  // P[0] = S[0] & U[0]
  sg13_nor2_1 a(.A(lSn[0]), .B(lUn[0]), .X(P[0]));

  // Complements:
  wire[3:0] cS; // these wires will drive the 4 stages of the shif&and replicator
  assign cS[0] = lS[0]; // copy
  
  
  

  
  // 
endmodule
