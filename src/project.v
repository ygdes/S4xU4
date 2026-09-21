/*
 * Copyright (c) 2026 Yann Guidon
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_S4xU4 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // interface: what sup ?
  wire [3:0] S;
  wire [3:0] U;
  wire [7:0] P1, P2, P3;
  wire [9:0] Sum, tSum;
  assign S = ui_in[3:0];
  assign U = ui_in[7:4];

  wire Sen0, Sen1, Sen2, Uen0, Uen1, Uen2;
  assign Sen0 = uio_in[0];
  assign Sen1 = uio_in[1];
  assign Sen2 = uio_in[2];
  assign Uen0 = uio_in[3];
  assign Uen1 = uio_in[4];
  assign Uen2 = uio_in[5];

  mulS4xU4  mul0(.Clk(clk), .Rst_n(rst_n), .Sen(Sen0), .Uen(Uen0), .S(S), .U(U), .P(P1));
  mulS4xU4  mul0(.Clk(clk), .Rst_n(rst_n), .Sen(Sen1), .Uen(Uen1), .S(S), .U(U), .P(P2));
  mulS4xU4  mul0(.Clk(clk), .Rst_n(rst_n), .Sen(Sen2), .Uen(Uen2), .S(S), .U(U), .P(P3));

  Add8x3 summer(.op1(P1), .op2(P2), .op3(P3), .S3(tSum));

  // latch the outputs to keep the timing tight
  sg13_dfrbpq_1 DffBuff0(.Q(Sum[0]), .D(tSum[0]), .RESET_B(rst_n), .CLK(clk));
  sg13_dfrbpq_1 DffBuff1(.Q(Sum[1]), .D(tSum[1]), .RESET_B(rst_n), .CLK(clk));
  sg13_dfrbpq_1 DffBuff2(.Q(Sum[2]), .D(tSum[2]), .RESET_B(rst_n), .CLK(clk));
  sg13_dfrbpq_1 DffBuff3(.Q(Sum[3]), .D(tSum[3]), .RESET_B(rst_n), .CLK(clk));
  sg13_dfrbpq_1 DffBuff4(.Q(Sum[4]), .D(tSum[4]), .RESET_B(rst_n), .CLK(clk));
  sg13_dfrbpq_1 DffBuff5(.Q(Sum[5]), .D(tSum[5]), .RESET_B(rst_n), .CLK(clk));
  sg13_dfrbpq_1 DffBuff6(.Q(Sum[6]), .D(tSum[6]), .RESET_B(rst_n), .CLK(clk));
  sg13_dfrbpq_1 DffBuff7(.Q(Sum[7]), .D(tSum[7]), .RESET_B(rst_n), .CLK(clk));
  sg13_dfrbpq_1 DffBuff8(.Q(Sum[8]), .D(tSum[8]), .RESET_B(rst_n), .CLK(clk));
  sg13_dfrbpq_1 DffBuff9(.Q(Sum[9]), .D(tSum[9]), .RESET_B(rst_n), .CLK(clk));
  
  // "All output pins must be assigned. If not used, assign to 0."
  assign uo_out  = Sum; // output the products' sum.
  assign uio_out = {Sum[9], Sum[8], 6'b000000}; // MSB on uio.
  assign uio_oe  = 8'b11000000; // uio port is in for the 6 LSB.

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7], uio_in[6], 1'b0};
endmodule
