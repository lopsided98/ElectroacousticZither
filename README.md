# Electroacoustic Zither

Source code for the electroacoustic zither, a hybrid instrument using
electromagnets to excite steel strings. Built at Dartmouth College for
ENGS 17.04, The Art, Science, and Symbolism of Musical Instruments during
Winter 2019.

## Layout
* Firmware - C code for Microblaze soft processor
* StringDriver - AXI4-lite peripheral for performing PWM and square wave
  generation
* System - top level block diagram for the project, designed to run on the
  Basys 3 development board using a Xilinx Artix-7 FPGA
* Tools - Utilities for tuning the instrument and connecting the ALSA MIDI 
  sequencer to a serial port