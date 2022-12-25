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
	LDA	#2		; +2 / 12
	STA	_TIA_VBLANK	; +3 / 15 - turn blank on

; Skip 16 lines. 16 lines is 16*76 = 1216 CPU cycles, i.e. 19*64.
; In other words, 19 ticks of 64T is 16 lines.
; Initialize timer at 20, it'll spend 64 cycles each in 19, 18... 1.
; When it reaches 0, we're into the 17th line.
; Timer is set 21 cycles into the line, plus 6 cycles of loop jitter,
; well within the 73 cycles before WSYNC.

	LDA	#19		; +2 / 17
	STA	_PIA_WT64T	; +4 / 21

	LDA	#0
TimOverscan:
	CMP	_PIA_RTIM
	BNE	TimOverscan

	STA	_TIA_WSYNC	; end of overscan line 16

; -------------------------------
; Vsync - 3 lines
	LDA	#2
	STA	_TIA_VSYNC	; turn sync on
	STA	_TIA_WSYNC	; 3+ / 76 - end of vsync line 0
	STA	_TIA_WSYNC	; 3+ / 76 - end of vsync line 1
	STA	_TIA_WSYNC	; 3+ / 76 - end of vsync line 2

; -------------------------------
; Vblank - 30 lines total
	LDA	#0		; +2 / 2
	STA	_TIA_VSYNC	; +3 / 5 - turn sync off

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

	STA	_TIA_WSYNC	; ? / 76 ; end vblank line 35

	; Start 71-clock delay
	LDX	#14		; +2 / 2
	DEX			; 14*2 = +28
	BNE	*-1		; 13*3 + 2 = +41 / 71
	; End 71-clock delay

	NOP			; +2 / 73
	STX	_TIA_VBLANK	; +3 / 76 - turn blank off

	; exact sync		; end vblank line 36



; -------------------------------
; Active area - 212 lines total

; Active lines 0-191
	LDY	#192		; +2 / 2
	STY	_ZP_LINE_COUNT	; +3 / 5
	STY	_ZP_LINE_COUNT	; +3 / 8 - extra to align line 0 with subsequent
Lines:
	LDA	#$AA		; +2 / 2
	LDX	#$AA		; +2 / 4
	LDY	#$AA		; +2 / 6
	STA	_TIA_PF0
	STX	_TIA_PF1
	STY	_TIA_PF2
	LDY	#$A4
	STY	_TIA_COLUPF

	STA	_TIA_WSYNC	; ? / 76 - end of line 8*n + 7

	DEC	_ZP_LINE_COUNT	; +5 / 5
	BNE	Lines		; taken: +3 / 8 DO NOT CROSS PAGE BOUNDARIES
				; not taken: +2 / 7


; Active line 192
; Set things up for signature

; Set all colors to be the same - everything is invisible
	LDA	#_TIA_CO_ORANGE + _TIA_LU_V_DARK	; +2 / 9
	STA	_TIA_COLUBK	; +3 / 12
	STA	_TIA_COLUPF	; +3 / 15
	STA	_TIA_COLUP0	; +3 / 18
	STA	_TIA_COLUP1	; +3 / 21 / COL 63 / PIX -5 - early enough!

; Sprite repeat setup
	LDA	#$3		; +2 / 23
	STA	_TIA_NUSIZ0	; +3 / 26
	LSR			; +2 / 28 - A contains 1
	STA	_TIA_NUSIZ1	; +3 / 31
; Disable all graphics
	LSR			; +2 / 33 - A contains 0
	STA	_TIA_GRP0	; +3 / 36
	STA	_TIA_GRP1	; +3 / 39
	STA	_TIA_ENAM0	; +3 / 42
	STA	_TIA_ENAM1	; +3 / 45
	STA	_TIA_ENABL	; +3 / 48
; Sprite reflection off
	STA	_TIA_REFP0	; +3 / 51
	STA	_TIA_REFP1	; +3 / 54
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

	STA	_TIA_WSYNC	; ? / 76 - end active line 193

; Active line 194
	STA	_TIA_WSYNC	; ? / 76 - end active line 194

; Active lines 195-208
	.repeat 14
	LDA	#$FF		; +2 / 2
	STA	_TIA_PF1	; +3 / 5
	STA	_TIA_PF2	; +3 / 8

; update PF1 between 37 and 53
; update PF2 between 48 and 64

	STA	_TIA_WSYNC	; end active line 195-208
	.repend
	STA	_TIA_WSYNC	; end active line 209
	STA	_TIA_WSYNC	; end active line 210
	STA	_TIA_WSYNC	; end active line 211

; -------------------------------
; Technically beginning of Overscan line 1.
; The overhead of JMP is not an issue since we have plenty of time
; to turn off Vblank before the first pixels of the screen.

	JMP	MainLoop	; +3 / 10

; Reset / Start vectors
	.org	$FFFC
	.word	Main
	.word	Main

; 345678901234567890123456789012345678901234567890123456789012345678901234567890
