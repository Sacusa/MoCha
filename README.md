# NUP

## Contents

1. [Todo](#1-todo)
2. [Increase Address Space](#2-increase-address-space)  
2.1 [Program Memory](#21-program-memory)  
2.2 [Data Memory](#22-data-memory)  
3. [Glossary](#3-glossary)

## 1. Todo

1. Increase Address Space
2. Update testbenches
3. Implement bootloader via UART
4. Improve software support and documentation
5. Pipelining

## 2. Increase Address Space

To increase the address space to 64K, the ISA was modified so that the memory could be viewed as 256 banks of 256B each. The main bus was, however, left 8b wide.

The first register to be modified is MR. MR was made 16b wide. This meant that it could not be loaded in a single cycle. The signal LMR was, consequently, made two bits wide. If MSB is 1, then load is enabled, otherwise disabled. If LSB is 0, the lower order byte is being loaded. If LSB is 1, the higher order byte is being loaded.

The impact on how both program memory and data memory are accessed is documented as follows.

### __2.1 Program Memory__

The PC was made into a 16b register. The challenges it posed and the solutions employed are as follows:

1. __The PC could not be loaded in a single cycle__: This necessitated that the LPC signal be made two bits. If MSB is 1, then load is enabled, otherwise disabled. If LSB is 0, the lower order byte is being loaded. If LSB is 1, the higher order byte is being loaded.

1. __The PC could only put one byte onto the bus__: This necessitated that the EPC signal be made two bits. If MSB is 1, then PC's output is enabled, otherwise disabled. If LSB is 0, the lower order byte is enabled. If LSB is 1, the higher order byte is enabled.

The instructions that were modified, and the modifications made, are as follows:

1. __JPD__: The immediate value is 8b wide. This value is treated as an unsigned value. It is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __JPP__: The immediate value is 8b wide. This value is treated as a signed value. The following steps are performed:

    * The immediate value is first added to the PC's lower order byte, with the result stored back into PC.
    * 0 is added to the higher order byte, which also adds to it the carry value of the previous computation, and the result stored back into PC.
    * The immediate value is passed as-is to the accumulator, and then added to itself. This will set the C flag if the immediate value is negative.
    * 0 is subtracted from the higher order byte, which also subtracts the carry value from it. The result stored back into PC

1. __JPR__: The AR value is 8b wide. This value is treated as an unsigned value. It is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __CAD__: The PC value now occupies two places on the stack. Its lower order byte is pushed first, followed by the higher order byte. The immediate address is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __CAR__: The PC value now occupies two places on the stack. Its lower order byte is pushed first, followed by the higher order byte. The AR value is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __RET__: The value is restored into the PC the same way it is stored. The first value popped off is stored into the higher order byte, followed by the next value which is stored into the lower order byte.

### __2.2 Data Memory__

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

## 3. Glossary

| Acronym | Meaning |
| - | - |
| ISA | Instruction Set Architecture|
| LSB | Least Significant Bit |
| MSB | Most Significant Bit |
| MR | Memory Register |
| LMR | Load Memory Register |
| PC | Program Counter |
| LPC | Load Program Counter |
| EPC | Enable Program Counter |
| AR | Accumulator |
| OR | Operand Register |
| BSR | Bank Select Register|
| LBR | Load Bank Register |
| EBR | Enable Bank Register |
| MVB | Move Value Bank |
| C Flag | Carry Flag |
| SP | Stack Pointer |
| LSP | Load Stack Pointer |
| ESP | Enable Stack Pointer |
