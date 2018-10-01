# MoCha

**M**icrocontroller f**o**r **C**omputer Arc**h**itecture Educ**a**tion (MoCha) is an 8-bit microcontroller developed at NIIT University. Targeting pedagogical purposes, the microcontroller ships with fully synthesizable VHDL code, testbenches for all individual components, an assembler and a cycle-accurate simulator.

This document provides a brief overview of the design followed by some specifics and usage. Specific documents and their links are as follows:

* [Design Document][design-document], containing the design decisions made during developement.
* [Assembler Manual][assembler-manual], containing information about the assembler's various features and usage.
* [Simulator Manual][simulator-manual], containing information about the simulator's various features and usage.

## Contents

1. [Overview](#1-overview)  
2. [Features](#2-features)  
2.1 [Memory Layout](#21-memory-layout)  
2.2 [Stepper Motor Peripheral](#22-stepper-motor-peripheral)  
2.3 [SPI Flash Controller](#23-spi-flash-controller)  
2.4 [Assembler](#24-assembler)  
2.5 [Simulator](#25-simulator)  
3. [Usage](#3-usage)  
3.1 [Boot Process](#31-boot-process)  
3.2 [Synthesis](#32-synthesis)  
3.3 [Loading User Programs](#33-loading-user-programs)  

## 1. Overview

Originally designed by Prof. R. N. Biswas for use in NIIT University's *Computer Organisation and Architecture* course, the design was used just once in the course's 2011 iteration prior to his departure from the university. The design has not been used since. Under close supervision of Prof. Sanjay Gupta, significant changes to the design have been made by the author and synthesized on a Field Programmable Gate Array (FPGA). Furthermore, rudimentary software support has been added to make it suitable for use in the courses *Computer Organisation and Architecture* and *Microprocessors and Microcontrollers*.

The additions to the original design are as follows:

1. **Bank register and MVB**, to increase the total memory from 256B to 64KB.
1. Memory-mapped I/O, to provide capability to interact with the environment.
1. **Stepper motor peripheral**, a feature absent from all current microcontrollers.
1. **SPI flash interface**, to provide support for storing persistent data.
1. **Assembler**, which can compile both user programs and bootloaders (the difference, along with the boot process has been explained in the [Usage][#3-usage] section).
1. **Simulator**, to simplify not only the teaching, but also the debugging process.

Figures 1 and 2 show the block diagram and the instruction set architecture (ISA) of MoCha, respectively. As figure 1 shows, it is an accumulator-based common bus architecture. While there are instructions that can perform register-to-register operations, all the results always end up in the accumulator first. The number of cycles varies greatly between instructions, being as low as 7 cycles for a no-op to as high as 18 cycles for JPP.

<div align=center>

| ![Figure 1: MoCha Block Diagram][block-diagram] |
|:--:|
| *Figure 1: Block Diagram* |

| ![Figure 2: MoCha ISA][isa] |
|:--:|
| *Figure 2: Instruction Set Architecture* |

</div>

We synthesized the design on a [Numato Mimas V2 Spartan 6 FPGA][fpga-website] board. Our implementation achieved a maximum clock speed of 62MHz. The design currently supports upto 16 I/O ports, out of which 8 are reserved. More information about the memory mapping can be found in the [Memory Layout](#21-memory-layout) section.

## 2. Features

This section elaborates on some features and design details of MoCha.

### 2.1 Memory Layout

Even though MoCha is an 8-bit design, it can address upto 64KB memory. This means that all the registers that need to hold an address, namely *Memory Address Register (MAR)*, *Program Counter (PC)*, and *Stack Pointer (SP)*, are all 16-bit wide. While the *Accumulator (AR)* also serves as the address source for the load and store instructions, it was not made 16-bit wide. Instead, another register, called *Bank Register (BR)*, was added which provides the higher order byte of the address. The register was named so to introduce and explain the concept of memory banks.

<div align=center>

| ![Figure 3: Memory mapping][memory-mapping] |
| :--: |
| *Figure 3: Memory Mapping* |

</div>

Figure 3 shows the memory layout of MoCha. As shown in the figure, the last 32 bytes of the memory are reserved for I/O. Ports upto port 7 are reserved for I/O and peripherals. The remaining ports can be used to add more peripherals or as GPIO. Our implementation used ports 8, 9, and 10 as GPIO, while the rest were unused. They can very easily be remapped by editing the files `memory_unit.vhd` and `controller.vhd`.

### 2.2 Stepper Motor Peripheral

The stepper motor peripheral is a **unique feature** of MoCha, in that it is not present in any other microcontroller. It is simply a combination of four I/O ports and timers. The peripheral has four configurable options: speed, steps, direction, and enable.

* **I/O Port 3 -- Speed (5-bits)**: The motor can be configured to run at 32 different speeds, 0 being the fastest and 31 the slowest.
* **I/O Port 4 -- Steps (8-bits)**: The motor can run for upto 256 steps.
* **I/O Port 5 -- Direction (1-bit)**: Used to configure the direction of rotation.
* **I/O Port 6 -- Enable (1-bit)**: This is the master enable bit. This must be set to 0 to configure the above options and set to 1 to run the motor.

### 2.3 SPI Flash Controller

The SPI controller allows the user to interact with flash memory. Though it can be used for any other purpose, it is assumed by the bootloader to be connected to the flash memory containing the user program. It has been implemented in a bit-banged fashion, i.e. there is no dedicated hardware for this purpose (apart from an I/O port) and all the handling is done by the software. Figure 4 shows the how the bits of port 7 are used by the protocol.

<div align=center>

| ![Figure 4: SPI Controller Port Mapping][spi-port-mapping] |
| :--: |
| *Figure 4: SPI Controller Port Mapping* |

</div>

There are four assembly functions provided to use the controller:

* **SPI_RESET_AND_ENABLE**: Resets the device and enables it to start accepting commands.
* **SPI_WRITE_BYTE**: Writes a single byte to the SPI port.
* **SPI_READ_BYTE**: Reads a single byte from the SPI port.
* **SPI_DISABLE**: Disables access to the device.

More information about each function and usage example can be found in the [bootloader][bootloader].

### 2.4 Assembler

*Please see [this][assembler-manual] file.*

### 2.5 Simulator

*Please see [this][simulator-manual] file.*

## 3. Usage

This section explains, in detail, the following:

1. the boot process of the microcontroller
1. details on how to synthesize the design onto an FPGA
1. load programs onto the microcontroller

### 3.1 Boot Process

To make the design as flexible as possible in terms of the software it runs, the micrcontroller has a seemingly complex boot process for a pedagogical design. The boot sequence is as follows:

1. The microcode starting at address 0 of the microprogram memory starts executing. This code resets all the registers to 0 and loads the initial values for PC and SP. The values are assumed to be stored in the ram in the following order:
    * *Address 0:* SP[15:8]
    * *Address 1:* SP[7:0]
    * *Address 2:* PC[15:8]
    * *Address 3:* PC[7:0]

1. The loaded PC value can point to the user program straight away. However, that would mean that for a user to load his/her program, he/she would have to hardcode it into the RAM and generate a new binary *every single time*. This proves to be a very time consuming process. In our implementation, the program pointed to by the loaded PC is actually a bootloader. The bootloader loads user programs stored in the SPI flash memory into the microcontroller's main memory. The bootloader is 201 bytes in size. Consequently, the user program is loaded into the RAM starting at address 202. Offsetting the PC in the binary appropriately is done by the assembler.

    The bootloader makes a few assumptions about the user binary, as stated below:
    * The size of the program in bytes is prepended to the user program, i.e. the first two bytes of the binary should contain the program size that follows. This allows the bootloader to know in advance the number of bytes to copy from the ROM to RAM.
    * The binary is stored in the ROM starting at address 0x0f0000.

1. Finally, once the program is copied, the bootloader jumps to the first instruction and starts executing.

The advantage of the above boot sequence is that a single FPGA binary can be generated to run different programs. The user can simply load his/her program into the ROM and switch on the microcontroller. More information about loading user programs can be found in the [Loading User Programs](#33-loading-user-programs) section.

### 3.2 Synthesis

To synthesize the microcontroller, Xilinx ISE 14.7 was used by the author to generate the bit file for Xilinx Spartan-6 XC6SLX9 FPGA. This section describes the synthesis process for the same.

1. The `hdl` directory in this repository contains all the HDL source and testbenches. Load all the source files into a project. Make `controller.vhd` the top-level module of this project.

1. Generate the main memory using Block Memory Generator. Look up the module specifications in the file `memory_unit.vhd` under the component name `main_ram`. This memory needs to be initialized with the bootloader, which can be done using the provided COE file `main_ram.coe` found in the directory `ipcore_dir`.

1. Similarly, generate decoder and microprogram memory using the specifications in `control_unit.vhd` under the names `decoder_ram` and `mp_ram`, respectively. Their corresponding COE files can also be found in the directory `ipcore_dir`.

1. Write the user-constraints file using the ports specified in `controller.vhd`. You may want to use the author's ucf file in the directory `ucf` if you are using a Numato Mimas V2 Spartan-6 FPGA board.

1. Finally, build the project. If everything goes well, you should have a `controller.bit` in your project directory.

### 3.3 Loading User Programs

When installing Xilinx ISE 14.7, a tool called `promgen` is also installed. The tool can be conveniently used to combine the FPGA's bit file and user binary file. To load the binaries onto the FPGA:

1. Generate your program's binary using the provided assembler.

1. Place `controller.bit` and your binary in the same directory as the files in the directory loader, i.e. the directory should contain a total of five files.

1. Run the script `comb_bin` and pass the name of your binary as the first argument. Windows users will need to run `comb_bin.bat` while Linux users will need to run `comb_bin.sh`.

1. Finally, run the script `MimasV2Config.py`, passing the FPGA's port number as the first argument and download.bin as the second argument.

You're done! The FPGA should boot your program now. To load a different program, place the new file in the above directory and repeat steps 3 and 4 with the new binary name.

[design-document]: design-document.md

[assembler-manual]: assembler/README.md

[simulator-manual]: simulator/README.md

[fpga-website]: https://numato.com/mimas-v2-spartan-6-fpga-development-board-with-ddr-sdram/

[block-diagram]: readme-resources/block-diagram.jpg

[isa]: readme-resources/isa.jpg

[memory-mapping]: readme-resources/memory-mapping.jpg

[spi-port-mapping]: readme-resources/spi-port-mapping.jpg

[bootloader]: assembly-programs/flash_boot.asm
