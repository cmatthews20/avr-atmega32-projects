; Cole Matthews
; AVR Timers: Counter

.INCLUDE "M32DEF.INC"
	CBI DDRB,0 ;make T0 (PB0) input
	SER R20
	OUT DDRD,R20 ;make PORTD output
	LDI R20,0x06 ;0b0000 0110
	OUT TCCR0,R20 ;counter, falling edge, normal mode
	LDI R20, 250
	OUT TCNT0, R20 ; manually set counter to preset value
AGAIN:
	IN R20,TCNT0
	COM R20
	OUT PORTD,R20 ;PORTD = TCNT0
	IN R16,TIFR
	SBRS R16,TOV0
	RJMP AGAIN ;repeat
	LDI R16,1<<TOV0
	OUT TIFR, R16
	RJMP AGAIN ;repeat

