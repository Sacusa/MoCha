# Assembler

The assembler converts assembly code written in plain English to the desired output format. It's features include:

1. Support for several output formats, as listed below:

    * __Binary__: This is the default format. A flat binary file is generated which can be loaded onto the chip.
    * __Xilinx coe__: In this, the output file can be used a COE file for initial RAM values for Xilinx FPGAs.
    * __Intel hex__: In this, the output file generated is in Intel I8HEX format.

1. Ability to assemble both user programs and bootloaders. The user programs can be loaded directly into the ROM, while bootloaders need to be hardcoded by generating coe files for them.

1. Setting custom PC and SP values. *This can be done for bootloaders ONLY.*

Program usage, along with other commandline options can be printed using

    asm.py -h