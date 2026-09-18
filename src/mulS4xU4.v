// mulS4xU4.v
// a small Signed×Unsigned multiplier
// © 2026 Yann Guidon
// https://www.falstad.com/s.php?s=Ir6c7z

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
  wire[3:0] lS;
  wire lSn0, // fo2
       lsn3;
  sg13_sdfrbp_1  DffMx0(.Q(lS[0]), .Q_N(lSn0), .D(lS[0]), .SCD(S[0]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbpq_1 DffMx1(.Q(lS[1]),             .D(lS[1]), .SCD(S[1]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbpq_1 DffMx2(.Q(lS[2]),             .D(lS[2]), .SCD(S[2]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1  DffMx3(.Q(lS[3]), .Q_N(lSn3), .D(lS[3]), .SCD(S[3]), .SCE(Sen), .RESET_B(rst_n), .CLK(Clk));

  wire[3:0] lU, lUn;
  wire lUn0, // fo2
       lUn3; // fo2
  sg13_sdfrbp_1  DffMx4(.Q(lU[0]), .Q_N(lUn0), .D(lU[0]), .SCD(U[0]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbpq_1 DffMx5(.Q(lU[1]),             .D(lU[1]), .SCD(U[1]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbpq_1 DffMx6(.Q(lU[2]),             .D(lU[2]), .SCD(U[2]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));
  sg13_sdfrbp_1  DffMx7(.Q(lU[3]), .Q_N(lUn3), .D(lU[3]), .SCD(U[3]), .SCE(Uen), .RESET_B(rst_n), .CLK(Clk));

  // The easy one:
  // P[0] = S[0] & U[0]
  sg13_nor2_1 no0(.A(lSn0), .B(lUn0), .X(P[0]));

  // S4 => unsigned
  
  // Complements: -x = (~x)+1 = ~(x-1)
  // This operand must not be negative
  wire[3:0] cS; // these wires will drive the 4 stages of the shif&and replicator

  // buffering the LSB
  sg13_inv_1    ivS0(.A(lSn0), .Y(cS[0]));  // fo4
  
  // cS[1] = lS[1]  (lS[3] and lS[0]  )
  wire lS1_t1, lS1_t2;
  sg13_nand2_1  naS1(.A(lS[3]), .B(lS[0]), .Y(lS1_t1));
  sg13_xor2_1   xoS1(.A(lS[1]), .B(lS1_t1), .X(lS1_t2));
  sg13_inv_1    ivS1(.A(lS1_t2), .Y(cS[1])); // fo5

  // cS[2] = lS[2]  (lS[3] and lS[0]  )
  wire lS2_t1, lS2_t2;
  sg13_o21ai_1  oaS2(.B1(lS[3]), .A1(lS[0]), .A2(lS[1]), .Y(lS2_t1));
  sg13_xor2_1   xoS2(.A(lS[2]),  .B(lS2_t1), .X(lS2_t2));
  sg13_inv_1    ivS2(.A(lS2_t2), .Y(cS[2])); // fo5

  // cS[3] = 1 when S=1000
  //       = lS[3] & ~(lS[2]|lS[1]|lS[0])
  wire lS3_t1;
  sg13_nor3_1 noS3(.A(lS[0]), .B(lS[1]),  .C(lS[2]), .Y(lS3_t1));
  sg13_and2_1 anS3(.A(lS[3]), .B(lS3_t1), .X(cS[3])); // fo4


  // U4 => signed 5 bits
  
  wire[4:0] cU; // this is a sign-extended word that drives the columns of the shif&and replicator

  // buffering
  sg13_inv_1    ivU0(.A(lUn0), .Y(cU[0]));  // fo3

  // cU[1] = lU[1] ^ ~(lS[3] & lU[0]) 
  wire lU1_t1, lU1_t2;
  sg13_nand2_1  naU1(.A(lS[3]), .B(lU[0]), .Y(lU1_t1));
  sg13_xor2_1   xoU1(.A(lU[1]), .B(lU1_t1), .X(lS1_t2));
  sg13_inv_1    ivU1(.A(lU1_t2), .Y(cU[1])); // fo4

  // cU[2] = lU[2] ^ ~(lS[3] & (lU[0] | lU[1]))
  wire lU2_t1, lU2_t2;
  sg13_o21ai_1  oaU2(.B1(lS[3]), .A1(lU[0]), .A2(lU[1]), .Y(lU2_t1));
  sg13_xor2_1   xoU2(.A(lU[2]),  .B(lU2_t1), .X(lU2_t2));
  sg13_inv_1    ivU2(.A(lU2_t2), .Y(cU[2])); // fo4


  
  assign P[7:1]={3'b000, cS};
endmodule
