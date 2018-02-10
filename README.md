# NUP

## 1. Increased Address Space

To increase the address space to 64K, the ISA was modified so that the memory could be viewed as 256 banks of 256B each. The main bus was, however, left 8b wide.

The first register to be modified is MR. MR was made 16b wide. This meant that it could not be loaded in a single cycle. The signal LMR was, consequently, made two bits wide. If MSB is 1, then load is enabled, otherwise disabled. If LSB is 0, the lower order byte is being loaded. If LSB is 1, the higher order byte is being loaded.

The impact on how both program memory and data memory are accessed is documented as follows.

### __1.1 Program Memory__

The PC was made into a 16b register. The challenges it posed and the solutions employed are as follows:

1. __The PC could not be loaded in a single cycle__: This necessitated that the LPC signal be made two bits. If MSB is 1, then load is enabled, otherwise disabled. If LSB is 0, the lower order byte is being loaded. If LSB is 1, the higher order byte is being loaded.

1. __The PC could only put one byte onto the bus__: This necessitated that the EPC signal be made two bits. If MSB is 1, then PC's output is enabled, otherwise disabled. If LSB is 0, the lower order byte is enabled. If LSB is 1, the higher order byte is enabled.

The instructions that were modified, and the modifications made, are as follows:

1. __JPD__: The immediate value is 8b wide. This value is treated as an unsigned value. It is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __JPP__: The immediate value is 8b wide. This value is treated as a signed value. The following steps are performed:

    * The immediate value is first added to the PC's lower order byte, with the result stored back into PC.
    * 0 is added to the higher order byte, which also adds to it the carry value of the previous computation.
    * The immediate value is passed as-is to the accumulator. This sets S flag appropriately.
    * At this point , if S=0 then the next instruction is fetched.
    * Otherwise, -1 (see \[[1]\] below) is added to the higher order byte and stored back.

1. __JPR__: The AR value is 8b wide. This value is treated as an unsigned value. It is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __CAD__: The PC value now occupies two places on the stack. Its higher order byte is pushed first, followed by the lower order byte. The immediate address is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __CAR__: The PC value now occupies two places on the stack. Its higher order byte is pushed first, followed by the lower order byte. The AR value is fed as-is into the PC's lower order byte. The higher order byte is made all 0s.

1. __RET__: The value is restored into the PC the same way it is stored. The first value popped off is stored into the lower order byte, followed by the next value which is stored into the higher order byte.

### __1.2 Data Memory__

Data memory is accessed using either the AR value as an address, or using the hardware stack.

Since the AR is only 8b wide, an additional register called BSR has been added. Whenever STR or LOD are used, the value of BSR is used as the higher order byte of the address, while the value of AR is used as the lower order byte of the address.

BSR has the following associated control signals:

1. __LBR__: This signal is used to load the value of BSR from the main bus.

1. __EBR__: This signal is used to put the value of BSR onto the main bus.

To manipulate BSR, the following instruction has been added

__MVB rn__: This instruction is used to move the value of register *rn* into BSR.

### __1.3 References__

1. __SOR__: This additional control signal, which operates on OR, is used to set its value to all 1s, or -1.

## 2. Glossary

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
| SOR | Set Operand Register |
| BSR | Bank Select Register|
| LBR | Load Bank Register |
| EBR | Enable Bank Register |
| MVB | Move Value Bank |
| S Flag | Sign Flag |

[1]: #__1-3-references__
