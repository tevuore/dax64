LDY #$00       ; Load Y
TYA            ; Transfer Y to Accumulator
STA $0400,y    ; Store Accumulator
LDA #$03       ; Load Accumulator
STA $d800,y    ; Store Accumulator
INY            ; Increment Y by one
BNE #$f4       ; Branch if Result Not Zero
RTS            ; Return from Subroutine
