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
  wire [7:0] P;
  assign S = ui_in[3:0];
  assign U = ui_in[7:4];

  wire Sen0, Sen1, Sen2, Uen0, Uen1, Uen2;
  assign Sen0 = uio_in[0];
  assign Sen1 = uio_in[1];
  assign Sen2 = uio_in[2];
  assign Uen0 = uio_in[3];
  assign Uen1 = uio_in[4];
  assign Uen2 = uio_in[5];

  mulS4xU4  mul0(.Clk(clk), .Rst_n(rst_n), .Sen(Sen0), .Uen(Uen0), .S(S), .U(U), .P(P));

  // TODO : latch the outputs

  // "All output pins must be assigned. If not used, assign to 0."
  assign uo_out  = P; // output the product.
  assign uio_out = 0; // no output on uio.
  assign uio_oe  = 0; // uio port is only in.

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, Sen1, Sen2, Uen1, Uen2, 1'b0};

endmodule
