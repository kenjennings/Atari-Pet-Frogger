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
; Version 02, January 2019
;
; --------------------------------------------------------------------------

; ==========================================================================
; Display Lists.
;
; The custom Display lists make the Atari impersonate the PET 4032's
; 40-column, 25 line display.  Each averages about 75 bytes, so
; three can fit in the same page.
;
; The Atari OS text printing is not being used, therefore the Atari screen
; editor's 24-line limitation is not an issue.
;
; Where a display expects completely static, blank, black lines a
; display list would use real, blank line instructions.  However, the
; ANTIC mode 2 text uses color differently from other text modes.
; The "background" behind text uses COLPF2 and COLPF4 for the border.
; Other modes use COLPF4 as true background through the border and
; empty background behind text.  Therefore where the program expects
; to use color in the background behind text, it uses a text instruction
; pointing to an empty line of blank spaces, so that COLPF2 can be used
; to show color within the same horizontal limits as the other text
; in the screen. This makes it easy to "animate" with color changes to
; the text background.
;
; We could start at ANTIC's 1K boundary for display lists.  But,
; we can make due with aligning to pages and just making sure none of
; the display lists cross a page boundary and by extension would not
; cross a 1K boundary.
; --------------------------------------------------------------------------

	.align $0100

; Revised V02 Title Screen and Instructions:
;    +----------------------------------------+
; 1  |              PET FROGGER               | TITLE
; 2  |              PET FROGGER               | TITLE
; 3  |              PET FROGGER               | TITLE
; 4  |              --- -------               | TITLE
; 5  |                                        |
; 6  |Help the frogs escape from Doc Hopper's | INSTXT_1
; 7  |frog legs fast food franchise! But, the | INSTXT_1
; 8  |frogs must cross piranha-infested rivers| INSTXT_1
; 9  |to reach freedom. You have three chances| INSTXT_1
; 10 |to prove your frog management skills by | INSTXT_1
; 11 |directing frogs to jump on boats in the | INSTXT_1
; 12 |rivers like this:  <QQQQ]  Land only on | INSTXT_1
; 13 |the seats in the boats ('Q').           | INSTXT_1
; 14 |                                        |
; 15 |Scoring:                                | INSTXT_2
; 16 |    10 points for each jump forward.    | INSTXT_2
; 17 |   500 points for each rescued frog.    | INSTXT_2
; 18 |                                        |
; 19 |Use joystick control to jump forward,   | INSTXT_3
; 20 |left, and right.                        | INSTXT_3
; 21 |                                        |
; 22 |                                        |
; 23 |                                        |
; 24 |   Press joystick button to continue.   | ANYBUTTON_MEM
; 25 |(c) November 1983 by DalesOft  Written b| SCROLLING CREDIT
;    +----------------------------------------+

; Mode 2 text and Load Memory Scan for text/graphics
; Using LMS on each line makes it easier to manipulate the
; text for animating transitions.

TITLE_DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_8, DL_BLANK_4|DL_DLI ; 20 blank scan lines.

SCROLL_TITLE_LMS0 = [* + 1]
	mDL_LMS DL_TEXT_2|DL_DLI,TITLE_MEM1       ; Scroll In Title.
SCROLL_TITLE_LMS1 = [* + 1]
	mDL_LMS DL_TEXT_2|DL_DLI,TITLE_MEM2       ; Scroll In Title
SCROLL_TITLE_LMS2 = [* + 1]
	mDL_LMS DL_TEXT_2|DL_DLI,TITLE_MEM3       ; Scroll In Title.
	mDL_LMS DL_TEXT_2|DL_DLI,TITLE_MEM4       ; Underlines
	.byte DL_BLANK_8|DL_DLI                   ; An empty line.

	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM1    ; Basic instructions...
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM2
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM3
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM4
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM5
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM6
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM7
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM8
	.byte DL_BLANK_8|DL_DLI                   ; An empty line.

	mDL_LMS DL_TEXT_2|DL_DLI,SCORING_MEM1     ; Scoring
	mDL_LMS DL_TEXT_2|DL_DLI,SCORING_MEM2
	mDL_LMS DL_TEXT_2|DL_DLI,SCORING_MEM3
	.byte DL_BLANK_8|DL_DLI                   ; An empty line.

	mDL_LMS DL_TEXT_2|DL_DLI,CONTROLS_MEM1    ; Game Controls
	mDL_LMS DL_TEXT_2|DL_DLI,CONTROLS_MEM2
	.byte DL_BLANK_8|DL_DLI                   ; An empty line.
	.byte DL_BLANK_8|DL_DLI                   ; An empty line.
	.byte DL_BLANK_8|DL_DLI                   ; An empty line.

	mDL_JMP BOTTOM_OF_DISPLAY                 ; End of display.  See Page 0 for the evil.



; Revised V02 Main Game Play Screen:
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; 3  |                                        | <-Grassy color
; 4  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_1
; 5  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_1
; 6  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_1
; 7  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_2
; 8  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_2
; 9  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_2
; 10 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_3
; 11 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_3
; 12 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_3
; 13 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_4
; 14 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_4
; 15 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_4
; 16 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_5
; 17 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_5
; 18 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_5
; 19 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_6
; 20 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_6
; 21 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_6
; 22 |BBBBBBBBBBBBBBBBBBBOBBBBBBBBBBBBBBBBBBBB| TEXT2
; 23 |                                        | <-Grassy color
; 24 |                                        |
; 25 |(c) November 1983 by DalesOft  Written b| SCROLLING CREDIT
;    +----------------------------------------+

GAME_DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_8, DL_BLANK_4|DL_DLI ; 20 blank scan lines.

	mDL_LMS DL_TEXT_2|DL_DLI,SCORE_MEM1      ; Labels for crossings counter, scores, and lives
	mDL_LMS DL_TEXT_2|DL_DLI,SCORE_MEM2
	mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM               ; An empty line of spaces.  (green grass)

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
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM10
PF_LMS11 = [* + 1]
	mDL_LMS DL_TEXT_2|DL_DLI,PLAYFIELD_MEM11
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
	mDL_LMS DL_TEXT_2|DL_DLI,BLANK_MEM        ; An empty line of spaces.  (green grass)

	mDL_JMP BOTTOM_OF_DISPLAY                 ; End of display.  See Page 0 for the evil.


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

	mDL_JMP BOTTOM_OF_DISPLAY                 ; End of display.  See Page 0 for the evil.



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

	mDL_JMP BOTTOM_OF_DISPLAY                 ; End of display.  See Page 0 for the evil.


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

	mDL_JMP BOTTOM_OF_DISPLAY                 ; End of display.  See Page 0 for the evil.

