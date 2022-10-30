; Cole Matthews
; Whack-a-rat game (A.K.A. whack-a-mole)

.EQU ON = 0x00
.EQU OFF = 0xFF
.EQU TRUE = 1
.DEF LED = R16
.DEF SWITCH = R17
.DEF SCORE = R18
.DEF RATREG = R19
.DEF GEN1 = R20
.DEF GEN2 = R21
.DEF GEN3 = R22
.DEF GEN4 = R23
.DEF GEN5 = R24

;Initialized locations for rat values
RAT0: .DB 0,0
RAT1: .DB 0,0
RAT2: .DB 0,0
RAT3: .DB 0,0
RAT4: .DB 0,0
RAT5: .DB 0,0
RAT6: .DB 0,0
RAT7: .DB 0,0


INITIALIZING:
LDI GEN1, ON
LDI GEN2, OFF
OUT DDRB, GEN1	;Sets port b as input
OUT PORTB, GEN2	;enables portB pull up resistors
OUT DDRD,GEN2	;Sets port d as output
OUT PORTD, GEN2
LDI GEN1, high(RAMEND)
LDI GEN2, low(RAMEND)
OUT SPH, GEN1
OUT SPL, GEN2
LDI SCORE, 0x00

MAIN:
;running code
CALL GETSEED
CALL STARTBLINK
CALL PLAYGAME
L1:RJMP L1


PLAYGAME:
LDS RATREG, RAT0
LDI GEN4, 0x01
CALL RATSHOW

LDS RATREG, RAT1
LDI GEN4, 0x02
CALL RATSHOW

LDS RATREG, RAT2
LDI GEN4, 0x04
CALL RATSHOW

LDS RATREG, RAT3
LDI GEN4, 0x08
CALL RATSHOW

LDS RATREG, RAT4
LDI GEN4, 0x10
CALL RATSHOW

LDS RATREG, RAT5
LDI GEN4, 0x20
CALL RATSHOW

LDS RATREG, RAT6
LDI GEN4, 0x40
CALL RATSHOW

LDS RATREG, RAT7
LDI GEN4, 0x80
CALL RATSHOW

SER GEN4
CPSE SCORE, GEN4
RJMP DISPLAYSCORE
CALL CELEBRATE
CALL CELEBRATE
DISPLAYSCORE:
COM SCORE
OUT PORTD, SCORE

RET

;=====================================================================================================
;RAT subroutine
RATSHOW:	;set led for rat, Check if button is pressed for half second, follow after
OUT PORTD, RATREG
CALL RATDELAY
LDI GEN1, OFF
OUT PORTD, GEN1
ret	;Returns from subroutine
;=====================================================================================================



;TOTAL DELAY: 1 + GEN1=*(GEN2*(1+2) + 1 + 2 + 1) cycles. For GEN1 = 244, GEN2 = 67,
;Total cycles = 50021, at f=100k, delay = 0.5 seconds
RATDELAY: 
LDI GEN3,6	;Sets Outer loop counter for loop 2 to 244 loops
RATDEC3:LDI GEN1,255	;1 cycle
RATDEC2: LDI GEN2,255	;jump point for loop 2. Sets loop count for loop 1 to 67 loops
RATDEC1: DEC GEN2	;label for loop 1. Lowers loop 1 count by 1
BRNE RATDEC1	;Checks if loop 1 is done
IN SWITCH, PINB		;looks at input from switches
SER GEN5
CPSE SWITCH, GEN5	; If switch 0 is not pressed, loops. once pressed, saves value of gen1
RJMP HITDETECTED
RJMP INPUTNOTEQUAL
INPUTNOTEQUAL: 
DEC GEN1	;decrements loop 2 count by 1
BRNE RATDEC2	; checks if loop 2 is done
DEC GEN3
BRNE RATDEC3

TIMEOUT:
RJMP HITFAIL

HITWRONG:
CALL SHORTDELAY
RJMP HITFAIL

HITDETECTED:
CPSE SWITCH, RATREG
RJMP HITWRONG

ADD SCORE, GEN4

LDI GEN4, OFF	;loads GEN4 with off
OUT PORTD, GEN4	;turns off LEDs
CALL SHORTDELAY	;Waits a short time
OUT PORTD, RATREG	;turns on LED for rat
CALL SHORTDELAY	;Waits a short time
OUT PORTD, GEN4	;turns off LEDs
CALL SHORTDELAY	;Waits a short time
OUT PORTD, RATREG	;turns on LED for rat
CALL SHORTDELAY	;Waits a short time
OUT PORTD, GEN4	;turns off LEDs
CALL SHORTDELAY	;Waits a short time
OUT PORTD, RATREG	;turns on LED for rat
CALL SHORTDELAY	;Waits a short time

HITFAIL: 
RET
;=====================================================================================================

GETSEED:
LDI GEN2, 0b11111110	;sets teh switch being checked to sw0
LDI GEN1, ON	;initialized register for randomization
CHECKSW0: INC GEN1	;loop to get random value
IN SWITCH, PINB		;looks at input from switches
CPSE SWITCH, GEN2	; If switch 0 is not pressed, loops. once pressed, saves value of gen1
RJMP CHECKSW0	;Returns to checking sw0

CALL RANDOMRAT	;Sets ratreg to a random value, gotten from GEN1
STS RAT0, RATREG	;stores that value to rat 0

CALL RANDOMRAT	;Sets ratreg to a random value, gotten from GEN1
STS RAT1, RATREG	;stores that value to rat 0

CALL RANDOMRAT	;Sets ratreg to a random value, gotten from GEN1
STS RAT2, RATREG	;stores that value to rat 0

CALL RANDOMRAT	;Sets ratreg to a random value, gotten from GEN1
STS RAT3, RATREG	;stores that value to rat 0

CALL RANDOMRAT	;Sets ratreg to a random value, gotten from GEN1
STS RAT4, RATREG	;stores that value to rat 0

CALL RANDOMRAT	;Sets ratreg to a random value, gotten from GEN1
STS RAT5, RATREG	;stores that value to rat 0

CALL RANDOMRAT	;Sets ratreg to a random value, gotten from GEN1
STS RAT6, RATREG	;stores that value to rat 0

CALL RANDOMRAT	;Sets ratreg to a random value, gotten from GEN1
STS RAT7, RATREG	;stores that value to rat 0
RET
;=====================================================================================================

RANDOMRAT:
LDI RATREG, 0b00000001
LDI GEN2, 0b00000111
AND GEN2, GEN1
BREQ SEEDCYCLE
RANDOMRAT0: LSL RATREG	;Label for assigning random value. moves location of '1' left by one.
DEC GEN2	;lowers the count of the number of shifts left to do
BRNE RANDOMRAT0	; continues to shift the 1 leftwards if the value of GEN2 is not 0
SEEDCYCLE: 
ROR GEN1	;cycles gen1 3 times rightwards
ROR GEN1
ROR GEN1
TST RATREG	;TEST IF GEN2 IS ZERO. SETS SREG FLAGS
BREQ RATiS1	;corrects RATREG to not be 0 if that happens
RJMP RATiS0	;skips over the fix for if RATREG is 0
RATis1: INC RATREG	;Increases RATREG from 0x00 to 0x01
RATis0: COM RATREG
RET ;RETURNS FROM SUB ROUTINE
;=====================================================================================================

CELEBRATE:
LDI GEN2, 0x55
OUT PORTD, GEN2
CALL DELAY
LDI GEN2, 0xAA
OUT PORTD,GEN2
CALL DELAY
CLR GEN2
OUT PORTD, GEN2
RET
;=====================================================================================================

;StartBlink sub routine
STARTBLINK:
CALL LEDON	;Turns all LEDs ON
CALL DELAY		;Waits 0.5 seconds
CALL LEDOFF	;Turns all LEDs OFF
CALL DELAY		;Waits 0.5 seconds
CALL LEDON	;Turns all LEDs ON
CALL DELAY		;Waits 0.5 seconds
CALL LEDOFF	;Turns all LEDs OFF
CALL DELAY		;Waits 0.5 seconds
CALL LEDON	;Turns all LEDs ON
CALL DELAY		;Waits 0.5 seconds
CALL LEDOFF	;Turns all LEDs OFF
CALL DELAY		;Waits 0.5 seconds
CALL DELAY		;Waits 0.5 seconds
RET	;Retruns from sub routine
;=====================================================================================================

LEDOFF:
LDI GEN1, OFF
OUT PORTD, GEN1	;Turns all LEDs ON
RET
;=====================================================================================================

LEDON:
LDI GEN1, ON
OUT PORTD, GEN1	;Turns all LEDs ON
RET
;=====================================================================================================

;Delay subroutine:
;TOTAL DELAY: 1 + GEN1*(GEN2*(1+2) + 1 + 2 + 1) cycles. For GEN1 = 244, GEN2 = 67,
;Total cycles = 50021, at f=100k, delay = 0.5 seconds
DELAY: 
LDI GEN3,3	;Sets Outer loop counter for loop 2 to 244 loops
DEC3:LDI GEN1,255	;1 cycle
DEC2: LDI GEN2,255	;jump point for loop 2. Sets loop count for loop 1 to 67 loops
DEC1: DEC GEN2	;label for loop 1. Lowers loop 1 count by 1
BRNE DEC1	;Checks if loop 1 is done
DEC GEN1	;decrements loop 2 count by 1
BRNE DEC2	; checks if loop 2 is done
DEC GEN3
BRNE DEC3
ret	;Returns from subroutine
;=====================================================================================================

;Delay subroutine:
;TOTAL DELAY: 1 + GEN1*(GEN2*(1+2) + 1 + 2 + 1) cycles. For GEN1 = 244, GEN2 = 67,
;Total cycles = 50021, at f=100k, delay = 0.5 seconds
SHORTDELAY: 
LDI GEN3,1	;Sets Outer loop counter for loop 2 to 244 loops
SHORTDEC3:LDI GEN1,200	;1 cycle
SHORTDEC2: LDI GEN2,255	;jump point for loop 2. Sets loop count for loop 1 to 67 loops
SHORTDEC1: DEC GEN2	;label for loop 1. Lowers loop 1 count by 1
BRNE SHORTDEC1	;Checks if loop 1 is done
DEC GEN1	;decrements loop 2 count by 1
BRNE SHORTDEC2	; checks if loop 2 is done
DEC GEN3
BRNE SHORTDEC3
ret	;Returns from subroutine
;=====================================================================================================