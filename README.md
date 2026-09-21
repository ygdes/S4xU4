![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

# 4×4 bit multiplier with Tiny Tapeout in Verilog on IHP SG13G2

## What is this tile ?

As the name suggests, it performs an integer multiplication, one operand is Signed 4 bits, the other is Unsigned 4 bits.

These two operands have a separate buffer, allowing independent updates.

Due to the small size, a different kind of logic and material optimisations are used, so it's a bit unusual.

Bonus: the multiplier is replicated 3 times and the products are summed. Each multiplier has their own pair of input latch enable signals.

[Read the documentation for project](docs/info.md)

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Join the community](https://tinytapeout.com/discord)

## What next?

First we'll see whether and how it works.
