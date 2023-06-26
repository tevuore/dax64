; Example prorgam to test assembler features

START
    LDY #BYTE       ; Load Y
    TYA            ; Transfer Y to Accumulator
    STA ADDRESS,y    ; Store Accumulator
    LDA #$03       ; Load Accumulator
    STA $d800,y    ; Store Accumulator
    INY            ; Increment Y by one
    BNE #$f4       ; Branch if Result Not Zero
    RTS            ; Return from Subroutine

STARTINDEX  .BYTE $00
ADDRESS     .WORD $0400
