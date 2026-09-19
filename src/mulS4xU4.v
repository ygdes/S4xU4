// mulS4xU4.v
// a small Signed×Unsigned multiplier
// © 2026 Yann Guidon
// complement+shift : https://www.falstad.com/s.php?s=OTRvLh
// adder: https://www.falstad.com/s.php?s=VlpSEz
// depends on FullAdder_sg13.v

module mulS4xU4(
  input  wire Clk,
  input  wire Rst_n,
  input  wire Sen,
  input  wire Uen,
  input  wire [3:0] S,
  input  wire [3:0] U,
  output wire [7:0] P
);

  ////////////////////
  // The synchronous input latches:
  ////////////////////
  
  // uses the "scan" version for the integrated MUX, and complementary output.
  // (though some outputs are not necessary and are trimmed)
  wire[3:0] lS;
  wire lSn0, // fo2
       lSn3;
  sg13_sdfrbp_1  DffMx0(.Q(lS[0]), .Q_N(lSn0), .D(lS[0]), .SCD(S[0]), .SCE(Sen), .RESET_B(Rst_n), .CLK(Clk));
  sg13_sdfrbpq_1 DffMx1(.Q(lS[1]),             .D(lS[1]), .SCD(S[1]), .SCE(Sen), .RESET_B(Rst_n), .CLK(Clk));
  sg13_sdfrbpq_1 DffMx2(.Q(lS[2]),             .D(lS[2]), .SCD(S[2]), .SCE(Sen), .RESET_B(Rst_n), .CLK(Clk));
  sg13_sdfrbp_1  DffMx3(.Q(lS[3]), .Q_N(lSn3), .D(lS[3]), .SCD(S[3]), .SCE(Sen), .RESET_B(Rst_n), .CLK(Clk));

  wire[2:0] lU;
  wire lUn0, // fo2
       lUn3, // fo2
       lUdum;
  sg13_sdfrbp_1  DffMx4(.Q(lU[0]), .Q_N(lUn0), .D(lU[0]), .SCD(U[0]), .SCE(Uen), .RESET_B(Rst_n), .CLK(Clk));
  sg13_sdfrbpq_1 DffMx5(.Q(lU[1]),             .D(lU[1]), .SCD(U[1]), .SCE(Uen), .RESET_B(Rst_n), .CLK(Clk));
  sg13_sdfrbpq_1 DffMx6(.Q(lU[2]),             .D(lU[2]), .SCD(U[2]), .SCE(Uen), .RESET_B(Rst_n), .CLK(Clk));
  sg13_sdfrbp_1  DffMx7(.Q(lUdum), .Q_N(lUn3), .D(lU[3]), .SCD(U[3]), .SCE(Uen), .RESET_B(Rst_n), .CLK(Clk));

  // The easy one:
  // P[0] = S[0] & U[0]
  sg13_nor2_1 no0(.A(lSn0), .B(lUn0), .Y(P[0]));


  ////////////////////
  // S4 => unsigned:
  ////////////////////
  
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


  ////////////////////
  // U4 => signed 5 bits
  ////////////////////
  
  wire[4:0] cU; // this is a sign-extended word that drives the columns of the shif&and replicator

  // buffering
  sg13_inv_1    ivU0(.A(lUn0), .Y(cU[0]));  // fo3

  // cU[1] = lU[1] ^ ~(lS[3] & lU[0]) 
  wire lU1_t1, lU1_t2;
  sg13_nand2_1  naU1(.A(lS[3]), .B(lU[0]), .Y(lU1_t1));
  sg13_xor2_1   xoU1(.A(lU[1]), .B(lU1_t1), .X(lU1_t2));
  sg13_inv_1    ivU1(.A(lU1_t2), .Y(cU[1])); // fo4

  // cU[2] = lU[2] ^ ~(lS[3] & (lU[0] | lU[1]))
  wire lU2_t1, lU2_t2;
  sg13_o21ai_1  oaU2(.B1(lS[3]), .A1(lU[0]), .A2(lU[1]), .Y(lU2_t1));
  sg13_xor2_1   xoU2(.A(lU[2]),  .B(lU2_t1), .X(lU2_t2));
  sg13_inv_1    ivU2(.A(lU2_t2), .Y(cU[2])); // fo4

  // cU[3] = lU[3] ^  (lSn3 | ~(lU[0] | lU[1] | lU[2] ))
  wire lU3_t0, lU3_t1, lU3_t2;
  sg13_nor3_1 noU3(.A(lU[0]),  .B(lU[1]),   .C(lU[2]), .Y(lU3_t0));
  sg13_nor2_1 noU2(.A(lSn3),   .B(lU3_t0),  .Y(lU3_t1));
  sg13_xor2_1 xoU3(.A(lUn3),   .B(lU3_t1),  .X(lU3_t2));
  sg13_inv_1  ivU3(.A(lU3_t2), .Y(cU[3])); // fo4

  // cU[4] = lSn3 & (lUn3 | lU3_t0)
  wire lU4_t1;
  sg13_a21oi_1  aoU4(.A1(lUn3), .A2(lU3_t0), .B1(lSn3), .Y(lU4_t1));
  sg13_inv_1    ivU4(.A(lU4_t1), .Y(cU[4])); // fo3

  assign P[7]=cU[4];  // yeah, at last a 2nd bit !

  ////////////////////
  // Replicator : shift-and
  ////////////////////
  // output bits ranks 3, 4, 5, 6 are negated.

  wire [6:1] Partial0;
  wire P0x; // fo3, sign extension
  sg13_and2_1    aP01(.A(cS[0]), .B(cU[1]), .X(Partial0[1]));
  sg13_and2_1    aP02(.A(cS[0]), .B(cU[2]), .X(Partial0[2]));
  sg13_nand2_1  naP03(.A(cS[0]), .B(cU[3]), .Y(Partial0[3]));
  sg13_nand2_1  naP04(.A(cS[0]), .B(cU[4]), .Y(P0x));
  assign Partial0[6:4]=  {P0x, P0x, P0x};
  
  wire [6:1] Partial1;
  wire P1x; // fo2, sign extension
  sg13_and2_1    aP11(.A(cS[1]), .B(cU[0]), .X(Partial1[1]));
  sg13_and2_1    aP12(.A(cS[1]), .B(cU[1]), .X(Partial1[2]));
  sg13_nand2_1  naP13(.A(cS[1]), .B(cU[2]), .Y(Partial1[3]));
  sg13_nand2_1  naP14(.A(cS[1]), .B(cU[3]), .Y(Partial1[4]));
  sg13_nand2_1  naP15(.A(cS[1]), .B(cU[4]), .Y(P0x));
  assign Partial1[6:5]=  {P1x, P1x};

  wire [6:2] Partial2; // Combines 2 levels, because numbers magic and happy coincidences.
  sg13_and2_1    aP32(.A (cS[2]), .B (cU[0]),                         .X(Partial2[2]));
  sg13_a22oi_1  aoP33(.A1(cS[2]), .A2(cU[1]), .B1(cS[3]), .B2(cU[0]), .Y(Partial2[3]));
  sg13_a22oi_1  aoP34(.A1(cS[2]), .A2(cU[2]), .B1(cS[3]), .B2(cU[1]), .Y(Partial2[4]));
  sg13_a22oi_1  aoP35(.A1(cS[2]), .A2(cU[3]), .B1(cS[3]), .B2(cU[2]), .Y(Partial2[5]));
  sg13_a22oi_1  aoP36(.A1(cS[2]), .A2(cU[4]), .B1(cS[3]), .B2(cU[3]), .Y(Partial2[6]));


  ////////////////////
  // Partials compression
  ////////////////////
  // 3 partial results reduced to 2

  wire A1, A2, A3n, A4n, A5n,
           B2, B3n, B4n, B5n,
     tx1;
  FullAdderSG13     fa2(.d1(Partial0[2]), .d2(Partial1[2]), .d3(Partial2[2]),  .S(A1), .C(A2));
  FullAdderSG13negS fa3(.d1(Partial0[3]), .d2(Partial1[3]), .d3(Partial2[3]), .Sn(B2), .C(A3n));
  FullAdderSG13     fa4(.d1(Partial0[4]), .d2(Partial1[4]), .d3(Partial2[4]), .S(B3n), .C(A4n));
  FullAdderSG13_x   fa5(.d1(Partial0[4]), .d2(Partial1[5]), .d3(Partial2[5]), .S(B4n), .C(A5n), .X(tx1));
  sg13_xor2_1       rx1(                                     .A(Partial2[6]), .B(tx1), .X(B5n));


  ////////////////////
  // Propagate/Generate
  ////////////////////
  wire G0, G1, G2, G3, G4,
               P2, P3, P4,     P34,
                   t3, t4, t5,
               X2, X3, X4, X5;
  // PGX: the 3 critical gates for a CLA, but some polarities
  // must be adjusted due to inverted inputs 
  sg13_xor2_1  PGX2x(.A(A2),  .B(B2),  .X(X2));
  sg13_and2_1  PGX2a(.A(A2),  .B(B2),  .X(G2));
  sg13_or2_1   PGX2o(.A(A2),  .B(B2),  .X(P2));

  sg13_xor2_1  PGX3x(.A(A3n), .B(B3n), .X(X3));
  sg13_nor2_1  PGX3o(.A(A3n), .B(B3n), .Y(G3));
  sg13_nand2_1 PGX3a(.A(A3n), .B(B3n), .Y(P3));

  sg13_xor2_1  PGX4x(.A(A4n), .B(B4n), .X(X4));
  sg13_nor2_1  PGX4o(.A(A4n), .B(B4n), .Y(G4));
  sg13_nand2_1 PGX4a(.A(A4n), .B(B4n), .Y(P4));

  sg13_xor2_1  PGX5x(.A(A5n), .B(B5n), .X(X5));

  // some intermediary signals
  sg13_and2_1  int1(.A(Partial0[1]),  .B(Partial1[1]),         .X(G0));
  sg13_and3_1  int2(.A(Partial0[1]),  .B(Partial1[1]), .C(A1), .X(G1));
  sg13_and2_1  int3(.A(P3),  .B(P4),  .X(P34));

  // at last some outputs:
  sg13_xor2_1  xo1(.A(Partial0[1]),  .B(Partial1[1]),  .X(P[1]));
  sg13_xor2_1  xo2(.A(G0),           .B(A1),           .X(P[2]));
  sg13_xor2_1  xo3(.A(G1),           .B(X2),           .X(P[3]));

  // Take a breath, and carry on
  sg13_a21o_1  ao(.A1(P2), .A2(G1), .B1(G2), .X(t3));

  // more outputs
  sg13_xor2_1  xo4(.A(t3), .B(X3), .X(P[4]));

  sg13_a21oi_1  ao4(.A1(t3), .A2(P3), .B1(G3), .Y(t4));
  sg13_xnor2_1  xo5(.A(t4),   .B(X4), .Y(P[5]));

  sg13_a221oi_1 ao5(.A1(t3), .A2(P34), .B1(G3), .B2(P4), .C1(G4), .Y(t5));
  sg13_xnor2_1  xo6(.A(t5), .B(X5), .Y(P[6]));
  
  wire _unused = &{lUdum, 1'b0};
endmodule
