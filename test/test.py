# SPDX-FileCopyrightText: © 2026 Yann Guidon
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

#  assign S = ui_in[3:0];
#  assign U = ui_in[7:4];
Sen0 = 1
Sen1 = 2
Sen2 = 4
Uen0 = 8
Uen1 = 16
Uen2 = 32

@cocotb.test()
async def test_project(dut):
  dut._log.info("Start")

  # Set the clock period to 10 us (100 KHz)
  clock = Clock(dut.clk, 10, unit="us")
  cocotb.start_soon(clock.start())

  # Reset
  dut._log.info("Reset")
  dut.ena.value = 1
  dut.ui_in.value = 0
  dut.uio_in.value = 0
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, 4)
  dut.rst_n.value = 1

  dut._log.info("Test project behavior")

  dut.uio_in.value = Sen0 + Uen0

  for U in range(0, 16):
    for S in range(-8, 8):
      dut.ui_in.value = (U << 4)|(S & 15);
      await ClockCycles(dut.clk, 6)
      val = int(dut.uo_out.value)
      if dut.uo_out.value[7] == 1:
        val = val-256
      diag=" ."
      if val != (U*S):
         diag=" ***"
      dut._log.info(str(U) + " * " + str(S) + " => " + str(dut.uo_out.value) + " : " + str(val)+ diag)

    # Set the input values you want to test
    # dut.ui_in.value = 20
    # dut.uio_in.value = 30

    # Wait for one clock cycle to see the output values
    # await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    # assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
