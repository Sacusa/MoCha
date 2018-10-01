# Design Document

This document explains the design decisions made and the challenges faced during the development of MoCha. The reader can refer to the glossary at the end of this document to understand the various acronyms.

## Contents

1. [Increase Address Space](#1-increase-address-space)  
1.1 [Program Memory](#11-program-memory)  
1.2 [Data Memory](#12-data-memory)  
2. [SPI Flash Controller](#2-spi-flash-controller)  
3. [Boot Process and Loading User Programs](#3-boot-process-and-loading-user-programs)  
4. [Glossary](#4-glossary)

## 1. Increase Address Space

To increase the address space to 64K, the ISA was modified so that the memory could be viewed as 256 banks of 256B each. The main bus was, however, left 8b wide.

The first register to be modified is MAR. MAR was made 16b wide. This meant that it could not be loaded in a single cycle. The signal LMR was, consequently, made two bits wide. If MSB is 1, then load is enabled, otherwise disabled. If LSB is 0, the lower order byte is being loaded. If LSB is 1, the higher order byte is being loaded.

The impact on how both program memory and data memory are accessed is documented as follows.

### 1.1 Program Memory

The PC was made into a 16b register. The challenges it posed and the solutions employed are as follows:

1. __The PC could not be loaded in a single cycle__: This necessitated that the LPC signal be made two bits. If MSB is 1, then load is enabled, otherwise disabled. If LSB is 0, the lower order byte is being loaded. If LSB is 1, the higher order byte is being loaded.

1. __The PC could only put one byte onto the bus__: This necessitated that the EPC signal be made two bits. If MSB is 1, then PC's output is enabled, otherwise disabled. If LSB is 0, the lower order byte is enabled. If LSB is 1, the higher order byte is enabled.

The instructions that were modified, and the modifications made, are as follows:

1. __JPD__: The immediate value is 8b wide. This value is treated as an unsigned value. It is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __JPP__: The immediate value is 8b wide. This value is treated as a signed value. The following steps are performed:

    * The immediate value is first added to the PC's lower order byte, with the result stored back into PC.
    * 0 is added to the higher order byte, which also adds to it the carry value of the previous computation, and the result stored back into PC.
    * The immediate value is added to itself. This will set the C flag if the immediate value is negative.
    * 0 is subtracted from the higher order byte, which also subtracts the carry value from it. The result stored back into PC

1. __JPR__: The AR value is 8b wide. This value is treated as an unsigned value. It is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __CAD__: The PC value now occupies two places on the stack. Its lower order byte is pushed first, followed by the higher order byte. The immediate address is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __CAR__: The PC value now occupies two places on the stack. Its lower order byte is pushed first, followed by the higher order byte. The AR value is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __RET__: The value is restored into the PC the same way it is stored. The first value popped off is stored into the higher order byte, followed by the next value which is stored into the lower order byte.

### 1.2 Data Memory

Data memory is accessed using either the AR value as an address, or using the hardware stack.

Since the AR is only 8b wide, an additional register called BSR has been added. Whenever STR or LOD are used, the value of BSR is used as the higher order byte of the address, while the value of AR is used as the lower order byte of the address.

BSR has the following associated control signals:

1. __LBR__: This signal is used to load the value of BSR from the main bus.

1. __EBR__: This signal is used to put the value of BSR onto the main bus.

To manipulate BSR, the following instruction has been added

__MVB \<rn\>__: This instruction is used to move the value of register *rn* into BSR.

An increase in memory meant that the stack can be much larger than 256B. For maximum flexibility, SP was also made 16b wide. Challenges and solutions are similiar to that of PC, re-written as follows:

1. __The SP could not be loaded in a single cycle__: This necessitated that the LSP signal be made two bits. If MSB is 1, then load is enabled, otherwise disabled. If LSB is 0, the lower order byte is being loaded. If LSB is 1, the higher order byte is being loaded.

1. __The SP could only put one byte onto the bus__: This necessitated that the ESP signal be made two bits. If MSB is 1, then SP's output is enabled, otherwise disabled. If LSB is 0, the lower order byte is enabled. If LSB is 1, the higher order byte is enabled.

The instructions that were modified, and the modifications made, are as follows:

1. __LOD__: The higher order byte of MR is now loaded with the value of BR, while the lower order byte is loaded with the value of AR.

1. __STR__: *Same as for LOD.*

## 2. SPI Flash Controller

The SPI flash controller was, initially, to be implemented fully in the hardware itself as a peripheral. However, not only was it going to be very complex for a 2nd year undergraduate to understand, it was also proving to be difficult for the author to implement in VHDL. Ultimately, it was decided to use a method called [bit-banging][bit-banging-wiki].

To implement bit banging, an I/O port was dedicated to the four SPI signals and required changes were made to `memory_unit.vhd`, `controller.vhd` and `mimas_v2.ucf`. Assembly programs to enable, disable, read and write the SPI device were written, which can be found in the [bootloader][bootloader] file. After that, it was simply a matter of writing the required SPI flash commands for our development board. The outputs were initially tested on a GPIO port on the board using a logic analyzer. Once the correct signals were being generated, the I/O port was hooked to the flash memory and... it worked!

To run the bootloader on another board, the user may have to modify the SPI flash commands used.

## 3. Boot Process and Loading User Programs

For much of the microcontroller's development, no bootloader was used. Every test program was loaded into a COE file, the block memory re-generated, and the entire design re-synthesized and loaded. This was quickly recognized to be an issue if the device was to be put into any practical use. Many ideas were thrown around, including, and (probably) limited to:

1. Loading from PC using UART
1. Loading from SD card using SPI
1. Loading from a ROM connected to a GPIO port using SPI

It was later that the author realized that the onboard 16MB flash can be accessed with dedicated pins. Consequently, the SPI flash controller described in the previous section was developed. The starting address of the user program in the ROM (0x0f0000) was chosen carefully so as to not overwrite FPGA configuration data. All this brought down the time required to load user programs by ~67%, all the while introducing flexibility to the whole process. Furthermore, the API used to access the flash memory can also be used by user programs to have data persist over time.

## 4. Glossary

| Acronym | Meaning |
| - | - |
| ISA | Instruction Set Architecture|
| MAR | Memory Address Register |
| LMR | Load Memory Register |
| MSB | Most Significant Bit |
| LSB | Least Significant Bit |
| PC | Program Counter |
| LPC | Load Program Counter |
| EPC | Enable Program Counter |
| C Flag | Carry Flag |
| AR | Accumulator |
| BSR | Bank Select Register|
| LBR | Load Bank Register |
| EBR | Enable Bank Register |
| SP | Stack Pointer |
| LSP | Load Stack Pointer |
| ESP | Enable Stack Pointer |

[bit-banging-wiki]: https://en.wikipedia.org/wiki/Bit_banging

[bootloader]: assembly-programs/flash_boot.asm
