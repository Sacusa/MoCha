# Assembler

The assembler converts assembly code written in plain English to the desired output format.

The possible output formats available are:

* __Binary__: This is the default format. The program binary is put into an *LF* separated ASCII file.
* __Xilinx coe__: In this, the output file can be used a coe file for initial RAM values for Xilinx FPGAs. This can be activated using the *-coe* flag.
* __Intel hex__: In this, the output file generated is in Intel I8HEX format. This can be activated using the *-hex* flag.

Program usage, along with other commandline options can be printed using

    asm.py -h