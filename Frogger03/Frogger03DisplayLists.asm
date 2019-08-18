; ==========================================================================
; Pet Frogger
; (c) November 1983 by John C. Dale, aka Dalesoft
; for the Commodore Pet 4032
; ==========================================================================
; Ported (parodied) to Atari 8-bit computers
; by Ken Jennings (if this were 1983, aka FTR Enterprises)
; ==========================================================================
; Version 00, November 2018
; Version 01, December 2018
; Version 02, February 2019
; Version 03, August 2019
; ==========================================================================

; ==========================================================================
; Display Lists.
;
; In Versions 00 through 02 the the custom Display lists make the Atari 
; impersonate the PET 4032's 40-column, 25 line display.  Version 03 now
; substitutes graphics for some uses of text modes, and uses different 
; sizes of blank lines to fill empty areas of the screen.  
; Due to requirements of the Game screen, the displays are now 202 
; scan lines, two taller than needed for the default, 25 text line 
; display used by the Pet.
;
; The Atari OS text printing is not being used, therefore the Atari screen
; editor's limitations are not an issue.
;
; ANTIC has a 1K boundary limit for Display Lists.  We do not need to align
; to 1K, because display lists are ordinarily short, and several will 
; easily fit in one page of memory.  So, the code can make due with 
; aligning to a page.  If they all stay in the page then they can't cross
; a 1K boundary.
; --------------------------------------------------------------------------

	.align $0100

; Revised V03 Title Screen and Instructions:
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0       00000000000000000000:Saved| SCORE_TXT
; 3  |              PET FROGGER               | TITLE
; 4  |              PET FROGGER               | TITLE
; 5  |              PET FROGGER               | TITLE
; 6  |              --- -------               | TITLE
; 7  |                                        |
; 8  |Help the frogs escape evil Doc Hopper's | INSTXT_1
; 9  |Frog Legs Fast Food Franchise! But, the | INSTXT_1
; 10 |frogs must cross piranha-infested rivers| INSTXT_1
; 11 |to reach freedom. You have three chances| INSTXT_1
; 12 |to prove your frog management skills by | INSTXT_1
; 13 |directing frogs to jump on boats in the | INSTXT_1
; 14 |rivers. Land in the middle of the boats.| INSTXT_1
; 15 |Do not fall off or jump in the river.   | INSTXT_1
; 16 |                                        |
; 17 |Scoring:                                | INSTXT_2
; 18 |    10 points for each jump forward.    | INSTXT_2
; 19 |   500 points for each saved frog.      | INSTXT_2
; 20 |                                        |
; 21 |Use the joystick control to jump        | INSTXT_3
; 22 |forward, left, and right.               | INSTXT_3
; 23 |                                        |
; 24 | Press the joystick button to continue. | ANYBUTTON_MEM
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

MAX_DISPLAYS  = 5

; Version 01, and 02  used graphics control characters in Antic Text 
; Mode 2 for the title.  Version 03 uses 6 lines of Map Mode 9 in place 
; of the 3 lines of Text Mode 2.  Real graphics ensue...
; Mode 9 requires only 10 bytes per line.  Therefore only 20 bytes 
; for 2 lines which cover the same screen real-estate (8 scan lines) 
; as the text line they replace.  The text line requires 40 bytes which 
; doesn't include the character set data needed for the Text mode.
; In V03 we're replacing the V02 scrolling with glitzier color 
; transitions as the Map mode allows full use of color and the 
; individual lines allow 6 easy transitions in this space instead 
; of 3 with the Text mode.  
; Also, the Title screen will add a flying frog demo, so that's the 
; eye candy for Version 03.

; New DLI updates.....  
; Before score line 1, need to set all PM registers.
; After score line 1 need a minimal line to burn off the second entry in the tables.
; Need a line before gfx to set all the regular player's attributes.
; May need to insert some blanks between lines to allow more time. 


TITLE_DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_4|DL_DLI
	.byte DL_BLANK_3                         ; 15 blank scan lines (instead of the usual 24).
	;                                                    SCORE DLI 0/Score1 sets COLPF1, COLPF2/COLBK for score text, and PMG
	mDL_LMS DL_TEXT_2|DL_DLI,SCORE_MEM1      ; (1-8)     Labels for scores 1.
	;                                                    SCORE DLI 1/Score2 sets COLPF1, COLPF2/COLBK for score text, and PMG
	.byte DL_BLANK_1                         ; (9)

	mDL_LMS DL_TEXT_2,SCORE_MEM2             ; (10-17)   Labels for Scores 2.

	.byte DL_BLANK_3|DL_DLI                  ; (18-20)   Blank before Title graphics
	;                                                    DLI 2/SPLASH_PMGSPECS2_DLI - Load PM Specs + COLPF0_COLBK_DLI
	;                Title Graphics... HSCROL means to show all color clocks LMS must be -1, HSCROL 0
TT_LMS0 = [* + 1]                            ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_MAP_9|DL_DLI|DL_HSCROLL,TITLE_START     ; (21-24)   DLI 3/COLPF0_COLBK_DLI Set COLPF0 for Line 2
TT_LMS1 = [* + 1]                            ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_MAP_9|DL_DLI|DL_HSCROLL,TITLE_START+20  ; (25-28)   DLI 4/COLPF0_COLBK_DLI Set COLPF0 for Line 3
TT_LMS2 = [* + 1]                            ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_MAP_9|DL_DLI|DL_HSCROLL,TITLE_START+40  ; (29-32)   DLI 5/COLPF0_COLBK_DLI Set COLPF0 for Line 4
TT_LMS3 = [* + 1]                            ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_MAP_9|DL_DLI|DL_HSCROLL,TITLE_START+60  ; (33-36)   DLI 6/COLPF0_COLBK_DLI Set COLPF0 for Line 5
TT_LMS4 = [* + 1]                            ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_MAP_9|DL_DLI|DL_HSCROLL,TITLE_START+80  ; (37-40)   DLI 7/COLPF0_COLBK_DLI Set COLPF0 for Line 6
TT_LMS5 = [* + 1]                            ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_MAP_9|DL_DLI|DL_HSCROLL,TITLE_START+100 ; (41-44)   DLI 8/COLPF0_COLBK_DLI Set COLPF0 for underlines

	.byte   DL_BLANK_2                       ; (45-46)   An empty line.      2
	mDL_LMS DL_MAP_9,TITLE_UNDERLINE         ; (47-50)   Underlines        + 4
	.byte   DL_BLANK_2|DL_DLI                ; (51-52)   An empty line.    + 2 = 8 
	;                                                    DLI 9/TITLE_DLI_BLACKOUT set BLACK for COLBK.

	.byte   DL_BLANK_8|DL_DLI                ; (53-60)   DLI 10/TITLE_DLI_TEXTBLOCK set AQUA for COLBK and COLPF2, and set COLPF1

	;                 Basic Instructions... 
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM1   ; (61-68)   DLI 11/TITLE_DLI_TEXTBLOCK set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI                 ; (69-76)   DLI 12/TITLE_DLI_TEXTBLOCK set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI                 ; (77-84)   DLI 13/TITLE_DLI_TEXTBLOCK set COLPF1 text
	mDL_LMS DL_TEXT_2|DL_DLI,INSTRUCT_MEM4   ; (85-92)   DLI 14/TITLE_DLI_TEXTBLOCK set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI                 ; (93-100)  DLI 15/TITLE_DLI_TEXTBLOCK set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI                 ; (101-108) DLI 16/TITLE_DLI_TEXTBLOCK set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI                 ; (109-116) DLI 17/TITLE_DLI_TEXTBLOCK set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI                 ; (117-124) DLI 18/TITLE_DLI_BLACKOUT set BLACK for COLBK

	.byte   DL_BLANK_8|DL_DLI                ; (125-132) DLI 19/TITLE_DLI_TEXTBLOCK set ORANGE2 for COLBK and COLPF2, set COLPF1 text

	;                                        ; Scoring.
	.byte   DL_TEXT_2|DL_DLI                 ; (133-140) DLI 20/TITLE_DLI_TEXTBLOCK set COLPF1 text
	mDL_LMS DL_TEXT_2|DL_DLI,SCORING_MEM2    ; (141-148) DLI 21/TITLE_DLI_TEXTBLOCK set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI                 ; (149-156) DLI 22/TITLE_DLI_BLACKOUT set BLACK for COLBK

	.byte   DL_BLANK_8|DL_DLI                ; (157-164) DLI 23/TITLE_DLI_TEXTBLOCK set PINK for COLBK and COLPF2, and set COLPF1 text

	;                 Game Controls...
	.byte   DL_TEXT_2|DL_DLI                 ; (165-172) DLI 24/TITLE_DLI_TEXTBLOCK set COLPF1 text
	.byte   DL_TEXT_2|DL_DLI                 ; (173-180) DLI 25/TITLE_DLI_BLACKOUT set BLACK for COLBK

	.byte   DL_BLANK_8|DL_DLI                ; (181-188) DLI 26/SCP1 sets COLBK, COLPF2, COLPF1 colors. Then sets up for SPC2
	.byte   DL_BLANK_1                       ; (189)     One extra to line up credit with the same line on the game screen 

	mDL_JMP BOTTOM_OF_DISPLAY                ; (190-197, 198, 199-206) End of display.  See Page 0 for this evil.


; Revised V03 Main Game Play Screen:
; FYI: Old boats.
; 8  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_2
; 9  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_2
; Old:  [QQQQ>
; New: [[QQQQQ>

; New boats are larger to provide more safe surface for the larger 
; frog and to provide some additional graphics enhancement for 
; the boats.  Illustration below shows the lines with the 
; additional boat data needed for scrolling.

; Line placement is jiggled about to add enough blank lines and 
; filler space to make the Display List Interrupts work, so the 
; gap at the  bottom of the illustration is not real -- its scan 
; lines are distributed between the other lines.
; Given the number of things that the Display List Interrupts must 
; reload between each line, and the fact that horizontal scrolling 
; lines results in variable DMA timing to the point where zero CPU 
; time is available, the DLIs on scrolling lines are moved to the 
; following line.  Consequently, in order to preserve the color 
; continuity after a boat line the line following the boat is not 
; a blank line.   It is a Mode C line filled with COLPF0 pixels. 
; This allows the DLIs to manage the color transition for the 
; Background color before it is needed, and delay the update to 
; COLPF0 until later.

;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0       00000000000000000000:Saved| SCORE_TXT
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

; New DLI updates.....  
; Before score line 1, need to set all PM registers.
; After score line 1 need to set everything for line 2.
; Need a line before gfx to set all the regular player's attributes.
; May need to insert some blanks between lines to allow more time. 
; Beach DLI may need to start earlier, run longer, and PM properties 
; may need to be setup first before playfield.

GAME_DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_4|DL_DLI
	.byte DL_BLANK_3                                ; 15 blank scan lines.  
	;                                                           SCORE DLI 0/Score1 sets COLPF1, COLPF2/COLBK for score text.
	
	mDL_LMS DL_TEXT_2|DL_DLI,SCORE_MEM1             ; (1-8)     Labels for scores 1. 
	;                                                           SCORE DLI 1/Score2 sets COLPF1, COLPF2/COLBK for score text.

	.byte DL_BLANK_1                                ; (9)      

; ========== Start

	mDL_LMS DL_TEXT_2|DL_DLI,SCORE_MEM2             ; (10-17)   Labels for Scores 2.
	;                                                           DLI 2/BEACH0 sets COLPF0,1,2,3,BK for Beach. (row 18)

; ========== 1

	.byte DL_BLANK_4                                ; (18-21)   Blank before Beach for time.
	
PF_LMS0 = [* + 1]                                   ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM0         ; (22-29)   Beach. 
	;                                                           DLI 3/BEACH2BOAT sets boats right (row 17) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (30)      One scan line 

PF_LMS1 = [* + 1] ; Right
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM1     ; (31-38)   Boats Right (row 17)

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (39)      One scan line 
	;                                                           DLI 4/BOAT2BOAT sets boats left (row 16) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (40)      One scan line free time for DLI

PF_LMS2 = [* + 1] ; Left
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM2+8   ; (41-48)   Boats Left (row 16)

; ========== 2

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (49)      One scan line 
	;                                                           DLI 5/BOAT2BEACH sets COLPF0,1,2,3,BK for Beach (row 15) 

PF_LMS3 = [* + 1]                                   ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM3         ; (50-57)   Beach. 
	;                                                           DLI 6/BEACH2BOAT sets boats right (row 14) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (58)      One scan line 

PF_LMS4 = [* + 1] ; Right
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM4+4   ; (59-66)   Boats Right (row 14)

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (67)      One scan line 
	;                                                           DLI 7/BOAT2BOAT sets boats left (row 13) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (68)      One scan line free time for DLI

PF_LMS5 = [* + 1] ; Left
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM5+12  ; (69-76)   Boats Left (row 13)

; ========== 3

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (77)      One scan line 
	;                                                           DLI 8/BOAT2BEACH sets COLPF0,1,2,3,BK for Beach (row 12) 

PF_LMS6 = [* + 1]                                   ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM6         ; (78-85)   Beach. 
	;                                                           DLI 9/BEACH2BOAT sets boats right (row 11) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (86)      One scan line 

PF_LMS7 = [* + 1] ; Right
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM7+4   ; (87-94)   Boats Right (row 11)

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (95)      One scan line 
	;                                                           DLI 10/BOAT2BOAT sets boats left (row 10) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (96)      One scan line free time for DLI

PF_LMS8 = [* + 1] ; Left
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM8+12  ; (97-104)  Boats Left (row 10)

; ========== 4

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (105)     One scan line 
	;                                                           DLI 11/BOAT2BEACH sets COLPF0,1,2,3,BK for Beach (row 9) 

PF_LMS9 = [* + 1]                                   ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM9         ; (106-113) Beach. 
	;                                                           DLI 12/BEACH2BOAT sets boats right (row 8) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (114)     One scan line 

PF_LMS10 = [* + 1] ; Right
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM10+8  ; (115-122) Boats Right (row 8)

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (123)     One scan line 
	;                                                           DLI 13/BOAT2BOAT sets boats left (row 7) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (124)     One scan line free time for DLI

PF_LMS11 = [* + 1] ; Left
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM11+12 ; (125-132) Boats Left (row 7)

; ========== 5

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (133)     One scan line 
	;                                                           DLI 14/BOAT2BEACH sets COLPF0,1,2,3,BK for Beach (row 6) 

PF_LMS12 = [* + 1]                                  ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM12        ; (134-141) Beach. 
	;                                                           DLI 15/BEACH2BOAT sets boats right (row 5) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (142)     One scan line 

PF_LMS13 = [* + 1] ; Right
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM13    ; (143-150) Boats Right (row 5)

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (151)     One scan line 
	;                                                           DLI 16/BOAT2BOAT sets boats left (row 4) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (152)     One scan line free time for DLI

PF_LMS14 = [* + 1] ; Left
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM14+4  ; (153-160) Boats Left (row 4)

; ========== 6

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (161)     One scan line 
	;                                                           DLI 17/BOAT2BEACH sets COLPF0,1,2,3,BK for Beach (row 3) 

PF_LMS15 = [* + 1]                                  ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM15        ; (162-169) Beach. 
	;                                                           DLI 18/BEACH2BOAT sets boats right (row 2) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (170)     One scan line 

PF_LMS16 = [* + 1] ; Right
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM16+8  ; (171-178) Boats Right (row 2)

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (179)     One scan line 
	;                                                           DLI 19/BOAT2BOAT sets boats left (row 1) COLPF0,1,2,3,BK,HSCROLL.
	.byte DL_BLANK_1                                ; (180)     One scan line free time for DLI

PF_LMS17 = [* + 1] ; Left
	mDL_LMS DL_TEXT_4|DL_HSCROLL,PLAYFIELD_MEM17+12 ; (181-188) Boats Left (row 1)

; ========== End Beach 

	mDL_LMS DL_MAP_C|DL_DLI,MODE_C_COLPF0           ; (189)     One scan line 
	;                                                           DLI 20/BOAT2BEACH sets COLPF0,1,2,3,BK for Beach (row 0) 

PF_LMS18 = [* + 1]                                  ;           Plus 1 is the address of the display list LMS
	mDL_LMS DL_TEXT_4|DL_DLI,PLAYFIELD_MEM18        ; (190-197) Beach. 
	;                                                           DLI 21/SPC2  then calls SPC2 to set COLPF2/COLBK Black

; ========== End 2

	.byte DL_BLANK_1                                ; (198)     One scan line 

	mDL_JMP DL_SCROLLING_CREDIT                     ; (199-206) End of display. No prompt for button. See Page 0 for the evil.



; Until some other eye candy improvement is conceived, these 
; three  graphics Display Lists are nearly identical with 
; the only difference as the bitmap shown in the graphics 
; section (and the main code color manipulation routines.)

; So, instead of three display lists, just use one.  The VBI
; will know which graphics memory address to use for the
; GFX_LMS in the display list.  And since all the bitmaps are
; in the same page only the LMS low byte needs to be updated.

; FROG SAVED screen, 200 scan lines....:
;    80 scan lines = 20 blank lines (by 4 scan lines each) of color cycling.
; +  24 scan lines = 6 lines (by 4 scan lines each) of big text.
; +  80 scan lines = 20 blank lines (by 4 scan lines each) of color cycling.
; +   8 scan lines = Press A Button Line of text
; +   8 scan lines = infinitely scrolling credit. 
; = 200 scan lines.

FROGSAVED_DISPLAYLIST
FROGDEAD_DISPLAYLIST
GAMEOVER_DISPLAYLIST
	.byte DL_BLANK_8|DL_DLI               ; Needed early to zero PM positions
	.byte DL_BLANK_8
	.byte DL_BLANK_3|DL_DLI               ; 20 blank scan lines. DLI 0/0 Set COLBK color

	.rept 20                              ; an empty line. times 20
		.byte DL_BLANK_4|DL_DLI           ; (1 - 80)  DLI 0/1 - 0/18 COLBK color, 
	.endr                                 ;           DLI 1/19 COLBK Title, COLPF0 gfx

GFX_LMS = [* + 1]                         ; Label the low byte of the LMS address.
	mDL_LMS DL_MAP_9|DL_DLI,FROGSAVE_MEM  ; (81-84)   DLI 1/20   COLPF0 gfx
	.byte DL_MAP_9|DL_DLI                 ; (85-88)   DLI 1/21   COLPF0 gfx
	.byte DL_MAP_9|DL_DLI                 ; (89-92)   DLI 1/22   COLPF0 gfx
	.byte DL_MAP_9|DL_DLI                 ; (93-96)   DLI 1/23   COLPF0 gfx
	.byte DL_MAP_9|DL_DLI                 ; (97-100)  DLI 1/24   COLPF0 gfx
	.byte DL_MAP_9|DL_DLI                 ; (101-104) DLI 0/25   COLBK Black

	.rept 20                              ; an empty line. times 20
		.byte DL_BLANK_4|DL_DLI           ; (105-184) DLI 0/26 - 0/43 COLBK color, 
	.endr                                 ;           DLI DLI SPC1/44 sets COLBK, COLPF2, COLPF1 colors.
	
	.byte DL_BLANK_1                      ; (191)     One scan line 
	
	mDL_JMP BOTTOM_OF_DISPLAY             ; End of display.  See Page 0 for the evil.

