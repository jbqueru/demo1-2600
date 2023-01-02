; SPDX-License-Identifier: Apache-2.0
;
; Portions Copyright 2022 Jean-Baptiste M. "JBQ" "Djaybee" Queru
; Portions Copyright 2023 Jean-Baptiste M. "JBQ" "Djaybee" Queru
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

; ############################
; ############################
; ###                      ###
; ###  Hardware constants  ###
; ###                      ###
; ############################
; ############################

; -------------------------------
; Start TIA registers
_TIA_VSYNC	.equ	$00	; ......s.
				;       |
                                ;       +-- 1 = vsync on

_TIA_VBLANK	.equ	$01	; gl....b.
				; ||    |
				; ||    +-- 1 = vblank on
				; |+------- 1 = latch I4/I5 (joystick buttons)
                                ; +-------- 1 = ground I0..I3 (paddle pots)

_TIA_WSYNC	.equ	$02	; ........  write = wait for end of next line

_TIA_RSYNC	.equ	$03	; ........  write = reset horizontal counter

_TIA_NUSIZ0	.equ	$04	; ..ss.nnn
				;   || |||
				;   || +++- 101 = double-width
				;   || +++- 111 = quad-width
				;   || |||
				;   || ||+- 1 = close sprite
				;   || |+-- 1 = medium sprite
				;   || +--- 1 = wide sprite
                                ;   ++----- missile width = 1 << ss

_TIA_NUSIZ1	.equ	$05	; see _TIA_NUSIZ0

_TIA_COLUP0	.equ	$06	; cccclll.
				; |||||||
				; ||||+++-- luminance
				; ++++----- color (0 = grey, 1..15 colors)

_TIA_COLUP1	.equ	$07	; see _TIA_COLUP0

_TIA_COLUPF	.equ	$08	; see _TIA_COLUP0

_TIA_COLUBK	.equ	$09	; see _TIA_COLUP0

_TIA_CTRLPF	.equ	$0A	; see _TIA_COLUP0

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
; End TIA registers
; -------------------------------

; -------------------------------
; Start RIOT registers
_RIOT_DATA_A	.equ	$280
_RIOT_DDR_A	.equ	$281
_RIOT_DATA_B	.equ	$282
_RIOT_DDR_B	.equ	$283

_RIOT_WT1T	.equ	$294
_RIOT_WT8T	.equ	$295
_RIOT_WT64T	.equ	$296
_RIOT_WT1024T	.equ	$297

_RIOT_RTIM	.equ	$284
; End RIOT registers
; -------------------------------



; ####################
; ####################
; ###              ###
; ###  RAM layout  ###
; ###              ###
; ####################
; ####################

; -------------------------------
; Start variables for global state
_ZP_MAINJMP1	.equ	$80
_ZP_MAINJMP1_HI	.equ	$81
_ZP_MAINJMP2	.equ	$82
_ZP_MAINJMP2_HI	.equ	$83
_ZP_MAINJMP3	.equ	$84
_ZP_MAINJMP3_HI	.equ	$85
; End variables for global state
; -------------------------------

; -------------------------------
; Start variables for signature bar
_ZP_SIGPAL	.equ	$88	; Address of 3rd line of raster palette
_ZP_SIGPAL_HI	.equ	$89	; Yup, that's a weird implementation detail
; End variables for signature bar
; -------------------------------

; -------------------------------
; Start variables for roller bar display
_ZP_BARGFX1	.equ	$90
_ZP_BARGFX1_HI	.equ	$91
_ZP_BARGFX2	.equ	$92
_ZP_BARGFX2_HI	.equ	$93
_ZP_BARGFX3	.equ	$94
_ZP_BARGFX3_HI	.equ	$95
_ZP_BARGFX4	.equ	$96
_ZP_BARGFX4_HI	.equ	$97
_ZP_BARGFX5	.equ	$98
_ZP_BARGFX5_HI	.equ	$99
_ZP_BARGFX6	.equ	$9A
_ZP_BARGFX6_HI	.equ	$9B
_ZP_BARPHASE	.equ	$9C	; the phase in the sequence of screens
_ZP_BARSTEP	.equ	$9D	; the step within the current phase
_ZP_BARLINE	.equ	$9E	; counts the 10 row of rollers in display loop
_ZP_BARREAD	.equ	$9F	; offset when reading buffer into pointers
_ZP_BAROFF	.equ	$A0
_ZP_BAROFF_END	.equ	$DB
; End variables for roller bar display
; -------------------------------



; ########################
; ########################
; ###                  ###
; ###  Initialization  ###
; ###                  ###
; ########################
; ########################

	.org	$F000,$EA	; $EA is NOP
Main:
; Set up CPU
	CLD			; Clear decimal mode
	LDX	#$FF		; Initial stack pointer
	TXS			; Set stack pointer

; Clear zero-page (TIA + RAM)
; TODO: be more precise, to avoid registers that might exist on the cartridge
	INX			; X is 0
	TXA
ClearZeroPage:
	STA	0,X
	INX
	BNE	ClearZeroPage

; Init logo
; TODO: possibly save a few bytes?
	LDA	#(Bar0 >> 8)
	STA	_ZP_BARGFX1 + 1
	STA	_ZP_BARGFX2 + 1
	STA	_ZP_BARGFX3 + 1
	STA	_ZP_BARGFX4 + 1
	STA	_ZP_BARGFX5 + 1
	STA	_ZP_BARGFX6 + 1

; Init jump target
	LDA	#(BarInit & $FF)
        STA	_ZP_MAINJMP1
	LDA	#(BarInit >> 8)
        STA	_ZP_MAINJMP1 + 1

; Set color pointer for signature background
; It's off-by-three because the index primarily counts lines in the sprite
; bitmap, from 13 down to 0, such that there are 3 lines to go after 0
; (i.e. at addresses before that of line 0).
	LDA	#(Colors1 + 3 & $FF)
	STA	_ZP_SIGPAL
	LDA	#(Colors1 + 3 >> 8)
	STA	_ZP_SIGPAL + 1



; ##############################
; ##############################
; ###                        ###
; ###  Main display routine  ###
; ###                        ###
; ##############################
; ##############################

; ######################
; #                    #
; #  Rolling graphics  #
; #                    #
; ######################

; This is a display of 10 rows or 10 rolling cylinders.
;
; The cylinders are a mix of background and playfield, 14 pixels wide
; overall, separated by players and missiles.
;
; The players and missiles are set for a 3x close repeat
;
; Player 0 is at pixel 15, i.e. 15, 31, 47
; Player 1 is at pixel 63, i.e. 63, 79, 95
; Missile 0 is at pixel 95, i.e. 95, 111, 127
; Missile 1 is at pixel 143, i.e. 143, 159, 15
;
; Those specific locations are chosen because they don't need any HMOVE
;
; Some of the missiles and players overlap, and player 0 has priority,
; resulting in the following layout, which allows to set color 0 early
; or late during the visible display:
; 1 - 0 - 0 - 0 - 1 - 1 - 0 - 0 - 0 - 1 - 1
;
; Each rolling cylinder has 16 visible lines, and there's a 3-line
; gap between each row. The code for each row has 2 empty lines for
; preparation, 16 lines of visible display, and 1 line of cleanup.
; With 2 extra lines below and some preparation during vblank, this
; covers the first 192 lines of active display.
;
; The display data is stored in RAM, as the low bytes of the pointers to the
; data to be loaded into the PFn registers. Before each row of rollers, those
; low bytes are copied into the actual pointers, ready for use in the tight
; display loop.
;
; Computing the display data is done during Vblank. The core loop combines
; essentially 3 sources: graphics before, graphics after, and roller offsets.
; Graphics before and graphics after must be in different formats, one using
; the low 2 bits and one the next 2 bits, so that a plain OR of the two can be
; fed into a lookup. There are 2 lookup tables, depending on the ordering of
; graphics before and after into thsoe bits. In turn, that allows to use the
; same ROM data for before and after without having to shift it.
;
; The 3 sources can come from ROM, from RAM, or from code. There are different
; routines for the different use cases. When one of the sources is RAM, it is
; generated separately from the combination loop, for better performance because
; of the very low register count.

; =========================
; Overscan - 17 lines total
; =========================

; -------------------------------
; Start overscan line 0		;
MainLoop:			; +3/3 from the JMP that gets here
	LDA	#2		; +2/5
	STA	_TIA_VBLANK	; +3/8 - turn blank on
				;
; Skip 16 lines. 16 lines is 16*76 = 1216 CPU cycles, i.e. 19*64.
; In other words, 19 ticks of 64T is 16 lines.
; Initialize timer at 20, it'll spend 64 cycles each in 19, 18... 1.
; When it reaches 0, we've skipped 16 lines.
; Timer is set 14 cycles into the line, plus 6 cycles of loop jitter,
; well within the 73 cycles before WSYNC.
				;
	LDA	#19		; +2/10
	STA	_RIOT_WT64T	; +4/14
				;
	; Start 1210 cycles	; From here we count clocks since timer start

; Jump to the phase-specific implementation of this 
	JMP	(_ZP_MAINJMP1)	; +5/5

; Begin independent clode block	;
; Overscan lines 0-16		;
BarInit:			;
	LDA	#(BarBlank1 & $FF)
        STA	_ZP_MAINJMP1	;
	LDA	#(BarBlank1 >> 8)
        STA	_ZP_MAINJMP1 + 1;
	LDA	#(BarBlank2 & $FF)
        STA	_ZP_MAINJMP2	;
	LDA	#(BarBlank2 >> 8)
        STA	_ZP_MAINJMP2 + 1;
	LDA	#(BarDisplay & $FF)
        STA	_ZP_MAINJMP3	;
	LDA	#(BarDisplay >> 8)
        STA	_ZP_MAINJMP3 + 1;
				;
	LDA	#0		;
	STA	_ZP_BARPHASE	;
	LDA	#60		;
	STA	_ZP_BARSTEP	;
	JMP	BarBlank1	;
; End independent clode block	;

; Begin independent clode block	;
; Overscan lines 0-16		;
BarBlank1:			;
	DEC	_ZP_BARSTEP	;
        BPL	StillInBarPause	;
	LDA	#(BarBitmapOnOff1 & $FF)
        STA	_ZP_MAINJMP1	;
	LDA	#(BarBitmapOnOff1 >> 8)
        STA	_ZP_MAINJMP1 + 1;
	LDA	#(BarBitmapOn2 & $FF)
        STA	_ZP_MAINJMP2	;
	LDA	#(BarBitmapOn2 >> 8)
        STA	_ZP_MAINJMP2 + 1;
	LDA	#0		;
	STA	_ZP_BARSTEP	;
        JMP	BarBitmapOnOff1	;
StillInBarPause:		;
	JMP	EndJmp1		;
; End independent clode block	;

; Begin independent clode block	;
; Overscan lines 0-16		;
BarBitmapOnOff1:
	LDX	_ZP_BARSTEP	; +3/3
	LDA	BarRotation,X	; +4/7
				;
	LDX	#0		; +2/9
GenLoopY:			;
	LDY	#5		; + +2
GenLoopX:			; |
	STA	_ZP_BAROFF,X	; |+ +4
	INX			; || +2
	DEY			; || +2
	BPL	GenLoopX	; |+ +3 - total loop 13*6-1 = 77
	CPX	#60		; | +2
	BNE	GenLoopY	; + +3 - total loop 10*84-1 = 839
				;
	LDX	_ZP_BARSTEP	;
        INX			;
	CPX	#25		;
	BNE	BarWrapped	;
	LDX	#0		;
BarWrapped:			;
	STX	_ZP_BARSTEP	;
				;
	JMP	EndJmp1		;
; End independent clode block	;
				;
EndJmp1:			;
	; End 1210 cycles	;
				;
	LDA	#0		;
TimOverscan:			;
	CMP	_RIOT_RTIM	;
	BNE	TimOverscan	;
				;
	STA	_TIA_WSYNC	; +3/(?>76)
; End overscan line 16		;
; -------------------------------

; =====================
; Vsync - 3 lines total
; =====================

; -------------------------------
; Start vsync line 0		;
	LDA	#2		; +2/2
	STA	_TIA_VSYNC	; +3/5 - turn sync on
	STA	_TIA_WSYNC	; +3/(8>76)
; End vsync line 0		;
; -------------------------------

; -------------------------------
; Start vsync line 1		;
	STA	_TIA_WSYNC	; +3/(3>76) - end of vsync line 1
; End vsync line 1		;
; -------------------------------

; -------------------------------
; Start vsync line 2		;
	STA	_TIA_WSYNC	; +3/(3>76) - end of vsync line 2
; End vsync line 2		;
; -------------------------------

; =======================
; Vblank - 30 lines total
; =======================

; -------------------------------
; Start vblank line 0		;
	LDA	#0		; +2/2
	STA	_TIA_VSYNC	; +3/5 - turn sync off
				;
; Skip 28 lines. 28 lines is 28*76 = 2128 CPU cycles, i.e. 33.25*64.
; In other words, 34 ticks of 64T is 28 lines + 48 CPU cycles.
; Initialize timer at 35, it'll spend 64 cycles each in 34, 34... 1.
; When it reaches 0, we've skipped 28 lines.
; Timer is set 11 cycles into the line, fires 48 cycles after the exact
; position, plus 6 cycles of loop jitter, within the 73 cycles
; before WSYNC.			;
				;
	LDA	#35		; +2/7 - load timer value
	STA	_RIOT_WT64T	; +4/11 - and set it into the RIOT
	; Start 2122 cycles	;
	JMP	(_ZP_MAINJMP2)	; +5/5
				;
; Begin independent clode block	;
; Vblank lines 0-28		;
BarBlank2:			;
	LDX	#59		;
	LDA	#0		;
FillBarPause:			;
	STA	_ZP_BAROFF,X	;
	DEY			;
	BPL	FillBarPause	;
				;
	LDA	#0		;
	STA	_ZP_BARREAD	;
				;
	JMP	EndJmp2		;
; End independent clode block	;

; Begin independent clode block ;
; Vblank lines 0-28		;
BarBitmapOn2:			;
	LDY	#59		;
FillBarGfxOn:			;
        LDA	MBLogo,Y	; +4/4
				; TODO: ORA xxx - that's why it's in A
	TAX			; +2/6
	LDA	BarLookupOn,X	; +4/10
	ASL			; +2/12
	BCS	BarFixedOn	; Not taken +2/14 - critical path
	ADC	_ZP_BAROFF,Y	; +4/18
BarFixedOn:			;
	STA	_ZP_BAROFF,Y	; +5/23
	DEY			; +2/25
	BPL	FillBarGfxOn	; Taken +3/28
				;
	LDA	#0		;
        STA	_ZP_BARREAD	;

	JMP	EndJmp2		;
; End independent clode block	;

; Begin independent clode block ;
; Vblank lines 0-28		;
BarBitmapOff2:			;
	LDY	#59		;
FillBarGfxOff:			;
        LDA	MBLogo,Y	; +4/4
				; TODO: ORA xxx - that's why it's in A
	TAX			; +2/6
	LDA	BarLookupOff,X	; +4/10
	ASL			; +2/12
	BCS	BarFixedOff	; Not taken +2/14 - critical path
	ADC	_ZP_BAROFF,Y	; +4/18
BarFixedOff:			;
	STA	_ZP_BAROFF,Y	; +5/23
	DEY			; +2/25
	BPL	FillBarGfxOff	; Taken +3/28
				;
	LDA	#0		;
        STA	_ZP_BARREAD	;

	JMP	EndJmp2		;
; End independent clode block	;

EndJmp2:			;
	; End 2122 cycles	;
				;
; Wait for timer to expire	;
	LDA	#0		;
TimVblank:			;
	CMP	_RIOT_RTIM	;
	BNE	TimVblank	;
				;
	JMP	(_ZP_MAINJMP3)	;
	.align	$100,$EA	; $EA is NOP
BarDisplay:			;
	STA	_TIA_WSYNC	; +3/(?>76)
; End vblank line 28		;
; -------------------------------

; -------------------------------
; Start vblank line 29		;
; Set up palette		;
; Set up sprites		;
;				;
; Stop sprite delay		;
	LDA	#$0		; +2/2
	STA	_TIA_VDELP0	; +3/5
	STA	_TIA_VDELP1	; +3/8
				;
; Disable sprite reflection	;
	STA	_TIA_RESP0	; +3/11
	STA	_TIA_RESP1	; +3/14
				;
; Color black (happens to be 0).;
	STA	_TIA_COLUP0	; +3/17
	STA	_TIA_COLUP1	; +3/20
	STA	_TIA_COLUPF	; +3/23 - TODO - might not need this
				;
	; Interleave set P0 position
	STA	_TIA_RESP0	; +3/26 COL=78 SPR=15
				;
	STA	_TIA_COLUBK	; +3/29 - TODO - might not need this
				;
; Set sprite pattern (same for both players - 2 leftmost pixels)
	LDA	#$C0		; +2/31
	STA	_TIA_GRP0	; +3/34
	STA	_TIA_GRP1	; +3/37
				;
; Set missile size / sprite repeat / enable missile (common bit 1).
	LDA	#$13		; +2/39 - 2-pixel missile, 3 copies close
				;
	; Interleave set P1 position
	STA	_TIA_RESP1	; +3/42 COL=126 SPR=63
				;
	STA	_TIA_NUSIZ0	; +3/45
	STA	_TIA_NUSIZ1	; +3/48
	NOP			; +2/50
				;
	; Interleave set M0 position
	STA	_TIA_RESM0	; +3/53 COL=159 MIS=95
				;
	STA	_TIA_ENAM0	; +3/56
	STA	_TIA_ENAM1	; +3/59
				;
; Prepare loop			;
	LDY	#9		; +2/61
	STY	_ZP_BARLINE	; +3/64
				;
	LDX	#0		; +2/66
				;
	; Interleave set M1 position
	STA	_TIA_RESM1	; +3/69 COL=207 MIS=143
				;
	STX	_TIA_VBLANK	; +3/72 turn blank off - as late as possible
				;
Line19To171:			;
	STA	_TIA_WSYNC	; +3/(75>76) when falling through
				; +3(25..26>76) when jumped to
; End vblank line 29		;
; Also end active line 18, 37, 56, ... 170 through jump
; -------------------------------

; ========================
; Active - 212 lines total
; ========================

; -------------------------------
; Start active line 0, 19, 38, ... 171
; Update graphics pointers for this row of rollers
	LDX	_ZP_BARREAD	; 3/3
				;
	LDA	_ZP_BAROFF,X	; 4/10
	STA	_ZP_BARGFX1	; 3/13
	INX			; 2/15
				;
	LDA	_ZP_BAROFF,X	; 4/19
	STA	_ZP_BARGFX2	; 3/22
	INX			; 2/24
				;
	LDA	_ZP_BAROFF,X	; 4/28
	STA	_ZP_BARGFX3	; 3/31
	INX			; 2/33
				;
	LDA	_ZP_BAROFF,X	; 4/37
	STA	_ZP_BARGFX4	; 3/40
	INX			; 2/42
				;
	LDA	_ZP_BAROFF,X	; 4/46
	STA	_ZP_BARGFX5	; 3/49
	INX			; 2/51
				;
	LDA	_ZP_BAROFF,X	; 4/55
	STA	_ZP_BARGFX6	; 3/58
	INX			; 2/60
				;
	STX	_ZP_BARREAD	; 3/63
				;
	STA	_TIA_WSYNC	; +3/(66>76)
; End active line 0, 19, 38, ... 171
; -------------------------------

; -------------------------------
; Start active line 1, 20, 39, ... 172
; Set things up for line loop	;
				;
	; start 63-cycle NOP	;
        LDX	#12		; +2/2
	DEX			; +2*12
	BNE	*-1		; +3*11+2/61
	NOP			; +2/63
	; end 63-cycle NOP	;
				;
	LDY	#15		; +2/65
	LDA	Pal1+15		; +4/69
	LDX	Pal2+15		; +4/73
	STX	_TIA_COLUP0	; +3/76
; Perfect sync			;
; End active line 1, 20, 39, ... 172
; -------------------------------

; -------------------------------
; Start active line 2..17, 21..36, 40..55, ... 173..188
; Display 16 lines of rollers	;
;				;
; Must enter this loop with the following:
; * A = background color	;
; * X = player color		;
; * P0 color already set	;
LinesRoller:			;
; Set the palette for this line (P0 has already been set)
	STA	_TIA_COLUPF	; +3/3 COL=9 PIX=-57
	ADC	#$2A		; +2/5
	STA	_TIA_COLUBK	; +3/8 COL=24 PIX=-44
	STX	_TIA_COLUP1	; +3/11 COL=33 PIX=-35
				;
; Update playfield graphics	;
	LDA	(_ZP_BARGFX1),Y	; +5/16
	STA	_TIA_PF0	; +3/19 COL=57 PIX=-11
				; For playfield update, CPU min=-23/*53 max=21
	LDA	(_ZP_BARGFX2),Y	; +5/24
	STA	_TIA_PF1	; +3/27 COL=81 PIX=13
				; For playfield update, CPU min=-12/*64 max=27
	LDA	(_ZP_BARGFX3),Y	; +5/32
	STA	_TIA_PF2	; +3/35 COL=105 PIX=37
				; For playfield update, CPU min=-1/*75 max=37
	LDA	(_ZP_BARGFX4),Y	; +5/40
	STA	_TIA_PF0	; +3/43 COL=129 PIX=61
				; For playfield update, CPU min=27 max=48
	LDA	(_ZP_BARGFX5),Y	; +5/48
	STA	_TIA_PF1	; +3/51 COL=153 PIX=85
				; For playfield update, CPU min=37 max=53
	LDA	(_ZP_BARGFX6),Y	; +5/56
	STA	_TIA_PF2	; +3/59 COL=177 PIX=109
				; For playfield update, CPU min=48 max=64
				;
; Prepare palette for next line	;
	LDX	Pal2-1,Y	; +4/63
	STX.w	_TIA_COLUP0	; +3/67 COL=201 PIX=133
	LDA	Pal1-1,Y	; +4/71
	DEY			; +2/73
	BPL	LinesRoller	; +3/76 when taken - exact sync
				; MUST NOT CROSS PAGE BOUNDARY
                                ; if it does, turn the STX.w into a plain STX
				; +2/75 when falling through
; Near-perfect sync, ends 1 cycle early
; End active line 2..17, 21..36, 40..55, ... 173..188
; -------------------------------

; -------------------------------
; Start active line 18, 37, 56, ... 189
; Starts 1 cycle early (see previous line)
				;
; Clear palette			;
	LDA	#0		; +2/1
	STA	_TIA_COLUBK	; +3/4
	STA	_TIA_COLUPF	; +3/7
	STA	_TIA_COLUP0	; +3/10
	STA	_TIA_COLUP1	; +3/13
				;
	DEC	_ZP_BARLINE	; +5/18
				; TODO: re-use BARREAD? (should be 60 here)
	BPL	Line19To171	; Taken: +3..4/22..23
				; WSYNC is borrowed from jump destination
				; Not taken: +2/20
				;
	STA	_TIA_WSYNC	; +3/(23>76)
; End active line 189		;
; -------------------------------

; -------------------------------
; Start active line 190		;
	STA	_TIA_WSYNC	; +3/(3>76)
; End active line 190		;
; -------------------------------

; -------------------------------
; Start active line 191		;
	STA	_TIA_WSYNC	; +3/(3>76)
; End active line 191		;
; -------------------------------


; ######################
; #                    #
; #  Bottom signature  #
; #                    #
; ######################
;
; The signature is an overlap of 3 techniques:
; * a 40-pixel sprite, quite far to the right of the screen
; * 2 opaque colors for the sprite, distinct from the actual background,
;       where 1 color is the playfield (black) and the other is the players
;	(white for both).
; * Per-line color changes for the background, with variable address.
;
; The sprite is at the rightmost position that still shows some background
;     to the right, i.e. pixels 116..155.
; The matching positions are 116 for P0 and 124 for P1
; Those get set (approximately) at the following CPU cycles:
; * SPR=117 COL=180 CPU=60
; * SPR=126 COL=189 CPU=63
;
; The timing to write the pixel data while the sprites are displayed:
; * Write 1: PIX=124..131 COL=192..199 CPU=64..66
; * Write 2: PIX=132..139 COL=200..207 CPU=67..69
; * Write 3: PIX=140..147 COL=208..215 CPU=70..71

; -------------------------------
; Start active line 192		;
;				;
; Set things up for signature	;
; Make no assumption about the state of the TIA, so that we can display
; the signature underneath any effect without interference.
;				;
; This line prinarily clears the palette, the graphics, and sets the
; sprites' horizontal position.	;
				;
; Set all colors to match the "background" - everything is invisible
	LDY	#16		; +2/2 - 3 lines above + 14 lines of bitmap
	LDA	(_ZP_SIGPAL),Y	; +5/7
	STA	_TIA_COLUBK	; +3/10 COL=30 PIX=-38
	STA	_TIA_COLUPF	; +3/13 COL=39 PIX=-29
	STA	_TIA_COLUP0	; +3/16 COL=48 PIX=-20
	STA	_TIA_COLUP1	; +3/19 COL=57 PIX=-11 - early enough
				;
; Disable all graphics		;
	LDA	#$0		; +2/21
	STA	_TIA_GRP0	; +3/24 - oP0=X nP0=0 oP1=X nP1=X
	STA	_TIA_GRP1	; +3/27 - oP0=0 nP0=0 oP1=X nP1=0
	STA	_TIA_GRP0	; +3/30 - oP0=0 nP0=0 oP1=0 nP1=0
	STA	_TIA_ENAM0	; +3/33
	STA	_TIA_ENAM1	; +3/36
	STA	_TIA_ENABL	; +3/39
				;
; Sprite reflection off		;
	STA	_TIA_REFP0	; +3/42
	STA	_TIA_REFP1	; +3/45
				;
	; begin 10-cycle NOP	;
	PHP			; +3/48
        BIT	0		; +3/51
	PLP			; +4/55
	; end 10-cycle NOP	;
				;
; Player 0 move 1 pixel to the left (clock 74 trick flips top bit)
	LDA	#$90		; +2/57
				;
	; Interleave set approximate sprite positions
	STA	_TIA_RESP0	; +3/60 COL=171 SPR=108
	STA	_TIA_RESP1	; +3/63 COL=180 SPR=117
				;
	STA	_TIA_HMP0	; +3/66
; Player 1 move 2 pixels to the left (clock 74 trick flips top bit)
	LDA	#$A0		; +2/68
	STA	_TIA_HMP1	; +3/71
				;
; Trigger HMOVE on clock 74 (magic trick)
	STA	_TIA_HMOVE	; +3/74
	DEY			; +2/76
; perfect sync			;
; End active line 192		;
; -------------------------------

; -------------------------------
; Start Active line 193		;
;				;
; This line primarily sets the palette, the playfield, the sprite repeat
; and sets the sprite delay (saves 1 precious CPU register)
				;
; Set "background" color for this line (actually playfield)
	LDA	(_ZP_SIGPAL),Y	; +5/5
	STA	_TIA_COLUBK	; +3/8 COL=24 PIX=-44
; Set a solid playfield		;
	LDA	#$0		; +2/10
	STA	_TIA_PF0	; +3/13 COL=39 PIX=-29
	STA	_TIA_PF1	; +3/16 COL=48 PIX=-20
	STA	_TIA_PF2	; +3/19 COL=57 PIX=-11
				;
; Set palette for background and players
	LDA	#_TIA_CO_GRAY + _TIA_LU_MIN	; +2/21
	STA	_TIA_COLUPF	; +3/24
	LDA	#_TIA_CO_GRAY + _TIA_LU_LIGHT	; +2/26
	STA	_TIA_COLUP0	; +3/29
	STA	_TIA_COLUP1	; +3/32
				;
; Reset horizontal move registers
	STA	_TIA_HMCLR	; +3/35
				;
; Setup sprite repeat / sprite delay (common bit 0)
	LDA	#$3		; +2/37
	STA	_TIA_NUSIZ0	; +3/30
	LSR			; +2/42 - A contains 1
	STA	_TIA_NUSIZ1	; +3/45
	STA	_TIA_VDELP0	; +3/48
	STA	_TIA_VDELP1	; +3/51
	DEY			; +2/53
	STA	_TIA_WSYNC	; +3/(56>76)
; End active line 193		;
; -------------------------------

; -------------------------------
; Start active line 194		;
;				;
; Nothing groundbreaking here, everything is already set up
				;
; Set "background" color for this line (actually playfield)
	LDA	(_ZP_SIGPAL),Y	; +5/5
	STA	_TIA_COLUBK	; +3/8 COL=24 PIX=-44
	DEY			; +2/10
	JMP	Line195To207	; +3/13
				;
	.align	$100,$EA	; $EA is NOP
Line195To207:			; Steal that WSYNC as end of subsequent lines
	STA	_TIA_WSYNC	; +3/(16>76) when falling through
        			; +3/76 when jumped to (no margin)
				;
; End active line 194		;
; Also end active line 195-207 through jump
; -------------------------------

; -------------------------------
; Start active line 195-208	;
;				;
; This is the core of the signature bar, with palette change, 40-pixel sprite,
; and split playfield.		;
				;
; Set "background" color for this line (actually playfield)
	LDA	(_ZP_SIGPAL),Y	; +5/5
	STA	_TIA_COLUBK	; +3/8 COL=24 PIX=-44
				;
; Reset playfield, filled	;
	LDA	#$0		; +2/10
	STA	_TIA_PF1	; +3/13 COL=39 PIX=-29
	STA	_TIA_PF2	; +3/16 COL=48 PIX=-20
				;
; Set the first 3 columns of sprite data
	LDA	Logo1,Y		; +4/20
	STA	_TIA_GRP0	; +3/23 COL=69 PIX=1
				;	oP0=X nP0=1 oP1=X nP1=X
	LDA	Logo2,Y		; +4/27
	STA	_TIA_GRP1	; +3/30 COL=90 PIX=22
				;	oP0=1 nP0=1 oP1=X nP1=2
	LDA	Logo3,Y		; +4/34
	STA	_TIA_GRP0	; +3/37 COL=111 PIX=43
				;	oP0=1 nP0=3 oP1=2 nP1=2
				;
; update PF1 between 37 and 53 (theo) / 57 (actual)
; update PF2 between 48 (theo) / 47 (actual) and 64
; PF2 works at 44 on my emulator, but there seem to be
; some 2600 implementations (Jr?) that are off by 1 pixel.
; Difference between theo and actual is because top 3 bits
; are identical between $FF and $E0, so we can change while
; those bits are getting displayed
	LDA	#$07		; +2/39
	STA	_TIA_PF1	; +3/42 COL=126 PIX=58
	LDA	#$7F		; +2/44
	STA	_TIA_PF2	; +3/47 COL=141 PIX=73
				;
; Load sprite data for last 2 columns
	LDX	Logo4,Y		; +4/51
	LDA	Logo5,Y		; +4/55
				;
	NOP			; +2/57
	NOP			; +2/59
	DEY			; +2/61 - flags untouched by store instructions
				;
	STX	_TIA_GRP1	; +3/64 COL=192 PIX=124
				;	P0=3 nP0=3 oP1=2 nP1=4
	STA	_TIA_GRP0	; +3/67 COL=201 PIX=133
				;	oP0=3 nP0=5 oP1=4 nP1=4
	STY	_TIA_GRP1	; +3/70 COL=210 PIX=142
				;	oP0=5 nP0=5 oP1=4 nP1=X
				;
	BPL	Line195To207	; Taken: +3/73 - MUST NOT CROSS PAGE BOUNDARY
				; WSYNC is borrowed from jump destination
				; Not taken +2/72
				;
	STA	_TIA_WSYNC	; +3/(75>76)
; End active line 208		;
; -------------------------------

; -------------------------------
; Start active line 209		;
;				;
; Clean up after the 40-pixel sprite: plain playfield, empty sprites
				;
; Set "background" color for this line (actually playfield)
	INY			; +2/2 - Y starts as $FF
	DEC	_ZP_SIGPAL	; +5/7
	LDA	(_ZP_SIGPAL),Y	; +5/12
	STA	_TIA_COLUBK	; +3/15 COL=45 PIX=-23
				;
; Clean up playfield and sprites;
	LDA	#$0		; +2/17
	STA	_TIA_PF1	; +3/20 COL=60 PIX=-8
	STA	_TIA_PF2	; +3/23 COL=69 PIX=1
				;
	STA	_TIA_GRP0	; +3/26 COL=78 PIX=10
				;	oP0=X nP0=0 oP1=X nP1=X
	STA	_TIA_GRP1	; +3/29 COL=85 PIX=19
				;	oP0=0 nP0=0 oP1=X nP1=0
	STA	_TIA_GRP0	; +3/31 COL=94 PIX=28
				;	oP0=0 nP0=0 oP1=0 nP1=0
				;
	STA	_TIA_WSYNC	; +3/(34>76) - end active line 209
; End active line 209		;
; -------------------------------

; -------------------------------
; Start active line 210		;
;				;
; Nothing big here, everything is clean
				;
; Set "background" color for this line (actually playfield)
	DEC	_ZP_SIGPAL	; +5/5
	LDA	(_ZP_SIGPAL),Y	; +5/10
	STA	_TIA_COLUBK	; +3/13 COL=39 PIX=-29
	STA	_TIA_WSYNC	; +3/(16>76)
; End active line 210		;
; -------------------------------

; -------------------------------
; Start active line 211		;
;				;
; Very little, just adjust color pointer back when done
				;
; Set "background" color for this line (actually playfield)
	DEC	_ZP_SIGPAL	; +5/5
	LDA	(_ZP_SIGPAL),Y	; +5/10
	STA	_TIA_COLUBK	; +3/13 COL=39 PIX=-29
	LDA	_ZP_SIGPAL	; +3/16
				;
; Adjust color pointer back	;
	CLC			; +2/18
	ADC	#3		; +2/20
	STA	_ZP_SIGPAL	; +2/22
	STA	_TIA_WSYNC	; +3/(25>76)
; End active line 211		;
; -------------------------------

; -------------------------------
; Start overscan line 0		;
	JMP	MainLoop	; +3/3
; Continue overscan line 0 up	;
; -------------------------------

; bar palette

Pal1:
	.byte	$16,$18,$1A,$1A,$1C,$1C,$1E,$1E
	.byte	$1E,$1E,$1C,$1C,$1A,$1A,$18,$16

Pal2:
	.byte	0,0,0,0,0,0,$74,$7a,$7a,$74,0,0,0,0,0,0

MBLogo:
	.byte	%10,%00,%10,%00,%11,%01
	.byte	%10,%10,%11,%00,%10,%10
	.byte	%10,%10,%11,%00,%10,%10
	.byte	%10,%01,%10,%00,%10,%10
	.byte	%10,%01,%10,%00,%11,%01
	.byte	%10,%00,%10,%00,%10,%10
	.byte	%10,%00,%10,%00,%10,%10
	.byte	%10,%00,%10,%00,%10,%10
	.byte	%10,%00,%10,%00,%10,%10
	.byte	%10,%00,%10,%00,%11,%01

; bar order
; 00 01 02 03 04 05 06 07 08 09 10 11 12
; 00 11 00 01 11 01 10 11 10 00 10 01 00

	.align	$100,0

Bar0:	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
Bar1:	.byte	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
Bar2:	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
Bar3:	.byte	$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
Bar4:	.byte	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
Bar5:	.byte	$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
Bar6:	.byte	$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
Bar7:	.byte	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
Bar8:	.byte	$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
Bar9:	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
Bar10:	.byte	$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
Bar11:	.byte	$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
Bar12:	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

BarLookupOff:
; format: top bit = fixed roller. Next 4 bits: bits 4-7 of graphics address
	.byte	(0 << 3) + $80	; 0000 - fixed bar 0
	.byte	2 << 3		; 0001 - rolling bar 2
	.byte	9 << 3		; 0010 - rolling bar 9
	.byte	0 << 3		; 0011 - rolling bar 0
	.byte	11 << 3		; 0100 - rolling bar 11
	.byte	(3 << 3) + $80	; 0101 - fixed bar 3
	.byte	5 << 3		; 0110 - rolling bar 5
	.byte	3 << 3		; 0111 - rolling bar 3
	.byte	8 << 3		; 1000 - rolling bar 8
	.byte	10 << 3		; 1001 - rolling bar 10
	.byte	(6 << 3) + $80	; 1010 - fixed bar 6
	.byte	6 << 3		; 1011 - rolling bar 6
	.byte	1 << 3		; 1100 - rolling bar 1
	.byte	4 << 3		; 1101 - rolling bar 4
	.byte	7 << 3		; 1110 - rolling bar 7
	.byte	(1 << 3) +$80	; 1111 - fixed bar 1

BarLookupOn:
	.byte	(0 << 3) + $80	; 0000 - fixed bar 0
	.byte	11 << 3		; 0100 - rolling bar 11
	.byte	8 << 3		; 1000 - rolling bar 8
	.byte	1 << 3		; 1100 - rolling bar 1
	.byte	2 << 3		; 0001 - rolling bar 2
	.byte	(3 << 3) + $80	; 0101 - fixed bar 3
	.byte	10 << 3		; 1001 - rolling bar 10
	.byte	4 << 3		; 1101 - rolling bar 4
	.byte	9 << 3		; 0010 - rolling bar 9
	.byte	5 << 3		; 0110 - rolling bar 5
	.byte	(6 << 3) + $80	; 1010 - fixed bar 6
	.byte	7 << 3		; 1110 - rolling bar 7
	.byte	0 << 3		; 0011 - rolling bar 0
	.byte	3 << 3		; 0111 - rolling bar 3
	.byte	6 << 3		; 1011 - rolling bar 6
	.byte	(1 << 3) +$80	; 1111 - fixed bar 1

BarRotation:
	.byte	16,16,16,15,15,14,14,13,12,11,10,9
        .byte	8,7,6,5,4,3,2,2,1,1,0,0

	.align	$100,0
; Signature
; MUST NO CROSS PAGE BOUNDARY

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
	.byte	%00010101

Logo4:
	.byte	%01101111
	.byte	%11101111
	.byte	%11001011
	.byte	%10001011
	.byte	%10001011
	.byte	%00001011
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
	.byte	$62,$64,$62
        .byte	$64,$66,$64,$66,$68,$66,$68,$68,$66,$68,$66,$64,$66,$64
        .byte	$62,$64,$62


; Reset / Start vectors
	.org	$FFFC
	.word	Main
	.word	Main

; 345678901234567890123456789012345678901234567890123456789012345678901234567890
