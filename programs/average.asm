; MikroBitti 3/84
; calculates average from two 0-255 integers.
;  - set values to $FB (251) and $FC (252)
;  - result will be in $FD (253)

A C000 LDA #$00     ; nollaa $FD:n
A C002 STA $FD
A C004 LDA $FB      ; lataa akkuun $FB:n
A C006 CLS          ; puhdistaa c-lipun
A C007 ADC $FC      ; lisää akkuun $FC:n arvon
A C009 BCC $C00F    ; jos luku alle $FF, niin $C==F
A C00B LDX #$80     ; lataa rekisteriin $0100:n keskiarvon
A C00D STX $FD      ; ja asettaa sen paikkaan $FD
A C00F LSR          ; jakaa akun kahdella
A C010 CLC          ; puhdistaa C-lipun
A C011 ADC $FD      ; lisää akkuun paikan $FD arvon
A C013 STA $FD      ; asettaa akun arvon muistipaikkaan $FD
A C015 RTS          ; paluu Basiciin


; Instructions to use from Basic
; average of 57 and 139
; POKE 251,57: POKE 252,139: SYS 49152
; PRINT PEEK (253)
; you should get 98 printed on screen
