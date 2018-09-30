    CAD U SPI_RESET_AND_ENABLE

    ;=========================================================
    ; Initialize the SPI flash memory for reading from address
    ; 0x0f0000 upwards.
    ;=========================================================

    MVI 0 3
    CAD U SPI_WRITE_BYTE
    MVI 0 0x0f
    CAD U SPI_WRITE_BYTE
    MVI 0 0
    CAD U SPI_WRITE_BYTE
    CAD U SPI_WRITE_BYTE

    ;==================================================
    ; Read the program size into R2 (MSB) and R3 (LSB).
    ;==================================================

    CAD U SPI_READ_BYTE
    MVS 0
    MVD 2
    CAD U SPI_READ_BYTE
    MVS 0
    MVD 3

    ; get bootloader size
    MVI 4 0
    CAD U GET_BOOTLOADER_SIZE
    MVS 0
    MVD 5

    ;===================================
    ; R6 <= MSB of number of bytes read.
    ; R7 <= LSB of number of bytes read.
    ; R0 <= (R2 XOR R6) OR (R3 XOR R7)
    ; If R0 == 0, all bytes read.
    ;===================================

    MVI 6 0  ; initialize R6
    MVI 7 0  ; initialize R7

    PSH 0  ; push anything

    READ_USER_CODE_LOOP_START:
        ; R0 <= (R2 XOR R6)
        MVS 2
        XRA 6
        MVD 0

        ; R0 <= (R3 XOR R7) OR R0
        MVS 3
        XRA 7
        ORA 0
        MVD 0

        MVS 0
        JPD Z READ_USER_CODE_LOOP_END

        ; read next byte
        CAD U SPI_READ_BYTE

        ; store it
        MVB 4
        MVS 5
        STR 0

        ; increment address
        INC 5
        ADI 4 0

        ; increment byte counter
        INC 7
        ADI 6 0

        JPD U READ_USER_CODE_LOOP_START
    READ_USER_CODE_LOOP_END:

    JPD U BOOTLOADER_END

;==============================================
; Resets the SPI flash memory.
; This is done by driving CS high and then low.
; SPI_CLK is low after this.
;==============================================
SPI_RESET_AND_ENABLE:
    PSH 0
    PSH 1

    MVI 0 0xff
    MVB 0
    MVI 0 0xe7
    
    ; reset SPI
    MVI 1 8
    MVS 0
    STR 1

    ; enable SPI
    MVI 1 0
    MVS 0
    STR 1

    POP 1
    POP 0

    RET U

;========================================
; Reads a single byte from the SPI flash.
; Requires the SPI_CLK to be low.
; Returns the byte in R0.
;========================================
SPI_WRITE_BYTE:
    PSH 1
    PSH 2
    PSH 3
    PSH 4

    MVI 1 0xff
    MVB 1
    MVI 1 0xe7
    MVS 1
    LOD 2
    MVI 3 8

    SPI_WRITE_BYTE.WRITE_LOOP_START:
        MVS 3
        JPD Z SPI_WRITE_BYTE.WRITE_LOOP_END

        ; extract MSB of data
        MVS 0
        MVD 4
        RRC 4
        RRC 4
        RRC 4
        RRC 4
        RRC 4
        RRC 4
        RRC 4
        ANI 4 1
        ANI 2 0x0e
        MVS 4
        ORA 2
        MVD 2

        ; write data to SPI register
        MVS 1
        STR 2

        ; give clock pulse
        XRI 2 4
        MVS 1
        STR 2
        XRI 2 4
        MVS 1
        STR 2

        RLC 0
        DCR 3
        JPD U SPI_WRITE_BYTE.WRITE_LOOP_START
    SPI_WRITE_BYTE.WRITE_LOOP_END:

    POP 4
    POP 3
    POP 2
    POP 1

    RET U

;============================================
; Writes a single byte (R0) to the SPI flash.
; Requires the SPI_CLK to be low.
;============================================
SPI_READ_BYTE:
    PSH 1
    PSH 2
    PSH 3
    PSH 4

    MVI 0 0
    MVI 1 0xff
    MVB 1
    MVI 1 0xe7
    MVS 1
    LOD 2
    MVI 3 8

    SPI_READ_BYTE.READ_LOOP_START:
        MVS 3
        JPD Z SPI_READ_BYTE.READ_LOOP_END

        RLC 0

        ; read data
        RRC 2
        ANI 2 1
        MVS 2
        ORA 0
        MVD 0

        ; give clock pulse
        MVS 1
        LOD 2
        XRI 2 4
        MVS 1
        STR 2
        XRI 2 4
        MVS 1
        STR 2
        
        MVS 1
        LOD 2
        DCR 3
        JPD U SPI_READ_BYTE.READ_LOOP_START
    SPI_READ_BYTE.READ_LOOP_END:

    POP 4
    POP 3
    POP 2
    POP 1

    RET U

;=================================
; Disables the SPI flash chip.
; This is done by driving CS high.
;=================================
SPI_DISABLE:
    PSH 0
    PSH 1

    MVI 0 0xff
    MVB 0
    MVI 0 0xe7
    MVI 1 8
    MVS 0
    STR 1

    POP 1
    POP 0

    RET U

;=========================================
; Returns the size of the bootloader code.
; Note: This should always be in the end.
; CAUTION: DO NOT MODIFY THE CODE BELOW!!
;=========================================
GET_BOOTLOADER_SIZE:
    CAD U SYS_GET_BOOTLOADER_SIZE
    RET U
SYS_GET_BOOTLOADER_SIZE:
    POP 1
    POP 0
    PSH 0
    PSH 1
    ADI 0 8
    RET U
BOOTLOADER_END: