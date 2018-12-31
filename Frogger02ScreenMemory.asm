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
; Screen Memory
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

ATASCII_HEART  = $00 ; heart graphics
ATASCII_HLINE  = $12 ; horizontal line, ctrl-r (title underline)
ATASCII_BALL   = $14 ; ball graphics, ctrl-t

ATASCII_ASTER  = $2A ; Character for '*' splattered frog.
ATASCII_0      = $30 ; Character for '0'

; ATASCII chars shorthanded due to frequency....
A_B = ATASCII_BALL
A_H = ATASCII_HLINE

; Atari uses different, "internal" values when writing to
; Screen RAM.  These are the internal codes for writing
; bytes directly to the screen:
INTERNAL_O        = $2F ; Letter 'O' is the frog.
INTERNAL_0        = $10 ; Number '0' for scores.
INTERNAL_BALL     = $54 ; Ball graphics, ctrl-t, boat part.
INTERNAL_SPACE    = $00 ; Blank space character.
INTERNAL_INVSPACE = $80 ; Inverse Blank space, for the beach.
INTERNAL_ASTER    = $0A ; Character for '*' splattered frog.
INTERNAL_HEART    = $40 ; heart graphics
INTERNAL_HLINE    = $52 ; underline for title text.

; Graphics chars shorthanded due to frequency in the code....
I_I  = 73      ; Internal ctrl-I
I_II = 73+$80  ; Internal ctrl-I Inverse
I_K  = 75      ; Internal ctrl-K
I_IK = 75+$80  ; Internal ctrl-K Inverse
I_L  = 76      ; Internal ctrl-L
I_IL = 76+$80  ; Internal ctrl-L Inverse
I_O  = 79      ; Internal ctrl-O
I_IO = 79+$80  ; Internal ctrl-O Inverse
I_U  = 85      ; Internal ctrl-U
I_IU = 85+$80  ; Internal ctrl-U Inverse
I_Y  = 89      ; Internal ctrl-Y
I_IY = 89+$80  ; Internal ctrl-Y Inverse
I_S  = 0       ; Internal Space
I_IS = 0+$80   ; Internal Space Inverse

I_T  = $54     ; Internal ctrl-t (ball)
I_IT = $54+$80 ; Internal ctrl-t Inverse


SIZEOF_LINE    = 39  ; That is, 40 - 1
SIZEOF_BIG_GFX = 119 ; That is, 120 - 1

; Ordinarily, this would start at ANTIC's 4K boundary for screen memory.
; But, we can simply align each set of lines into pages to prevent any 
; line from crossing over a 4K boundary.

	.align $0100 
;Below the declarations will make sure 
; each line of data fits within 256 byte pages.

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

TITLE_MEM1 ; Instructions/Title text.
; 1  |              PET FROGGER               | TITLE
	.sb "              PET FROGGER               "

TITLE_MEM2
; 2  |              --- -------               | TITLE
	.sb "              "
	.sb A_H A_H A_H " " A_H A_H A_H A_H
	.sb A_H A_H A_H "               "

CREDIT_MEM1 ; The perpetrators identified...
; 3  |     (c) November 1983 by DalesOft      | CREDIT
	.sb "     (c) November 1983 by Dales" ATASCII_HEART "ft      "

CREDIT_MEM2
; 4  |        Written by John C Dale          | CREDIT
	.sb "        Written by John C. Dale         "

CREDIT_MEM3
; 5  |Atari V02 port by Ken Jennings, Dec 2018| CREDIT
	.sb "Atari V02 port by Ken Jennings, Dec 2018"

	
BLANK_MEM ; Blank line used to erase things. 
; 6  |                                        |
	.sb "                                        "

; Six lines times 40 characters is 240 bytes of data.  
; Realign to next page.
	.align $0100

INSTRUCT_MEM1 ; Basic instructions...
; 7  |Help the frogs escape from Doc Hopper's | INSTXT_1
	.sb "Help the frogs escape from Doc Hopper's "
INSTRUCT_MEM2
; 8  |frog legs fast food franchise! But, the | INSTXT_1
	.sb "frog legs fast food franchise! But, the "
INSTRUCT_MEM3
; 9  |frogs must cross piranha-infested rivers| INSTXT_1
	.sb "frogs must cross piranha-infested rivers"
INSTRUCT_MEM4
; 10 |to reach freedom. You have three chances| INSTXT_1
	.sb "to reach freedom. You have three chances"
INSTRUCT_MEM5
; 11 |to prove your frog management skills by | INSTXT_1
	.sb "to prove your frog management skills by "
INSTRUCT_MEM6
; 12 |directing frogs to jump on boats in the | INSTXT_1
	.sb "directing frogs to jump on boats in the "

; Six lines times 40 characters is 240 bytes of data.  
; Realign to next page.
	.align $0100

INSTRUCT_MEM7
; 13 |rivers like this:  <QQQQ]  Land only on | INSTXT_1
	.sb "rivers like this:  "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "  Land only on  "
INSTRUCT_MEM8
; 14 |the seats in the boats.                 | INSTXT_1
	.sb "the seats in the boats.                 "

SCORING_MEM1 ; Scoring
; 16 |Scoring:                                | INSTXT_2
	.sb "Scoring:                                "
SCORING_MEM2 
; 17 |    10 points for each jump forward.    | INSTXT_2
	.sb "    10 points for each jump forward.    "
SCORING_MEM3
; 18 |   500 points for each rescued frog.    | INSTXT_2
	.sb "   500 points for each rescued frog.    "

CONTROLS_MEM1 ; Game Controls
; 20 |Use Joystick Controller:                | INSTXT_3
	.sb "Use Joystick Controller:                "

; Six lines times 40 characters is 240 bytes of data.  
; Realign to next page.
	.align $0100

CONTROLS_MEM2
; 21 |                   Up                   | INSTXT_3
	.sb "                   Up                   "
CONTROLS_MEM3 
; 22 |      left                   right      | INSTXT_3
	.sb "      left                   right      "

ANYKEY_MEM ; Prompt to start game.
; 24 |   Press joystick button to continue.   | INSTXT_4
	.sb "   Press joystick button to continue.   "


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
	.by I_BF I_SR I_SO I_SG I_SS $00 I_BS I_BS I_SV I_SE I_SD
SCREEN_SAVED
	.sb "                 "

; Playfield groups.  
; Each beach line is 40 characters, because it is not scrolled.
; Each boat line is doubled at 80 characters for horizontal coarse 
; scrolling.  Each group is aligned to a 256 byte boundary to make sure 
; they are all one page, and none will cross a 4K boundary.  This makes 
; the scrolling math easier by being sure only the low byte of the LMS 
; needs to be changed.

	.align $0100

PLAYFIELD_MEM0 ; Default display of "Beach", for lack of any other description, and the two lines of Boats
; 3  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_1
	.sb "         "
	.by I_BEACH1
	.sb "      "
	.by I_BEACH2
	.sb "              "
	.by I_BEACH3
	.sb "        " ; "Beach"
PLAYFIELD_MEM1
; 4  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_1 ; Boats Right
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
PLAYFIELD_MEM2
; 5  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_1 ; Boats Left
	.sb "      "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "          "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "


	.align $0100

PLAYFIELD_MEM3 ; Default display of "Beach", for lack of any other description, and the two lines of Boats
; 6  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_2
	.sb "      "
	.by I_BEACH3
	.sb "    "
	.by I_BEACH1
	.sb "                "
	.by I_BEACH3
	.sb "           " ; "Beach"
PLAYFIELD_MEM4
; 7  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_2 ; Boats Right
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
PLAYFIELD_MEM5
; 8  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_2 ; Boats Left
	.sb "      "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "          "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "


	.align $0100

PLAYFIELD_MEM6 ; Default display of "Beach", for lack of any other description, and the two lines of Boats
; 9  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_3
	.sb "     "
	.by I_BEACH2
	.sb "       "
	.by I_BEACH3
	.sb "              "
	.by I_BEACH1
	.sb "           " ; "Beach"
PLAYFIELD_MEM7
; 10  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_3 ; Boats Right
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
PLAYFIELD_MEM8
; 11  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_3 ; Boats Left
	.sb "      "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "          "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "


	.align $0100

PLAYFIELD_MEM9 ; Default display of "Beach", for lack of any other description, and the two lines of Boats
; 12  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_4
	.sb "          "
	.by I_BEACH1
	.sb "         "
	.by I_BEACH3
	.sb "           "
	.by I_BEACH2
	.sb "       " ; "Beach"
PLAYFIELD_MEM10
; 13  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_4 ; Boats Right
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
PLAYFIELD_MEM11
; 14  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_4 ; Boats Left
	.sb "      "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "          "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "


	.align $0100

PLAYFIELD_MEM12 ; Default display of "Beach", for lack of any other description, and the two lines of Boats
; 15  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_5
	.sb "       "
	.by I_BEACH2
	.sb "      "
	.by I_BEACH2
	.sb "              "
	.by I_BEACH1
	.sb "          " ; "Beach"
PLAYFIELD_MEM13
; 16  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_5 ; Boats Right
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
PLAYFIELD_MEM14
; 17  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_5 ; Boats Left
	.sb "      "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "          "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "


	.align $0100

PLAYFIELD_MEM15 ; Default display of "Beach", for lack of any other description, and the two lines of Boats
; 18  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_6
	.sb "           "
	.by I_BEACH1
	.sb "         "
	.by I_BEACH2
	.sb "          "
	.by I_BEACH3
	.sb "       " ; "Beach"
PLAYFIELD_MEM16
; 19  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_6 ; Boats Right
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
	.by $00 I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "        "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "       "
	.by I_BOAT_RB I_SEATS I_SEATS I_SEATS I_BOAT_RF
	.sb "      "
PLAYFIELD_MEM17
; 20  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_6 ; Boats Left
	.sb "      "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "          "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "        "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
	.by I_BOAT_LF I_SEATS I_SEATS I_SEATS I_BOAT_LB
	.sb "    "
PLAYFIELD_MEM18 ; One last line of Beach
; 21  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT2
	.sb "        "
	.by I_BEACH3
	.sb "        "
	.by I_BEACH1
	.sb "                 "
	.by I_BEACH1
	.sb "    " ; "Beach"


	.align $0100

; FROG SAVED screen., 25 lines:
; 10 blank lines.
; 3 lines of big text.
; 10 blank lines
; Press Any Key Line
; 1 blank line

FROGSAVE_MEM
; Graphics chars design, SAVED!
; |  |**|**|  |  | *|* |  | *|* | *|* | *|**|**|* | *|**|* |  |  |**|
; | *|* |  |  |  |**|**|  | *|* | *|* | *|* |  |  | *|* |**|  |  |**|
; |  |**|**|  | *|* | *|* | *|* | *|* | *|**|**|  | *|* | *|* |  |**|
; |  |  | *|* | *|* | *|* | *|* | *|* | *|* |  |  | *|* | *|* |  |**|
; |  |  | *|* | *|**|**|* |  |**|**|  | *|* |  |  | *|* |**|  |  |  |
; |  |**|**|  | *|* | *|* |  | *|* |  | *|**|**|* | *|**|* |  |  |**|

; Graphics chars, SAVED!
; | I|iI|iU|  |  |iL|iK|  |iY| Y|iY| Y|iY|iI|iU| L|iY|iI|iK|  |  |i |
; |  |iU|iO| O|iY| Y|iY| Y|iY| Y|iY|Y |iY|iI|iU|  |iY| Y|iY| Y|  |i |
; |  | U|iL| L|iY|iI|iO| Y|  |iO|iI|  |iY|iK| U| O|iY|iK|iI|  |  | U|

; Graphics data, SAVED!  (22) + 18 spaces.
	.by $0 $0 $0 $0 $0 $0 $0 $0 $0 I_I I_II I_IU I_S I_S  I_IL I_IK I_S I_IY I_Y  I_IY I_Y I_IY I_II I_IU I_L I_IY I_II I_IK I_S I_S I_IS $0 $0 $0 $0 $0 $0 $0 $0 $0
	.by $0 $0 $0 $0 $0 $0 $0 $0 $0 I_S I_IU I_IO I_O I_IY I_Y  I_IY I_Y I_IY I_Y  I_IY I_Y I_IY I_II I_IU I_S I_IY I_Y  I_IY I_Y I_S I_IS $0 $0 $0 $0 $0 $0 $0 $0 $0
	.by $0 $0 $0 $0 $0 $0 $0 $0 $0 I_S I_U  I_IL I_L I_IY I_II I_IO I_Y I_S  I_IO I_II I_S I_IY I_IK I_U  I_O I_IY I_IK I_II I_S I_S I_U  $0 $0 $0 $0 $0 $0 $0 $0 $0


; FROG DEAD screen., 25 lines:
; 10 blank lines.
; 3 lines of big text.
; 10 blank lines
; Press Any Key Line
; 1 blank line

FROGDEAD_MEM
; Graphics chars design, DEAD FROG!
; | *|**|* |  | *|**|**|* |  | *|* |  | *|**|* |  |  |  |  | *|**|**|* | *|**|**|  |  |**|**|  |  |**|**|* |  |**|
; | *|* |**|  | *|* |  |  |  |**|**|  | *|* |**|  |  |  |  | *|* |  |  | *|* | *|* | *|* | *|* | *|* |  |  |  |**|
; | *|* | *|* | *|**|**|  | *|* | *|* | *|* | *|* |  |  |  | *|**|**|  | *|* | *|* | *|* | *|* | *|* |  |  |  |**|
; | *|* | *|* | *|* |  |  | *|* | *|* | *|* | *|* |  |  |  | *|* |  |  | *|**|**|  | *|* | *|* | *|* |**|* |  |**|
; | *|* |**|  | *|* |  |  | *|**|**|* | *|* |**|  |  |  |  | *|* |  |  | *|* |**|  | *|* | *|* | *|* | *|* |  |  |
; | *|**|* |  | *|**|**|* | *|* | *|* | *|**|* |  |  |  |  | *|* |  |  | *|* | *|* |  |**|**|  |  |**|**|* |  |**|

; Graphics chars, DEAD FROG!
; |iY|iI|iK|  |iY|iI|iU| L|  |iL|iK|  |iY|iI|iK|  |  |  |  |iY|iI|iU| L|iY|iI|iO| O| I|iI|iO| O| I|iI|iU| L|  |i |
; |iY| Y|iY| Y|iY|iI|iU|  |iY| Y|iY| Y|iY| Y|iY| Y|  |  |  |iY|iI|iU|  |iY|iK|iL| L|iY| Y|iY| Y|iY| Y| U| O|  |i |
; |iY|iK|iI|  |iY|iK| U| O|iY|iI|iO| Y|iY|iK|iI|  |  |  |  |iY| Y|  |  |iY| Y|iO| O| K|iK|iL| L| K|iK|iL|iY|  | U|

; Graphics data, DEAD FROG!  (37) + 3 spaces.
	.by $0 $0 I_IY I_II I_IK I_S I_IY I_II I_IU I_L I_S  I_IL I_IK I_S I_IY I_II I_IK I_S I_S I_S I_S I_IY I_II I_IU I_L I_IY I_II I_IO I_O I_I  I_II I_IO I_O I_I  I_II I_IU I_L I_S I_IS $0
	.by $0 $0 I_IY I_Y  I_IY I_Y I_IY I_II I_IU I_S I_IY I_Y  I_IY I_Y I_IY I_Y  I_IY I_Y I_S I_S I_S I_IY I_II I_IU I_S I_IY I_IK I_IL I_L I_IY I_Y  I_IY I_Y I_IY I_Y  I_U  I_O I_S I_IS $0
	.by $0 $0 I_IY I_IK I_II I_S I_IY I_IK I_U  I_O I_IY I_II I_IO I_Y I_IY I_IK I_II I_S I_S I_S I_S I_IY I_Y  I_S  I_S I_IY I_Y  I_IO I_O I_K  I_IK I_IL I_L I_K  I_IK I_IL I_Y I_S I_U  $0


	.align $0100

; GAME OVER screen., 25 lines:
; 10 blank lines.
; 3 lines of big text.
; 10 blank lines
; Press Any Key Line
; 1 blank line

GAMEOVER_MEM
; Graphics chars design, GAME OVER
; |  |**|**|* |  | *|* |  |**|  | *|* |**|**|**|  |  |  |  |**|**|  | *|* | *|* | *|**|**|* | *|**|**|  |
; | *|* |  |  |  |**|**|  |**|* |**|* |**|  |  |  |  |  | *|* | *|* | *|* | *|* | *|* |  |  | *|* | *|* |
; | *|* |  |  | *|* | *|* |**|**|**|* |**|**|* |  |  |  | *|* | *|* | *|* | *|* | *|**|**|  | *|* | *|* |
; | *|* |**|* | *|* | *|* |**| *| *|* |**|  |  |  |  |  | *|* | *|* | *|* | *|* | *|* |  |  | *|**|**|  |
; | *|* | *|* | *|**|**|* |**|  | *|* |**|  |  |  |  |  | *|* | *|* |  |**|**|  | *|* |  |  | *|* |**|  |
; |  |**|**|* | *|* | *|* |**|  | *|* |**|**|**|  |  |  |  |**|**|  |  | *|* |  | *|**|**|* | *|* | *|* |

; Graphics chars, Game Over.
; | I|iI|iU| L|  |iL|iK|  |iS| O|iL| Y|i |iU|iU|  |  |  | I|iI|iO| O|iY| Y|iY| Y|iY|iI|iU| L|iY|iI|iO| O|
; |iY| Y| U| O|iY| Y|iY| Y|i |iO|iO| Y|i |iU| L|  |  |  |iY| Y|iY| Y|iY| Y|iY| Y|iY|iI|iU|  |iY|iK|iL| L|
; | K|iK|iL| Y|iY|iI|iO| Y|i |  |iY| Y|i | U| U|  |  |  | K|iK|iL| L|  |iO|iI|  |iY| K| U| O|iY| Y|iO| O|

; Graphics data, Game Over.  (34) + 6 spaces.
	.by $0 $0 $0 I_I  I_II I_IU I_L I_S  I_IL I_IK I_S I_IS I_O  I_IL I_Y I_IS I_IU I_IU I_S I_S I_S I_I  I_II I_IO I_O I_IY I_Y  I_IY I_Y I_IY I_II I_IU I_L I_IY I_II I_IO I_O $0 $0 $0
	.by $0 $0 $0 I_IY I_Y  I_U  I_O I_IY I_Y  I_IY I_Y I_IS I_IO I_IO I_Y I_IS I_IU I_L  I_S I_S I_S I_IY I_Y  I_IY I_Y I_IY I_Y  I_IY I_Y I_IY I_II I_IU I_S I_IY I_IK I_IL I_L $0 $0 $0
	.by $0 $0 $0 I_K  I_IK I_IL I_Y I_IY I_II I_IO I_Y I_IS I_S  I_IY I_Y I_IS I_U  I_U  I_S I_S I_S I_K  I_IK I_IL I_L I_S  I_IO I_II I_S I_IY I_IK I_U  I_O I_IY I_Y  I_IO I_O $0 $0 $0






; ==========================================================================
; Text is static.  The vertical position may vary based on parameter
; by the caller.
; So, all we need are lists --  a list of the text and the sizes.
; To index the lists we need enumerated values.
; --------------------------------------------------------------------------
;PRINT_BLANK_TXT     = 0  ; BLANK_TXT     ; Blank line used to erase things.
;PRINT_BLANK_TXT_INV = 1  ; BLANK_TXT_INV ; Inverse blank line used to "animate" things.
;PRINT_TITLE_TXT     = 2  ; TITLE_TXT     ; Instructions/Title text.
;PRINT_CREDIT_TXT    = 3  ; CREDIT_TXT    ; The perpetrators identified...
;PRINT_INST_TXT1     = 4  ; INST_TXT1     ; Basic instructions...
;PRINT_INST_TXT2     = 5  ; INST_TXT2     ; Scoring
;PRINT_INST_TXT3     = 6  ; INST_TXT3     ; Game Controls
;PRINT_INST_TXT4     = 7  ; INST_TXT4     ; Prompt to start game.
;PRINT_INST_TXT4_INV = 8  ; INST_TXT4_INV ; inverse version to support blinking.
;PRINT_SCORE_TXT     = 9  ; SCORE_TXT     ; Labels for crossings counter, scores, and lives
;PRINT_TEXT1         = 10 ; TEXT1         ; Beach and boats.
;PRINT_TEXT2         = 11 ; TEXT2         ; Beach with frog (starting line)

;PRINT_END           = 12 ; value marker for end of list.


;TEXT_MESSAGES ; Starting addresses of each of the text messages
;	.word BLANK_TXT,BLANK_TXT_INV
;	.word TITLE_TXT,CREDIT_TXT,INST_TXT1,INST_TXT2,INST_TXT3,INST_TXT4,INST_TXT4_INV
;	.word SCORE_TXT,TEXT1,TEXT2


;TEXT_SIZES ; length of message.  Each should be a multiple of 40.
;	.word 40,40
;	.word 80,120,320,120,120,40,40
;	.word 80,120,40


;SCREEN_ADDR ; Direct address lookup for each row of screen memory.
;	.rept 25,#
;		.word [40*:1+SCREENMEM]
;	.endr

CopyTitleColorsToDLI
	ldx #24
LoopCopyTitleColors
	lda TITLE_BACK_COLORS,x
	sta COLPF2_TABLE,x
	lda TITLE_TEXT_COLORS,x
	sta COLPF1_TABLE,x
	dex
	bpl LoopCopyTitleColors

	rts


CopyGameColorsToDLI
	ldx #24
LoopCopyGameColors
	lda GAME_BACK_COLORS,x
	sta COLPF2_TABLE,x
	lda GAME_TEXT_COLORS,x
	sta COLPF1_TABLE,x
	dex
	bpl LoopCopyGameColors

	rts


CopyDeadColorsToDLI
	ldx #24
LoopCopyDeadColors
	lda DEAD_BACK_COLORS,x
	sta COLPF2_TABLE,x
	lda DEAD_TEXT_COLORS,x
	sta COLPF1_TABLE,x
	dex
	bpl LoopCopyDeadColors

	rts


CopyWinColorsToDLI
	ldx #24
LoopCopyWinColors
	lda WIN_BACK_COLORS,x
	sta COLPF2_TABLE,x
	lda WIN_TEXT_COLORS,x
	sta COLPF1_TABLE,x
	dex
	bpl LoopCopyWinColors

	rts


CopyOverColorsToDLI
	ldx #24
LoopCopyOverColors
	lda OVER_BACK_COLORS,x
	sta COLPF2_TABLE,x
	lda OVER_TEXT_COLORS,x
	sta COLPF1_TABLE,x
	dex
	bpl LoopCopyOverColors

	rts


	.align $0100

; ==========================================================================
; Color Layouts for the screens.
; --------------------------------------------------------------------------

TITLE_BACK_COLORS
	.by COLOR_GREEN COLOR_GREEN ; Title line
	.by COLOR_BLACK COLOR_BLACK COLOR_BLACK COLOR_BLACK ; Credits
	.by COLOR_AQUA COLOR_AQUA COLOR_AQUA COLOR_AQUA ; Directions
	.by COLOR_AQUA COLOR_AQUA COLOR_AQUA COLOR_AQUA ; Directions
	.by COLOR_BLACK
	.by COLOR_ORANGE2 COLOR_ORANGE2 COLOR_ORANGE2 ; Scoring
	.by COLOR_BLACK
	.by COLOR_PINK COLOR_PINK COLOR_PINK ; Controls
	.by COLOR_BLACK
	.by COLOR_BLUE_GREEN ; Press Any Key.
	.by COLOR_BLACK

TITLE_TEXT_COLORS
	.rept 25
		.by $0A ; Text luminance
	.endr 


GAME_BACK_COLORS
	.by COLOR_BLACK COLOR_BLACK ; Scores
	.by COLOR_ORANGE1 COLOR_BLUE1 COLOR_BLUE1 ; Beach, boats, boats.
	.by COLOR_ORANGE1 COLOR_BLUE1 COLOR_BLUE1 ; Beach, boats, boats.
	.by COLOR_ORANGE1 COLOR_BLUE1 COLOR_BLUE1 ; Beach, boats, boats.
	.by COLOR_ORANGE1 COLOR_BLUE1 COLOR_BLUE1 ; Beach, boats, boats.
	.by COLOR_ORANGE1 COLOR_BLUE1 COLOR_BLUE1 ; Beach, boats, boats.
	.by COLOR_ORANGE1 COLOR_BLUE1 COLOR_BLUE1 ; Beach, boats, boats.
	.by COLOR_ORANGE1 ; one last Beach.
	.by COLOR_GREEN ; gap 
	.by COLOR_BLACK COLOR_BLACK COLOR_BLACK  ; Credits

GAME_TEXT_COLORS
	.rept 25
		.by $0A ; Text luminance
	.endr 


DEAD_BACK_COLORS
	.by COLOR_BLACK 
	.by COLOR_RED_ORANGE COLOR_RED_ORANGE COLOR_RED_ORANGE COLOR_RED_ORANGE
	.by COLOR_RED_ORANGE COLOR_RED_ORANGE COLOR_RED_ORANGE COLOR_RED_ORANGE

	.by COLOR_BLACK COLOR_PINK COLOR_PINK COLOR_PINK COLOR_BLACK

	.by COLOR_RED_ORANGE COLOR_RED_ORANGE COLOR_RED_ORANGE COLOR_RED_ORANGE
	.by COLOR_RED_ORANGE COLOR_RED_ORANGE COLOR_RED_ORANGE COLOR_RED_ORANGE
	
	.by COLOR_BLACK COLOR_GREEN COLOR_BLACK  ; Credits

DEAD_TEXT_COLORS
	.by $00; Text luminance
	.by $0E $0C $0A $08 $06 $04 $02 $00
	.by $00 $0A $08 $06 $00
	.by $00 $02 $04 $06 $08 $0A $0C $0E
	.by $00 $0A $00


WIN_BACK_COLORS
	.by COLOR_BLACK  ; Scores
	.by COLOR_ORANGE1 COLOR_ORANGE2 COLOR_RED_ORANGE COLOR_PINK
	.by COLOR_PURPLE COLOR_PURPLE_BLUE COLOR_BLUE1 COLOR_BLUE2
	
	.by COLOR_BLACK COLOR_GREEN COLOR_GREEN COLOR_GREEN COLOR_BLACK
	
	.by COLOR_LITE_BLUE COLOR_AQUA COLOR_BLUE_GREEN COLOR_GREEN
	.by COLOR_YELLOW_GREEN COLOR_ORANGE_GREEN COLOR_LITE_ORANGE COLOR_ORANGE2
	
	.by COLOR_BLACK COLOR_GREEN COLOR_BLACK 

WIN_TEXT_COLORS
	.by $00; Text luminance
	.by $0A $0A $0A $0A $0A $0A $0A $0A
	.by $00 $0C $08 $04 $00
	.by $0A $0A $0A $0A $0A $0A $0A $0A
	.by $00 $0A $00


OVER_BACK_COLORS
	.by COLOR_BLACK 
	.by COLOR_PINK COLOR_PINK COLOR_PINK COLOR_PINK
	.by COLOR_PINK COLOR_PINK COLOR_PINK COLOR_PINK

	.by COLOR_BLACK COLOR_BLACK COLOR_BLACK COLOR_BLACK COLOR_BLACK

	.by COLOR_PINK COLOR_PINK COLOR_PINK COLOR_PINK
	.by COLOR_PINK COLOR_PINK COLOR_PINK COLOR_PINK

	.by COLOR_BLACK COLOR_GREEN COLOR_BLACK  

OVER_TEXT_COLORS
	.by $00; Text luminance
	.by $00 $02 $04 $06 $08 $0A $0C $0E
	.by $00 $0A $08 $06 $00
	.by $0E $0C $0A $08 $06 $04 $02 $00
	.by $00 $0A $00


	.align $0100

; ==========================================================================
; Tables listing pointers to all the assets.
; --------------------------------------------------------------------------

; ==========================================================================
; Give a display number below the VBI routine can set the Display List, 
; and populate zero page pointers for other routines. 
; --------------------------------------------------------------------------

DISPLAY_TITLE = 0
DISPLAY_GAME  = 1
DISPLAY_WIN   = 2
DISPLAY_DEAD  = 3
DISPLAY_OVER  = 4

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
	.byte <GAME_TEXT_COLORS
	.byte <WIN_TEXT_COLORS
	.byte <DEAD_TEXT_COLORS
	.byte <OVER_TEXT_COLORS
	
COLOR_TEXT_HI_TABLE
	.byte >TITLE_TEXT_COLORS
	.byte >GAME_TEXT_COLORS
	.byte >WIN_TEXT_COLORS
	.byte >DEAD_TEXT_COLORS
	.byte >OVER_TEXT_COLORS
	
; ==========================================================================
; A list of the game playfield screen memory locations.  Note this is 
; only the part of the game screen that presents the beaches and boats.  
; It does not include anything else before or after the playfield.
; --------------------------------------------------------------------------
PLAYFIELD_MEM_LO_TABLE
	.byte <PLAYFIELD_MEM0
	.byte <PLAYFIELD_MEM1
	.byte <PLAYFIELD_MEM2
	.byte <PLAYFIELD_MEM3
	.byte <PLAYFIELD_MEM4
	.byte <PLAYFIELD_MEM5
	.byte <PLAYFIELD_MEM6
	.byte <PLAYFIELD_MEM7
	.byte <PLAYFIELD_MEM8
	.byte <PLAYFIELD_MEM9
	.byte <PLAYFIELD_MEM10
	.byte <PLAYFIELD_MEM11
	.byte <PLAYFIELD_MEM12
	.byte <PLAYFIELD_MEM13
	.byte <PLAYFIELD_MEM14
	.byte <PLAYFIELD_MEM15
	.byte <PLAYFIELD_MEM16
	.byte <PLAYFIELD_MEM17
	.byte <PLAYFIELD_MEM18

PLAYFIELD_MEM_HI_TABLE
	.byte >PLAYFIELD_MEM0
	.byte >PLAYFIELD_MEM1
	.byte >PLAYFIELD_MEM2
	.byte >PLAYFIELD_MEM3
	.byte >PLAYFIELD_MEM4
	.byte >PLAYFIELD_MEM5
	.byte >PLAYFIELD_MEM6
	.byte >PLAYFIELD_MEM7
	.byte >PLAYFIELD_MEM8
	.byte >PLAYFIELD_MEM9
	.byte >PLAYFIELD_MEM10
	.byte >PLAYFIELD_MEM11
	.byte >PLAYFIELD_MEM12
	.byte >PLAYFIELD_MEM13
	.byte >PLAYFIELD_MEM14
	.byte >PLAYFIELD_MEM15
	.byte >PLAYFIELD_MEM16
	.byte >PLAYFIELD_MEM17
	.byte >PLAYFIELD_MEM18

; ==========================================================================
; A list of the game playfield's LMS address locations.
; --------------------------------------------------------------------------

PLAYFIELD_LMS_LO_TABLE
	.byte <PF_LMS0
	.byte <PF_LMS1
	.byte <PF_LMS2
	.byte <PF_LMS3
	.byte <PF_LMS4
	.byte <PF_LMS5
	.byte <PF_LMS6
	.byte <PF_LMS7
	.byte <PF_LMS8
	.byte <PF_LMS9
	.byte <PF_LMS10
	.byte <PF_LMS11
	.byte <PF_LMS12
	.byte <PF_LMS13
	.byte <PF_LMS14
	.byte <PF_LMS15
	.byte <PF_LMS16
	.byte <PF_LMS17
	.byte <PF_LMS18

PLAYFIELD_LMS_HI_TABLE
	.byte >PF_LMS0
	.byte >PF_LMS1
	.byte >PF_LMS2
	.byte >PF_LMS3
	.byte >PF_LMS4
	.byte >PF_LMS5
	.byte >PF_LMS6
	.byte >PF_LMS7
	.byte >PF_LMS8
	.byte >PF_LMS9
	.byte >PF_LMS10
	.byte >PF_LMS11
	.byte >PF_LMS12
	.byte >PF_LMS13
	.byte >PF_LMS14
	.byte >PF_LMS15
	.byte >PF_LMS16
	.byte >PF_LMS17
	.byte >PF_LMS18




