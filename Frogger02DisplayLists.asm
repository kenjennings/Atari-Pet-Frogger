; ==========================================================================
; Pet Frogger
; (c) November 1983 by John C. Dale, aka Dalesoft
; for the Commodore Pet 4032
;
; ==========================================================================
; Ported (parodied) to Atari 8-bit computers
; by Ken Jennings (if this were 1983, aka FTR Enterprises)
;
; Version 00, November 2018
; Version 01, December 2018
; Version 02, December 2018
;
; --------------------------------------------------------------------------

; ==========================================================================
; Display Lists.
; 
; The custom Display lists make the Atari impersonate the PET 4032's 
; 40-column, 25 line display.  Each averages about 81 bytes, so 
; three can fit in the same page.
;
; The Atari OS text printing is not being used, therefore the Atari screen
; editor's 24-line limitation is not an issue.
;
; Blank lines in the display are done by referring to an empty line of data.
; This makes it easy to "animate" with color changes.  Also, the screen 
; transitions are easier when the screen geometry is consistent.  Truly
; blank scan lines are displayed by COLPF4 (border) instead of the COLPF2
; (background) used in ANTIC mode 2.
; --------------------------------------------------------------------------

	.align $0400 ; Start at ANTIC's 1K boundary for display lists. 

; Revised V01 and V02 Title Screen and Instructions:
;    +----------------------------------------+
; 1  |              PET FROGGER               | TITLE
; 2  |              --- -------               | TITLE
; 3  |     (c) November 1983 by DalesOft      | CREDIT
; 4  |        Written by John C Dale          | CREDIT
; 5  |Atari V01 port by Ken Jennings, Dec 2018| CREDIT
; 6  |                                        |
; 7  |Help the frogs escape from Doc Hopper's | INSTXT_1
; 8  |frog legs fast food franchise! But, the | INSTXT_1
; 9  |frogs must cross piranha-infested rivers| INSTXT_1
; 10 |to reach freedom. You have three chances| INSTXT_1
; 11 |to prove your frog management skills by | INSTXT_1
; 12 |directing frogs to jump on boats in the | INSTXT_1
; 13 |rivers like this:  <QQQQ]  Land only on | INSTXT_1
; 14 |the seats in the boats ('Q').           | INSTXT_1
; 15 |                                        |
; 16 |Scoring:                                | INSTXT_2
; 17 |    10 points for each jump forward.    | INSTXT_2
; 18 |   500 points for each rescued frog.    | INSTXT_2
; 19 |                                        |
; 20 |Game controls:                          | INSTXT_3
; 21 |                 S = Up                 | INSTXT_3
; 22 |      left = 4           6 = right      | INSTXT_3
; 23 |                                        |
; 24 |     Hit any key to start the game.     | INSTXT_4
; 25 |                                        |
;    +----------------------------------------+

; Mode 2 text and Load Memory Scan for text/graphics
; Using LMS on each line makes it easier to manipulate the 
; text for animating transitions.

TITLE_DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_8, DL_BLANK_4|DL_DLI ; 20 blank scan lines.

	mDL_LMS DL_TEXT_2|DL_DLI,TITLE_MEM1    ; Instructions/Title text.
	mDL_LMS DL_TEXT_2|DL_DLI,TITLE_MEM2    ; Underlines
	mDL_LMS DL_TEXT_2|DL_DLI,CREDIT_MEM1   ; The perpetrators identified
	mDL_LMS DL_TEXT_2|DL_DLI,CREDIT_MEM2 
	mDL_LMS DL_TEXT_2|DL_DLI,CREDIT_MEM3
	mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM     ; An empty line.
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM1 ; Basic instructions...
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM2 
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM3
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM4 
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM5
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM6 
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM7 
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM8 
	mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM     ; An empty line.
	mDL_LMS DL_TEXT_2|DL_DLI,SCORING_MEM1  ; Scoring
	mDL_LMS DL_TEXT_2|DL_DLI,SCORING_MEM2 
	mDL_LMS DL_TEXT_2|DL_DLI,SCORING_MEM3
	mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM     ; An empty line.
	mDL_LMS DL_TEXT_2|DL_DLI,CONTROLS_MEM1 ; Game Controls
	mDL_LMS DL_TEXT_2|DL_DLI,CONTROLS_MEM2
	mDL_LMS DL_TEXT_2|DL_DLI,CONTROLS_MEM3 
	mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM     ; An empty line.
	mDL_LMS DL_TEXT_2|DL_DLI,ANYKEY_MEM    ; Prompt to start game.
	mDL_LMS DL_TEXT_2,BLANK_MEM            ; An empty line.

	.byte DL_JUMP_VB                       ; End list, Vertical Blank 
	.word TITLE_DISPLAYLIST                ; Restart display at the same display list.


; Revised V01 and V02 Main Game Play Screen:
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; 3  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_1
; 4  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_1
; 5  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_1
; 6  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_2
; 7  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_2
; 8  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_2
; 9  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_3
; 10 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_3
; 11 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_3
; 12 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_4
; 13 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_4
; 14 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_4
; 15 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_5
; 16 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_5
; 17 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_5
; 18 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_6
; 19 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_6
; 20 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_6
; 21 |BBBBBBBBBBBBBBBBBBBOBBBBBBBBBBBBBBBBBBBB| TEXT2
; 22 |                                        |
; 23 |     (c) November 1983 by DalesOft      | CREDIT
; 24 |        Written by John C Dale          | CREDIT
; 25 |Atari V01 port by Ken Jennings, Dec 2018| CREDIT
;    +----------------------------------------+

GAME_DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_8, DL_BLANK_4|DL_DLI ; 20 blank scan lines.

	mDL_LMS DL_TEXT_2|DL_DLI,SCORE_MEM1      ; Labels for crossings counter, scores, and lives
	mDL_LMS DL_TEXT_2|DL_DLI,SCORE_MEM2    
PF_LMS0 = [* + 1] ; Plus 1 is the address of the display list LMS
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM0  ; "Beach", and the two lines of Boats
PF_LMS1 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM1  ; Right Boats.
PF_LMS2 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM2  ; Left Boats.
PF_LMS3 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM3  ; "Beach", and the two lines of Boats
PF_LMS4 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM4
PF_LMS5 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM5
PF_LMS6 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM6  ; "Beach", and the two lines of Boats
PF_LMS7 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM7
PF_LMS8 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM8
PF_LMS9 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM9  ; "Beach", and the two lines of Boats
PF_LMS10 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM11
PF_LMS11 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM10
PF_LMS12 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM12 ; "Beach", and the two lines of Boats
PF_LMS13 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM13
PF_LMS14 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM14
PF_LMS15 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM15 ; "Beach", and the two lines of Boats
PF_LMS16 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM16
PF_LMS17 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM17
PF_LMS18 = [* + 1] 
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM18 ; Frog starting beach.

	mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM       ; An empty line.
	mDL_LMS DL_TEXT_2|DL_DLI,CREDIT_MEM1     ; The perpetrators identified
	mDL_LMS DL_TEXT_2|DL_DLI,CREDIT_MEM2 
	mDL_LMS DL_TEXT_2,CREDIT_MEM3

	.byte DL_JUMP_VB                         ; End list, Vertical Blank 
	.word GAME_DISPLAYLIST                   ; Restart display at the same display list.


; FROG SAVED screen, 25 lines:
; 10 blank lines.
; 3 lines of big text.
; 10 blank lines
; Press Any Key Line
; 1 blank line

FROGSAVED_DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_8, DL_BLANK_4|DL_DLI ; 20 blank scan lines.

	.rept 10
		mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM          ; An empty line. times 10
	.endr

	mDL_LMS DL_TEXT_2|DL_DLI,FROGSAVE_MEM           ; Frog Saved Line 1, 2, and 3.
	mDL_LMS DL_TEXT_2|DL_DLI,FROGSAVE_MEM+40 
	mDL_LMS DL_TEXT_2|DL_DLI,FROGSAVE_MEM+80

	.rept 10
		mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM          ; An empty line. times 10
	.endr

	mDL_LMS DL_TEXT_2|DL_DLI,ANYKEY_MEM             ; Prompt to start game.
	mDL_LMS DL_TEXT_2,BLANK_MEM                     ; An empty line.

	.byte DL_JUMP_VB                                ; End list, Vertical Blank 
	.word FROGSAVED_DISPLAYLIST                     ; Restart display at the same display list.


	.align $0100 ; Align in the next page.

; FROG DEAD screen., 25 lines:
; 10 blank lines.
; 3 lines of big text.
; 10 blank lines
; Press Any Key Line
; 1 blank line

FROGDEAD_DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_8, DL_BLANK_4|DL_DLI ; 20 blank scan lines.

	.rept 10
		mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM          ; An empty line. times 10
	.endr

	mDL_LMS DL_TEXT_2|DL_DLI,FROGDEAD_MEM           ; Dead Frog Line 1, 2, and 3.
	mDL_LMS DL_TEXT_2|DL_DLI,FROGDEAD_MEM+40 
	mDL_LMS DL_TEXT_2|DL_DLI,FROGDEAD_MEM+80

	.rept 10
		mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM          ; An empty line. times 10
	.endr

	mDL_LMS DL_TEXT_2|DL_DLI,ANYKEY_MEM             ; Prompt to start game.
	mDL_LMS DL_TEXT_2,BLANK_MEM                     ; An empty line.

	.byte DL_JUMP_VB                                ; End list, Vertical Blank 
	.word FROGDEAD_DISPLAYLIST                      ; Restart display at the same display list.


; GAME OVER screen., 25 lines:
; 10 blank lines.
; 3 lines of big text.
; 10 blank lines
; Press Any Key Line
; 1 blank line

GAMEOVER_DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_8, DL_BLANK_4|DL_DLI ; 20 blank scan lines.

	.rept 10
		mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM          ; An empty line. times 10
	.endr

	mDL_LMS DL_TEXT_2|DL_DLI,GAMEOVER_MEM           ; Game Over Line 1, 2, and 3.
	mDL_LMS DL_TEXT_2|DL_DLI,GAMEOVER_MEM+40 
	mDL_LMS DL_TEXT_2|DL_DLI,GAMEOVER_MEM+80

	.rept 10
		mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM          ; An empty line. times 10
	.endr

	mDL_LMS DL_TEXT_2|DL_DLI,ANYKEY_MEM             ; Prompt to start game.
	mDL_LMS DL_TEXT_2,BLANK_MEM                     ; An empty line.

	.byte DL_JUMP_VB                                ; End list, Vertical Blank 
	.word GAMEOVER_DISPLAYLIST                      ; Restart display at the same display list.



