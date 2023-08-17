; vertaa onko muistipaikassa $02 arvo $05
; MikroBitti 3/84

    LDA #$05    ; lataa akkuun arvon 5
    CMP $02     ; vertaa akun arvoa muistipaikan 2-arvoon
    BEQ on      ; jos tulos on 0 eli Z-lippu on asettunut, hiin hyppää tiettyyn muistipaikkaan (on)
    RTS         ; paluu Basicciin
on: LDA #$4F    ; tulostaa "ON"
    JSR $FFD2
    LDA #$4E
    JSR $FFD2
    RTS


