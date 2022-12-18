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

Loop:
; -------------------------------
; Overscan - 30 lines total
	LDA	#2		; 3 clocks into overscan line 1 (JMP)
	STA	_TIA_VBLANK	; turn blank on

; Skip 29 lines. 29 lines is 29*76 = 2204 CPU cycles, i.e. 34.43*64.
; In other words, 35 ticks of 64T is 29 lines + 36 CPU cycles.
; Initialize timer at 36, it'll spend 64 cycles each in 35, 35... 1.
; When it reaches 0, we're into the 30th line.
; Timer is set 14 cycles into the line, fires 36 cycles after the exact
; position, plus 6 cycles of loop jitter, well within the 76 cycles
; of a line.

	LDA	#36
        STA	_PIA_WT64T

	LDA	#0
TimOverscan:
	CMP	_PIA_RTIM
	BNE	TimOverscan

	STA	_TIA_WSYNC	; end of overscan line 30

; -------------------------------
; Vsync - 3 lines
	LDA	#2
	STA	_TIA_VSYNC	; turn sync on
	STA	_TIA_WSYNC	; end of vsync line 1
	STA	_TIA_WSYNC	; end of vsync line 2
	STA	_TIA_WSYNC	; end of vsync line 3

; -------------------------------
; Vblank - 37 lines total
	LDA	#0
	STA	_TIA_VSYNC	; turn sync off

; Skip 36 lines. 36 lines is 36*76 = 2736 CPU cycles, i.e. 42.75*64.
; In other words, 43 ticks of 64T is 36 lines + 16 CPU cycles.
; Initialize timer at 44, it'll spend 64 cycles each in 43, 42... 1.
; When it reaches 0, we're into the 37th line.
; Timer is set 11 cycles into the line, fires 16 cycles after the exact
; position, plus 6 cycles of loop jitter, well within the 76 cycles
; of a line.

	LDA	#44
        STA	_PIA_WT64T

	LDA	#0
TimVblank:
	CMP	_PIA_RTIM
	BNE	TimVblank

	STA	_TIA_WSYNC	; vblank line 37

; -------------------------------
; Active lines 1-191
	LDA	#0
	STA	_TIA_VBLANK	; turn blank off
	LDA	#20
	STA	_PIA_WT64T

	.repeat 16
	STA	_TIA_WSYNC
	.repend

	LDA	#1
	CMP	_PIA_RTIM
	BEQ	Was1
Not1:
	LDA	#_TIA_CO_PINK + _TIA_LU_MAX
        STA	_TIA_COLUBK
Was1:

	.repeat 29
        NOP
        .repend

	LDA	#0
	CMP	_PIA_RTIM
	BEQ	Was0
Not0:
	LDA	#_TIA_CO_BLUE + _TIA_LU_MAX
        STA	_TIA_COLUBK
Was0:

	LDY	#191-16
Lines:
	.repeat	7
	LDA	_PIA_RTIM
        ASL
;	STA	_TIA_COLUBK
        .repend

	STA	_TIA_WSYNC
	DEY
	BNE	Lines

; -------------------------------
; Active line 192
	STA	_TIA_WSYNC

; -------------------------------
	JMP	Loop

; Reset / Start vectors
	.org	$FFFC
	.word	Main
	.word	Main

; 345678901234567890123456789012345678901234567890123456789012345678901234567890
