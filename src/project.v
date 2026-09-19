/*
 * Copyright (c) 2024 Your Name
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
    wire [7:0] P, tP;
  assign S = ui_in[3:0];
  assign U = ui_in[7:4];

  wire Sen0, Sen1, Sen2, Uen0, Uen1, Uen2;
  assign Sen0 = uio_in[0];
  assign Sen1 = uio_in[1];
  assign Sen2 = uio_in[2];
  assign Uen0 = uio_in[3];
  assign Uen1 = uio_in[4];
  assign Uen2 = uio_in[5];

  mulS4xU4  mul0(.Clk(clk), .Rst_n(rst_n), .Sen(Sen0), .Uen(Uen0), .S(S), .U(U), .P(tP));

  // latch the outputs to keep the timing tight
  sg13_dfrbpq_1 DffBuff0(.Q(P[0]), .D(tP[0]), .RESET_B(Rst_n), .CLK(Clk));
  sg13_dfrbpq_1 DffBuff1(.Q(P[1]), .D(tP[1]), .RESET_B(Rst_n), .CLK(Clk));
  sg13_dfrbpq_1 DffBuff2(.Q(P[2]), .D(tP[2]), .RESET_B(Rst_n), .CLK(Clk));
  sg13_dfrbpq_1 DffBuff3(.Q(P[3]), .D(tP[3]), .RESET_B(Rst_n), .CLK(Clk));
  sg13_dfrbpq_1 DffBuff4(.Q(P[4]), .D(tP[4]), .RESET_B(Rst_n), .CLK(Clk));
  sg13_dfrbpq_1 DffBuff5(.Q(P[5]), .D(tP[5]), .RESET_B(Rst_n), .CLK(Clk));
  sg13_dfrbpq_1 DffBuff6(.Q(P[6]), .D(tP[6]), .RESET_B(Rst_n), .CLK(Clk));
  sg13_dfrbpq_1 DffBuff7(.Q(P[7]), .D(tP[7]), .RESET_B(Rst_n), .CLK(Clk));
  
  // "All output pins must be assigned. If not used, assign to 0."
  assign uo_out  = P; // output the product.
  assign uio_out = 0; // no output on uio.
  assign uio_oe  = 0; // uio port is only in.

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, Sen1, Sen2, Uen1, Uen2, 1'b0};

endmodule
