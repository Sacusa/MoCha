# NUP

NUP is an 8-bit microcontroller developed at NIIT University. Targeting pedagogical purposes, the microcontroller ships with fully synthesizable VHDL code, testbenches for all individual components, an assembler and a cycle-accurate simulator.

This document provides a brief overview of the design followed by some specifics and usage. Specific documents and their links are as follows:

* [Design Document][design-document], containing the design decisions made during developement.
* [Assembler Manual][assembler-manual], containing information about the assembler's various features and usage.
* [Simulator Manual][simulator-manual], containing information about the simulator's various features and usage.

## Contents

1. Overview  
2. Features  
2.1 Memory Layout  
2.2 Stepper Motor Peripheral  
2.3 SPI Flash Controller  
2.4 Assembler  
2.5 Simulator  
3. Usage  
3.1 Boot Process  
3.2 Synthesis  
3.3 Loading User Programs  

## 1. Overview

Originally designed by Prof. R. N. Biswas for use in NIIT University's *Computer Organisation and Architecture* course, the design was used just once in the course's 2011 iteration prior to his departure from the university. The design has not been used since. Under close supervision of Prof. Sanjay Gupta, significant changes to the design have been made by the author and synthesized on a Field Programmable Gate Array (FPGA). Furthermore, rudimentary software support has been added to make it suitable for use in the courses *Computer Organisation and Architecture* and *Microprocessors and Microcontrollers*.

The additions to the original design are as follows:

1. **Bank Register**, to increase the total memory from 256B to 64KB.
1. Memory-mapped I/O, to provide capability to interact with the environment.
1. **Stepper motor peripheral**, a feature absent from all current microcontrollers.
1. **SPI flash interface**, to provide support for storing persistent data.
1. **Assembler**, which can compile both user programs and bootloaders (the difference, along with the boot process has been explained in the [Usage][#3-usage] section).
1. **Simulator**, to simplify not only the teaching, but also the debugging process.

Figures 1 and 2 show the block diagram and the instruction set architecture (ISA) of NUP, respectively. As figure 1 shows, it is an accumulator-based common bus architecture.

<div align=center>

| ![Figure 1: NUP Block Diagram][block-diagram] |
|:--:|
| *Figure 1: Block Diagram* |

</div>

While there are instructions that can perform register-to-register operations, all the results always end up in the accumulator first. The number of cycles varies greatly between instructions, being as low as 7 cycles for a no-op to as high as 18 cycles for JPP.

<div align=center>

| ![Figure 2: NUP ISA][isa] |
|:--:|
| *Figure 2: Instruction Set Architecture* |

</div>

We synthesized the design on a [Numato Mimas V2 Spartan 6 FPGA][fpga-website] board. Our implementation achieved a maximum clock speed of 62MHz. The design currently supports upto 16 I/O ports, out of which 8 are reserved. More information about the memory mapping can be found in the [Memory Layout][#21-memory-layout] section.

## 2. Features

### 2.1 Memory Layout

Even though NUP is an 8-bit design, it can address upto 64KB memory. This means that all the registers that need to hold an address, namely *Memory Address Register (MAR)*, *Program Counter (PC)*, and *Stack Pointer (SP)*, are all 16-bit wide. While the *Accumulator (AR)* also serves as the address source for the load and store instructions, it was not made 16-bit wide. Instead, another register, called *Bank Register (BR)*, was added which provides the higher order byte of the address. The register was named so to introduce and explain the concept of memory banks.

<div align=center>

| ![Figure 3: Memory mapping][memory-mapping] |
| :--: |
| *Figure 3: Memory Mapping* |

</div>

Figure 3 shows the memory layout of NUP. As shown in the figure, the last 32 bytes of the memory are reserved for I/O. Ports upto port 7 are reserved for I/O and peripherals. The remaining ports can be used to add more peripherals or as GPIO. Our implementation used ports 8, 9, and 10 as GPIO, while the rest were unused. They can very easily be remapped by editing the files `memory_unit.vhd` and `controller.vhd`.

### 2.2 Stepper Motor Peripheral

The stepper motor peripheral is a **unique feature** of NUP, in that it is not present in any other microcontroller. It is simply a combination of four I/O ports and timers. The peripheral has four configurable options: speed, steps, direction, and enable.

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

[design-document]: design-document.md

[assembler-manual]: assembler/README.md

[simulator-manual]: simulator/README.md

[block-diagram]: readme-resources/block-diagram.jpg

[isa]: readme-resources/isa.jpg

[memory-mapping]: readme-resources/memory-mapping.jpg
