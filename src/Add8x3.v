// Add8x3.v
// © 2026 Yann Guidon
// Add 3 signed 8-bit numbers
// https://www.falstad.com/s.php?s=TkZ9cY
// depends on FullAdder_sg13.v

module Add8x3(
  input  wire[7:0] op1,
  input  wire[7:0] op2,
  input  wire[7:0] op3,
  output wire[7:0] S3
);
  wire[7:0] C, S;
  wire[9:1] A, B, T;

  // reduction by fulladdering :
  FullAdderSG13 fa0(.d1(op1[0]),.d2(op2[0]), .d3(op3[0]), .S(S[0]), .C(C[0]));
  FullAdderSG13 fa1(.d1(op1[1]),.d2(op2[1]), .d3(op3[1]), .S(S[1]), .C(C[1]));
  FullAdderSG13 fa2(.d1(op1[2]),.d2(op2[2]), .d3(op3[2]), .S(S[2]), .C(C[2]));
  FullAdderSG13 fa3(.d1(op1[3]),.d2(op2[3]), .d3(op3[3]), .S(S[3]), .C(C[3]));
  FullAdderSG13 fa4(.d1(op1[4]),.d2(op2[4]), .d3(op3[4]), .S(S[4]), .C(C[4]));
  FullAdderSG13 fa5(.d1(op1[5]),.d2(op2[5]), .d3(op3[5]), .S(S[5]), .C(C[5]));
  FullAdderSG13 fa6(.d1(op1[6]),.d2(op2[6]), .d3(op3[6]), .S(S[6]), .C(C[6]));
  FullAdderSG13 fa7(.d1(op1[7]),.d2(op2[7]), .d3(op3[7]), .S(S[7]), .C(C[7]));
  assign A = {};
  assign B = {};
  assign T = A+B // 9-bit adder with no Carry In or Carry Out
  assign S3 = { T , S[0]};
endmodule
