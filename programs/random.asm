; random value 0-3
; MikroBitti 1/85 Konekielikurssi 6502:lle
;
LDA $A2 ; akkuun ladataan satunnaisluku
LSR     ; luku jaetaan 64:llä
LSR
LSR
LSR
LSR
LSR
STA $FB ; luku asetetaan muistipaikkaan $FB, johon arvoväliltä 0-3
RTS     ; paluu