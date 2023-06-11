	LDA #$41	; $A9; lataa akkuun $41
			; $41;
	CLC		; $18; puhdistaa Carry-lipun
 	ADC #$02	; $69; lisää akkuun $02
			; $02;
	JSR $FFD2	; $20; hyppy aliohjelmaan, tulostaa C:n
			; $D2;
			; $D2;
			; $FF;
	RTS		; $60; paluu takaisin Basiciin

