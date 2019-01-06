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
;
; --------------------------------------------------------------------------

; ==========================================================================
; SCREEN GRAPHICS
;
; All "printed" items declared.  All screen data and various lookups
; related to real "printed' data.

; The original Pet version mixed printing to the screen with direct
; writes to screen memory.  The printing required adjustments, because
; the Atari full screen editor works differently from the Pet terminal.

; Most of the ASCII/PETASCII/ATASCII is now removed.  No more "printing"
; to the screen.  Everything is directly written to the screen memory.
; All the data to write to the screen is declared, then the addresses to
; the data is listed in a table. Rather than several different screen
; printing routines there is now one display routine that accepts an index
; into the table driving the data movement to screen memory.  Since the
; data also has a declared length the end of text sentinel byte is no
; longer needed.
; --------------------------------------------------------------------------

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
; 25 |Atari V01 port by Ken Jennings, Nov 2018| PORTBYTEXT
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
; 25 |Atari V01 port by Ken Jennings, Nov 2018| PORTBYTEXT
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


; ==========================================================================
; Animation speeds of various displayed items.   Number of frames to wait...
; --------------------------------------------------------------------------
BLINK_SPEED     = 36 ; blinking Press Any Key text
CREDIT_SPEED    = 3  ; Animated Credits.
DEAD_FILL_SPEED = 3  ; Fill the Screen for Dead Frog
WIN_FILL_SPEED  = 4  ; Fill screen for Win
FROG_WAKE_SPEED = 90 ; Initial delay 1.5 sec for frog corpse '*' viewing/mourning
RES_IN_SPEED    = 2  ; Speed of Game over Res in animation
TITLE_SPEED     = 6  ; Fill screen to present title

; ==========================================================================
; Some Atari character things for convenience, or that can't be easily
; typed in a modern text editor...
; --------------------------------------------------------------------------
ATASCII_UP     = $1C ; Move Cursor
ATASCII_DOWN   = $1D
ATASCII_LEFT   = $1E
ATASCII_RIGHT  = $1F

ATASCII_CLEAR  = $7D
ATASCII_EOL    = $9B ; Mark the end of strings

ATASCII_HEART  = $00 ; heart graphics
ATASCII_HLINE  = $12 ; horizontal line, ctrl-r (title underline)
ATASCII_BALL   = $14 ; ball graphics, ctrl-t

ATASCII_EQUALS = $3D ; Character for '='
ATASCII_ASTER  = $2A ; Character for '*' splattered frog.
ATASCII_Y      = $59 ; Character for 'Y'
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

; ==========================================================================

BLANK_TXT ; Blank line used to erase things.
	.sb "                                        "

BLANK_TXT_INV ; Inverse blank line used to "animate" things.
	.sb +$80 "                                        "

; ==========================================================================

TITLE_TXT ; Instructions/Title text.
; 1  |              PET FROGGER               | TITLE
; 2  |              --- -------               | TITLE
	.sb "              PET FROGGER               "
	.sb "              "
	.sb A_H A_H A_H " " A_H A_H A_H A_H
	.sb A_H A_H A_H "               "

CREDIT_TXT ; The perpetrators identified...
; 3  |     (c) November 1983 by DalesOft      | CREDIT
; 4  |        Written by John C Dale          | CREDIT
; 5  |Atari V01 port by Ken Jennings, Dec 2018| CREDIT
	.sb "     (c) November 1983 by Dales" ATASCII_HEART "ft      "
	.sb "        Written by John C. Dale         "
	.sb "Atari V01 port by Ken Jennings, Dec 2018"

INST_TXT1 ; Basic instructions...
; 7  |Help the frogs escape from Doc Hopper's | INSTXT_1
; 8  |frog legs fast food franchise! But, the | INSTXT_1
; 9  |frogs must cross piranha-infested rivers| INSTXT_1
; 10 |to reach freedom. You have three chances| INSTXT_1
; 11 |to prove your frog management skills by | INSTXT_1
; 12 |directing frogs to jump on boats in the | INSTXT_1
; 13 |rivers like this:  <QQQQ]  Land only on | INSTXT_1
; 14 |the seats in the boats ('Q').           | INSTXT_1
	.sb "Help the frogs escape from Doc Hopper's "
	.sb "frog legs fast food franchise! But, the "
	.sb "frogs must cross piranha-infested rivers"
	.sb "to reach freedom. You have three chances"
	.sb "to prove your frog management skills by "
	.sb "directing frogs to jump on boats in the "
	.sb "rivers like this:  <" A_B A_B A_B "]  Land only on  "
	.sb "the seats in the boats ('" A_B "').           "

INST_TXT2 ; Scoring
; 16 |Scoring:                                | INSTXT_2
; 17 |    10 points for each jump forward.    | INSTXT_2
; 18 |   500 points for each rescued frog.    | INSTXT_2
	.sb "Scoring:                                "
	.sb "    10 points for each jump forward.    "
	.sb "   500 points for each rescued frog.    "

INST_TXT3 ; Game Controls
; 20 |Game controls:                          | INSTXT_3
; 21 |                 S = Up                 | INSTXT_3
; 22 |      left = 4           6 = right      | INSTXT_3
	.sb "Game controls:                          "
	.sb "                 S = Up                 "
	.sb "      left = 4           6 = right      "

INST_TXT4 ; Prompt to start game.
; 24 |     Hit any key to start the game.     | INSTXT_4
	.sb "        Hit any key to continue.        "

INST_TXT4_INV ; inverse version to support blinking.
; 24 |     Hit any key to start the game.     | INSTXT_4INV
	.sb +$80 "        Hit any key to continue.        "

; ==========================================================================


SCORE_TXT  ; Labels for crossings counter, scores, and lives
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
	.sb "Score:                               :Hi"
	.sb "Frogs:     Frogs Saved:                 "



TEXT1 ; Default display of "Beach", for lack of any other description, and the two lines of Boats
; 4  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_1
; 5  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_1
	.sb +$80 "                                        " ; "Beach"
	.sb " [" A_B A_B A_B A_B ">        " ; Boats Right
	.sb "[" A_B A_B A_B A_B ">       "
	.sb "[" A_B A_B A_B A_B ">      "
	.sb "      <" A_B A_B A_B A_B "]" ; Boats Left
	.sb "        <" A_B A_B A_B A_B "]"
	.sb "    <" A_B A_B A_B A_B "]    "

TEXT2 ; this last block includes a Beach, with the "Frog" character which is the starting line.
	.sb +$80 "                   O                    " ; The "beach" + frog

; ==========================================================================

SIZEOF_LINE    = 39  ; That is, 40 - 1
SIZEOF_BIG_GFX = 119 ; That is, 120 - 1

FROG_SAVE_GFX
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

FROG_DEAD_GFX
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

GAME_OVER_GFX
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
PRINT_BLANK_TXT     = 0  ; BLANK_TXT     ; Blank line used to erase things.
PRINT_BLANK_TXT_INV = 1  ; BLANK_TXT_INV ; Inverse blank line used to "animate" things.
PRINT_TITLE_TXT     = 2  ; TITLE_TXT     ; Instructions/Title text.
PRINT_CREDIT_TXT    = 3  ; CREDIT_TXT    ; The perpetrators identified...
PRINT_INST_TXT1     = 4  ; INST_TXT1     ; Basic instructions...
PRINT_INST_TXT2     = 5  ; INST_TXT2     ; Scoring
PRINT_INST_TXT3     = 6  ; INST_TXT3     ; Game Controls
PRINT_INST_TXT4     = 7  ; INST_TXT4     ; Prompt to start game.
PRINT_INST_TXT4_INV = 8  ; INST_TXT4_INV ; inverse version to support blinking.
PRINT_SCORE_TXT     = 9  ; SCORE_TXT     ; Labels for crossings counter, scores, and lives
PRINT_TEXT1         = 10 ; TEXT1         ; Beach and boats.
PRINT_TEXT2         = 11 ; TEXT2         ; Beach with frog (starting line)

PRINT_END           = 12 ; value marker for end of list.


TEXT_MESSAGES ; Starting addresses of each of the text messages
	.word BLANK_TXT,BLANK_TXT_INV
	.word TITLE_TXT,CREDIT_TXT,INST_TXT1,INST_TXT2,INST_TXT3,INST_TXT4,INST_TXT4_INV
	.word SCORE_TXT,TEXT1,TEXT2


TEXT_SIZES ; length of message.  Each should be a multiple of 40.
	.word 40,40
	.word 80,120,320,120,120,40,40
	.word 80,120,40


SCREEN_ADDR ; Direct address lookup for each row of screen memory.
	.rept 25,#
		.word [40*:1+SCREENMEM]
	.endr


; ==========================================================================
; "Printing" things to the screen.
; --------------------------------------------------------------------------

; ==========================================================================
; Clear the screen.
; 25 lines of text is divisible by 5 lines, and 5 lines of text is
; 200 bytes, so the code will loop and clear in multiple, 5 line
; sections at the same time.
;
; Indexing to 200 means bpl/bmi can't be used to identify continuing
; or ending condition of the loop.  Therefore, the loop counts 200 to
; 1 and uses value 0 for end of loop.  This means the base address for
; the indexing must be one less (-1) from the intended target base.
;
; Used by code:
; A = 0 for blank space.
; X = index, 200 to 1
; --------------------------------------------------------------------------
ClearScreen

	mRegSaveAX ; Save A and X, so the caller doesn't need to.

	lda #INTERNAL_SPACE  ; Blank Space byte. (known to be 0)
	ldx #200             ; Loop 200 to 1, end when 0

ClearScreenLoop
	sta SCREENMEM-1, x    ; 0   to 199
	sta SCREENMEM+200-1,x ; 200 to 399
	sta SCREENMEM+400-1,x ; 400 to 599
	sta SCREENMEM+600-1,x ; 600 to 799
	sta SCREENMEM+800-1,x ; 800 to 999
	dex
	bne ClearScreenLoop

	mRegRestoreAX ; Restore X and A

	rts


; ==========================================================================
; Empty the lines of text immediately above and below the big 
; text announcements (win, dead, game over)
;
; Used by code:
; A = 0 for blank space.
; X = index, 200 to 1
; --------------------------------------------------------------------------
ClearForGfx

	ldx #SIZEOF_LINE
	lda #INTERNAL_SPACE
	
LoopClearForGfx
	sta SCREENMEM+400,x ; Line 10 
	sta SCREENMEM+560,x ; Line 14 

	dex
	bpl LoopClearForGfx

	rts


; ==========================================================================
; Print the big text announcement for dead frog.
; --------------------------------------------------------------------------
PrintDeadFrogGfx
	jsr ClearForGfx

	ldx #SIZEOF_BIG_GFX
LoopPrintDeadText
	lda FROG_DEAD_GFX,x
	sta SCREENMEM+440,X 
	dex
	bpl LoopPrintDeadText

	rts


; ==========================================================================
; Print the big text announcement for Winning frog.
; --------------------------------------------------------------------------
PrintWinFrogGfx
	jsr ClearForGfx
	
	ldx #SIZEOF_BIG_GFX
LoopPrintWinsText
	lda FROG_SAVE_GFX,x
	sta SCREENMEM+440,X
	dex
	bpl LoopPrintWinsText

	rts


; ==========================================================================
; Print the big text announcement for Game Over.
; --------------------------------------------------------------------------
PrintGameOverGfx
	jsr ClearForGfx
	
	ldx #SIZEOF_BIG_GFX
LoopPrintGameOverText
	lda GAME_OVER_GFX,x
	sta SCREENMEM+440,x
	dex
	bpl LoopPrintGameOverText
	
	rts
	
		
; ==========================================================================
; Print the instruction/title screen text.
; Set state of the text line that is blinking.
; --------------------------------------------------------------------------
DisplayTitleScreen
	jsr ClearScreen

	ldx #0

; An individual setup and call to PrintToScreen is 7 bytes which
; makes explicit setup for six calls for screen writing 42 bytes long.
; Since there are multiple, repeat patterns of the same thing,
; wrap it in a loop and read the driving data from a table.
; The ldx for setup, this code in the loop, plus the actual data
; in the driving tables is 2+19+12 = 33 bytes long.

LoopDisplayTitleText
	ldy TITLE_PRINT_LIST,x
	txa
	pha
	lda TITLE_PRINT_ROWS,x
	tax
	jsr PrintToScreen
	pla
	tax
	inx
	cpx #6
	bne LoopDisplayTitleText

	lda #1                   ; default condition of blinking prompt is inverse
	sta ToggleState

	rts

TITLE_PRINT_LIST
	.byte PRINT_TITLE_TXT,PRINT_CREDIT_TXT,PRINT_INST_TXT1
	.byte PRINT_INST_TXT2,PRINT_INST_TXT3,PRINT_INST_TXT4_INV

TITLE_PRINT_ROWS
	.byte 0,2,6,15,19,23


; ==========================================================================
; Display the game screen.
; The credits at the bottom of the screen is still always redrawn.
; From the title screen it is animated to move to the bottom of the
; screen.  But from the Win and Dead frog screens the credits
; are overdrawn.
; --------------------------------------------------------------------------
DisplayGameScreen
	mRegSaveAYX             ; Save A and Y and X, so the caller doesn't need to.

	jsr ClearScreen

	ldy #PRINT_CREDIT_TXT   ; Identify the culprits responsible
	ldx #22
	jsr PrintToScreen

	ldy #PRINT_SCORE_TXT    ; Print the lives and score labels
	ldx #0
	jsr PrintToScreen

	ldy #PRINT_TEXT1        ; Print TEXT1 -  beaches and boats (6 times)
	ldx #2

LoopPrintBoats
	jsr PrintToScreen

	inx                     ; Skip forward three lines
	inx
	inx

	cpx #20                 ; Printed six times? (18 lines total)
	bne LoopPrintBoats      ; No, go back to print another set of lines.

	ldy #PRINT_TEXT2        ; Print TEXT2 - last Beach with the frog (X is 20 here)
	jsr PrintToScreen

	; Display the current score and number of frogs that crossed the river.
	jsr CopyScoreToScreen
	jsr PrintFrogsAndLives
	
	jsr SetBoatSpeed        ; Animation speed set by number of saved frogs
	
	mRegRestoreAYX          ; Restore X, Y and A

	rts


; ==========================================================================
; Load ScreenPointer From X
;
; Parameters:
; X = row number on screen 0 to 24. (times 2 for index)
;
; Used by code:
; A = used to multiply  move the values.
; --------------------------------------------------------------------------
LoadScreenPointerFromX
	lda SCREEN_ADDR,x      ; Get screen row address low byte.
	sta ScreenPointer
	inx
	lda SCREEN_ADDR,x      ; Get screen row address high byte.
	sta ScreenPointer+1
	inx                    ; doing this for consistency so the next call pulls correct row

	rts


; ==========================================================================
; Copy text blocks to screen memory.
;
; Parameters:
; Y = index of the text item.  One of the PRINT_... values.
; X = row number on screen 0 to 24.
;
; Used by code:
; A = used to multiply  value of index, and move the values.
; --------------------------------------------------------------------------
PrintToScreen
	cpy #PRINT_END
	bcs ExitPrintToScreen      ; Greater than or equal to END marker, so exit.

	mRegSaveAYX                ; Save A and Y and X, so the caller doesn't need to.

	asl                        ; multiply row number by 2 for address lookup.
	tax                        ; use as index.
	jsr LoadScreenPointerFromX ; get row pointer based on X

	tya                        ; get the text identification.
	asl                        ; multiply by 2 for all the word lookups.
	tay                        ; use as index.

	lda TEXT_MESSAGES,y        ; Load up the values from the tables
	sta TextPointer
	lda TEXT_SIZES,y
	sta TextLength
	iny                        ; now the high bytes
	lda TEXT_MESSAGES,y        ; Load up the values from the tables.
	sta TextPointer+1
	lda TEXT_SIZES,y
	sta TextLength+1

	ldy #0
PrintToScreenLoop              ; sub-optimal copy through page 0 indirect index
	lda (TextPointer),y        ; Always assumes at least 1 byte to copy
	sta (ScreenPointer),y

	dec TextLength             ; Decrement length.  Stop when length is 0.
	bne DoEvaluateLengthHi     ; If low byte is not 0, then continue
	lda TextLength+1           ; Is the high byte also 0?
	beq EndPrintToScreen       ; Low byte and high byte are 0, so we're done.

DoEvaluateLengthHi             ; Check if hi byte of length must decrement
	lda TextLength             ; If this rolled from 0 to $FF
	cmp #$FF                   ; this means there is a high byte to decrement
	bne DoTextPointer          ; Nope.  So, continue.
	dec TextLength+1           ; Yes, low byte went 0 to FF, so decrement high byte.

DoTextPointer                  ; inc text pointer.
	inc TextPointer
	bne DoScreenPointer        ; Did not roll from 255 to 0, so skip hi byte
	inc TextPointer+1

DoScreenPointer                ; inc screen pointer.
	inc ScreenPointer
	bne PrintToScreenLoop      ; Did not roll from 255 to 0, so skip hi byte
	inc ScreenPointer+1
	bne PrintToScreenLoop      ; The inc above must reasonably be non-zero.

EndPrintToScreen
	mRegRestoreAYX             ; Restore X, Y and A

ExitPrintToScreen
	rts


; ==========================================================================
; ANIMATE BOATS
; Move the lines of boats around either left or right.
; Changed logic for moving lines.  The original code moved all the
; rows going right then all the rows going left.
; This version does each line in order from the top to the bottom of
; the screen.  This is done on the chance that the code is racing the
; screen rendering and so we don't want main line execution to find
; a pattern where the code is updating a text line that is being
; displayed and we end up with tearing animation.
; --------------------------------------------------------------------------
AnimateBoats
	ldx #6                ; Loop 3 to 18 step 3 -- 6 = 3 times 2 for size of word in SCREEN_ADDR

	; FIRST PART -- Set up for Right Shift...
RightShiftRow
	lda SCREEN_ADDR,x     ; Get address of this row in X from the screen memeory lookup.
	sta MovesCars
	inx
	lda SCREEN_ADDR,x
	sta MovesCars+1
	inx

	ldy #$27              ; Character position, start at +39 (dec)
	lda (MovesCars),y     ; Read byte from screen (start +39)
	pha                   ; Save the character at the end to move to position 0.
	dey                   ; now at offset +38 (dec)

MoveToRight ; Shift text lines to the right.
	lda (MovesCars),y     ; Read byte from screen (start +38)
	iny
	sta (MovesCars),y     ; Store byte to screen at next position (start +39)

	dey                   ; Back up to the original read position.
	dey                   ; Backup to previous position.

	bpl MoveToRight       ; Backed up from 0 to FF? No. Do the shift again.

	; Copy character at end of line to the start of the line.
	iny                   ; Go back from $FF to $00
	pla                   ; Get character that was at the end of the line.
	sta (MovesCars),y     ; Save it at start of line.

	; SECOND PART -- Setup for Left Shift...
	lda SCREEN_ADDR,x
	sta MovesCars
	inx
	lda SCREEN_ADDR,x
	sta MovesCars+1
	inx

	lda (MovesCars),y     ; Read byte from screen (start +0)
	pha                   ; Save to move to position +39.
	iny                   ; now at offset +1 (dec)

MoveToLeft                ; Shift text lines to the left.
	lda (MovesCars),y     ; Get byte from screen (start +1)
	dey
	sta (MovesCars),y     ; Store byte at previous position (start +0)

	iny                   ; Forward to the original read position. (start +1)
	iny                   ; Forward to the next read position. (start +2)

	cpy #40               ; Reached position $27/39 (dec) (end of line)?
	bne MoveToLeft        ; No.  Do the shift again.

	; Copy character at start of line to the end of the line.
	ldy #39               ; Offset $27/39 (dec)
	pla                   ; Get character that was at the end of the line.
	sta (MovesCars),y     ; Save it at end of line.

	inx                   ; skip the beach line
	inx

	cpx #40               ; 21st line (20 from base 0) times 2
	bcc RightShiftRow     ; Continue to loop, right, left, right, left

	jsr CopyScoreToScreen ; Finish up by updating score display.

	rts


; ==========================================================================
; Copy the score from memory to screen positions.
;
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; --------------------------------------------------------------------------
CopyScoreToScreen
	ldx #7

DoUpdateScreenScore
	lda MyScore,x       ; Read from Score buffer
	sta SCREENMEM+6,x   
	lda HiScore,x       ; Read from Hi Score buffer
	sta SCREENMEM+29,x  
	dex                 ; Loop 8 bytes - 7 to 0.
	bpl DoUpdateScreenScore

	rts


; ==========================================================================
; PRINT FROGS AND LIVES
; Display the number of frogs that crossed the river and lives.
;
; 1  |0000000:Score                 Hi:0000000| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; --------------------------------------------------------------------------
PrintFrogsAndLives
	lda #INTERNAL_O     ; On Atari we're using "O" as the frog shape.
	ldx FrogsCrossed    ; number of times successfully crossed the rivers.
	beq WriteLives      ; then nothing to display. Skip to do lives.

	cpx #18             ; Limit saved frogs to the remaining width of screen
	bcc SavedFroggies
	ldx #17

SavedFroggies
	sta SCREENMEM+62,x  ; Write to screen. (second line, 24th position)
	dex                 ; Decrement number of frogs.
	bne SavedFroggies   ; then go back and display the next frog counter.

WriteLives
	lda NumberOfLives   ; Get number of lives.
	clc                 ; Add to value for
	adc #INTERNAL_0     ; Atari internal code for '0'
	sta SCREENMEM+46    ; Write to screen. *7th char on second line.)

	rts

