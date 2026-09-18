// mulS4xU4.v
// a small Signed×Unsigned multiplier
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
  sg13_sdfrbp_1 DffMx0(.Q(lS[0]), .Q_N(lSn[0]), .D(lS[0]), .SCD(S[0]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx1(.Q(lS[1]), .Q_N(lSn[1]), .D(lS[1]), .SCD(S[1]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx2(.Q(lS[2]), .Q_N(lSn[2]), .D(lS[2]), .SCD(S[2]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx3(.Q(lS[3]), .Q_N(lSn[3]), .D(lS[3]), .SCD(S[3]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));

  wire[3:0] lU, lUn;
  sg13_sdfrbp_1 DffMx4(.Q(lU[0]), .Q_N(lUn[0]), .D(lU[0]), .SCD(U[0]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx5(.Q(lU[1]), .Q_N(lUn[1]), .D(lU[1]), .SCD(U[1]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx6(.Q(lU[2]), .Q_N(lUn[2]), .D(lU[2]), .SCD(U[2]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1 DffMx7(.Q(lU[3]), .Q_N(lUn[3]), .D(lU[3]), .SCD(U[3]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));

  // The easy one:
  // P[0] = S[0] & U[0]
  sg13_nor2_1 no0(.A(lSn[0]), .B(lUn[0]), .X(P[0]));

  // Complements:
  wire[3:0] cS; // these wires will drive the 4 stages of the shif&and replicator
  assign cS[0] = lS[0]; // copy
  
  // cS[1] = lS[1] xor (lS[3] and lS[0]  )
  wire lS1_t1, lS1_t2;
  sg13_nand2_1  na1(.A(lS[3]), .B(lS[0]), .Y(lS1_t1));
  sg13_xor2_1   xo1(.A(lS[1]), .B(lS1_t1), .X(lS1_t2));
  sg13_inv_1    iv1(.A(lS1_t2), .Y(cS[1]));

  // cS[2] = lS[2] xor (lS[3] and lS[0]  )
  wire lS2_t1, lS2_t2;
  sg13_o21ai_1  oa2(.A(lS[3]), .B(lS[0]), .C(lS[1]), .Y(lS2_t1));
  sg13_xor2_1   xo2(.A(lS[2]), .B(lS2_t1), .X(lS2_t2));
  sg13_inv_1    iv2(.A(lS2_t2), .Y(cS[2]));

  // cS[3] = 1 when S=1000
  //       = lS[3] & ~(lS[2]|lS[1]|lS[0])
  wire lS3_t1;
  sg13_nor3_1 no3(.A(lSn[0]), .B(lSn[1]), .C(lSn[2]), .Y(lS3_t1));
  sg13_and2_1 an3(.A(lSn[3]), .B(lS3_t1), .X(cS[3]));

// enlever les ports invesés des DFF en trop 
  
  assign P[7:1]={3'b000, cS};
endmodule
