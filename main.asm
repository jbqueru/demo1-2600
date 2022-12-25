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

; -------------------------------
; TIA registers

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

; -------------------------------
; PIA registers

_PIA_DATA_A	.equ	$280
_PIA_DDR_A	.equ	$281
_PIA_DATA_B	.equ	$282
;_PIA_DDR_B	.equ	$283

_PIA_WT1T	.equ	$294
_PIA_WT8T	.equ	$295
_PIA_WT64T	.equ	$296
_PIA_WT1024T	.equ	$297

_PIA_RTIM	.equ	$284

; -------------------------------
; Zero-page layout

_ZP_LINE_COUNT	.equ	$80
_ZP_SIGPAL_LO	.equ	$81
_ZP_SIGPAL_HI	.equ	$82

; -------------------------------
; Code start

	.org	$F000,$EA	; $EA is NOP
Main:
; Set up CPU
	CLD			; Clear decimal mode
	LDX	#$FF		; Initial stack pointer
	TXS			; Set stack pointer

; Clear zero-page (TIA + RAM)
	INX			; X is 0
	TXA
ClearZeroPage:
	STA	0,X
	INX
	BNE	ClearZeroPage

	LDA	#Colors1 & $FF
	STA	_ZP_SIGPAL_LO
	LDA	#Colors1 >> 8
	STA	_ZP_SIGPAL_HI

MainLoop:			; +3/3 from the JMP that gets here
; -------------------------------
; Overscan - 17 lines total

; Start overscan line 0
	LDA	#2		; +2/5
	STA	_TIA_VBLANK	; +3/8 - turn blank on

; Skip 16 lines. 16 lines is 16*76 = 1216 CPU cycles, i.e. 19*64.
; In other words, 19 ticks of 64T is 16 lines.
; Initialize timer at 20, it'll spend 64 cycles each in 19, 18... 1.
; When it reaches 0, we've skipped 16 lines.
; Timer is set 14 cycles into the line, plus 6 cycles of loop jitter,
; well within the 73 cycles before WSYNC.

	LDA	#19		; +2/10
	STA	_PIA_WT64T	; +4/14

	LDA	#0
TimOverscan:
	CMP	_PIA_RTIM
	BNE	TimOverscan

	STA	_TIA_WSYNC	; +3/(?->76)
; End overscan line 16

; -------------------------------
; Vsync - 3 lines
	LDA	#2		; +2/2
	STA	_TIA_VSYNC	; +3/5 - turn sync on
	STA	_TIA_WSYNC	; +3/(8..76) - end of vsync line 0
	STA	_TIA_WSYNC	; +3/(3..76) - end of vsync line 1
	STA	_TIA_WSYNC	; +3/(3..76) - end of vsync line 2

; -------------------------------
; Vblank - 30 lines total

; Start vblank line 0
	LDA	#0		; +2/2
	STA	_TIA_VSYNC	; +3/5 - turn sync off

; Skip 28 lines. 28 lines is 28*76 = 2128 CPU cycles, i.e. 33.25*64.
; In other words, 34 ticks of 64T is 28 lines + 48 CPU cycles.
; Initialize timer at 35, it'll spend 64 cycles each in 34, 33... 1.
; When it reaches 0, we've skipped 28 lines.
; Timer is set 11 cycles into the line, fires 48 cycles after the exact
; position, plus 6 cycles of loop jitter, within the 73 cycles
; before WSYNC.

	LDA	#35		; +2/7 - load timer value
	STA	_PIA_WT64T	; +4/11 - and set it into the PIA

	LDA	#0
TimVblank:
	CMP	_PIA_RTIM
	BNE	TimVblank

	STA	_TIA_WSYNC	; +3/(?..76)
; End vblank line 28

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

; Start vblank line 29

; Stop sprite delay
	LDA	#$0		; +2/2
	STA	_TIA_VDELP0	; +3/5
	STA	_TIA_VDELP1	; +3/8

; Disable sprite reflection
	STA	_TIA_RESP0	; +3/11
	STA	_TIA_RESP1	; +3/14

; Color black (happens to be 0).
	STA	_TIA_COLUP0	; +3/17
	STA	_TIA_COLUP1	; +3/20
	STA	_TIA_COLUPF	; +3/23

	; Interleave set P0 position
	STA	_TIA_RESP0	; +3/26 COL=78 SPR=15

	STA	_TIA_COLUBK	; +3/29

; Set sprite pattern (same for both players - 2 leftmost pixels)
	LDA	#$C0		; +2/31
	STA	_TIA_GRP0	; +3/34
	STA	_TIA_GRP1	; +3/37

; Set missile size / sprite repeat / enable missile (common bit 1).
	LDA	#$13		; +2/39 - 2-pixel missile, 3 copies close

	; Interleave set P1 position
	STA	_TIA_RESP1	; +3/42 COL=126 SPR=63

	STA	_TIA_NUSIZ0	; +3/45
	STA	_TIA_NUSIZ1	; +3/48
	NOP			; +2/50

	; Interleave set M0 position
	STA	_TIA_RESM0	; +3/53 COL=159 MIS=95

	STA	_TIA_ENAM0	; +3/56
	STA	_TIA_ENAM1	; +3/59

; Prepare loop
	LDY	#24		; +2/61
	STY	_ZP_LINE_COUNT	; +3/64

; Turn Vblank off
	LDY	#0		; +2/66

	; Interleave set M1 position
	STA	_TIA_RESM1	; +3/69 COL=207 MIS=143

	STY	_TIA_VBLANK	; +3/72 COL=216 PIX=148 - turn blank off

Line7To183:
	STA	_TIA_WSYNC	; +3/(75..76)
; End vblank line 29
; Also end active line 7, 15, [+8], 183



; -------------------------------
; Active area - 212 lines total

; Active lines 0-191
Lines:
	LDY	#$A4		; +2/2
	STY	_TIA_COLUPF	; +3/5

	.repeat	7
	STA	_TIA_WSYNC	; +3/(8..76) - end of line 8*n
				; +3/(3..76) - end of line 8*n + 1..6
	.repend
	DEC	_ZP_LINE_COUNT	; +5/5
	BNE	Line7To183	; taken: +3/8 + page boundary
				; not taken: +2/7
	STA	_TIA_WSYNC	; +3/(10..76) - end of line 8*n + 7

; ###################################
; #                                 #
; #  40-pixel sprite for signature  #
; #                                 #
; ###################################
;
; The sprite is displayed at 116..155, with 1 playfield pixel to the right
;
; P0 at 116, P1 at 124
; SPR=117 COL=180 CPU=60
; SPR=126 COL=189 CPU=63
;
; Timing to write the pixel data:
; Write 1: PIX=124..131 COL=192..199 CPU=64..66
; Write 2: PIX=132..139 COL=200..207 CPU=67..69
; Write 3: PIX=140..147 COL=208..215 CPU=70..71

; Start active line 192

; Set things up for signature
; Set all colors to be the same - everything is invisible
	LDA	#_TIA_CO_PUR_BLU + _TIA_LU_DARK	; +2/2
	STA	_TIA_COLUBK	; +3/5
	STA	_TIA_COLUPF	; +3/8
	STA	_TIA_COLUP0	; +3/11
	STA	_TIA_COLUP1	; +3/14 COL=42 - early enough to hide everything

; Disable all graphics
	LDA	#$0		; +2/16
	STA	_TIA_GRP0	; +3/19 - oP0=X nP0=0 oP1=X nP1=X
	STA	_TIA_GRP1	; +3/22 - oP0=0 nP0=0 oP1=X nP1=0
	STA	_TIA_GRP0	; +3/25 - oP0=0 nP0=0 oP1=0 nP1=0
	STA	_TIA_ENAM0	; +3/28
	STA	_TIA_ENAM1	; +3/31
	STA	_TIA_ENABL	; +3/34

; Sprite reflection off
	STA	_TIA_REFP0	; +3/37
	STA	_TIA_REFP1	; +3/40

	; begin 15-cycle NOP
	PHP			; +3/43
	TSX			; +2/45
	PLP			; +4/49
	TXS			; +2/51
	PLP			; +4/55
	; end 15-cycle NOP

; Player 0 move 1 pixel to the left (clock 74 trick flips top bit)
	LDA	#$90		; +2/57

	; Interleave set approximate sprite positions
	STA	_TIA_RESP0	; +3/60 COL=171 SPR=108
	STA	_TIA_RESP1	; +3/63 COL=180 SPR=117

	STA	_TIA_HMP0	; +3/66
; Player 1 move 2 pixels to the left (clock 74 trick flips top bit)
	LDA	#$A0		; +2/68
	STA	_TIA_HMP1	; +3/71

; Trigger HMOVE on clock 74 (magic trick)
	STA	_TIA_HMOVE	; +3/74
	NOP			; +2/76
; No WSYNC, perfect sync
; End active line 192

; Start Active line 193
; Set a solid playfield
	LDA	#$FF		; +2/2
	STA	_TIA_PF0	; +3/5
	STA	_TIA_PF1	; +3/8
	STA	_TIA_PF2	; +3/11

; Set palette for background and players
	LDA	#_TIA_CO_GRAY + _TIA_LU_MIN	; +2/13
	STA	_TIA_COLUBK	; +3/16
	LDA	#_TIA_CO_GRAY + _TIA_LU_LIGHT	; +2/18
	STA	_TIA_COLUP0	; +3/21
	STA	_TIA_COLUP1	; +3/24

; Reset horizontal move registers
	STA	_TIA_HMCLR	; +3/27

; Setup sprite repeat / sprite delay (common bit 0)
	LDA	#$3		; +2/29
	STA	_TIA_NUSIZ0	; +3/32
	LSR			; +2/34 - A contains 1
	STA	_TIA_NUSIZ1	; +3/37
	STA	_TIA_VDELP0	; +3/40
	STA	_TIA_VDELP1	; +3/43

	STA	_TIA_WSYNC	; +3/(46..76)
; End active line 193

; Start Active line 194
	LDY	#13		; +2/2
	JMP	Line195To207	; +3/5

	.align	$100,$EA	; $EA is NOP
Line195To207:
	STA	_TIA_WSYNC	; +3/(2..76) - end active line 194
        			; +3/76 - end active line 195-207

; Active lines 195-208
; Set raster palette for signature bar
	LDA	(_ZP_SIGPAL_LO),Y	; +5/5
	STA	_TIA_COLUPF	; +3/8 COL=24 PIX=-44

; Reset playfield, filled
	LDA	#$FF		; +2/10
	STA	_TIA_PF1	; +3/13 COL=39 PIX=-29
	STA	_TIA_PF2	; +3/16 COL=48 PIX=-20

	LDA	Logo1,Y		; +4/20
	STA	_TIA_GRP0	; +3/23 COL=69 PIX=1 - oP0=X nP0=1 oP1=X nP1=X
	LDA	Logo2,Y		; +4/27
	STA	_TIA_GRP1	; +3/30 COL=90 PIX=22 - oP0=1 nP0=1 oP1=X nP1=2
	LDA	Logo3,Y		; +4/34
	STA	_TIA_GRP0	; +3/37 COL=111 PIX=43 - oP0=1 nP0=3 oP1=2 nP1=2

; update PF1 between 37 and 53 (theo) / 57 (actual)
; update PF2 between 48 (theo) / 47 (actual) and 64
; PF2 works at 44 on my emulator, but there seem to be
; some 2600 implementations (Jr?) that are off by 1 pixel.
; Difference between theo and actual is because top 3 bits
; are identical between $FF and $E0, so we can change while
; those bits are getting displayed
	LDA	#$F8		; +2/39
	STA	_TIA_PF1	; +3/42 COL=126 PIX=58
	LDA	#$80		; +2/44
	STA	_TIA_PF2	; +3/47 COL=141 PIX=73

	LDX	Logo4,Y		; +4/51
	LDA	Logo5,Y		; +4/55

	NOP			; +2/57
	NOP			; +2/59
	DEY			; +2/61 - flags untouched by store instructions

	STX	_TIA_GRP1	; +3/64 COL=192 PIX=124 - oP0=3 nP0=3 oP1=2 nP1=4
	STA	_TIA_GRP0	; +3/67 COL=201 PIX=133 - oP0=3 nP0=5 oP1=4 nP1=4
	STY	_TIA_GRP1	; +3/70 COL=210 PIX=142 - oP0=5 nP0=5 oP1=4 nP1=X

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

;	.align	$100,0
; Signature
; MUST NO CROSS PAGE BOUNDARY

; xxxxxxxx xxxxxxx. ...x.x.x ....xxxx xxxxxxxx
; xxx.x... xxx..xx. ...x.x.x ....x.xx x.x...xx
; xxx.x.xx .x.xx.x. ...x.x.x ....x..x ..x.xx.x
; xxx.x... xx.xx.x. ...x.x.x ....x.x. x.x...xx
; xxx.x.xx .x.xx.x. ...x.x.x ....x.xx x.x.xx.x
; x..xx... xxx...x. ..x..x.. x...x.xx x.x...xx
; xxxxxxxx xxxxxxx. xx...x.. .xx.xxxx xxxxxxxx


Logo1:
	.byte	%11111111
	.byte	%11111111
	.byte	%10011000
	.byte	%10001000
	.byte	%11101011
	.byte	%11101011
	.byte	%11101000
	.byte	%11101000
	.byte	%11101011
	.byte	%11101011
	.byte	%11101000
	.byte	%11101000
	.byte	%11111111
	.byte	%11111111

Logo2:
	.byte	%11111110
	.byte	%11111110
	.byte	%11100010
	.byte	%01000010
	.byte	%01010010
	.byte	%01011010
	.byte	%11011010
	.byte	%11011010
	.byte	%01011010
	.byte	%01011010
	.byte	%01000010
	.byte	%11100110
	.byte	%11111110
	.byte	%11111110

Logo3:
	.byte	%10000100
	.byte	%11000100
	.byte	%11100100
	.byte	%01100100
	.byte	%00110101
	.byte	%00110101
	.byte	%00010101
	.byte	%00010101
	.byte	%00010101
	.byte	%00010101
	.byte	%00010101
	.byte	%00010101
	.byte	%00010101
	.byte	%00010101

Logo4:
	.byte	%00101111
	.byte	%01101111
	.byte	%11101011
	.byte	%11001011
	.byte	%10001011
	.byte	%10001011
	.byte	%00001011
	.byte	%00001010
	.byte	%00001000
	.byte	%00001001
	.byte	%00001011
	.byte	%00001011
	.byte	%00001111
	.byte	%00001111

Logo5:
	.byte	%11111111
	.byte	%11111111
	.byte	%10100011
	.byte	%10100001
	.byte	%10101101
	.byte	%10101101
	.byte	%10100011
	.byte	%10100011
	.byte	%00101101
	.byte	%00101101
	.byte	%10100001
	.byte	%10100011
	.byte	%11111111
	.byte	%11111111

Colors1:
	.byte	$10,$12,$14,$16,$18,$1A,$1C,$1E,$1E,$1C,$1A,$18,$16,$14,$12,$10

; Reset / Start vectors
	.org	$FFFC
	.word	Main
	.word	Main

; 345678901234567890123456789012345678901234567890123456789012345678901234567890
