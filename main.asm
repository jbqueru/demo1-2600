; Copyright 2022 Jean-Baptiste M. "JBQ" "Djaybee" Queru
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;    http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

	.processor	6502

_TIA_VSYNC	.equ	$00
_TIA_VBLANK	.equ	$01
_TIA_WSYNC	.equ	$02
;_TIA_RSYNC	.equ	$03
_TIA_NUSIZ0	.equ	$04
_TIA_NUSIZ1	.equ	$05
_TIA_COLUP0	.equ	$06
_TIA_COLUP1	.equ	$07
_TIA_COLUPF	.equ	$08
_TIA_COLUBK	.equ	$09
_TIA_CTRLPF	.equ	$0A
_TIA_REFP0	.equ	$0B
_TIA_REFP1	.equ	$0C
_TIA_PF0	.equ	$0D
_TIA_PF1	.equ	$0E
_TIA_PF2	.equ	$0F
_TIA_RESP0	.equ	$10
_TIA_RESP1	.equ	$11
_TIA_RESM0	.equ	$12
_TIA_RESM1	.equ	$13
_TIA_RESBL	.equ	$14
_TIA_AUDC0	.equ	$15
_TIA_AUDC1	.equ	$16
_TIA_AUDF0	.equ	$17
_TIA_AUDF1	.equ	$18
_TIA_AUDV0	.equ	$19
_TIA_AUDV1	.equ	$1A
_TIA_GRP0	.equ	$1B
_TIA_GRP1	.equ	$1C
_TIA_ENAM0	.equ	$1D
_TIA_ENAM1	.equ	$1E
_TIA_ENABL	.equ	$1F
_TIA_HMP0	.equ	$20
_TIA_HMP1	.equ	$21
_TIA_HMM0	.equ	$22
_TIA_HMM1	.equ	$23
_TIA_HMBL	.equ	$24
_TIA_VDELP0	.equ	$25
_TIA_VDELP1	.equ	$26
_TIA_VDELBL	.equ	$27
_TIA_RESMP0	.equ	$28
_TIA_RESMP1	.equ	$29
_TIA_HMOVE	.equ	$2A
_TIA_HMCLR	.equ	$2B
_TIA_CXCLR	.equ	$2C

_TIA_CXM0P	.equ	$00
_TIA_CXM1P	.equ	$01
_TIA_CXP0FB	.equ	$02
_TIA_CXP1FB	.equ	$03
_TIA_CXM0FB	.equ	$04
_TIA_CXM1FB	.equ	$05
_TIA_CXBLPF	.equ	$06
_TIA_CXPPMM	.equ	$07
_TIA_INPT0	.equ	$08
_TIA_INPT1	.equ	$09
_TIA_INPT2	.equ	$0A
_TIA_INPT3	.equ	$0B
_TIA_INPT4	.equ	$0C
_TIA_INPT5	.equ	$0D

_TIA_CO_GRAY	.equ	$00
_TIA_CO_GOLD	.equ	$10
_TIA_CO_ORANGE	.equ	$20
_TIA_CO_BRT_ORG	.equ	$30
_TIA_CO_PINK	.equ	$40
_TIA_CO_PURPLE	.equ	$50
_TIA_CO_PUR_BLU	.equ	$60
_TIA_CO_BLU_PUR	.equ	$70
_TIA_CO_BLUE	.equ	$80
_TIA_CO_LT_BLUE	.equ	$90
_TIA_CO_TURQ	.equ	$A0
_TIA_CO_GRN_BLU	.equ	$B0
_TIA_CO_GREEN	.equ	$C0
_TIA_CO_YLW_GRN	.equ	$D0
_TIA_CO_ORG_GRN	.equ	$E0
_TIA_CO_LT_ORG	.equ	$F0

_TIA_LU_MIN	.equ	$00
_TIA_LU_V_DARK	.equ	$02
_TIA_LU_DARK	.equ	$04
_TIA_LU_M_DARK	.equ	$06
_TIA_LU_M_LIGHT	.equ	$08
_TIA_LU_LIGHT	.equ	$0A
_TIA_LU_V_LIGHT	.equ	$0C
_TIA_LU_MAX	.equ	$0E

_PIA_DATA_A	.equ	$280
_PIA_DDR_A	.equ	$281
_PIA_DATA_B	.equ	$282
;_PIA_DDR_B	.equ	$283

_PIA_WT1T	.equ	$294
_PIA_WT8T	.equ	$295
_PIA_WT64T	.equ	$296
_PIA_WT1024T	.equ	$297

_PIA_RTIM	.equ	$284

_ZP_LINE_COUNT	.equ	$80

	.org	$F000,$EA
Main:
; Set up CPU
	CLD			; Clear decimal mode
	LDX	#$FF		; Initial stack pointer
	TXS			; Set stack pointer

; Clear zero-page (TIA + RAM)
	LDA	#0
	TAX
ClearZeroPage:
	STA	0,X
	INX
	BNE	ClearZeroPage

MainLoop:
; -------------------------------
; Overscan - 17 lines total
	LDA	#2		; +2/5
	STA	_TIA_VBLANK	; +3/8 - turn blank on

; Skip 16 lines. 16 lines is 16*76 = 1216 CPU cycles, i.e. 19*64.
; In other words, 19 ticks of 64T is 16 lines.
; Initialize timer at 20, it'll spend 64 cycles each in 19, 18... 1.
; When it reaches 0, we're into the 17th line.
; Timer is set 14 cycles into the line, plus 6 cycles of loop jitter,
; well within the 73 cycles before WSYNC.

	LDA	#19		; +2/10
	STA	_PIA_WT64T	; +4/14

	LDA	#0
TimOverscan:
	CMP	_PIA_RTIM
	BNE	TimOverscan

	STA	_TIA_WSYNC	; +3/(?->76) - end of overscan line 16

; -------------------------------
; Vsync - 3 lines
	LDA	#2		; +2/2
	STA	_TIA_VSYNC	; +3/5 - turn sync on
	STA	_TIA_WSYNC	; +3/(8..76) - end of vsync line 0
	STA	_TIA_WSYNC	; +3/(3..76) - end of vsync line 1
	STA	_TIA_WSYNC	; +3/(3..76) - end of vsync line 2

; -------------------------------
; Vblank - 30 lines total
	LDA	#0		; +2/2
	STA	_TIA_VSYNC	; +3/5 - turn sync off

; Skip 28 lines. 28 lines is 28*76 = 2128 CPU cycles, i.e. 33.25*64.
; In other words, 34 ticks of 64T is 28 lines + 48 CPU cycles.
; Initialize timer at 35, it'll spend 64 cycles each in 34, 33... 1.
; When it reaches 0, we're into the 29th line.
; Timer is set 11 cycles into the line, fires 48 cycles after the exact
; position, plus 6 cycles of loop jitter, within the 73 cycles
; before WSYNC.

	LDA	#35		; +2 / 7 - load timer value
	STA	_PIA_WT64T	; +4 / 11 - and set it into the PIA

	LDA	#0
TimVblank:
	CMP	_PIA_RTIM
	BNE	TimVblank

	STA	_TIA_WSYNC	; +3/(?..76) ; end vblank line 28


; Segment playfield lines every 16 pixels = 10 segments
; P0 repeat 3x
; M0 repeat 3x
; M1 repeat 2x (or 3x w/ overlap)
; P1 repeat 2x (or 3x w/ overlap)

; possible M positions
; MIS=47 COL=111 CPU=37 (implies MIS=63 MIS=79)
; MIS=95 COL=159 CPU=53 (implies MIS=111 MIS=127)
; MIS=143 COL=207 CPU=69 (implies MIS=159 MIS=15)

; Assuming 95-143, missing 31 47 63 79
; Can be done at 31 or 15

; SPR=15 COL=78 CPU=26
; SPR=63 COL=126 CPU=42

; Stop sprite delay (Todo: cheaper to embrace it?)
	LDA	#$0		; +2/2
	STA	_TIA_VDELP0	; +3/5
	STA	_TIA_VDELP1	; +3/8
; Disable sprite reflection
	STA	_TIA_RESP0	; +3/11
	STA	_TIA_RESP1	; +3/14
; Color black (happens to be 0).
	STA	_TIA_COLUP0	; +3/17
	STA	_TIA_COLUP1	; +3/20

	BIT	0		; +3/23
        STA	_TIA_RESP0	; +3/26 COL=78 SPR=15

	LDA	#$C0		; +2/28
	STA	_TIA_GRP0	; +3/31
	STA	_TIA_GRP1	; +3/34

	LDA	#$13		; +2/36
	STA	_TIA_NUSIZ0	; +3/39
        STA	_TIA_RESP1	; +3/42 COL=126 SPR=63

	STA	_TIA_ENAM0	; +3/45
	STA	_TIA_ENAM1	; +3/48
        NOP			; +2/50
	STA	_TIA_RESM0	; +3/53 COL=159 MIS=95
	STA	_TIA_NUSIZ1	; +3/56

	PHP			; +3/59
        PLP			; +4/63
        BIT	0		; +3/66
	STA	_TIA_RESM1	; +3/69 COL=207 MIS=143
	NOP			; /71

	LDX	#$0		; +2/73
	STX	_TIA_VBLANK	; +3/76 COL=228 PIX=160 - turn blank off

	; exact sync		; end vblank line 29



; -------------------------------
; Active area - 212 lines total

; Active lines 0-191
	LDY	#192		; +2 / 2
	STY	_ZP_LINE_COUNT	; +3 / 5
	STY	_ZP_LINE_COUNT	; +3 / 8 - extra to align line 0 with subsequent
Lines:
;	LDA	#$AA		; +2 / 2
;	LDX	#$AA		; +2 / 4
;	LDY	#$AA		; +2 / 6
;	STA	_TIA_PF0
;	STX	_TIA_PF1
;	STY	_TIA_PF2
	LDY	#$A4
	STY	_TIA_COLUPF

	STA	_TIA_WSYNC	; ? / 76 - end of line 8*n + 7

	DEC	_ZP_LINE_COUNT	; +5 / 5
	BNE	Lines		; taken: +3 / 8 DO NOT CROSS PAGE BOUNDARIES
				; not taken: +2 / 7

; 40-pixel sprite for signature
;
; Display at pixel 108 - 147 -> same value in PF1 and PF2
; SPR 108 = COL 171 = CPU 57
; SPR 117 = COL 180 = CPU 60
; Write 1: PIX 116 to 123 = COL 184 to 191 = CPU 62 to 63
; Write 2: PIX 124 to 131 = COL 192 to 199 = CPU 64 to 66
; Write 3: PIX 132 to 139 = COL 200 to 207 = CPU 67 to 69

; Active line 192
; Set things up for signature


; Set all colors to be the same - everything is invisible
	LDA	#_TIA_CO_PUR_BLU + _TIA_LU_DARK	; +2 / 9
	STA	_TIA_COLUBK	; +3 / 12
	STA	_TIA_COLUPF	; +3 / 15
	STA	_TIA_COLUP0	; +3 / 18
	STA	_TIA_COLUP1	; +3 / 21 / COL 63 / PIX -5 - early enough!

; Disable all graphics
	LDA	#$0		; +2 / 23
	STA	_TIA_GRP0	; +3 / 26 - write iP0, copy iP1 to dP1
	STA	_TIA_GRP1	; +3 / 29 - write iP1, copy iP0 to dP0
	STA	_TIA_GRP0	; +3 / 32 - write iP0, copy iP1 to dP1
	STA	_TIA_ENAM0	; +3 / 35
	STA	_TIA_ENAM1	; +3 / 38
	STA	_TIA_ENABL	; +3 / 41
; Sprite reflection off
	STA	_TIA_REFP0	; +3 / 44
	STA	_TIA_REFP1	; +3 / 47
; Delay to sync
	PHP			; +3 / 50
	PLP			; +4 / 54
; Set approximate sprite position
	STA	_TIA_RESP0	; +3 / 57 / COL 171 / SPR 108
	STA	_TIA_RESP1	; +3 / 60 / COL 180 / SPR 117
; Move sprite 1 pixel to the left (+1 clock)
	LDA	#$10		; +2 / 62
	STA	_TIA_HMP1	; +3 / 65
	STA	_TIA_WSYNC	; ? / 76 - end active line 192

; Active line 193
	STA	_TIA_HMOVE	; +3 / 3

	LDA	#$FF		; +2 / 5
        STA	_TIA_PF0	; +3 / 8
        STA	_TIA_PF1	; +3 / 11
        STA	_TIA_PF2	; +3 / 14

	LDA	#_TIA_CO_GRAY + _TIA_LU_MIN	; +2 / 16
	STA	_TIA_COLUBK	; +3 / 19
	LDA	#_TIA_CO_GRAY + _TIA_LU_LIGHT	; +2 / 21
	STA	_TIA_COLUP0	; +3 / 24
	STA	_TIA_COLUP1	; +3 / 27

	STA	_TIA_HMCLR	; +3 / 30

; Sprite repeat setup
	LDA	#$3		; +2 / 23
	STA	_TIA_NUSIZ0	; +3 / 26
	LSR			; +2 / 28 - A contains 1
	STA	_TIA_NUSIZ1	; +3 / 31

	LDA	#$1		; +2 / 32
	STA	_TIA_VDELP0	; +3 / 35
	STA	_TIA_VDELP1	; +3 / 38

	STA	_TIA_WSYNC	; ? / 76 - end active line 193

; Active line 194
	LDY	#13		; +2/2
Line195To207:
	STA	_TIA_WSYNC	; +3/(2..76) - end active line 194
        			; +3/76 - end active line 195-207

; Active lines 195-208
	LDA	#$FF		; +2/2
	STA	_TIA_PF1	; +3/5
	STA	_TIA_PF2	; +3/8

	LDA	Logo1,Y		; +4/12
        STA	_TIA_GRP0	; +3/15 - oP0=X nP0=1 oP1=X nP1=X
	LDA	Logo2,Y		; +4/19
        STA	_TIA_GRP1	; +3/22 - oP0=1 nP0=1 oP1=X nP1=2
	LDA	Logo3,Y		; +4/26
        STA	_TIA_GRP0	; +3/29 - oP0=1 nP0=3 oP1=2 nP1=2

	LDX	Logo4,Y		; +4/33
	NOP			; +2/35
        NOP			; +2/37

; update PF1 between 37 and 53 (theo) / 57 (actual)
; update PF2 between 48 (theo) / 45 (actual) and 64
; PF2 works at 44 on my emulator, but there seem to be
; some 2600 implementations (Jr?) that are off by 1 pixel.
; Difference between theo and actual is because top 3 bits
; are identical between $FF and $E0, so we can change while
; those bits are getting displayed
	LDA	#$E0		; +2/39
	STA	_TIA_PF1	; +3/42 COL=111 PIX=43
	STA	_TIA_PF2	; +3/45 COL=135 PIX=67

	LDA	Logo5,Y		; +4/49

	; 10-cycle NOP
	PHP			; +3/52
	BIT	0		; +3/55
	PLP			; +4/59

	STX	_TIA_GRP1	; +3/62 COL=186 PIX=118 - oP0=3 nP0=3 oP1=2 nP1=4
	STA	_TIA_GRP0	; +3/65 COL=195 PIX=127 - oP0=3 nP0=5 oP1=4 nP1=4
	STY	_TIA_GRP1	; +3/68 COL=204 PIX=136 - oP0=5 nP0=5 oP1=4 nP1=X

	DEY			; +2/70
	BPL	Line195To207	; Taken: +3/73 - MUST NOT CROSS PAGE BOUNDARY
				; Not taken +2/72

	STA	_TIA_WSYNC	; +3/(75..76) - end active line 208

; Clean up playfield
	LDA	#$FF		; +2/2
	STA	_TIA_PF1	; +3/5
	STA	_TIA_PF2	; +3/8
; Clean up sprites
	LDA	#$0		; +2/10
        STA	_TIA_GRP0	; +3/13
        STA	_TIA_GRP1	; +3/16
        STA	_TIA_GRP0	; +3/19
	STA	_TIA_WSYNC	; +3/(22..76) - end active line 209

	STA	_TIA_WSYNC	; +3/(3..76) end active line 210
	STA	_TIA_WSYNC	; +3/(3..76) end active line 211

; -------------------------------
; Technically beginning of Overscan line 1.
; The overhead of JMP is not an issue since we have plenty of time
; to turn off Vblank before the first pixels of the screen.

	JMP	MainLoop	; +3/3


; A naked RTS, allowing for a 12-clock delay with a JSR here
Rts12:	RTS

;	.org	$F100
; Signature
; MUST NO CROSS PAGE BOUNDARY
; ........ ........ ........ ........ ........
; .xxxx... .x...x.. x...x.xx xx..xxxx x.xxxxx.
; .x...x.. .x..x.x. .x.x..x. ..x.x... ..x.....
; .x...x.. .x.x...x ..x...xx xx..xxx. ..xxx...
; .x...x.. .x.xxxxx ..x...x. ..x.x... ..x.....
; .xxxx... .x.x...x ..x...xx xx..xxxx x.xxxxx.
; ......xx x....... ........ ........ ........

Logo1:
	.byte	%00000011
	.byte	%00000011
	.byte	%01111000
	.byte	%01111000
	.byte	%01000100
	.byte	%01000100
	.byte	%01000100
	.byte	%01000100
	.byte	%01000100
	.byte	%01000100
	.byte	%01111000
	.byte	%01111000
	.byte	%00000000
	.byte	%00000000

Logo2:
	.byte	%10000000
	.byte	%10000000
	.byte	%01010001
	.byte	%01010001
	.byte	%01011111
	.byte	%01011111
	.byte	%01010001
	.byte	%01010001
	.byte	%01001010
	.byte	%01001010
	.byte	%01000100
	.byte	%01000100
	.byte	%00000000
	.byte	%00000000

Logo3:
	.byte	%00000000
	.byte	%00000000
	.byte	%00100011
	.byte	%00100011
	.byte	%00100010
	.byte	%00100010
	.byte	%00100011
	.byte	%00100011
	.byte	%01010010
	.byte	%01010010
	.byte	%10001011
	.byte	%10001011
	.byte	%00000000
	.byte	%00000000

Logo4:
	.byte	%00000000
	.byte	%00000000
	.byte	%11001111
	.byte	%11001111
	.byte	%00101000
	.byte	%00101000
	.byte	%11001110
	.byte	%11001110
	.byte	%00101000
	.byte	%00101000
	.byte	%11001111
	.byte	%11001111
	.byte	%00000000
	.byte	%00000000

Logo5:
	.byte	%00000000
	.byte	%00000000
	.byte	%10111110
	.byte	%10111110
	.byte	%00100000
	.byte	%00100000
	.byte	%00111000
	.byte	%00111000
	.byte	%00100000
	.byte	%00100000
	.byte	%10111110
	.byte	%10111110
	.byte	%00000000
	.byte	%00000000

; Reset / Start vectors
	.org	$FFFC
	.word	Main
	.word	Main

; 345678901234567890123456789012345678901234567890123456789012345678901234567890
