soft-utmi
=========
A "soft" (VHDL) implementation of the UTMI+ PHYs specification using the SERDES
found in Xilinx Spartan-6.

The idea is to allow USB **2.0** to be run directly into the I/O pins of a
Xilinx Spartan-6. The Xilinx Spartan-6 isn't designed to do this, so it
requires a bunch of clever hacks to make work.

Once UTMI+ PHYs works, it should be able to be combined with the [daisho USB
core](https://github.com/mossmann/daisho/tree/master/sw/fpga/common/usb3).
Note, this would **only be USB2.0 support**, not USB3.0.

**This implementation does not work yet.**
