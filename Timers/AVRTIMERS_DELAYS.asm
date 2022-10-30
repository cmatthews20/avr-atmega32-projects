; Cole Matthews
; AVR Timers: Delays

; Port Initialization, Main subroutine, and helper subroutine:
; all waves verified by oscilloscope

;Initialization
.INCLUDE "M32DEF.INC"

LDI R17, high(RAMEND)	;Initializes stack pointer
LDI R16, low(RAMEND)	;Initializes stack pointer
OUT SPH, R17		
OUT SPL, R16

CBI DDRB,0 ;make T0 (PB0) input

LDI R16, 0xFF	
OUT DDRD,R16	;PORT D as an output
SER R17
OUT PORTD,R17	;turns off all LEDs

MAIN: ; comment for desired subroutine
;CALL SHORTDELAY
;CALL ONEKDELAY
CALL LONGDELAY
CALL TOGGLELED
;CALL SHORTDELAY
;CALL ONEKDELAY
CALL LONGDELAY
CALL TOGGLELED
RJMP MAIN

TOGGLELED:
IN R17, PIND	;reads the current LED states
LDI R16, 0B00000001	
EOR R17, R16		;toggles the state of LED 1
OUT PORTD,R17	;outputs new LED states
RET

; 5Hz Delay:
SHORTDELAY: LDI R20, 158
OUT TCNT0,R20	;load timer0
LDI R20,0x05	;loads register for prescale
OUT TCCR0,R20	;Timer0,Normal mode, prescale clk/256
SHORTCHECK: IN R20,TIFR	;read TIFR
SBRS R20,TOV0	;if TOV0 is set skip next
RJMP SHORTCHECK	;jump to check if timer full
LDI R20,0x0
OUT TCCR0,R20	;stop Timer0
LDI R20,0x01
OUT TIFR,R20	;clear TOV0 flag
RET

; 1kHz Delay:
ONEKDELAY: LDI R20, 197	;theoretical value: 192.5
OUT TCNT0,R20	;load timer 
LDI R20,0x02	;loads register for prescale
OUT TCCR0,R20	;Timer0, Normal mode, prescale clk/8
ONEKCHECK: IN R20,TIFR	;read TIFR
SBRS R20,TOV0	;if TOV0 is set skip next
RJMP SHORTCHECK	;jump to check if timer full
LDI R20,0x0
OUT TCCR0,R20	;stop Timer0
LDI R20,0x01
OUT TIFR,R20	;clear TOV0 flag
RET

; 1/4Hz Delay:
LONGDELAY:LDI R20, 0x85
OUT TCNT1H,R20	;load timer1 upper bits
LDI R20, 0xEE
OUT TCNT1L,R20	;load timer1 lower bits
LDI R20,0x00
OUT TCCR1A,R20	;Timer0,Normal mode, prescale clk/64
LDI R20,0x03
OUT TCCR1B,R20	;Timer0,Normal mode, prescale clk/64
LONGCHECK:IN R20,TIFR ;read TIFR
SBRS R20,TOV1	;if TOV1 is set skip next instruction
RJMP LONGCHECK	;jump to check if timer full
LDI R20,0x0
OUT TCCR1A,R20	;stop Timer 1
OUT TCCR1B,R20	;stop Timer 1
LDI R20,0x04
OUT TIFR,R20	;clear TOV1 flag
RET
