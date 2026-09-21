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
  errors=0

  for U in range(0, 16):
    for S in range(-8, 8):
      dut.ui_in.value = (U << 4)|(S & 15);

      # 3-stage binary counter
      for n1 in range(0, 2):
        for n2 in range(0, 2):
          for n3 in range(0, 2):
            mul = n1 + n2 + n3

            # reset cycle
            dut.rst_n.value = 0
            await ClockCycles(dut.clk, 1)
            dut.rst_n.value = 1

            # enable the multipliers
            dut.uio_in.value = ((Sen0 + Uen0) * n1) \
                             + ((Sen1 + Uen1) * n2) \
                             + ((Sen2 + Uen2) * n3)
            await ClockCycles(dut.clk, 6)
            # read the sum of products
            val = int(dut.uo_out.value) + (int(dut.uio_out.value[6]) * 256)
            if dut.uio_out.value[7] == 1:
              val = val-512
            diag = " == "
            expected = U*S*mul

            if val != expected:
              diag = " *** "
              errors = errors+1
            # assert val == expected
            dut._log.info(str(n1)+str(n2)+str(n3)+": "+str(mul)+" * "+
                  str(U)+" * "+ str(S) + " => " + str(dut.uo_out.value) +
                  " : " + str(val)+ diag+str(expected))


  # another reset cycle
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, 1)
  dut.rst_n.value = 1

  vals=[0,0,0]
  index=0

  for i in range(0, 100):
    val = (val+13) & 255 # what a sublime PRNG !

    dut.ui_in.value = val
    U = val >> 4
    S = val & 15
    if S > 7:
      S=S-16
    vals[index] = U * S
    dut.uio_in.value = (Sen0 + Uen0) << index
    await ClockCycles(dut.clk, 2)

    # read the sum of products
    res = int(dut.uo_out.value) + (int(dut.uio_out.value[6]) * 256)
    if dut.uio_out.value[7] == 1:
      res = res-512

    expected = vals[0]+vals[1]+vals[2]
    dut._log.info(
       str(index)+": "+
       str(val)+"=>"+
       str(U)+"*"+
       str(S)+"="+
       str(U*S)+"  -  "+
       str(vals[0])+ " + " +
       str(vals[1])+ " + " +
       str(vals[2])+ " = " +
       str(expected)+ " ??? "+
       str(res))
  
    index = index+1
    if index > 2:
      index=0;

  dut._log.info(str(errors) + " errors.")
  assert errors == 0
