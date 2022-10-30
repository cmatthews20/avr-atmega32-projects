; Cole Matthews
; Traffic Light Embedded System

.SET MAINGO = 0b11011011 ; 4 possible states of traffic lights
.SET MAINSLOW = 0b10111011
.SET SIDEGO = 0b01111110
.SET SIDESLOW = 0b01111101

.EQU TRAFFICLIGHTS = PORTA

INIT: ; get ports/LEDS ready
SER R16
OUT DDRA, R16 ; set port A as output

LDI R17, high(RAMEND)    ;loads register to initialize stack poitner high
LDI R16, low(RAMEND)    ;loads register to initialize stack poitner low
OUT SPH, R17            ;Initializes stack pointer high
OUT SPL, R16            ;Initializes stack pointer low


MAIN:
LDI R16, MAINGO
OUT TRAFFICLIGHTS, R16
RCALL SHORTDELAY
RCALL SHORTDELAY ; call 20s delay twice for 40s total delay

LDI R16, MAINSLOW
OUT TRAFFICLIGHTS, R16
RCALL SHORTDELAY ; 2s delay

LDI R16, SIDEGO
OUT TRAFFICLIGHTS, R16
RCALL SHORTDELAY ; single 20s delay for side lights

LDI R16, SIDESLOW
OUT TRAFFICLIGHTS, R16
RCALL SHORTDELAY

RJMP MAIN ; keep lights going forever

SHORTDELAY:
; calculations for 2s delay
; T = 1/f = 1 / 1MHz = 1us
; 2 / 1us = 2 000 000
; Prescale of clk/1024: 2 000 000 / 1024 = 1953.125 ~ 1953
; 65536 - 1953 = 63583 = 0xF85F
LDI R16, HIGH(0xF85F)
OUT TCNT1H, R16
LDI R16, LOW(0xF85F)
OUT TCNT1L, R16
LDI R16, 0x00
OUT TCCR1A, R16 ; normal mode
LDI R16, 0x05
OUT TCCR1B, R16 ; clk/1024

AGAIN:
IN R16, TIFR
SBRS R16, TOV1 ; skip next instr if TOV1 set
RJMP AGAIN
LDI R16, 0x00
OUT TCCR1B, R16 ; stop timer1
LDI R16, 0x04
OUT TIFR, R16 ; clear TOV1 flag

RET ; end of SHORTDELAY subroutine

LONGDELAY:
; calculations for 20s delay
; T = 1/f = 1 / 1MHz = 1us
; 20 / 1us = 20 000 000
; Prescale of clk/1024: 20 000 000 / 1024 = 19531.25 ~ 19531
; 65536 - 19531 = 46005 = 0xB3B5

LDI R16, HIGH(0xB3B5)
OUT TCNT1H, R16
LDI R16, LOW(0xB3B5)
OUT TCNT1L, R16
LDI R16, 0x00
OUT TCCR1A, R16 ; normal mode
LDI R16, 0x05
OUT TCCR1B, R16 ; clk/1024

AGAIN2:
IN R16, TIFR
SBRS R16, TOV1 ; skip next instr if TOV1 set
RJMP AGAIN2
LDI R16, 0x00
OUT TCCR1B, R16 ; stop timer1
LDI R16, 0x04
OUT TIFR, R16 ; clear TOV1 flag

RET ; end of LONGDELAY subroutine

; --- END OF FILE ---