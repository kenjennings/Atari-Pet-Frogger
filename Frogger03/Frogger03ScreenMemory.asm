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
; Version 03, June 2019
;
; --------------------------------------------------------------------------

; ==========================================================================
; Screen Memory
;
; The Atari OS text printing is not being used, therefore the Atari OS's
; screen editor's 24-line limitation is not an issue.  The game can be 
; 25 lines like the original Pet 4032 screen.  Or it can be more. 
; Sooooo, custom display list means do what we want.
;
; Prior versions used Mode 2 text lines exclusively to perpetuate the 
; flavor of the original's text-mode-based game.
; 
; However, Version 03 makes a few changes.  The chunky text used for the
; title and the dead/saved/game-over screens in V02 was built from Atari 
; graphics control characters.   Version 03 changes this to a graphics 
; mode that provides the same chunky-pixel size, but at only half the 
; memory for the same screen geometry.  Two lines of graphics is 
; vertically the same height as one line of text.  The V02 block 
; character patterns provide two apparent rows of pixels, so, everything 
; is equal.  
;
; Switching to a graphics mode for the big text allows:
; * Complete color expression for background and pixels. 
;   (Text mode 2 manages playfield and border colors differently.) 
; * Six lines of graphics in place of three lines of text makes it 
;   trivial to double the number of color changes in the big text.
;   Just a DLI for each line.
; * The background colors extend through the overscan area making 
;   a seemingly wider screen than the text mode with border. 
;  
; In Version 02 blank lines of mode 2 text were used and colored 
; to make animated prize displays.  Instead of using a text mode 
; we use actual blank lines instructions.  Again, since these display 
; background color into the overscan area the prize animations are 
; larger, filling the entire screen width.  Also, blanks smaller 
; than a text line allow more frequent color transitions.  Thus more 
; color on one display is more eye candy on one display.
;
; Remember, screen memory need not be contiguous from line to line.
; Therefore, we can re-think the declaration of screen contents and
; rearrange it in ways to benefit the code:
;
; 1) The first thing is that data declared for display on screen IS the
;    screen memory.  It is not something that must be copied to screen
;    memory.  Data properly placed in any memory makes it the actual
;    screen memory thanks to the Display List LMS instructions.
; 2) a) In the prior versions all the rows of boats moving left look 
;       the same, and all the rows moving right looked the same.  
;       Version 02 declared a copy of data for every line of boats.
;       This was necessary, because the frog was drawn in screen memory 
;       and must appear on every row.
;    b) But now, since the frog is a Player/Missile object there is no 
;       need to change the screen memory to draw the frog.   Therefore,
;       all the boat rows could be the same screen memory.  Declaring 
;       one row of left boats, and one row of right boats saves the 
;       contents of 10 more rows of the same.  This is actually a 
;       significant part of the executable size. 
;    c) Even if the same data is used for each type of boat, they do not 
;       need to appear identical on screen.   If each row has its own 
;       concept of current scroll value, then all the rows can be in 
;       different positions of scrolling, though using the same data.
; 3) Since scrolling is in effect the line width is whatever is needed 
;    to allow the boats to move from an original position to destination
;    and then return the the original scroll position.  If the boats 
;    and waves between them are identical then the entire line of boats 
;    does not need to be duplicated.  There only needs to be enough 
;    data to scroll from one boat position to the next boat's position.
; 3) Organizing the boats' row of graphics to sit within one page of data 
;    means scrolling updates and LMS math only need deal with the low
;    byte of addresses. 
; 3) To avoid wasting space the lines of data from other displays can be
;    dropped into the unused spaces between scrolling sections.
; --------------------------------------------------------------------------

ATASCII_HEART  = $00 ; heart graphics

; Atari uses different, "internal" values when writing to
; Screen RAM.  These are the internal codes for writing
; bytes directly to the screen:
INTERNAL_0        = $10 ; Number '0' for scores.
INTERNAL_SPACE    = $00 ; Blank space character.
;INTERNAL_HLINE    = $52 ; underline for title text.

;I_H = INTERNAL_HLINE

SIZEOF_LINE    = 39  ; That is, 40 - 1
SIZEOF_BIG_GFX = 119 ; That is, 120 - 1


; Display layouts and associated text blocks:

; Original V00 Title Screen and Instructions:
;    +----------------------------------------+
; 1  |              PET FROGGER               | INSTXT_1
; 2  |              --- -------               | INSTXT_1
; 3  |     (c) November 1983 by DalesOft      | INSTXT_1
; 4  |                                        |
; 5  |All you have to do is to get as many of | INSTXT_2
; 6  |the frogs across the river without      | INSTXT_2
; 7  |drowning them. You have to leap onto a  | INSTXT_2
; 8  |boat like this :- <QQQ] and land on the | INSTXT_2
; 9  |seats ('Q'). You get 10 points for every| INSTXT_2
; 10 |jump forward and 500 points every time  | INSTXT_2
; 11 |you get a frog across the river.        | INSTXT_2
; 12 |                                        |
; 13 |                                        |
; 14 |                                        |
; 15 |The controls are :-                     | INSTXT_3
; 16 |                 S = Up                 | INSTXT_3
; 17 |  4 = left                   6 = right  | INSTXT_3
; 18 |                                        |
; 19 |                                        |
; 20 |     Hit any key to start the game.     | INSTXT_4
; 21 |                                        |
; 22 |                                        |
; 23 |                                        |
; 24 |                                        |
; 25 |Atari V00 port by Ken Jennings, Nov 2018| PORTBYTEXT
;    +----------------------------------------+

;  Original V00 Main Game Play Screen:
;    +----------------------------------------+
; 1  |Successful Crossings =                  | SCORE_TXT
; 2  |Score = 00000000     Hi = 00000000  Lv:3| SCORE_TXT
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
; 29 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_6
; 20 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_6
; 21 |BBBBBBBBBBBBBBBBBBBOBBBBBBBBBBBBBBBBBBBB| TEXT2
; 22 |     (c) November 1983 by DalesOft      | TEXT2
; 23 |        Written by John C Dale          | TEXT2
; 24 |                                        |
; 25 |Atari V00 port by Ken Jennings, Nov 2018| PORTBYTEXT
;    +----------------------------------------+



; Revised V01 Title Screen and Instructions:
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

; Transition Title screen to Game Screen.
; Animate Credit lines down from Line 3 to Line 23.

; Revised V01 Main Game Play Screen:
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



; Revised V02 Title Screen and Instructions:
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

; Revised V02 Main Game Play Screen:
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; 3  |                                        |
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
; 23 |                                        |
; 24 |                                        |
; 25 |(c) November 1983 by DalesOft  Written b| SCROLLING CREDIT
;    +----------------------------------------+



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
; 14 |rivers. Land in the middle of the boats.| INSTXT_1
; 15 |Do not fall off or jump in the river.   | INSTXT_1
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

; Revised V03 Main Game Play Screen:
; FYI: Old boats.
; 8  | [QQQQ1        [QQQQ1       [QQQQ1      | TEXT1_2
; 9  |      <QQQQ0        <QQQQ0    <QQQQ0    | TEXT1_2
; New boats are larger to provide more safe surface for the larger 
; frog and to provide some additional graphics enhancement for 
; the boats.  Illustration below shows the entire memory needed 
; for scrolling.   Since boats on each row are identical, and 
; they are spaced equally, then scrolling only need move the 
; distance between two boats (16 chars), and then reset
; to the starting position. 
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; 3  |                                        | 
; 4  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_1
; 5  |[[QQQQQ1        [[QQQQQ1        [[QQQQQ1        [[QQQQQ1        | ; Boats Right
; 6  |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        | ; Boats Left
; 7  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_2
; 8  |[[QQQQQ1        [[QQQQQ1        [[QQQQQ1        [[QQQQQ1        |
; 9  |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 10 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_3
; 11 |[[QQQQQ1        [[QQQQQ1        [[QQQQQ1        [[QQQQQ1        |
; 12 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 13 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_4
; 14 |[[QQQQQ1        [[QQQQQ1        [[QQQQQ1        [[QQQQQ1        |
; 15 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 16 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_5
; 17 |[[QQQQQ1        [[QQQQQ1        [[QQQQQ1        [[QQQQQ1        |
; 18 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 19 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_6
; 20 |[[QQQQQ1        [[QQQQQ1        [[QQQQQ1        [[QQQQQ1        |
; 21 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 22 |BBBBBBBBBBBBBBBBBBBOBBBBBBBBBBBBBBBBBBBB| TEXT2
; 23 |                                        | 
; 24 |                                        |
; 25 |(c) November 1983 by DalesOft  Written b| SCROLLING CREDIT
;    +----------------------------------------+

; These things repeat four times.
; Let's just type it once and macro it elsewhere.

; 5  |[[QQQQQ1        [[QQQQQ1        [[QQQQQ1        [[QQQQQ1        | ; Boats Right
	.macro mBoatGoRight
		.by I_BOAT_RBW+$80 I_BOAT_RB+$80 I_BOAT_EMPTY I_SEATS_R3 I_SEATS_R2 I_SEATS_R1 I_BOAT_RFW+$80 I_BOAT_RF+$80 ;   8
		.by I_WATER1 I_WATER2 I_WATER3 I_WATER4 I_WATER1 I_WATER2 I_WATER3 I_WATER4                 ; + 8 = 16
	.endm

	.macro mLineOfRightBoats
		.rept 4
			mBoatGoRight ; 16 ] 4 = 64
		.endr
	.endm


; 6  |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        | ; Boats Left
	.macro mBoatGoLeft
		.by I_BOAT_LF+$80 I_BOAT_LFW+$80 I_SEATS_L1 I_SEATS_L2 I_SEATS_L3 I_BOAT_EMPTY I_BOAT_LB+$80 I_BOAT_LBW+$80 ;   8
		.by I_WATER1 I_WATER2 I_WATER3 I_WATER4 I_WATER1 I_WATER2 I_WATER3 I_WATER4                         ; + 8 = 16
	.endm

	.macro mLineOfLeftBoats
		.rept 4
			mBoatGoLeft ; 16 ] 4 = 64
		.endr
	.endm


; ANTIC has a 4K boundary for screen memory.
; But, since the visibly adjacent lines of screen data need not be
; contiguous in memory we can simply align screen data into 256
; byte pages only making sure a line doesn't cross the end of a 
; page.  This will prevent any line of displayed data from crossing 
; over a 4K boundary.


	.align $0100 ; Realign to next page.

; The declarations below are arranged to make sure
; each line of data fits within 256 byte pages.

; Remember, lines of screen data need not be contiguous to
; each other since LMS in the Display List tells ANTIC where to 
; start reading screen memory.  Therefore we can declare lines in
; any order....   Just remember to use LMS in the Display List 
; when data is not contiguous, OK.


; The lines of scrolling boats.  Only one line of data for each 
; direction is declared.  Every other moving row can re-use the 
; same data for display.  Also, since the entire data fits within 
; one page, the coarse scrolling need only update the low byte of 
; the LMS instruction....
 
; 5  |[[QQQQQ1        [[QQQQQ1        [[QQQQQ1        [[QQQQQ1        | ; Boats Right ;   64
; Start Scroll position = LMS + 12 (decrement), HSCROL 0  (Increment)
; End   Scroll position = LMS + 0,              HSCROL 15
PLAYFIELD_MEM1
PLAYFIELD_MEM4
PLAYFIELD_MEM7
PLAYFIELD_MEM10
PLAYFIELD_MEM13
PLAYFIELD_MEM16
	mLineOfRightBoats


; Title text.  Bit-mapped version for Mode 9.
; Will not scroll these, so no need for individual labels and leading blanks.
; 60 bytes here instead of the 240 bytes used for the scrolling text version.

; Graphics chars design, PET FROGGER
; |]]|]]|] |  |]]|]]|]]|  |]]|]]|]]|  |  |]]|]]|]]|  |]]|]]|] |  | ]|]]|] |  | ]|]]|]]|  | ]|]]|]]|  |]]|]]|]]|  |]]|]]|] |
; |]]|  |]]|  |]]|  |  |  |  |]]|  |  |  |]]|  |  |  |]]|  |]]|  |]]|  |]]|  |]]|  |  |  |]]|  |  |  |]]|  |  |  |]]|  |]]|
; |]]|  |]]|  |]]|]]|] |  |  |]]|  |  |  |]]|]]|] |  |]]|  |]]|  |]]|  |]]|  |]]|  |  |  |]]|  |  |  |]]|]]|] |  |]]|  |]]|
; |]]|]]|] |  |]]|  |  |  |  |]]|  |  |  |]]|  |  |  |]]|]]|] |  |]]|  |]]|  |]]| ]|]]|  |]]| ]|]]|  |]]|  |  |  |]]|]]|] |
; |]]|  |  |  |]]|  |  |  |  |]]|  |  |  |]]|  |  |  |]]| ]|] |  |]]|  |]]|  |]]|  |]]|  |]]|  |]]|  |]]|  |  |  |]]| ]|] |
; |]]|  |  |  |]]|]]|]]|  |  |]]|  |  |  |]]|  |  |  |]]|  |]]|  | ]|]]|] |  | ]|]]|]]|  | ]|]]|]]|  |]]|]]|]]|  |]]|  |]]|

TITLE_MEM1
	.by %11111000 %11111100 %11111100 %00111111 %00111110 %00011110 %00011111 %00011111 %00111111 %00111110
	.by %11001100 %11000000 %00110000 %00110000 %00110011 %00110011 %00110000 %00110000 %00110000 %00110011
	.by %11001100 %11111000 %00110000 %00111110 %00110011 %00110011 %00110000 %00110000 %00111110 %00110011
	.by %11111000 %11000000 %00110000 %00110000 %00111110 %00110011 %00110111 %00110111 %00110000 %00111110
	.by %11000000 %11000000 %00110000 %00110000 %00110110 %00110011 %00110011 %00110011 %00110000 %00110110
	.by %11000000 %11111100 %00110000 %00110000 %00110011 %00011110 %00011111 %00011111 %00111111 %00110011 ; + 60

; 4  |--- --- ---  --- --- --- --- --- --- ---| TITLE underline

	.by %11111100 %11111100 %11111100 %00111111 %00111111 %00111111 %00111111 %00111111 %00111111 %00111111 ; + 10 

ANYBUTTON_MEM ; Prompt to start game.
; 24 |   Press joystick button to continue.   | INSTXT_4 
	.sb "   Press joystick button to continue.   "

INSTRUCT_MEM1 ; Basic instructions...
; 6  |Help the frogs escape from Doc Hopper's | INSTXT_1
	.sb "Help the frogs escape from Doc Hopper's "

INSTRUCT_MEM2
; 7  |frog legs fast food franchise! But, the | INSTXT_1
	.sb "frog legs fast food franchise! But, the "


	.align $0100 ; Realign to next page.


; 6  |<QQQQQ00        <QQQQQ00        <QQQQQ00        <QQQQQ00        | ; Boats Left ; + 64 
; Start Scroll position = LMS + 0 (increment), HSCROL 15  (Decrement)
; End   Scroll position = LMS + 12,            HSCROL 0
PLAYFIELD_MEM2
PLAYFIELD_MEM5
PLAYFIELD_MEM8
PLAYFIELD_MEM11
PLAYFIELD_MEM14
PLAYFIELD_MEM17
	mLineOfLeftBoats

INSTRUCT_MEM3
; 8  |frogs must cross piranha-infested rivers| INSTXT_1
	.sb "frogs must cross piranha-infested rivers"

INSTRUCT_MEM4
; 9  |to reach freedom. You have three chances| INSTXT_1
	.sb "to reach freedom. You have three chances"

INSTRUCT_MEM5
; 10 |to prove your frog management skills by | INSTXT_1
	.sb "to prove your frog management skills by "

INSTRUCT_MEM6
; 11 |directing frogs to jump on boats in the | INSTXT_1
	.sb "directing frogs to jump on boats in the "


	.align $0100 ; Realign to next page.


; The Credit text.  Rather than three lines on the main
; and game screen let's make this a continuously scrolling
; line of text on all screens.  This requires two more blocks
; of blank text to space out the start and end of the text.

; Originally:
; 3  |     (c) November 1983 by DalesOft      | CREDIT
; 4  |        Written by John C Dale          | CREDIT
; 5  |Atari V02 port by Ken Jennings, Nov 2018| CREDIT
; 6  |                                        |

; Now:
SCROLLING_CREDIT   ; 40+52+62+57+40 == 251 ; almost a page, how nice.
BLANK_MEM ; Blank text also used for blanks in other places.
	.sb "                                        " ; 40

; The perpetrators identified...
	.sb "    PET FROGGER    (c) November 1983 by Dales" ATASCII_HEART "ft.   " ; 52

	.sb "Original program for CBM PET 4032 written by John C. Dale.    " ; 62

	.sb "Atari 8-bit computer port by Ken Jennings, V03, June 2019" ; 57

END_OF_CREDITS
EXTRA_BLANK_MEM ; Trailing blanks for credit scrolling.
	.sb "                                        " ; 40


	.align $0100  ; Realign to next page.


INSTRUCT_MEM7
; 12 |rivers like this:  <QQQQ00  Land only on| INSTXT_1
	.sb "rivers. Land in the middle of the boats."

INSTRUCT_MEM8
; 13 |the seats in the boats.                 | INSTXT_1
	.sb "Do not fall off or jump in the river.   "

SCORING_MEM1 ; Scoring
; 15 |Scoring:                                | INSTXT_2
	.sb "Scoring:                                "

SCORING_MEM2
; 16 |    10 points for each jump forward.    | INSTXT_2
	.sb "    10 points for each jump forward.    "

SCORING_MEM3
; 17 |   500 points for each rescued frog.    | INSTXT_2
	.sb "   500 points for each rescued frog.    "

CONTROLS_MEM1 ; Game Controls
; 19 |Use joystick control to jump forward,   | INSTXT_3
	.sb "Use joystick controller to move         "



	.align $0100  ; Realign to next page.


CONTROLS_MEM2
; 20 |left, and right.                        | INSTXT_3
	.sb "forward, left, and right.               "


; FROG SAVED screen.
; Graphics chars design, SAVED!
; |  |]]|]]|  |  | ]|] |  | ]|] | ]|] | ]|]]|]]|] | ]|]]|] |  |  |]]|
; | ]|] |  |  |  |]]|]]|  | ]|] | ]|] | ]|] |  |  | ]|] |]]|  |  |]]|
; |  |]]|]]|  | ]|] | ]|] | ]|] | ]|] | ]|]]|]]|  | ]|] | ]|] |  |]]|
; |  |  | ]|] | ]|] | ]|] | ]|] | ]|] | ]|] |  |  | ]|] | ]|] |  |]]|
; |  |  | ]|] | ]|]]|]]|] |  |]]|]]|  | ]|] |  |  | ]|] |]]|  |  |  |
; |  |]]|]]|  | ]|] | ]|] |  | ]|] |  | ]|]]|]]|] | ]|]]|] |  |  |]]|

; Another benefit of using the bitmap is it makes the data much more obvious. 
FROGSAVE_MEM   ; Graphics data, SAVED!  43 pixels.  40 - 21 == 19 blanks. 43 + 19 = 62.  + 18 = 80
	.by %00000000 %00000000 %00001111 %00000110 %00011001 %10011111 %10011110 %00001100 %00000000 %00000000
	.by %00000000 %00000000 %00011000 %00001111 %00011001 %10011000 %00011011 %00001100 %00000000 %00000000
	.by %00000000 %00000000 %00001111 %00011001 %10011001 %10011111 %00011001 %10001100 %00000000 %00000000
	.by %00000000 %00000000 %00000001 %10011001 %10011001 %10011000 %00011001 %10001100 %00000000 %00000000
	.by %00000000 %00000000 %00000001 %10011111 %10001111 %00011000 %00011011 %00000000 %00000000 %00000000
	.by %00000000 %00000000 %00001111 %00011001 %10000110 %00011111 %10011110 %00001100 %00000000 %00000000


; FROG DEAD screen.
; Graphics chars design, DEAD FROG!
; | ]|]]|] |  | ]|]]|]]|] |  | ]|] |  | ]|]]|] |  |  |  |  | ]|]]|]]|] | ]|]]|]]|  |  |]]|]]|  |  |]]|]]|] |  |]]|
; | ]|] |]]|  | ]|] |  |  |  |]]|]]|  | ]|] |]]|  |  |  |  | ]|] |  |  | ]|] | ]|] | ]|] | ]|] | ]|] |  |  |  |]]|
; | ]|] | ]|] | ]|]]|]]|  | ]|] | ]|] | ]|] | ]|] |  |  |  | ]|]]|]]|  | ]|] | ]|] | ]|] | ]|] | ]|] |  |  |  |]]|
; | ]|] | ]|] | ]|] |  |  | ]|] | ]|] | ]|] | ]|] |  |  |  | ]|] |  |  | ]|]]|]]|  | ]|] | ]|] | ]|] |]]|] |  |]]|
; | ]|] |]]|  | ]|] |  |  | ]|]]|]]|] | ]|] |]]|  |  |  |  | ]|] |  |  | ]|] |]]|  | ]|] | ]|] | ]|] | ]|] |  |  |
; | ]|]]|] |  | ]|]]|]]|] | ]|] | ]|] | ]|]]|] |  |  |  |  | ]|] |  |  | ]|] | ]|] |  |]]|]]|  |  |]]|]]|] |  |]]|

FROGDEAD_MEM   ; Graphics data, DEAD FROG!  (37) + 3 spaces.
	.by %00001111 %00001111 %11000011 %00001111 %00000000 %00111111 %00111110 %00011110 %00011111 %00011000
	.by %00001101 %10001100 %00000111 %10001101 %10000000 %00110000 %00110011 %00110011 %00110000 %00011000
	.by %00001100 %11001111 %10001100 %11001100 %11000000 %00111110 %00110011 %00110011 %00110000 %00011000
	.by %00001100 %11001100 %00001100 %11001100 %11000000 %00110000 %00111110 %00110011 %00110111 %00011000
	.by %00001101 %10001100 %00001111 %11001101 %10000000 %00110000 %00110110 %00110011 %00110011 %00000000
	.by %00001111 %00001111 %11001100 %11001111 %00000000 %00110000 %00110011 %00011110 %00011111 %00011000


; GAME OVER screen.
; Graphics chars design, GAME OVER
; |  |]]|]]|] |  | ]|] |  |]]|  | ]|] |]]|]]|]]|  |  |  |  |]]|]]|  | ]|] | ]|] | ]|]]|]]|] | ]|]]|]]|  |
; | ]|] |  |  |  |]]|]]|  |]]|] |]]|] |]]|  |  |  |  |  | ]|] | ]|] | ]|] | ]|] | ]|] |  |  | ]|] | ]|] |
; | ]|] |  |  | ]|] | ]|] |]]|]]|]]|] |]]|]]|] |  |  |  | ]|] | ]|] | ]|] | ]|] | ]|]]|]]|  | ]|] | ]|] |
; | ]|] |]]|] | ]|] | ]|] |]]| ]| ]|] |]]|  |  |  |  |  | ]|] | ]|] | ]|] | ]|] | ]|] |  |  | ]|]]|]]|  |
; | ]|] | ]|] | ]|]]|]]|] |]]|  | ]|] |]]|  |  |  |  |  | ]|] | ]|] |  |]]|]]|  | ]|] |  |  | ]|] |]]|  |
; |  |]]|]]|] | ]|] | ]|] |]]|  | ]|] |]]|]]|]]|  |  |  |  |]]|]]|  |  | ]|] |  | ]|]]|]]|] | ]|] | ]|] |

GAMEOVER_MEM ; Graphics data, Game Over.  (34) + 6 spaces.
	.by %00000000 %11111000 %01100011 %00011011 %11110000 %00001111 %00011001 %10011111 %10011111 %00000000
	.by %00000001 %10000000 %11110011 %10111011 %00000000 %00011001 %10011001 %10011000 %00011001 %10000000
	.by %00000001 %10000001 %10011011 %11111011 %11100000 %00011001 %10011001 %10011111 %00011001 %10000000
	.by %00000001 %10111001 %10011011 %01011011 %00000000 %00011001 %10011001 %10011000 %00011111 %00000000
	.by %00000001 %10011001 %11111011 %00011011 %00000000 %00011001 %10001111 %00011000 %00011011 %00000000
	.by %00000000 %11111001 %10011011 %00011011 %11110000 %00001111 %00000110 %00011111 %10011001 %10000000


	.align $0100 ; Realign to next page.


; Defining one line of 80 characters of Beach decorations.
; Each of the beach lines shows a 40 character subset of the larger line.
; This eliminates 5 lines worth of data.
 
PLAYFIELD_MEM0 ; Default display of "Beach", for lack of any other description, and the two lines of Boats
; 3  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_1
	.by I_BEACH1 I_BEACH2 I_BEACH3 I_BEACH4 I_BEACH5 I_BEACH6  I_BEACH7  I_BEACH8 
	.by I_BEACH1 I_BEACH2 I_BEACH3 I_BEACH4 I_BEACH5 I_ROCKS1L I_ROCKS1R I_BEACH8 
	.by I_BEACH1 I_BEACH2 I_BEACH3 I_BEACH4 I_BEACH5 I_BEACH6  I_ROCKS2  I_BEACH8 
	.by I_BEACH1 I_BEACH2 I_BEACH3 I_BEACH4 I_BEACH5 I_BEACH6  I_ROCKS3  I_BEACH8 
	.by I_BEACH1 I_BEACH2 I_BEACH3 I_BEACH4 I_BEACH5 I_BEACH6  I_ROCKS4  I_BEACH8
	.by I_BEACH1 I_BEACH2 I_BEACH3 I_BEACH4 I_BEACH5 I_BEACH6  I_BEACH7  I_BEACH8 
	.by I_BEACH1 I_BEACH2 I_BEACH3 I_BEACH4 I_BEACH5 I_BEACH6  I_ROCKS3  I_BEACH8 
	.by I_BEACH1 I_BEACH2 I_BEACH3 I_BEACH4 I_BEACH5 I_ROCKS1L I_ROCKS1R I_BEACH8 
	.by I_BEACH1 I_BEACH2 I_BEACH3 I_BEACH4 I_BEACH5 I_BEACH6  I_BEACH7  I_BEACH8 
	.by I_BEACH1 I_BEACH2 I_BEACH3 I_BEACH4 I_BEACH5 I_BEACH6  I_ROCKS4  I_BEACH8 ; "Beach"

PLAYFIELD_MEM3 = PLAYFIELD_MEM0+32 ; Default display of "Beach", for lack of any other description.

PLAYFIELD_MEM6 = PLAYFIELD_MEM0+20 ; Default display of "Beach", for lack of any other description.

PLAYFIELD_MEM9 = PLAYFIELD_MEM0+7 ; Default display of "Beach", for lack of any other description.

PLAYFIELD_MEM12 = PLAYFIELD_MEM0+29 ; Default display of "Beach", for lack of any other description.

PLAYFIELD_MEM15 = PLAYFIELD_MEM0+14 ; Default display of "Beach", for lack of any other description.

PLAYFIELD_MEM18 = PLAYFIELD_MEM0+23 ; One last line of Beach

; Two lines for Scores, lives, and frogs saved.

SCORE_MEM1 ; Labels for crossings counter, scores, and lives
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
	.by I_BS I_SC I_SO I_SR I_SE I_CO
SCREEN_MYSCORE
	.sb "00000000               "
SCREEN_HISCORE
	.sb "00000000"
	.by I_CO I_BH I_SI

SCORE_MEM2
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
	.by I_BF I_SR I_SO I_SG I_SS I_CO
SCREEN_LIVES
	.sb"0    "
	.by I_BF I_SR I_SO I_SG I_SS $00 I_BS I_BA I_SV I_SE I_SD I_CO
SCREEN_SAVED
	.sb "                 "

; Filler space for a Mode C line to show a line of COLPF0 between scrolling boat lines.
MODE_C_COLPF0
	.rept 20
		.by %11111111
	.endr


	.align $0100 ; Realign to next page.

; ==========================================================================
; Color Layouts for the screens.
; 23 lines of data each, not 25.
; Line 24 for the Press A Button Prompt and 
; line 25 for the scrolling credits are managed directly, by
; the VBI, so they do not need entries in the tables.
; --------------------------------------------------------------------------
; FYI from GTIA.asm:
; COLOR_ORANGE1 =      $10
; COLOR_ORANGE2 =      $20
; COLOR_RED_ORANGE =   $30
; COLOR_PINK =         $40
; COLOR_PURPLE =       $50
; COLOR_PURPLE_BLUE =  $60
; COLOR_BLUE1 =        $70
; COLOR_BLUE2 =        $80
; COLOR_LITE_BLUE =    $90
; COLOR_AQUA =         $A0
; COLOR_BLUE_GREEN =   $B0
; COLOR_GREEN =        $C0
; COLOR_YELLOW_GREEN = $D0
; COLOR_ORANGE_GREEN = $E0
; COLOR_LITE_ORANGE =  $F0

TITLE_BACK_COLORS ; 25 entries ; Mode 2, text background and border. Also the Gfx background.
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry. 
	.by COLOR_BLACK              ; Scores, and blank line
	.by COLOR_BLUE1        COLOR_PURPLE_BLUE+2      ; Title colors.  Dark to light... 
	.by COLOR_PURPLE+4     COLOR_PINK+6             ; Title lines
	.by COLOR_RED_ORANGE+8 COLOR_ORANGE2+10         ; Title lines
	.by COLOR_ORANGE1+12                            ; Title lines
	.by COLOR_BLACK                                 ; Space
	.by COLOR_AQUA COLOR_AQUA COLOR_AQUA COLOR_AQUA ; Instructions
	.by COLOR_AQUA COLOR_AQUA COLOR_AQUA COLOR_AQUA ; Instructions
	.by COLOR_BLACK                                 ; Space
	.by COLOR_ORANGE2 COLOR_ORANGE2 COLOR_ORANGE2   ; Scoring
	.by COLOR_BLACK                                 ; Space
	.by COLOR_PINK COLOR_PINK                       ; Controls

TITLE_TEXT_COLORS ; 25 entries ; Mode 2 Text luminance.  Also the Gfx pixel colors.
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.by $0E                                     ; Scores, and blank line
	.by $EC $DA $C8 $B6 $A4 $92 $C2                 ; title colors. light to dark
	.by $00                                         ; blank
	.by $04 $06 $08 $0A $0C $0A $08 $06             ; Instructions
	.by $00                                         ; blank
	.by $06 $08 $0a                                 ; Scoring
	.by $00                                         ; blank
	.by $08 $0A                                     ; controls



GAME_BACK_COLORS; 22 entries.
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.by COLOR_BLACK                   ; Scores
	.by COLOR_BLACK                   ; lives, saved frogs.
	
	.by COLOR_GREEN+6     ; Beach
	.by COLOR_AQUA+2      ; Water for boats
	.by COLOR_AQUA+4      ; Water for boats. 

	.by COLOR_RED_ORANGE+6
	.by COLOR_BLUE1+2     
	.by COLOR_BLUE1+4     ; Beach, boats, boats.

	.by COLOR_ORANGE2+6   
	.by COLOR_BLUE2+2     
	.by COLOR_BLUE2+4     ; Beach, boats, boats.

	.by COLOR_RED_ORANGE+6
	.by COLOR_LITE_BLUE+2 
	.by COLOR_LITE_BLUE+4 ; Beach, boats, boats.

	.by COLOR_ORANGE2+6   
	.by COLOR_BLUE1+2     
	.by COLOR_BLUE1+4     ; Beach, boats, boats.

	.by COLOR_GREEN+6 
	.by COLOR_AQUA+2      
	.by COLOR_AQUA+4     ; Beach, boats, boats.

	.by COLOR_ORANGE2+6                                    ; one last Beach.

	
GAME_COLPF0_COLORS; 22 entries
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.by COLOR_BLACK                   ; Scores
	.by COLOR_BLACK                   ; lives, saved frogs.

	.by COLOR_BLUE1     ; Beach sky
	.by COLOR_AQUA+4    ; Water top 1 with boats
	.by COLOR_AQUA+6    ; Water top 2 with boats

	.by COLOR_AQUA+6    ; Beach sky (water)
	.by COLOR_BLUE1+4
	.by COLOR_BLUE1+6     
	
	.by COLOR_BLUE1+6     ; Beach sky (water)
	.by COLOR_BLUE2+4    
	.by COLOR_BLUE2+6    
	
	.by COLOR_BLUE2+6     ; Beach sky (water)
	.by COLOR_LITE_BLUE+4
	.by COLOR_LITE_BLUE+6 
	
	.by COLOR_LITE_BLUE+6 ; Beach sky (water)
	.by COLOR_BLUE1+4    
	.by COLOR_BLUE1+6 
	
	.by COLOR_BLUE1+6     ; Beach sky (water)
	.by COLOR_AQUA+4
	.by COLOR_AQUA+6      
	
	.by COLOR_AQUA+6      ; Beach sky (water)

; beach color and the boats
GAME_COLPF1_COLORS ; 22 entries
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.by COLOR_BLACK+$e                        ; Scores
	.by COLOR_BLACK+$a                        ; lives, saved frogs.
	
	.by COLOR_GREEN+$8     ; beach 
	.by COLOR_PINK+$a        ; boat
	.by COLOR_PURPLE+$c      ; boat
	
	.by COLOR_RED_ORANGE+$8  ; beach
	.by COLOR_PURPLE_BLUE+$a
	.by COLOR_BLUE_GREEN+$c
	
	.by COLOR_ORANGE2+$8     ; beach
	.by COLOR_GREEN+$a
	.by COLOR_YELLOW_GREEN+$c
	
	.by COLOR_RED_ORANGE+$8  ; beach
	.by COLOR_ORANGE_GREEN+$a
	.by COLOR_LITE_ORANGE+$c
	
	.by COLOR_ORANGE2+$8     ; beach
	.by COLOR_ORANGE1+$a
	.by COLOR_ORANGE2+$c
	
	.by COLOR_GREEN+$8  ; beach
	.by COLOR_RED_ORANGE+$a
	.by COLOR_PINK+$c
	
	.by COLOR_ORANGE2+$8  ; Last beach

; beach color, and the lines on the boat.
GAME_COLPF2_COLORS ; 24 entries... ?????????????
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.by COLOR_BLACK                   ; Scores
	.by COLOR_BLACK                   ; lives, saved frogs.
	
	.by COLOR_GREEN+2                 ; beach
	.by COLOR_PINK+$4                 ; boat lines
	.by COLOR_PURPLE+$4               ; boat lines
	
	.by COLOR_RED_ORANGE+2            ; beach
	.by COLOR_PURPLE_BLUE+$4
	.by COLOR_BLUE_GREEN+$4
	
	.by COLOR_ORANGE2+2               ; beach
	.by COLOR_GREEN+$4
	.by COLOR_YELLOW_GREEN+$4
	
	.by COLOR_RED_ORANGE+2            ; beach
	.by COLOR_ORANGE_GREEN+$4
	.by COLOR_LITE_ORANGE+$4
	
	.by COLOR_ORANGE2+2               ; beach
	.by COLOR_ORANGE1+$4
	.by COLOR_ORANGE2+$4
	
	.by COLOR_GREEN+2            ; beach
	.by COLOR_RED_ORANGE+$4
	.by COLOR_PINK+$4
	
	.by COLOR_ORANGE2+2                 ; last beach

	.by COLOR_BLACK+$0E
	.by COLOR_BLACK+$0E


GAME_COLPF3_COLORS ; 22 entries.  Arg!  Tried to avoid this, but it is needed in order to do the fade/wipe
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.by COLOR_BLACK+$E                        ; Scores
	.by COLOR_BLACK+$a                        ; lives, saved frogs.
	
	.by COLOR_BLACK+$E ; beach
	.by COLOR_BLACK+$E
	.by COLOR_BLACK+$E
	
	.by COLOR_BLACK+$E ; beach
	.by COLOR_BLACK+$E
	.by COLOR_BLACK+$E
	
	.by COLOR_BLACK+$E ; beach
	.by COLOR_BLACK+$E
	.by COLOR_BLACK+$E
	
	.by COLOR_BLACK+$E ; beach
	.by COLOR_BLACK+$E
	.by COLOR_BLACK+$E
	
	.by COLOR_BLACK+$E ; beach
	.by COLOR_BLACK+$E
	.by COLOR_BLACK+$E
	
	.by COLOR_BLACK+$E ; beach
	.by COLOR_BLACK+$E
	.by COLOR_BLACK+$E
	
	.by COLOR_BLACK+$E ; Last beach


; COLOR_ORANGE1 =      $10
; COLOR_ORANGE2 =      $20
; COLOR_RED_ORANGE =   $30
; COLOR_PINK =         $40
; COLOR_PURPLE =       $50
; COLOR_PURPLE_BLUE =  $60
; COLOR_BLUE1 =        $70
; COLOR_BLUE2 =        $80
; COLOR_LITE_BLUE =    $90
; COLOR_AQUA =         $A0
; COLOR_BLUE_GREEN =   $B0
; COLOR_GREEN =        $C0
; COLOR_YELLOW_GREEN = $D0
; COLOR_ORANGE_GREEN = $E0
; COLOR_LITE_ORANGE =  $F0


DEAD_BACK_COLORS ; 47 entries.  Gfx background colors.
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.by COLOR_BLACK+0  COLOR_BLACK+2  COLOR_BLACK+4  COLOR_BLACK+6
	.by COLOR_BLACK+8  COLOR_BLACK+10 COLOR_BLACK+12 COLOR_BLACK+14
	.by COLOR_BLACK+0  COLOR_BLACK+2  COLOR_BLACK+4  COLOR_BLACK+6
	.by COLOR_BLACK+8  COLOR_BLACK+10 COLOR_BLACK+12 COLOR_BLACK+14
	.by COLOR_BLACK+0  COLOR_BLACK+2  COLOR_BLACK+4  COLOR_BLACK+6

	.by COLOR_GREEN COLOR_GREEN+2 COLOR_GREEN+4 COLOR_GREEN+6 COLOR_GREEN+8 COLOR_GREEN+10 

	.by COLOR_BLACK+8  COLOR_BLACK+10 COLOR_BLACK+12 COLOR_BLACK+14
	.by COLOR_BLACK+0  COLOR_BLACK+2  COLOR_BLACK+4  COLOR_BLACK+6
	.by COLOR_BLACK+8  COLOR_BLACK+10 COLOR_BLACK+12 COLOR_BLACK+14
	.by COLOR_BLACK+0  COLOR_BLACK+2  COLOR_BLACK+4  COLOR_BLACK+6
	.by COLOR_BLACK+8  COLOR_BLACK+10 COLOR_BLACK+12 COLOR_BLACK+14


DEAD_COLPF0_COLORS ; 47 entries.  Gfx pixel colors.
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.rept 20
		.by $00                                     ; Top Scroll.
	.endr

	.by COLOR_PINK+$0C COLOR_PINK+$0A COLOR_PINK+$08 COLOR_PINK+$06 COLOR_PINK+$04 COLOR_PINK+$02

	.rept 20
		.by $00                                     ; Bottom Scroll
	.endr


WIN_BACK_COLORS ; 47 entries.  Gfx background colors.
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	; Do not use $0x or $Fx for base color.
	.rept 20
		.by $00                                     ; Top Scroll.
	.endr

	.by $02 $04 $06 $08 $0A $0C ; Static white background

	.rept 20
		.by $00                                     ; Top Scroll.
	.endr


WIN_COLPF0_COLORS ; 47 entries.  Gfx pixel colors.
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.rept 20
		.by $00                                     ; Top Scroll.
	.endr
	; EOR first color of WIN_BACK+$80 (but not $0x or $Fx)
	.by $AE $AC $AA $A8 $A6 $A4

	.rept 20
		.by $00                                     ; Bottom Scroll
	.endr


OVER_BACK_COLORS  ; 47 entries.  Gfx background colors.
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.rept 20
		.by $00                                     ; Top Scroll.
	.endr

	.by  $00 $00 $00 $00 $00 $00 

	.rept 20
		.by $00                                     ; Bottom Scroll
	.endr

OVER_COLPF0_COLORS ; 47 entries.  Gfx pixel colors.
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.rept 20
		.by $00                                     ; Top Scroll.
	.endr

	.by $0E $0C $0A $08 $06 $04

	.rept 20
		.by $00                                     ; Bottom Scroll
	.endr


	.align $0100 ; Realign to next page.


; ==========================================================================
; Tables listing pointers to all the assets.
; --------------------------------------------------------------------------

; All Display lists fit in one page, so only only byte update is needed.
DISPLAYLIST_LO_TABLE  
	.byte <TITLE_DISPLAYLIST
	.byte <GAME_DISPLAYLIST
	.byte <FROGSAVED_DISPLAYLIST
	.byte <FROGDEAD_DISPLAYLIST
	.byte <GAMEOVER_DISPLAYLIST

DISPLAYLIST_HI_TABLE
	.byte >TITLE_DISPLAYLIST
	.byte >GAME_DISPLAYLIST
	.byte >FROGSAVED_DISPLAYLIST
	.byte >FROGDEAD_DISPLAYLIST
	.byte >GAMEOVER_DISPLAYLIST

DISPLAYLIST_GFXLMS_TABLE
	.byte $00, $00  ; no gfx pointer for title and game screen.
	.byte <FROGSAVE_MEM
	.byte <FROGDEAD_MEM
	.byte <GAMEOVER_MEM

DISPLAY_NEEDS_BORDERS_TABLE
	.byte 0 ; Title, no.
	.byte 1 ; Game, Yes.
	.byte 0 ; Saved, No.
	.byte 0 ; Dead, No.
	.byte 0 ; Over, No.

DLI_LO_TABLE  ; Address of first chained DLI per each screen.
	.byte <TITLE_DLI_CHAIN_TABLE ; DLI (0) -- Set colors for Scores.
	.byte <GAME_DLI_CHAIN_TABLE
	.byte <SPLASH_DLI_CHAIN_TABLE ; FROGSAVED_DLI
	.byte <SPLASH_DLI_CHAIN_TABLE ; FROGDEAD_DLI
	.byte <SPLASH_DLI_CHAIN_TABLE ; GAMEOVER_DLI

DLI_HI_TABLE
	.byte >TITLE_DLI_CHAIN_TABLE ; DLI sets COLPF1, COLPF2, COLBK for score text. 
	.byte >GAME_DLI_CHAIN_TABLE  ; DLI sets COLPF1, COLPF2, COLBK for score text. 
	.byte >SPLASH_DLI_CHAIN_TABLE ; FROGSAVED_DLI
	.byte >SPLASH_DLI_CHAIN_TABLE ; FROGDEAD_DLI
	.byte >SPLASH_DLI_CHAIN_TABLE ; GAMEOVER_DLI

	; GTIA GPRIOR varies by Display.
	; The VBI will manage the values based on the current Display List.
	; Tell GTIA the various Player/Missile options and color controls
	; Turn on 5th Player (Missiles COLPF3), Multicolor players, and 
	; Priority bits %0001 put 5th Player below regular Players. 
GPRIOR_TABLE
	.byte MULTICOLOR_PM|%0001              ; Title Screen
	.byte MULTICOLOR_PM|%0001              ; Game Screen uses P3/M3 to black left and right borders
	.byte 0                                ; Splash screen SAVED, no P/M
	.byte FIFTH_PLAYER|MULTICOLOR_PM|%0001 ; Splash screen DEAD - needs P5
	.byte 0                                ; Splash screen GAMEOVER, no P/M
	sta GPRIOR


TITLE_DLI_CHAIN_TABLE ; Low byte update to next DLI from the title display
	.byte <Score_DLI            ; DLI (0) Text - COLPF1, Black - COLBK COLPF2
	.byte <COLPF0_COLBK_DLI     ; DLI (1) Table - COLBK, Pixels - COLPF0
	.byte <COLPF0_COLBK_DLI     ; DLI 2   Table - COLBK, Pixels - COLPF0
	.byte <COLPF0_COLBK_DLI     ; DLI 3   Table - COLBK, Pixels - COLPF0
	.byte <COLPF0_COLBK_DLI     ; DLI 4   Table - COLBK, Pixels - COLPF0
	.byte <COLPF0_COLBK_DLI     ; DLI 5   Table - COLBK, Pixels - COLPF0
	.byte <COLPF0_COLBK_DLI     ; DLI 6   Table - COLBK, Pixels - COLPF0
	.byte <COLPF0_COLBK_DLI     ; DLI 7   Table - COLBK, Pixels - COLPF0
	.byte <TITLE_DLI_BLACKOUT   ; DLI 8   Black - COLBK COLPF2
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 9   Text - COLPF1, Table - COLBK COLPF2. - start instructions
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 10  Text - COLPF1
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 11  Text - COLPF1
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 12  Text - COLPF1
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 13  Text - COLPF1
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 14  Text - COLPF1
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 15  Text - COLPF1
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 16  Text - COLPF1 - end instructions.
	.byte <TITLE_DLI_BLACKOUT   ; DLI 17  Black - COLBK COLPF2
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 18  Text - COLPF1, Table - COLBK COLPF2. - start scoring
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 19  Text - COLPF1
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 20  Text - COLPF1 - end scoring
	.byte <TITLE_DLI_BLACKOUT   ; DLI 21  Black - COLBK COLPF2
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 22  Text - COLPF1, Table - COLBK COLPF2. - start controls
	.byte <TITLE_DLI_TEXTBLOCK  ; DLI 23  Text - COLPF1 - end controls
	.byte <TITLE_DLI_BLACKOUT   ; DLI 24  Black - COLBK COLPF2
	.byte <DLI_SPC1             ; DLI 25 Special DLI for Press Button Prompt will go to DLI SPC2 for Scrolling text.	
;	.byte <TITLE_DLI_SPC2       ; DLI 26 


GAME_DLI_CHAIN_TABLE    ; Low byte update to next DLI from the title display
	.byte <Score_DLI            ; DLI (0)   SCORES   - COLBK,                 COLPF1
	.byte <Score_DLI            ; DLI (1)   SCORES   - COLBK,                 COLPF1
	
	.byte <GAME_DLI_BEACH0      ; DLI (2)   Beach 18 - COLBK,         COLPF0, COLPF1, COLPF2, COLPF3.
	.byte <GAME_DLI_BEACH2BOAT  ; DLI (3)   Boats 17 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3
	.byte <GAME_DLI_BOAT2BOAT   ; DLI (4)   Boats 16 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3
	
	.byte <GAME_DLI_BOAT2BEACH  ; DLI (5)   Beach 15 - COLBK,         COLPF0, COLPF1, COLPF2, COLPF3
	.byte <GAME_DLI_BEACH2BOAT  ; DLI (6)   Boats 14 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3
	.byte <GAME_DLI_BOAT2BOAT   ; DLI (7)   Boats 13 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3

	.byte <GAME_DLI_BOAT2BEACH  ; DLI (8)   Beach 12 - COLBK,         COLPF0, COLPF1, COLPF2, COLPF3.
	.byte <GAME_DLI_BEACH2BOAT  ; DLI (9)   Boats 11 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3
	.byte <GAME_DLI_BOAT2BOAT   ; DLI (10)  Boats 10 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3

	.byte <GAME_DLI_BOAT2BEACH  ; DLI (11)  Beach 09 - COLBK,         COLPF0, COLPF1, COLPF2, COLPF3.
	.byte <GAME_DLI_BEACH2BOAT  ; DLI (12)  Boats 08 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3
	.byte <GAME_DLI_BOAT2BOAT   ; DLI (13)  Boats 07 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3

	.byte <GAME_DLI_BOAT2BEACH  ; DLI (14)  Beach 06 - COLBK,         COLPF0, COLPF1, COLPF2, COLPF3.
	.byte <GAME_DLI_BEACH2BOAT  ; DLI (15)  Boats 05 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3
	.byte <GAME_DLI_BOAT2BOAT   ; DLI (16)  Boats 04 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3

	.byte <GAME_DLI_BOAT2BEACH  ; DLI (17)  Beach 03 - COLBK,         COLPF0, COLPF1, COLPF2, COLPF3.
	.byte <GAME_DLI_BEACH2BOAT  ; DLI (18)  Boats 02 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3
	.byte <GAME_DLI_BOAT2BOAT   ; DLI (19)  Boats 01 - COLBK, HSCROL, COLPF0, COLPF1, COLPF2, COLPF3

	.byte <GAME_DLI_BOAT2BEACH   ; DLI (20)  Beach 00 - COLBK,         COLPF0, COLPF1, COLPF2, COLPF3.
	.byte <DLI_SPC2   ; DLI (21)  Credits  - Set scrolling credits HSCROL.  Set colors.


; All three graphics screens use the same list.
; Basically, the background color is updated per every line
SPLASH_DLI_CHAIN_TABLE ; Low byte update to next DLI from the title display
	.byte <COLPF0_COLBK_DLI     ; DLI (0)  ; VBI uses for initializing DLI.

	.byte <COLPF0_COLBK_DLI     ; DLI (1)  1
	.byte <COLPF0_COLBK_DLI     ; DLI (2)  2
	.byte <COLPF0_COLBK_DLI     ; DLI (3)  3
	.byte <COLPF0_COLBK_DLI     ; DLI (4)  4
	.byte <COLPF0_COLBK_DLI     ; DLI (5)  5
	.byte <COLPF0_COLBK_DLI     ; DLI (6)  6
	.byte <COLPF0_COLBK_DLI     ; DLI (7)  7
	.byte <COLPF0_COLBK_DLI     ; DLI (8)  8
	.byte <COLPF0_COLBK_DLI     ; DLI (9)  9
	.byte <COLPF0_COLBK_DLI     ; DLI (10) 10
	.byte <COLPF0_COLBK_DLI     ; DLI (11) 11
	.byte <COLPF0_COLBK_DLI     ; DLI (12) 12
	.byte <COLPF0_COLBK_DLI     ; DLI (13) 13
	.byte <COLPF0_COLBK_DLI     ; DLI (14) 14
	.byte <COLPF0_COLBK_DLI     ; DLI (15) 15
	.byte <COLPF0_COLBK_DLI     ; DLI (16) 16
	.byte <COLPF0_COLBK_DLI     ; DLI (17) 17
	.byte <COLPF0_COLBK_DLI     ; DLI (18) 18
	.byte <COLPF0_COLBK_DLI     ; DLI (19) 19
	.byte <COLPF0_COLBK_DLI     ; DLI (20) 20

	.byte <COLPF0_COLBK_DLI     ; DLI (21) 1 Splash Graphics
	.byte <COLPF0_COLBK_DLI     ; DLI (22) 2 Splash Graphics
	.byte <COLPF0_COLBK_DLI     ; DLI (23) 3 Splash Graphics
	.byte <COLPF0_COLBK_DLI     ; DLI (24) 4 Splash Graphics
	.byte <COLPF0_COLBK_DLI     ; DLI (25) 5 Splash Graphics
	.byte <COLPF0_COLBK_DLI     ; DLI (26) 6 Splash Graphics

	.byte <COLPF0_COLBK_DLI     ; DLI (27) 20 
	.byte <COLPF0_COLBK_DLI     ; DLI (28) 19 
	.byte <COLPF0_COLBK_DLI     ; DLI (29) 18 
	.byte <COLPF0_COLBK_DLI     ; DLI (30) 17 
	.byte <COLPF0_COLBK_DLI     ; DLI (31) 16 
	.byte <COLPF0_COLBK_DLI     ; DLI (32) 15 
	.byte <COLPF0_COLBK_DLI     ; DLI (33) 14
	.byte <COLPF0_COLBK_DLI     ; DLI (34) 13
	.byte <COLPF0_COLBK_DLI     ; DLI (35) 12
	.byte <COLPF0_COLBK_DLI     ; DLI (36) 11
	.byte <COLPF0_COLBK_DLI     ; DLI (37) 10
	.byte <COLPF0_COLBK_DLI     ; DLI (38) 9
	.byte <COLPF0_COLBK_DLI     ; DLI (39) 8
	.byte <COLPF0_COLBK_DLI     ; DLI (40) 7
	.byte <COLPF0_COLBK_DLI     ; DLI (41) 6
	.byte <COLPF0_COLBK_DLI     ; DLI (42) 5
	.byte <COLPF0_COLBK_DLI     ; DLI (43) 4
	.byte <COLPF0_COLBK_DLI     ; DLI (44) 3
	.byte <COLPF0_COLBK_DLI     ; DLI (45) 2
;	.byte <COLPF0_COLBK_DLI     ; DLI (46) 1

	.byte <DLI_SPC1             ; DLI 47 - Special DLI for Press Button Prompt will go to the next DLI for Scrolling text.
;	.byte <DLI_SPC2_SetCredits  ; DLI 48 - Set black background and white text for scrolling credits


; Color tables must be big enough to contain data up to the maximum DLI index that
; occurs of all the screens. 
; COLPF3 is white all the time.

COLBK_TABLE ; Must be big enough to do splash screens. +1 for entry 0
	.ds 47

COLPF0_TABLE ; Must be big enough to do splash screens. +1 for entry 0
	.ds 47

COLPF1_TABLE ; Must be big enough to do Title screen. 
	.ds 25

COLPF2_TABLE ; Must be big enough to do Title screen.
	.ds 25

COLPF3_TABLE ; Must be big enough to do Game screen.
	.by $0E $0E $0E $0E $0E
	.by $0E $0E $0E $0E $0E
	.by $0E $0E $0E $0E $0E
	.by $0E $0E $0E $0E $0E
	.by $0E $0E

HSCROL_TABLE ; Must be big enough to do Game screen up to  last boat row. (21 entries)
	.by 0 ; Entry 0 in the DLI list was indexed through by VBI to start the first entry.
	.by 0 0 0 ; Top, scores, beach
	.by 0 14
	.by 0 ; beach
	.by 2 12
	.by 0 ; beach
	.by 4 10
	.by 0 ; beach
	.by 6 8
	.by 0 ; beach
	.by 8 6
	.by 0 ; beach
	.by 10 4

;PXPF_TABLE ; Big enough for game area for Frog.
;	.ds 22

COLOR_BACK_LO_TABLE
	.byte <TITLE_BACK_COLORS
	.byte <GAME_BACK_COLORS
	.byte <WIN_BACK_COLORS
	.byte <DEAD_BACK_COLORS
	.byte <OVER_BACK_COLORS

COLOR_BACK_HI_TABLE
	.byte >TITLE_BACK_COLORS
	.byte >GAME_BACK_COLORS
	.byte >WIN_BACK_COLORS
	.byte >DEAD_BACK_COLORS
	.byte >OVER_BACK_COLORS

COLOR_TEXT_LO_TABLE
	.byte <TITLE_TEXT_COLORS
	.byte <GAME_COLPF1_COLORS
	.byte <WIN_COLPF0_COLORS
	.byte <DEAD_COLPF0_COLORS
	.byte <OVER_COLPF0_COLORS

COLOR_TEXT_HI_TABLE
	.byte >TITLE_TEXT_COLORS
	.byte >GAME_COLPF1_COLORS
	.byte >WIN_COLPF0_COLORS
	.byte >DEAD_COLPF0_COLORS
	.byte >OVER_COLPF0_COLORS


; List of pointers to the animation character shapes for the boats.

; R I G H T 

RIGHT_BOAT_WATER_LOW ; Front wave of boat
	.byte <[RIGHT_BOAT_WATER_ANIM]
	.byte <[RIGHT_BOAT_WATER_ANIM+8]
	.byte <[RIGHT_BOAT_WATER_ANIM+16]
	.byte <[RIGHT_BOAT_WATER_ANIM+24]
	.byte <[RIGHT_BOAT_WATER_ANIM+32]
	.byte <[RIGHT_BOAT_WATER_ANIM+40]
	.byte <[RIGHT_BOAT_WATER_ANIM+48]
	.byte <[RIGHT_BOAT_WATER_ANIM+56]

RIGHT_BOAT_WATER_HIGH
	.byte >[RIGHT_BOAT_WATER_ANIM]
	.byte >[RIGHT_BOAT_WATER_ANIM+8]
	.byte >[RIGHT_BOAT_WATER_ANIM+16]
	.byte >[RIGHT_BOAT_WATER_ANIM+24]
	.byte >[RIGHT_BOAT_WATER_ANIM+32]
	.byte >[RIGHT_BOAT_WATER_ANIM+40]
	.byte >[RIGHT_BOAT_WATER_ANIM+48]
	.byte >[RIGHT_BOAT_WATER_ANIM+56]

RIGHT_BOAT_FRONT_LOW ; Front of Boat.
	.byte <[RIGHT_BOAT_FRONT_ANIM]   
	.byte <[RIGHT_BOAT_FRONT_ANIM]
	.byte <[RIGHT_BOAT_FRONT_ANIM+8] ; switch on 2
	.byte <[RIGHT_BOAT_FRONT_ANIM+8]
	.byte <[RIGHT_BOAT_FRONT_ANIM+8]
	.byte <[RIGHT_BOAT_FRONT_ANIM+8]
	.byte <[RIGHT_BOAT_FRONT_ANIM]  ; switch on 6
	.byte <[RIGHT_BOAT_FRONT_ANIM]

RIGHT_BOAT_FRONT_HIGH
	.byte >[RIGHT_BOAT_FRONT_ANIM]
	.byte >[RIGHT_BOAT_FRONT_ANIM]
	.byte >[RIGHT_BOAT_FRONT_ANIM+8]
	.byte >[RIGHT_BOAT_FRONT_ANIM+8]
	.byte >[RIGHT_BOAT_FRONT_ANIM+8]
	.byte >[RIGHT_BOAT_FRONT_ANIM+8]
	.byte >[RIGHT_BOAT_FRONT_ANIM]
	.byte >[RIGHT_BOAT_FRONT_ANIM]

RIGHT_BOAT_WAKE_LOW
	.byte <[RIGHT_BOAT_WAKE_ANIM]
	.byte <[RIGHT_BOAT_WAKE_ANIM+8]
	.byte <[RIGHT_BOAT_WAKE_ANIM+16]
	.byte <[RIGHT_BOAT_WAKE_ANIM+24]
	.byte <[RIGHT_BOAT_WAKE_ANIM+32]
	.byte <[RIGHT_BOAT_WAKE_ANIM+40]
	.byte <[RIGHT_BOAT_WAKE_ANIM+48]
	.byte <[RIGHT_BOAT_WAKE_ANIM+56]

RIGHT_BOAT_WAKE_HIGH
	.byte >[RIGHT_BOAT_WAKE_ANIM]
	.byte >[RIGHT_BOAT_WAKE_ANIM+8]
	.byte >[RIGHT_BOAT_WAKE_ANIM+16]
	.byte >[RIGHT_BOAT_WAKE_ANIM+24]
	.byte >[RIGHT_BOAT_WAKE_ANIM+32]
	.byte >[RIGHT_BOAT_WAKE_ANIM+40]
	.byte >[RIGHT_BOAT_WAKE_ANIM+48]
	.byte >[RIGHT_BOAT_WAKE_ANIM+56]

; L E F T 

LEFT_BOAT_WATER_LOW
	.byte <[LEFT_BOAT_WATER_ANIM]
	.byte <[LEFT_BOAT_WATER_ANIM+8]
	.byte <[LEFT_BOAT_WATER_ANIM+16]
	.byte <[LEFT_BOAT_WATER_ANIM+24]
	.byte <[LEFT_BOAT_WATER_ANIM+32]
	.byte <[LEFT_BOAT_WATER_ANIM+40]
	.byte <[LEFT_BOAT_WATER_ANIM+48]
	.byte <[LEFT_BOAT_WATER_ANIM+56]

LEFT_BOAT_WATER_HIGH
	.byte >[LEFT_BOAT_WATER_ANIM]
	.byte >[LEFT_BOAT_WATER_ANIM+8]
	.byte >[LEFT_BOAT_WATER_ANIM+16]
	.byte >[LEFT_BOAT_WATER_ANIM+24]
	.byte >[LEFT_BOAT_WATER_ANIM+32]
	.byte >[LEFT_BOAT_WATER_ANIM+40]
	.byte >[LEFT_BOAT_WATER_ANIM+48]
	.byte >[LEFT_BOAT_WATER_ANIM+56]
	
LEFT_BOAT_FRONT_LOW
	.byte <[LEFT_BOAT_FRONT_ANIM]
	.byte <[LEFT_BOAT_FRONT_ANIM]
	.byte <[LEFT_BOAT_FRONT_ANIM+8] ; switch on 2
	.byte <[LEFT_BOAT_FRONT_ANIM+8]
	.byte <[LEFT_BOAT_FRONT_ANIM+8]
	.byte <[LEFT_BOAT_FRONT_ANIM+8]
	.byte <[LEFT_BOAT_FRONT_ANIM]  ; switch on 6
	.byte <[LEFT_BOAT_FRONT_ANIM]

LEFT_BOAT_FRONT_HIGH
	.byte >[LEFT_BOAT_FRONT_ANIM]
	.byte >[LEFT_BOAT_FRONT_ANIM]
	.byte >[LEFT_BOAT_FRONT_ANIM+8]
	.byte >[LEFT_BOAT_FRONT_ANIM+8]
	.byte >[LEFT_BOAT_FRONT_ANIM+8]
	.byte >[LEFT_BOAT_FRONT_ANIM+8]
	.byte >[LEFT_BOAT_FRONT_ANIM]
	.byte >[LEFT_BOAT_FRONT_ANIM]

LEFT_BOAT_WAKE_LOW
	.byte <[LEFT_BOAT_WAKE_ANIM]
	.byte <[LEFT_BOAT_WAKE_ANIM+8]
	.byte <[LEFT_BOAT_WAKE_ANIM+16]
	.byte <[LEFT_BOAT_WAKE_ANIM+24]
	.byte <[LEFT_BOAT_WAKE_ANIM+32]
	.byte <[LEFT_BOAT_WAKE_ANIM+40]
	.byte <[LEFT_BOAT_WAKE_ANIM+48]
	.byte <[LEFT_BOAT_WAKE_ANIM+56]

LEFT_BOAT_WAKE_HIGH
	.byte >[LEFT_BOAT_WAKE_ANIM]
	.byte >[LEFT_BOAT_WAKE_ANIM+8]
	.byte >[LEFT_BOAT_WAKE_ANIM+16]
	.byte >[LEFT_BOAT_WAKE_ANIM+24]
	.byte >[LEFT_BOAT_WAKE_ANIM+32]
	.byte >[LEFT_BOAT_WAKE_ANIM+40]
	.byte >[LEFT_BOAT_WAKE_ANIM+48]
	.byte >[LEFT_BOAT_WAKE_ANIM+56]


; ==========================================================================
; PLAYER/MISSILE GRAPHICS
;
; --------------------------------------------------------------------------
; VBI manages moving Frog around, so there's never any visible tearing.
; Also, its best to evaluate the P/M collisions when the display is not active.

MIN_FROGX = PLAYFIELD_LEFT_EDGE_NORMAL    ; Left edge of frog movement
MAX_FROGX = PLAYFIELD_RIGHT_EDGE_NORMAL-8 ; right edge of frog movement
MID_FROGX = [MIN_FROGX+MAX_FROGX]/2       ; Middle of screen, starting position.

MAX_FROGY = PM_1LINE_NORMAL_BOTTOM-15     ; starting position for frog at bottom of screen

OFF_FROGX = 84                            ; Offset for frog X coordinates on title animation.
OFF_FROGY = 75                            ; Offset for frog Y coordinates on title animation.
OFF_TOMBX = 84                            ; Offset for tomb X coordinates on game over animation.
OFF_TOMBY = 75                            ; Offset for tomb Y coordinates on game over animation.

; List of Player/Missile shapes.
SHAPE_OFF   = 0
SHAPE_FROG  = 1
SHAPE_SPLAT = 2
SHAPE_TOMB  = 3


	.align $0800 ; single line P/M needs 2K boundary.

PMADR

MISSILEADR = PMADR+$300
PLAYERADR0 = PMADR+$400
PLAYERADR1 = PMADR+$500
PLAYERADR2 = PMADR+$600
PLAYERADR3 = PMADR+$700


; The first three pages of P/M memory are free, so plenty of space
; to lay out the simple and mostly un-animated frog stuff.

; P0 = Left part of Frog.
; P1 = Right part of frog, mouth, and the eyeballs.
; P2 = Whites of the eyes.

; P3/M3 = Black (On game screen the left and right masks.)
;               (On Dead screen the "RIP" on the tomb)
;               (unused on Main, Win, and GameOver.)

; HPOS changes:
; P0 == X
; P1 == X+1
; P2 == X+1

; . - ] + . - ] + .
; . - ] ] ] ] ] + .
; - W W W ] W W W +
; - W B W ] W B W +
; - W W W ] W W W +
; - ] ] ] ] ] ] ] +
; . - ] ] ] ] ] + .
; . - ] + + + ] + .
; . - ] ] ] ] ] + .
; . . - ] ] ] + . .
; . . . - ] + . . .

; Players 0, 1 Are the greens of the Frog.
; P0                 P1
; . 0 0 . . 0 0 .    . 1 1 . . 1 1 .  - 0   66  66
; 0 0 0 0 0 0 0 .    . 1 1 1 1 1 1 1  - 1   FE  7F
; 0 . . . 0 . . .    . . . 1 . . . 1  - 2   88  11
; 0 . . . 0 . . .    . . . 1 . . . 1  - 3   88  11
; 0 . . . 0 . . .    . . . 1 . . . 1  - 4   88  11
; 0 0 0 0 0 0 0 0    1 1 1 1 1 1 1 1  - 5   FF  FF
; 0 0 0 0 0 0 0 0    1 1 1 1 1 1 1 1  - 6   FF  FF
; 0 0 . . . . . 0    1 1 1 1 1 1 1 1  - 7   C1  FF
; 0 0 0 . . . 0 0    1 1 1 1 1 1 1 1  - 8   E3  FF
; . 0 0 0 0 0 0 .    . 1 1 1 1 1 1 .  - 9   7E  7E
; . . 0 0 0 0 . .    . . 1 1 1 1 . .  - 10  3C  3C

PLAYER0_FROG_DATA 
	.by $66 $FE $88 $88 $88 $FF $FF $C1 $E3 $7E $3c

PLAYER1_FROG_DATA
	.by $66 $7F $11 $11 $11 $FF $FF $FF $FF $7E $3C

; Player 2 is the white eyes.
; 2 2 2 . 2 2 2 . 
PLAYER2_FROG_DATA  ; at Y+2 to Y+4
	.by $00 $00 $ee $ee $ee $00 $00 $00 $00 $00 $00

; Using 4 bytes here instead of 3 to eliminate another address lookup table.
; The 4th byte is the same for all instances.
; Eye positions:
;  - 3 -
;  0 1 2
;  - - -

; 0 . . . 0 . . .    . . . 1 . . . 1  - 3   88  11
; 0 . . . 0 . . .    1 . . 1 1 . . 1  - 2   88  99
; 0 . . . 0 . . .    . . . 1 . . . 1  - 4   88  11
; 0 0 0 0 0 0 0 .    1 1 1 1 1 1 1 1  - 5   FE  FF  

; 0 . . . 0 . . .    . . . 1 . . . 1  - 2   88  11
; 0 . . . 0 . . .    . 1 . 1 . 1 . 1  - 3   88  55
; 0 . . . 0 . . .    . . . 1 . . . 1  - 4   88  11
; 0 0 0 0 0 0 0 .    1 1 1 1 1 1 1 1  - 5   FE  FF  

; 0 . . . 0 . . .    . . . 1 . . . 1  - 3   88  11
; 0 . . . 0 . . .    . . 1 1 . . 1 1  - 2   88  33
; 0 . . . 0 . . .    . . . 1 . . . 1  - 4   88  11
; 0 0 0 0 0 0 0 .    1 1 1 1 1 1 1 1  - 5   FE  FF  

; 0 . . . 0 . . .    . 1 . 1 . 1 . 1  - 2   88  55
; 0 . . . 0 . . .    . . . 1 . . . 1  - 3   88  11
; 0 . . . 0 . . .    . . . 1 . . . 1  - 4   88  11
; 0 0 0 0 0 0 0 .    1 1 1 1 1 1 1 1  - 5   FE  FF  

PLAYER1_EYE_DATA
	.by $11 $99 $11 $FF
	.by $11 $55 $11 $FF
	.by $11 $33 $11 $FF
	.by $55 $11 $11 $FF

;PLAYER1_EYE_OFFSET ; Image number * 4 -1
;	.by 3 7 11 15

	
	
; The small frog parts are padded to minimum 3 bytes so they 
; can be redrawn in a common loop.

;; Player 3 is the mouth.
;; 3 . . . 3 . . .
;; 3 3 . 3 3 . . .
;; . 3 3 3 . . . .

;PLAYER3_FROG_DATA
;	.by $00 $00 $00 $00 $00 $00 $00 $63 $3E $1C $00

; Player 5 (the Missile, M3) is COLPF3, White. +1 
; 1 1 . . . . . .  ; 
; 1 1 . . . . . .  ; 
; 1 1 . . . . . .  ;
; Player 5 (the Missile, M2) is COLPF3, White. +3
; . . 1 . . . . .  ; 
; . . 1 . . . . .  ; 
; . . 1 . . . . .  ;
; Player 5 (the Missile, M1) is COLPF3, White.+5
; . . . . 1 1 . .  ; 
; . . . . 1 1 . .  ; 
; . . . . 1 1 . .  ; 
; Player 5 (the Missile, M0) is COLPF3, White.+7
; . . . . . . 1 .  ; 
; . . . . . . 1 .  ; 
; . . . . . . 1 .  ; 

; Data for Player 3 and Missile 3 is $C0 to draw the vertical 
; mask for the left and right sides of the game display.
; At quad width that will cover 8 color clocks/2 characters.

PLAYER5_FROG_DATA 
	.by $C0 $C0 $C0 $C0 $C0 $0C0 $C0 $C0 $C0 $C0 $C0



; Splatty Frog
; P0                 P1
; . 0 0 .  . . 0 0    . 1 1 .  . . 1 1  - 0
; 0 0 0 0  . 0 0 0    1 1 1 1  . 1 1 1  - 1
; 0 0 0 0  . 0 0 0    1 1 1 1  . 1 1 1  - 2
; . 0 0 0  . 0 0 .    . 1 1 1  . 1 1 .  - 3
; . . . 0  0 0 . .    . . . 1  1 1 . .  - 4
; 0 0 . 0  0 0 0 0    1 1 . 1  1 1 1 1  - 5
; . 0 0 0  0 0 . .    . 1 1 1  1 1 . .  - 6
; . 0 0 0  0 0 . .    . 1 1 1  1 1 . .  - 7
; 0 0 0 .  . 0 0 .    1 1 1 .  . 1 1 .  - 8 
; 0 0 0 .  . 0 0 0    1 1 1 .  . 1 1 1  - 9 
; . . . .  . 0 0 .    . . . .  . 1 1 .  - 10

PLAYER0_SPLATTER_DATA
	.by $63 $F7 $F7 $76 $1C $DF $7C $7C $E6 $E7 $06

PLAYER1_SPLATTER_DATA
	.by $63 $F7 $F7 $76 $1C $DF $7C $7C $E6 $E7 $06


; HPOS changes:
; P0 == X
; P1 == X+7
; P2 == X+5
; P3 == X+4
; M0 == X+2

; Interred Frog for Game Over
; . . . . . . . . ~ . . . . . .  - 1
; . . . . . . . ~ ~ ~ . . . . .  - 2
; . . . . . . . . ~ . . . . . .  - 3
; . . . . . . . . ~ . . . . . .  - 4
; . . . > > > > > ~ . . . . . .  - 5 
; . . > > > > ~ ~ ~ ~ ~ . . . .  - 6
; . > > > > ~ ~ ~ ~ ~ ~ ~ . . .  - 7
; . > > > ~ ~ ~ ~ ~ ~ ~ ~ ~ . .  - 8
; > > > ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ .  - 9
; > > > ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ .  - 10
; > > ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  - 11
; > > ~ ~ ] ] ~ ~ ] ~ ] ] ~ ~ ~  - 12
; > > ~ ~ ] ~ ] ~ ] ~ ] ~ ] ~ ~  - 13
; > > ~ ~ ] ] ~ ~ ] ~ ] ] ~ ~ ~  - 14
; > > ~ ~ ] ] ~ ~ ] ~ ] ~ ~ ~ ~  - 15
; > > ~ ~ ] ~ ] ~ ] ~ ] ~ ~ ~ ~  - 16
; > > ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  - 17
; > > ~ ~ ~ ~ ] ] ] ] ] ~ ~ ~ ~  - 18
; > > ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  - 19
; > > ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  - 20 
; > > ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  - 21
; . > ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  - 22
; . . ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  - 23

; P0 - Darker grey shadow.
; | . . . . | . . . . . . . . . . .  - 1  $00
; | . . . . | . . . . . . . . . . .  - 2  $00
; | . . . . | . . . . . . . . . . .  - 3  $00
; | . . . . | . . . . . . . . . . .  - 4  $00
; | . . . > | > > > > . . . . . . .  - 5  $1F
; | . . > > | > > . . . . . . . . .  - 6  $3C
; | . > > > | > . . . . . . . . . .  - 7  $78
; | . > > > | . . . . . . . . . . .  - 8  $70
; | > > > . | . . . . . . . . . . .  - 9  $E0
; | > > > . | . . . . . . . . . . .  - 10 $E0
; | > > . . | . . . . . . . . . . .  - 11 $C0
; | > > . . | . . . . . . . . . . .  - 12 $C0
; | > > . . | . . . . . . . . . . .  - 13 $C0
; | > > . . | . . . . . . . . . . .  - 14 $C0
; | > > . . | . . . . . . . . . . .  - 15 $C0
; | > > . . | . . . . . . . . . . .  - 16 $C0
; | > > . . | . . . . . . . . . . .  - 17 $C0
; | > > . . | . . . . . . . . . . .  - 18 $C0
; | > > . . | . . . . . . . . . . .  - 19 $C0
; | > > . . | . . . . . . . . . . .  - 20 $C0
; | > > . . | . . . . . . . . . . .  - 21 $C0
; | . > . . | . . . . . . . . . . .  - 22 $40
; | . . . . | . . . . . . . . . . .  - 23 $00

PLAYER0_GRAVE_DATA
	.by $00 $00 $00 $00 $1F $3C $78 $70
	.by $E0 $E0 $C0 $C0 $C0 $C0 $C0 $C0 
	.by $C0 $C0 $C0 $C0 $C0 $40 $00

; P1 - Detail right side
; . . . . . . . | . ~ . . | . . . .  - 1  $40
; . . . . . . . | ~ ~ ~ . | . . . .  - 2  $E0
; . . . . . . . | . ~ . . | . . . .  - 3  $40
; . . . . . . . | . ~ . . | . . . .  - 4  $40
; . . . . . . . | . ~ . . | . . . .  - 5  $40
; . . . . . . . | ~ ~ ~ ~ | . . . .  - 6  $F0
; . . . . . . . | ~ ~ ~ ~ | ~ . . .  - 7  $F8
; . . . . . . . | ~ ~ ~ ~ | ~ ~ . .  - 8  $FC
; . . . . . . . | ~ ~ ~ ~ | ~ ~ ~ .  - 9  $FE
; . . . . . . . | ~ ~ ~ ~ | ~ ~ ~ .  - 10 $FE
; . . . . . . . | ~ ~ ~ ~ | ~ ~ ~ ~  - 11 $FF
; . . . . . . . | ~ . ~ . | . ~ ~ ~  - 12 $A7
; . . . . . . . | ~ . ~ . | ~ . ~ ~  - 13 $AB
; . . . . . . . | ~ . ~ . | . ~ ~ ~  - 14 $A7
; . . . . . . . | ~ . ~ . | ~ ~ ~ ~  - 15 $AF
; . . . . . . . | ~ . ~ . | ~ ~ ~ ~  - 16 $AF
; . . . . . . . | ~ ~ ~ ~ | ~ ~ ~ ~  - 17 $FF
; . . . . . . . | . . . . | ~ ~ ~ ~  - 18 $0F
; . . . . . . . | ~ ~ ~ ~ | ~ ~ ~ ~  - 19 $FF
; . . . . . . . | ~ ~ ~ ~ | ~ ~ ~ ~  - 20 $FF
; . . . . . . . | ~ ~ ~ ~ | ~ ~ ~ ~  - 21 $FF
; . . . . . . . | ~ ~ ~ ~ | ~ ~ ~ ~  - 22 $FF
; . . . . . . . | ~ ~ ~ ~ | ~ ~ ~ ~  - 23 $FF

PLAYER1_GRAVE_DATA
	.by $40 $E0 $40 $40 $40 $F0 $F8 $FC
	.by $FE $FE $FF $A7 $AB $A7 $AF $AF
	.by $FF $0F $FF $FF $FF $FF $FF


; P2 + P3 - Black RIP 
; . . . . | . | . . . . | . . . . . .  - 1  $00 $00
; . . . . | . | . . . . | . . . . . .  - 2  $00 $00
; . . . . | . | . . . . | . . . . . .  - 3  $00 $00
; . . . . | . | . . . . | . . . . . .  - 4  $00 $00
; . . . . | . | . . . . | . . . . . .  - 5  $00 $00
; . . . . | . | . . . . | . . . . . .  - 6  $00 $00
; . . . . | . | . . . . | . . . . . .  - 7  $00 $00
; . . . . | . | . . . . | . . . . . .  - 8  $00 $00
; . . . . | . | . . . . | . . . . . .  - 9  $00 $00
; . . . . | . | . . . . | . . . . . .  - 10 $00 $00
; . . . . | . | . . . . | . . . . . .  - 11 $00 $00
; . . . . | 3 | 2 . . 2 | . 2 2 . . .  - 12 $80 $96
; . . . . | 3 | . 2 . 2 | . 2 . 2 . .  - 13 $80 $55
; . . . . | 3 | 2 . . 2 | . 2 2 . . .  - 14 $80 $96
; . . . . | 3 | 2 . . 2 | . 2 . . . .  - 15 $80 $94
; . . . . | 3 | . 2 . 2 | . 2 . . . .  - 16 $80 $54
; . . . . | . | . . . . | . . . . . .  - 17 $00 $00
; . . . . | . | . 2 2 2 | 2 2 . . . .  - 18 $00 $7C
; . . . . | . | . . . . | . . . . . .  - 19 $00 $00
; . . . . | . | . . . . | . . . . . .  - 20 $00 $00
; . . . . | . | . . . . | . . . . . .  - 21 $00 $00
; . . . . | . | . . . . | . . . . . .  - 22 $00 $00
; . . . . | . | . . . . | . . . . . .  - 23 $00 $00

PLAYER2_GRAVE_DATA
	.by $00 $00 $00 $00 $00 $00 $00 $00 
	.by $00 $00 $00 $96 $55 $96 $94 $54
	.by $00 $7C $00 $00 $00 $00 $00

PLAYER3_GRAVE_DATA
	.by $00 $00 $00 $00 $00 $00 $00 $00
	.by $00 $00 $00 $80 $80 $80 $80 $80
	.by $00 $00 $00 $00 $00 $00 $00


; FYI, remaining left detail...
; . . . . . . . . . . . . . . .  - 1
; . . . . . . . . . . . . . . .  - 2
; . . . . . . . . . . . . . . .  - 3
; . . . . . . . . . . . . . . .  - 4
; . . . . . . . . . . . . . . .  - 5 
; . . . . . . ~ . . . . . . . .  - 6
; . . . . . ~ ~ . . . . . . . .  - 7
; . . . . ~ ~ ~ . . . . . . . .  - 8
; . . . ~ ~ ~ ~ . . . . . . . .  - 9
; . . . ~ ~ ~ ~ . . . . . . . .  - 10
; . . ~ ~ ~ ~ ~ . . . . . . . .  - 11
; . . ~ ~ . . ~ . . . . . . . .  - 12
; . . ~ ~ . ~ . . . . . . . . .  - 13
; . . ~ ~ . . ~ . . . . . . . .  - 14
; . . ~ ~ . . ~ . . . . . . . .  - 15
; . . ~ ~ . ~ . . . . . . . . .  - 16
; . . ~ ~ ~ ~ ~ . . . . . . . .  - 17
; . . ~ ~ ~ ~ . . . . . . . . .  - 18
; . . ~ ~ ~ ~ ~ . . . . . . . .  - 19
; . . ~ ~ ~ ~ ~ . . . . . . . .  - 20 
; . . ~ ~ ~ ~ ~ . . . . . . . .  - 21
; . . ~ ~ ~ ~ ~ . . . . . . . .  - 22
; . . ~ ~ ~ ~ ~ . . . . . . . .  - 23

; Masking 
; M0 (p5) - left detail - quad width lowest priority.
; Upper section masked by shadow (P0) and this is 
; also lower priority than P2 and P3 displaying text.
 
; . ~  - 6   ; $01
; ~ ~  - 7   ; $03
; ~ ~  - 7   ; $03
; ~ ~  - 7   ; $03
; . . .
; ~ ~  - 22  ; $03 
; ~ ~  - 23  ; $03

; . . . . . . . . . . . . . . .  - 1  $00
; . . . . . . . . . . . . . . .  - 2  $00
; . . . . . . . . . . . . . . .  - 3  $00
; . . . . . . . . . . . . . . .  - 4  $00
; . . . . . . . . . . . . . . .  - 5  $00
; . . . . . . ~ ~ ~ ~ . . . . .  - 6  $01
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 7  $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 8  $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 9  $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 10 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 11 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 12 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 13 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 14 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 15 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 16 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 17 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 18 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 19 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 20 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 21 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 22 $03
; . . ~ ~ ~ ~ ~ ~ ~ ~ . . . . .  - 23 $03

PLAYER5_GRAVE_DATA; Missile 0
	.by $00 $00 $00 $00 $00 $01 $03 $03
	.by $03 $03 $03 $03 $03 $03 $03 $03
	.by $03 $03 $03 $03 $03 $03 $03

BASE_PMCOLORS_TABLE ; When "off", and so multiplication for frog = 1 works.
	.by 0 0 0 0

FROG_PMCOLORS_TABLE ; 0, 1, 2, 3
	.by COLOR_GREEN+$4       ; P0, frog
	.by COLOR_GREEN+$2       ; P1, frog, green iris
	.by COLOR_BLACK+$E       ; P2, frog mouth 
	.by COLOR_BLACK          ; P3, (and M3) Left/Right Wall Masks 

SPLAT_PMCOLORS_TABLE ; 0, 1, 2, 3
	.by COLOR_PINK+$4        ; P0, splat
	.by COLOR_PINK+$2        ; P1, splat
	.by COLOR_PINK+$6        ; P2, 
	.by COLOR_BLACK          ; P3, (and M3) Left/Right Wall Masks 

; Splash screens don't use the wall masks.

GRAVE_PMCOLORS_TABLE ; 0, 1, 2, 3
	.by COLOR_BLACK+$4        ; P0, 
	.by COLOR_BLACK+$C        ; P1, 
	.by COLOR_BLACK+$2        ; P2, 
	.by COLOR_BLACK+$2        ; P3, 

