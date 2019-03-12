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
; Version 02, February 2019
;
; --------------------------------------------------------------------------

; ==========================================================================
; Display Lists.
;
; In Versions 00 through 02 the the custom Display lists make the Atari 
; impersonate the PET 4032's 40-column, 25 line display.  Version 03 now
; substitutes graphics for some uses of text modes, and uses different 
; sizes of blank lines to fill empty areas of the screen.  However the
; total size of the siaply is still the 25 lines used by the Pet.
;
; The Atari OS text printing is not being used, therefore the Atari screen
; editor's 24-line limitation is not an issue.
;
; We could start at ANTIC's 1K boundary for display lists.  But,
; we can make due with aligning to pages and just making sure none of
; the display lists cross a page boundary and by extension would not
; cross a 1K boundary.
; --------------------------------------------------------------------------

	.align $0100

; Revised V03 Title Screen and Instructions:
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |                                        |
; 3  |              PET FROGGER               | TITLE
; 4  |              PET FROGGER               | TITLE
; 5  |              PET FROGGER               | TITLE
; 6  |              --- -------               | TITLE
; 7  |                                        |
; 8  |Help the frogs escape from Doc Hopper's | INSTXT_1
; 9  |frog legs fast food franchise! But, the | INSTXT_1
; 10 |frogs must cross piranha-infested rivers| INSTXT_1
; 11 |to reach freedom. You have three chances| INSTXT_1
; 12 |to prove your frog management skills by | INSTXT_1
; 13 |directing frogs to jump on boats in the | INSTXT_1
; 14 |rivers like this:  <QQQQ]  Land only on | INSTXT_1
; 15 |the seats in the boats ('Q').           | INSTXT_1
; 16 |                                        |
; 17 |Scoring:                                | INSTXT_2
; 18 |    10 points for each jump forward.    | INSTXT_2
; 19 |   500 points for each rescued frog.    | INSTXT_2
; 20 |                                        |
; 21 |Use joystick control to jump forward,   | INSTXT_3
; 22 |left, and right.                        | INSTXT_3
; 23 |                                        |
; 24 |   Press joystick button to continue.   | ANYBUTTON_MEM
; 25 |(c) November 1983 by DalesOft  Written b| SCROLLING CREDIT
;    +----------------------------------------+

; ==========================================================================
; Give a display number below the VBI routine can set the Display List,
; and populate zero page pointers for other routines.
; --------------------------------------------------------------------------

DISPLAY_TITLE = 0
DISPLAY_GAME  = 1
DISPLAY_WIN   = 2
DISPLAY_DEAD  = 3
DISPLAY_OVER  = 4

; Mode 2 text and Load Memory Scan for text/graphics
; Using LMS on each line makes it easier to manipulate the
; text for animating transitions.

TITLE_DISPLAYLIST
	.byte   DL_BLANK_8, DL_BLANK_8          ; 16 blank scan lines.
	.byte   DL_BLANK_4|DL_DLI               ; 4 blank lines. DLI 0/0 sets COLPF1, COLPF2 for score text. 

	mDL_LMS DL_TEXT_2,SCORE_MEM1            ; (1-8) scores
	.byte   DL_BLANK_8|DL_DLI               ; (9-16) An empty line. DLI 1/1 Set GREEN background (COLBAK) and Map mode 9 color (COLPF0) for Line1.

; Replace the 3 lines of Text Mode 2 used in Version 00, 01, 02 
; with 6 lines of Map Mode 9.  
; Only 10 bytes per line (or 20 bytes for 2 lines occupying 8 scan lines.)
; Text mode is 40 bytes for the same area not including the 
; character set image.
; Not going to scroll the title this time.  Just fade it in 
; using the display list colors.  
; Also, the DLI can make six gradient transitions in the title 
; instead of 3.
; (Based on the way screen memory is declared, every line does
;  not require an LMS, so reducing 3 byte instructions to 1 byte.)
 
	mDL_LMS DL_MAP_9|DL_DLI,TITLE_MEM1     ; (17-20) DLI 2/2 Set COLPF0 for Line 2
	.byte   DL_MAP_9|DL_DLI                ; (21-24) DLI 2/3 Set COLPF0 for Line 3
	.byte   DL_MAP_9|DL_DLI                ; (25-28) DLI 2/4 Set COLPF0 for Line 4
	.byte   DL_MAP_9|DL_DLI                ; (29-32) DLI 2/5 Set COLPF0 for Line 5
	.byte   DL_MAP_9|DL_DLI                ; (33-36) DLI 2/6 Set COLPF0 for Line 6
	.byte   DL_MAP_9|DL_DLI                ; (37-40) DLI 2/7 Set COLPF0 for underlines

	.byte   DL_BLANK_2                     ; (41-42) An empty line.      2
	.byte   DL_MAP_9                       ; (43-46) Underlines        + 4
	.byte   DL_BLANK_2|DL_DLI              ; (47-48) An empty line.    + 2 = 8, DLI 3/8 set BLACK for COLBK.

	.byte   DL_BLANK_8|DL_DLI              ; (49-56) DLI 4/9 set AQUA for COLBK and COLPF2, and set COLPF1

	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM1 ; (57-64) Basic instructions... DLI 5/10 set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI               ; (65-72) DLI 5/11 set COLPF1 text
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM3 ; (73-80) DLI 5/12 set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI               ; (81-88) DLI 5/13 set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI               ; (89-96) DLI 5/14 set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI               ; (97-104) DLI 5/15 set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI,INSTRUCT_MEM7 ; (105-112) DLI 5/16 set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI               ; (113-120) DLI 3/17 set BLACK for COLBK

	.byte   DL_BLANK_8|DL_DLI              ; (121-128) An empty line.  DLI 4/18 set ORANGE2 for COLBK and COLPF2, set COLPF1 text

	.byte   DL_TEXT_2|DL_DLI               ; (129-136) Scoring.  DLI 5/19 set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI               ; (137-144) DLI 5/20 set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI               ; (145-152) DLI 3/21 set BLACK for COLBK

	.byte   DL_BLANK_8|DL_DLI              ; (153-160) An empty line.  DLI 4/22 set PINK for COLBK and COLPF2, and set COLPF1 text

	.byte   DL_TEXT_2|DL_DLI               ; (161-168) Game Controls.  DLI 5/23 set COLPF1 text
	mDL_LMS DL_TEXT_2|DL_DLI               ; (169-176) DLI 3/24 set BLACK for COLBK

	.byte   DL_BLANK_8|DL_DLI              ; (177-184) An empty line.  DLI SPC1/25 sets COLBK, COLPF2, COLPF1 colors.

	mDL_JMP BOTTOM_OF_DISPLAY              ; (185-192, 193-200) End of display.  See Page 0 for this evil.


; Revised V03 Main Game Play Screen:
; FYI: Old boats.
; 8  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_2
; 9  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_2
; Old:  [QQQQ>
; New: [[QQQQQ>
; New boats are larger to provide more safe surface for the larger 
; frog and to provide some additional graphics enhancement for 
; the boats.  Illustration below shows the entire memory needed 
; for scrolling.
; The two grassy areas at the top and the bottom are sacrificed to 
; distribute their scan lines between each game line providing 9 scan 
; lines per boat line which are used to extend the water area and 
; allow for a 10 scan line frog image and also provide a space safe 
; for updating five color registers plus HSCROL.  (a few of the scan 
; lines from the unused Press A Button line also participate.)
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; 3  |                                        | 
; 4  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_1
; 5  |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        | ; Boats Right
; 6  |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        | ; Boats Left
; 7  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_2
; 8  |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        |
; 9  |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 10 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_3
; 11 |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        |
; 12 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 13 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_4
; 14 |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        |
; 15 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 16 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_5
; 17 |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        |
; 18 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 19 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_6
; 20 |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        |
; 21 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 22 |BBBBBBBBBBBBBBBBBBBOBBBBBBBBBBBBBBBBBBBB| TEXT2
; 23 |                                        |
; 24 |                                        |
; 25 |(c) November 1983 by DalesOft  Written b| SCROLLING CREDIT
;    +----------------------------------------+

GAME_DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_8, DL_BLANK_4|DL_DLI ; 20 blank scan lines.  DLI 0/0 sets COLPF1, COLPF2 for score text.

	mDL_LMS DL_TEXT_2|DL_DLI,SCORE_MEM1      ; (1-8) Labels for crossings, scores, and lives. DLI 1/1 sets COLPF1 for text.
	mDL_LMS DL_TEXT_2,SCORE_MEM2             ; (9-16) 
	.byte DL_BLANK_1|DL_DLI                  ; (17) DLI 2/2 sets COLPF0,1,2,3,BK for Beach.

PF_LMS0 = [* + 1]                            ; Plus 1 is the address of the display list LMS
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM0  ; (18-25) Beach. DLI 3/3 sets boats COLPF0,1,2,3,BK, HSCROLL.
	.byte DL_BLANK_1                         ; (26) One scan line 

PF_LMS1 = [* + 1] ; Right
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM1  ; (27-34) Boats. DLI 3/4 sets boats COLPF0,1,2,3,BK, HSCROLL.
	.byte DL_BLANK_1                         ; (35) One scan line 

PF_LMS2 = [* + 1] ; Left
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM2  ; (36-43) Boats. DLI 2/5 sets COLPF0,1,2,3,BK for Beach.
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS3 = [* + 1] 
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM3  ; (-) Beach. DLI 3/6 sets boats COLPF0,1,2,3,BK, HSCROLL.
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS4 = [* + 1] ; Right
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM4  ; (-) Boats. 
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS5 = [* + 1] ; Left
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM5  ; (-) Boats. 
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS6 = [* + 1] ; 
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM6  ; (-) Beach. DLI 
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS7 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM7  ; (-) Boats.
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS8 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM8  ; (-) Boats.
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS9 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM9  ; (-) Beach. DLI 
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS10 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM10 ; (-) Boats.
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS11 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM11 ; (-) Boats.
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS12 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM12 ; (-) Beach. DLI 
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS13 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM13 ; (-) Boats.
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS14 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM14 ; (-) Boats.
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS15 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM15 ; (-) Beach. DLI 
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS16 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM16 ; (-) Boats.
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS17 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM17 ; (-) Boats.
	.byte DL_BLANK_1                         ; (44) One scan line 

PF_LMS18 = [* + 1]
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM18 ; (-) Frog starting Beach. DLI 

	.byte DL_BLANK_1|DLI                     ; (??) Some scan lines. DLI SPC2/26 sets HSCROL, (and COLBK/COLPF2/COLPF1 for credit.)

	mDL_JMP DL_SCROLLING_CREDIT              ; (193-200) End of display. No prompt for button.  See Page 0 for the evil.



; FROG SAVED screen, 25 lines:
; 10 blank lines.
; 3 lines of big text.
; 10 blank lines
; Press A Button Line
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
