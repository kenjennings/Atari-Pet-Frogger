; ==========================================================================
; Pet Frogger
; (c) November 1983 by John C. Dale, aka Dalesoft
;
; ==========================================================================
; Ported (parodied) to Atari 8-bit computers 
; November 2018 by Ken Jennings (if this were 1983, aka FTR Enterprises)
;
; Version 00.
; As much of the Pet code is used as possible.
; In most places only the barest minimum of changes are made to deal with
; the differences on the Atari.  Notable changes:
; * References to fixed addresses are changed to meaningful labels.  This
;   includes page 0 variables, and score values.
; * Kernel call $FFD2 is replaced with "fputc" subroutine for Atari.
; * The Atari screen is a full screen editor, so cursor movement off the
;   right edge of the screen is different from the Pet requiring an extra
;   "DOWN" character to move the cursor to next lines.
; * Direct write to screen memory uses different internal code values, not
;   ASCII/ATASCII values.
; * Direct keyboard scanning is different requiring Atari to clear the
;   OS value in order to get the next character.  Also, key codes are
;   different on the Atari (and not ASCII or Internal codes.)
; * Given the differences in clock speed and frame rates between the
;   UK Pet 4032 the game is intended for and the NTSC Atari to which it is
;   ported the timing values in the delays are altered to scale the game
;   speed more like the original on the Pet.
; --------------------------------------------------------------------------
; Version 01.  
; Atari-specific optimizations, though limited.  Most of the program 
; still could assemble on a Pet (with changes for values and registers).
; The only doubt I have is monitoring for the start of a frame where the 
; Atari could monitor vcount or the jiffy counter.  Not sure how the Pet 
; could do this.
; * No IOCB printing to screen.  All screen writing is directly to 
;   screen memory.  This greatly speeds up the Title screen and game
;   playfield presentation.  It also shrinks code a little.
; * Extra "graphics" inserted for crossing the river, dying and game over.
; * Code is reorganized into an event/timer loop operation to facilitate
;  future Atari-fication and other features.
; --------------------------------------------------------------------------


; ==========================================================================
; Random blabbering across the versions of Pet Frogger concerning 
; differences between Atari and Pet, and the code considerations:
;
; It appears text printing on the Pet treats the screen like a typewriter.
; "Right" cursor movement used to move through full line width will cause
; the cursor to wrap around to the next line.  "Down" also moves to the next
; line.  I don't know for certain, but for printing purposes the program
; code makes it seem like character printing on the PET does not support
; direct positioning of the cursor other than "Home".

; Printing for the Atari version implemented similarly by sending single
; characters to the screen editor, E: device, channel 0.  The Atari'
; full screen editor does things differently.   Moving off the right edge
; of the screen returns the cursor to the left edge of the screen on the
; same line.  (Full screen editor, remember).  Therefore the Atari needs
; an extra "Down" cursor inserted where code expects the cursor on the
; Pet to be on the following line.  It looks like replacing the "Right"
; cursor movements with a blank space should accomplish the same thing,
; but for the sake of minimal changes Version 00 of the port retains the
; Pet's idea of cursor movement.

; Also, depending on how the text is printed the Atari editor can relate
; several adjacent physical lines as one logical line. Great for editing
; text lines longer than 40 characters, not so good when printing wraps the
; cursor from one line to the next.  Printing a character through the end of
; the screen line (aka the right margin) extends the current line as a
; logical line into the next screen line which pushes the content in lines
; below that further down the screen.

; Since some code does direct manipulation of the screen memory, I wonder
; why all the screen code didn't just do the same.  Copy from source to
; destination is easier (or at least more consistent) than printing.
; Changing all the text handling to use direct write is number one on
; the short list of Version 01 optimizations.

; The "BRK" instruction, byte value $00, is used as the end of string
; sentinel in the data.  This conflicts with the character value $00 for
; the graphics heart which the code also uses in place of the "o" in
; "Dalesoft".  The end of string sentinel is changed to the Atari End
; Of Line character, $9B, which does not conflict with anything else in
; the code for printing or data.

; None of the game displays use the entire 25 lines available on the PET.
; The only time the game writes to the entire screen is when it fills the
; screen with the block graphics upon the frog's demise.  This conveniently
; leaves the 25th line free for the "ported by" credit.  But the Atari only
; displays 24 lines of text!?!  Gasp!  Not true.  The NTSC Atari can do up
; to 30 lines of text.  Only the OS printing routines are limited to 24
; lines of text.  The game's 25 screen lines is accomplished on the Atari
; with a custom display list that also designates screen memory starting at
; $8000 which is the same location the Pet uses for its display.
; --------------------------------------------------------------------------

; ==========================================================================
; Ideas for Atari-specific version improvements, Version 01 and beyond!:
; * Remove all printing.  Replace with direct screen writes.  This will
;   be much faster.
; * Timing delay loops are imprecise.  Use the OS jiffy clock (frame
;   counter) to maintain timing, and while we're here make timing tables
;   for NTSC and PAL.
; * Joystick controls.  I hate the keyboard.  The joystick is free and
;   easy on the Atari.
; * Color... Simple version: a DLI for each line could make separate text
;   line colors for beach lines vs boat lines (and credit text lines.)
; * Sound..  Some simple splats, plops, beeps, water sloshings.
; * Custom character set that looks more like beach, boats, water, and frog.
; * Horizontal Fine scrolling text allows smoother movements for the boats.
; * Player Missile Frog. This would make frog placement v the boat
;   positions easier when horizontal scrolling is in effect, not to mention
;   extra color for the frog.
; * Stir, rinse, repeat -- more extreme of all of the above: more color,
;   more DLI, more custom character sets, isometric perspective.
;   Game additions -- pursuing enemies, alternate boat shapes, lily pads,
;   bonus objects to collect, variable/changing boat speeds.  Heavy metal
;   chip tune soundtrack unrelated to frogs that has no good reason for
;   drowning out the game sound effects.  Boss battles.  Online multi-
;   player death matches.  Game Achievements.  In-game micro transaction
;   payments for upgrades and abilities.
; --------------------------------------------------------------------------

; ==========================================================================
; Atari System Includes (MADS assembler)
	icl "ANTIC.asm" ; Display List registers
	icl "GTIA.asm"  ; Color Registers.
	icl "POKEY.asm" ;
	icl "OS.asm"    ;
	icl "DOS.asm"   ; LOMEM, load file start, and run addresses.
; --------------------------------------------------------------------------

; ==========================================================================
; Macros (No code/data declared)
	icl "macros.asm"
; --------------------------------------------------------------------------


; ==========================================================================
; Declare some Page Zero variables.
; On the Atari the OS owns the first half of Page Zero.

; The Atari load file format allows loading from disk to anywhere in 
; memory, therefore indulging in this evilness to define Page Zero 
; variables and load directly into them at the same time...
; --------------------------------------------------------------------------
	ORG $88

MovesCars       .word $00 ; = Moves Cars
FrogLocation    .word $00 ; = Frog Location
FrogColumn      .byte $00 ; = Frog X coord
FrogRow         .word $00 ; = Frog Y row position (on the playfield not counting score lines)
FrogLastColumn  .byte $00 ; = Frog's last X coordinate
FrogLastRow     .byte $00 ; = Frog's last Y row position 
LastCharacter   .byte 0   ; = Last Character Under Frog
FrogSafety      .byte 0   ; = 0 When Frog OK.  !0 == Yer Dead.
DelayNumber     .byte 0   ; = Delay No. (Hi = Slow, Low = Fast)
FrogsCrossed    .byte 0   ; = Number Of Frogs crossed
ScoreToAdd      .byte 0   ; = Number To Be Added to Score
NumberOfChars   .byte 0   ; = Number Of Characters Across
FlaggedHiScore  .byte 0   ; = Flag For Hi Score.  0 = no high score.  $FF = High score.
NumberOfLives   .byte 0   ; = Is Number Of Lives
LastKeyPressed  .byte 0   ; = Remember last key pressed
ScreenPointer   .word $00 ; = Pointer to location in screen memory.
TextPointer     .word $00 ; = Pointer to text message to write.
TextLength      .word $00 ; = Length of text message to write.

; Timers and event control.
DoTimers        .byte $00 ; = 0 means stop timer features.  Return from event polling. Main line
						  ; code would inc DoTimers to make sure accidental animation does not
						  ; occur while the code switches between screens.  This will become
						  ; more important when the game logic is enhanced to an event loop.

; Frame counters are decremented each frame.
; Once they decrement to  0 they enable the related activity.

; In the case of key press this counter value is set whenever a key is 
; pressed to force a delay between key presses to limit the speed of 
; the frog movement.
KeyscanFrames   .byte $00 ; = KEYSCAN_FRAMES

; In the case of animation frames the value is set from the ANIMATION_FRAMES
; table based on the number of frogs that crossed the river (difficulty level) 
AnimateFrames   .byte $00 ; = ANIMATION_FRAMES,X.  

; Identify the current screen.  This is what drives which timer/event loop 
; features are in effect.  Value is enumerated from SCREEN_LIST table.
CurrentScreen   .byte $00 ; = identity of current screen.

; This is a 0, 1, toggle to remember the last state of  
; something that blinks on screen.
ToggleState     .byte 0   ; = 0, 1, flipper to drive a blinking thing.

; Another event value.  Use for counting things for each pass of a screen/event.
EventCounter    .byte 0

; Game Score and High Score.
MyScore .by $0 $0 $0 $0 $0 $0 $0 $0 
HiScore .by $0 $0 $0 $0 $0 $0 $0 $0 

; In the event X, Y can't be saved on stack, hide them here....
SAVEX = $FE
SAVEY = $FF

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

; Graphics chars shorthanded due to frequency....
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

; Keyboard codes for keyboard game controls.
KEY_S = 62
KEY_Y = 43
KEY_6 = 27
KEY_4 = 24


; Timer values.  NTSC.
; About 7 keys per second.
KEYSCAN_FRAMES = $09

; based on number of frogs, how many frames between boat movements...
ANIMATION_FRAMES .byte 30,25,20,18,15,13,11,10,9,8,7,6

; Timer values.  PAL ?? guesses...
; About 7 keys per second.
; KEYSCAN_FRAMES = $07
; based on number of frogs, how many frames between boat movements...
;ANIMATION_FRAMES .byte 25,21,17,14,12,11,10,9,8,7,6,5

; Screen enumeration states for current processing condition.
; Note that the order here does not imply the only order of 
; movement between screens/event activity.  The enumeration 
; could be entirely random.
SCREEN_START       = 0  ; Entry Point for New Game setup..
SCREEN_TITLE       = 1  ; Credits and Instructions.
SCREEN_TRANS_GAME  = 2  ; Transition animation from Title to Game.
SCREEN_GAME        = 3  ; GamePlay 
SCREEN_TRANS_WIN   = 4  ; Transition animation from Game to Win.
SCREEN_WIN         = 5  ; Crossed the river!
SCREEN_TRANS_DEAD  = 6  ; Transition animation from Game to Dead.
SCREEN_DEAD        = 7  ; Yer Dead!
SCREEN_TRANS_OVER  = 8  ; Transition animation from Dead to Game Over.
SCREEN_OVER        = 9  ; Game Over.
SCREEN_TRANS_TITLE = 10 ; Transition animation from Game Over to Title.

; Screen Order/Path
;                       +-------------------------+
;                       V                         |
; Screen Title ---> Game Screen -+-> Win Screen  -+
;       ^               ^        |
;       |               |        +-> Dead Screen -+-> Game Over -+
;       |               |                         |              |
;       |               +-------------------------+              |
;       +--------------------------------------------------------+

; Programmer's unintelligently chosen higher address on Atari
; to account for DOS, etc.
	ORG $5000

	; Label and Credit
	.by "** Thanks to the Word (John 1:1), Creator of heaven and earth, and "
	.by "the semiconductor chemistry and physics which makes all this fun possible. ** "
	.by "Dales" ATASCII_HEART "ft PET FROGGER by John C. Dale, November 1983. ** "
	.by "Atari port by Ken Jennings, November 2018. Version 01. "
	.by "IOCB Printing removed. Everything is direct writes to screen RAM. **" 
	.by "Code reworked into timer/event loop organization. **"


; ==========================================================================
; All "printed" items declared:

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
; 2  |Score = 0000000      Hi = 0000000   Lv:3| SCORE_TXT
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
; 5  |Atari V01 port by Ken Jennings, Nov 2018| CREDIT
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
; 1  |Score = 0000000      Hi = 0000000   Lv:3| SCORE_TXT
; 2  |  Frogs Saved =                         | SCORE_TXT 
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
; 25 |Atari V01 port by Ken Jennings, Nov 2018| CREDIT
;    +----------------------------------------+



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
; 5  |Atari V01 port by Ken Jennings, Nov 2018| CREDIT
	.sb "     (c) November 1983 by Dales" ATASCII_HEART "ft      "
	.sb "        Written by John C. Dale         "
	.sb "Atari V01 port by Ken Jennings, Nov 2018"

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
	.sb "     Hit any key to start the game.     "

INST_TXT4_INV ; inverse version to support blinking.
; 24 |     Hit any key to start the game.     | INSTXT_4INV
	.sb +$80 "     Hit any key to start the game.     "

; ==========================================================================

SCORE_TXT  ; Labels for crossings counter, scores, and lives
; 1  |Score = 0000000      Hi = 0000000   Lv:3| SCORE_TXT
; 2  |  Frogs Saved =                         | SCORE_TXT 
	.sb "Score =              Hi =           Lv: "
	.sb "  Frogs Saved =                         "

TEXT1 ; Default display of "Beach", for lack of any other description, and the two lines of Boats
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

YRDDTX  ; Yer dead! Text prompt.
	.sb +$80 "     YOU'RE DEAD!! YOU WAS SWAMPED!     "

FROGTXT ; You made it across the rivers.
	.sb +$80 "     CONGRATULATIONS!! YOU MADE IT!     "
	.sb ATASCII_EOL
	BRK

OVER ; Prompt for playing again.
	.sb "        DO YOU WANT ANOTHER GO ?        "
	.sb ATASCII_EOL
	brk

INSTXT_1 ; Instructions text.  
	.sb "              PET FROGGER               "
	.sb "              " 
	.sb A_H A_H A_H " " A_H A_H A_H A_H
	.sb A_H A_H A_H "               "
	.sb "     (c) November 1983 by Dales" ATASCII_HEART "ft      "

INSTXT_2 ; Instructions text.
	.sb "All you have to do is to get as many of "
	.sb "the frogs across the river without      "
	.sb "drowning them. You have to leap onto a  "
	.sb "boat like this :- <" A_B A_B A_B "] and land on the "
	.sb "seats ('" A_B "'). You get 10 points for every"
	.sb "jump forward and 500 points every time  "
	.sb "you get a frog across the river.        "

INSTXT_3 ; More instructions
	.sb "The controls are :-                     "
	.sb "                 S = Up                 "
	.sb "  4 = left                   6 = right  "

INSTXT_4
	.sb +$80 "     Hit any key to start the game.     "



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
	.by $0,$0,$0,$0,$0,$0,$0,$0,$0,I_I,I_II,I_IU,I_S,I_S,I_IL,I_IK,I_S,I_IY,I_Y,I_IY,I_Y,I_IY,I_II,I_IU,I_L,I_IY,I_II,I_IK,I_S,I_S,I_IS,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.by $0,$0,$0,$0,$0,$0,$0,$0,$0,I_S,I_IU,I_IO,I_O,I_IY,I_Y,I_IY,I_Y,I_IY,I_Y,I_IY,I_Y,I_IY,I_II,I_IU,I_S,I_IY,I_Y,I_IY,I_Y,I_S,I_IS,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.by $0,$0,$0,$0,$0,$0,$0,$0,$0,I_S,I_U,I_IL,I_L,I_IY,I_II,I_IO,I_Y,I_S,I_IO,I_II,I_S,I_IY,I_IK,I_U,I_O,I_IY,I_IK,I_II,I_S,I_S,I_U,$0,$0,$0,$0,$0,$0,$0,$0,$0

; Graphics chars design, DEAD FROG!
; | *|**|* |  | *|**|**|* |  | *|* |  | *|**|* |  |  |  |  | *|**|**|* | *|**|**|  |  |**|**|  |  |**|**|* |  |**|
; | *|* |**|  | *|* |  |  |  |**|**|  | *|* |**|  |  |  |  | *|* |  |  | *|* | *|* | *|* | *|* | *|* |  |  |  |**|
; | *|* | *|* | *|**|**|  | *|* | *|* | *|* | *|* |  |  |  | *|**|**|  | *|* | *|* | *|* | *|* | *|* |  |  |  |**|
; | *|* | *|* | *|* |  |  | *|* | *|* | *|* | *|* |  |  |  | *|* |  |  | *|**|**|  | *|* | *|* | *|* |**|* |  |**|
; | *|* |**|  | *|* |  |  | *|**|**|* | *|* |**|  |  |  |  | *|* |  |  | *|* |**|  | *|* | *|* | *|* | *|* |  |  |
; | *|**|* |  | *|**|**|* | *|* | *|* | *|**|* |  |  |  |  | *|* |  |  | *|* | *|* |  |**|**|  |  |**|**|* |  |**|

; Graphics chars, DEAD FROG!
; |iY|iI|iK|  |iY|iI|iU| L|  |iL|iK|  |iY|iI|iK|  |  |  |  |iY|iI|iU| L|iY|iI|iO| O| I|iI|iO| O| I|iI|iU| L|  |i |
; |iY| Y|iY| Y|iY| I|iU|  |iY| Y|iY| Y|iY| Y|iY| Y|  |  |  |iY|iI|iU|  |iY|iK|iL| L|iY| Y|iY| Y|iY| Y| U| O|  |i |
; |iY|iK|iI|  |iY|iK| U| O|iY|iI|iO| Y|iY|iK|iI|  |  |  |  |iY| Y|  |  |iY| Y|iO| O| K|iK|iL| L| K|iK|iL|iY|  | U|

; Graphics data, DEAD FROG!  (37) + 3 spaces.
	.by $0,$0,I_IY,I_II,I_IK,I_S,I_IY,I_II,I_IU,I_L,I_S,I_IL,I_IK,I_S,I_IY,I_II,I_IK,I_S,I_S,I_S,I_S,I_IY,I_II,I_IU,I_L,I_IY,I_II,I_IO,I_O,I_I,I_II,I_IO,I_O,I_I,I_II,I_IU,I_L,I_S,I_IS,$0
	.by $0,$0,I_IY,I_Y,I_IY,I_Y,I_IY,I_I,I_IU,I_S,I_IY,I_Y,I_IY,I_Y,I_IY,I_Y,I_IY,I_Y,I_S,I_S,I_S,I_IY,I_II,I_IU,I_S,I_IY,I_IK,I_IL,I_L,I_IY,I_Y,I_IY,I_Y,I_IY,I_Y,I_U,I_O,I_S,I_IS,$0
	.by $0,$0,I_IY,I_IK,I_II,I_S,I_IY,I_IK,I_U,I_O,I_IY,I_II,I_IO,I_Y,I_IY,I_IK,I_II,I_S,I_S,I_S,I_S,I_IY,I_Y,I_S,I_S,I_IY,I_Y,I_IO,I_O,I_IK,I_IK,I_IL,I_L,I_IK,I_IK,I_IL,I_IY,I_S,I_U ,$0

; Graphics chars design, GAME OVER 
; |  |**|**|* |  | *|* |  |**|  | *|* |**|**|**|  |  |  |  |**|**|  | *|* | *|* | *|**|**|* | *|**|**|  |
; | *|* |  |  |  |**|**|  |**|* |**|* |**|  |  |  |  |  | *|* | *|* | *|* | *|* | *|* |  |  | *|* | *|* |
; | *|* |  |  | *|* | *|* |**|**|**|* |**|**|* |  |  |  | *|* | *|* | *|* | *|* | *|**|**|  | *|* | *|* |
; | *|* |**|* | *|* | *|* |**| *| *|* |**|  |  |  |  |  | *|* | *|* | *|* | *|* | *|* |  |  | *|**|**|  |
; | *|* | *|* | *|**|**|* |**|  | *|* |**|  |  |  |  |  | *|* | *|* |  |**|**|  | *|* |  |  | *|* |**|  |
; |  |**|**|* | *|* | *|* |**|  | *|* |**|**|**|  |  |  |  |**|**|  |  | *|* |  | *|**|**|* | *|* | *|* |

; Graphics chars, Game Over. 
; | I|iI|iU| I|  |iL|iK|  |iS| O|iL| Y|i |iU|iU|  |  |  | I|iI|iO| O|iY| Y|iY| Y|iY|iI|iU| L|iY|iI|iO| O|
; |iY| Y| U| O|iY| Y|iY| Y|i |iO|iO| Y|i |iU| L|  |  |  |iY| Y|iY| Y|iY| Y|iY| Y|iY|iI|iU|  |iY|iK|iL| L|
; | K|iK|iL| Y|iY|iI|iO| Y|i |  |iY| Y|i | U| U|  |  |  | K|iK|iL| L|  |iO|iI|  |iY| K| U| O|iY| Y|iO| O|

; Graphics data, Game Over.  (34) + 6 spaces.
	.by $0,$0,$0,I_I,I_II,I_IU,I_I,I_S,I_IL,I_IK,I_S,I_IS,I_O,I_IL,I_Y,I_IS,I_IU,I_IU,I_S,I_S,I_S,I_I,I_II,I_IO,I_O,I_IY,I_Y,I_IY,I_Y,I_IY,I_II,I_IU,I_L,I_IY,I_II,I_IO,I_O,$0,$0,$0
	.by $0,$0,$0,I_IY,I_Y,I_U,I_O,I_IY,I_Y,I_IY,I_Y,I_IS,I_IO,I_IO,I_Y,I_IS,I_IU,I_L,I_S,I_S,I_S,I_IY,I_Y,I_IY,I_Y,I_IY,I_Y,I_IY,I_Y,I_IY,I_II,I_IU,I_S,I_IY,I_IK,I_IL,I_L,$0,$0,$0
	.by $0,$0,$0,I_IK,I_IK,I_IL,I_Y,I_IY,I_II,I_IO,I_Y,I_IS,I_S,I_IY,I_Y,I_IS,I_U,I_U,I_S,I_S,I_S,I_IK,I_IK,I_IL,I_L,I_S,I_IO,I_II,I_S,I_IY,I_IK,I_U,I_O,I_IY,I_Y,I_IO,I_O,$0,$0,$0


; ==========================================================================
; Text is static.  The vertical position may vary based on parameter 
; by the caller.
; So, all we need are lists --  a list of the text and the sizes.
; To index the lists we neeed enumerated values.
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
	
	.word YRDDTX,FROGTXT,OVER
	.word INSTXT_1,INSTXT_2,INSTXT_3,INSTXT_4,PORTBYTEXT

TEXT_SIZES ; length of message.  Each should be a multiple of 40.
	.word 40,40
	.word 80,120,320,120,120,40,40
	.word 80,120,40
	.word 80,40,40,40
	.word 120,280,120,40,40

SCREEN_ADDR ; Direct address lookup for each row of screen memory.
	.rept 25,#           
		.word [40*:1+SCREENMEM]
	.endr


; ==========================================================================
; "Printing" things to the screen.
; --------------------------------------------------------------------------

; ==========================================================================
; Clear the screen.  
; 25 lines of text is divisible by 5 lines, and 5 lines of text is 200 bytes,
; so the code will loop and clear in multiple, 5 line sections at the same
; time.
;
; Used by code:
; A = 0 for blank sopace.
; Y = used to pull values from the tables. 
; --------------------------------------------------------------------------
ClearScreen
	pha   ; Save A and Y, so the caller doesn't need to.
	tya
	pha

	lda #INTERNAL_SPACE  ; Blank Space byte.
	ldy #200             ; Loop 200 to 1, end when 0

ClearScreenLoop
	sta SCREENMEM-1, y    ; 0   to 199 
	sta SCREENMEM+200-1,y ; 200 to 399
	sta SCREENMEM+400-1,y ; 400 to 599
	sta SCREENMEM+600-1,y ; 600 to 799
	sta SCREENMEM+800-1,y ; 800 to 999
	dey
	bne ClearScreenLoop

	pla   ; Restore Y and A.
	tay
	pla

	rts


; ==========================================================================
; Print the instruction/title screen text.
; Set state of the text line that is blinking.
; --------------------------------------------------------------------------
DisplayTitleScreen
INSTR 
	jsr ClearScreen 

	ldy #PRINT_TITLE_TXT ; title 
	ldx #0
	jsr PrintToScreen

	ldy #PRINT_CREDIT_TXT ; culprits responsible
	ldx #2
	jsr PrintToScreen

	ldy #PRINT_INST_TXT1  ; directions.
	ldx #6
	jsr PrintToScreen

	ldy #PRINT_INST_TXT2 ; scoring values
	ldx #15
	jsr PrintToScreen

	ldy #PRINT_INST_TXT3 ; input controls
	ldx #19
	jsr PrintToScreen

	ldy #PRINT_INST_TXT4_INV  ; prompt to press a key to start.
	ldx #23
	jsr PrintToScreen

	lda #1 ; default condition of blinking prompt is inverse
	sta ToggleState

	rts


; ==========================================================================
; Display the game screen. 
; The credits at the bottom of the screen is still always redrawn.
; From the title screen it is animated to move to the bottom of the 
; screen.  But from the Win and Dead frog screens the credits
; are overdrawn. 
; --------------------------------------------------------------------------
DisplayGameScreen
PRINTSC 
	jsr ClearScreen 

	ldy #PRINT_SCORE_TXT    ; Print the lives and score labels 
	ldx #0
	jsr PrintToScreen

	ldy #PRINT_TEXT1        ; Print TEXT1 -  beaches and boats (6 times)
	ldx #2

LoopPrintBoats
	jsr PrintToScreen

	inx
	inx
	inx

	cpx #20                 ; Printed six times? (18 lines total) 
	bne LoopPrintBoats      ; No, go back to print another set of lines.

	ldy #PRINT_TEXT2        ; Print TEXT2 - last Beach with the frog
;	ldx #20
	jsr PrintToScreen

	ldy #PRINT_CREDIT_TXT   ; Identify the culprits responsible
	ldx #2
	jsr PrintToScreen

; Display the number of frogs that crossed the river.
	jsr PrintFrogsAndLives

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
	bcs ExitPrintToScreen  ; Greater than or equal to END marker, so exit.

	pha   ; Save A and Y and X, so the caller doesn't need to.
	tya
	pha
	txa
	pha

	asl                    ; multiply row number by 2 for address lookup.
	tax                    ; use as index.
	lda SCREEN_ADDR,x      ; Get screen row address low byte.
	sta ScreenPointer
	inx 
	lda SCREEN_ADDR,x      ; Get screen row address high byte.
	sta ScreenPointer+1

	tya                    ; get the text identification.
	asl                    ; multiply by 2 for all the word lookups.
	tay                    ; use as index.

	lda TEXT_MESSAGES,y    ; Load up the values from the tables
	sta TextPointer
	lda TEXT_SIZES,y
	sta TextLength
	iny                    ; now the high bytes
	lda TEXT_MESSAGES,y    ; Load up the values from the tables.
	sta TextPointer+1
	lda TEXT_SIZES,y
	sta TextLength+1

	ldy #0
PrintToScreenLoop          ; sub-optimal copy through page 0 indirect index
	lda (TextPointer),y    ; Always assumes at least 1 byte to copy
	sta (ScreenPointer),y

	dec TextLength         ; Decrement length.  Stop when length is 0.
	bne DoEvaluateLengthHi ; If low byte is not 0, then continue
	lda TextLength+1       ; Is the high byte also 0?
	beq EndPrintToScreen   ; Low byte and high byte are 0, so we're done.

DoEvaluateLengthHi         ; Check if hi byte of length must decrement 
	lda TextLength         ; If this rolled from 0 to $FF
	cmp #$FF               ; this means there is a high byte to decrement
	bne DoTextPointer      ; Nope.  So, continue.
	dec TextLength+1       ; Yes, low byte went 0 to FF, so decrement high byte.

DoTextPointer              ; inc text pointer.
	inc TextPointer
	bne DoScreenPointer    ; Did not roll from 255 to 0, so skip hi byte
	inc TextPointer+1

DoScreenPointer            ; inc screen pointer.
	inc ScreenPointer
	bne PrintToScreenLoop  ; Did not roll from 255 to 0, so skip hi byte
	inc ScreenPointer+1
	bne PrintToScreenLoop  ; The inc above must reasonably be non-zero.

EndPrintToScreen
	pla  ; Restore X, Y and A
	tax
	pla
	tay
	pla

ExitPrintToScreen
	rts


; ==========================================================================
; A little code size optimization.
; Add 120 (dec) to the current MovesCars pointer.
; This moves the pointer to the next river/boat line 3 lines lower, 
; so the current shift logic can be repeated.
; --------------------------------------------------------------------------
MoveCarsPlus120
	clc
	lda MovesCars     ; Add $78/120 (dec) to the start of line pointer
	adc #$78          ; to set new position 3 lines lower.
	sta MovesCars
	bcc ExitMoveCarsPlus120 
	inc MovesCars + 1 ; Smartly done instead of lda/adc #0/sta.

ExitMoveCarsPlus120
	rts


; ==========================================================================
; AUTO MOVE FROG
; Process automagical movement on the frog in the boat.
; --------------------------------------------------------------------------

AutoMoveFrog
AUTMVE
	ldx FrogRow   ; Get the current row number.
	lda DATA,x         ; Get the movement flag for the row.
	cmp #0             ; Is it 0?  Nothing to do.  Bail and go back to keyboard polling..  
	beq RETURN         ; (ya know, the cmp was not actually necessary.)
	cmp #$FF           ; is it $ff?  then automatic right move.
	bne AUTRIG         ; (ya know, could have done  bmi AUTRIG without the cmp).
	dey                ; Move Frog left one character
	cpy #0             ; Is it at 0? (Why not check for $FF here (or bmi)?)
	bne RETURN         ; No.  Bail and go back to keyboard polling.
	jmp YRDD           ; Yup.  Ran out of river.   Yer Dead!

AUTRIG 
	iny                ; Move Frog right one character
	cpy #$28           ; Did it reach the right side ?    $28/40 (dec)
	bne RETURN         ; No.  Bail and go back to keyboard polling.
	jmp YRDD           ; Yup.  Ran out of river.   Yer Dead!

RETURN
	jmp KEY            ; Return to keyboard polling.





; ==========================================================================
; ANIMATE BOATS
; Move the lines of boats around either left or right.
; Changed logic to move lines from the top to the bottom rather than 
; the original code which moves all the rows going right, then all the 
; rows going left
; --------------------------------------------------------------------------
AnimateBoats
MOVESC
	; FIRST PART -- Set up for Right Shift... 
	; MovedCars is a word set to $8078...
	; which is SCREENMEM + $78 (or 120 decimal [i.e. 3rd line of text])
;	lda #<[SCREENMEM+$78] ; low byte 
;	sta MovesCars
;	lda #>[SCREENMEM+$78] ; high byte
;	sta MovesCars + 1

	ldx #6            ; Loop 3 to 18 step 3 -- times 2 for size of word in SCREEN_ADDR

RightShiftRow
	lda SCREEN_ADDR,x ; Get address of this row in X from the screen memeory lookup.
	sta MovesCars
	inx
	lda SCREEN_ADDR,x
	sta MovesCars+1
	inx 

	ldy #$27          ; Character position, start at +39 (dec)
	lda (MovesCars),y ; Read byte from screen (start +39)
	pha               ; Save the character at the end to move to position 0.
	dey               ; now at offset +38 (dec)

MOVE ; Shift text lines to the right.
	lda (MovesCars),y ; Read byte from screen (start +38)
	iny
	sta (MovesCars),y ; Store byte to screen at next position (start +39)

	dey               ; Back up to the original read position.
	dey               ; Backup to previous position.

	bpl MOVE          ; Backed up from 0 to FF? No. Do the shift again.

	; Copy character at end of line to the start of the line.
	pla               ; Get character that was at the end of the line.
	ldy #$00          ; Offset 0 == start of line
	sta (MovesCars),y ; Save it at start of line.



	; Move to the next river/boat line to shift to the right 3 lines lower.
;	jsr MoveCarsPlus120

;	dex               ; Track a line is done. All six done?
;	bne RightShiftRow ; No.  Go do right shift on another line.

	; SECOND PART -- Setup for Left Shift...
	; MovedCars is a word to set to $80A0...
	; which is SCREENMEM + $A0 (or 160 decimal [i.e. 4th line of text])
;	lda #>[SCREENMEM+$A0] ; high byte
;	sta MovesCars + 1 ; 
;	lda #<[SCREENMEM+$A0] ; low byte 
;	sta MovesCars
	lda SCREEN_ADDR,x
	sta MovesCars
	inx
	lda SCREEN_ADDR,x
	sta MovesCars+1
	inx 

;	ldx #6            ; Count number of rows to shift

LeftShiftRow
	ldy #$00          ; Character position, start at +0 (dec)

	lda (MovesCars),y ; Read byte from screen (start +0)
	pha               ; Save to move to position +39.
	iny               ; now at offset +1 (dec)

MOVE1 ; Shift text lines to the left.
	lda (MovesCars),y ; Get byte from screen (start +1)
	dey
	sta (MovesCars),y ; Store byte at previous position (start +0)

	iny               ; Forward to the original read position. (start +1)
	iny               ; Forward to the next read position. (start +2)

	cpy #$27          ; Reached position $27/39 (dec) (end of line)?
	bne MOVE1         ; No.  Do the shift again.

	; Copy character at start of line to the end of the line.
	pla               ; Get character that was at the end of the line.
	ldy #$27          ; Offset $27/39 (dec)
	sta (MovesCars),y ; Save it at end of line.

	inx ; skip the beach line
	inx

	cpx #40 ; 21st line (20 base 0) times 2  
	bcc RightShiftRow ; Continue to loop, right, left, right, left

;	; Move to the next river/boat line to shift to the left 3 lines lower.
;	jsr MoveCarsPlus120

;	dex               ; Track a line is done.  All six done?
;	bne LeftShiftRow  ; No.  Go do left shift on another line.

	jsr CopyScoreToScreen ; Finish up by updating score display.

	rts


; ==========================================================================
; Copy the score from memory to screen positions.
; --------------------------------------------------------------------------
CopyScoreToScreen
PRITSC
	ldx #7

REPLACE
	lda MyScore,x       ; Read from Score buffer
	sta SCREENMEM+8,x   ; Screen Memory + 9th character 
	lda HiScore,x       ; Read from Hi Score buffer
	sta SCREENMEM+26,x  ; Screen Memory + 27th character
	dex                 ; Loop 8 bytes - 7 to 0.
	bpl REPLACE 

	rts


; ==========================================================================
; Display the number of frogs that crossed the river.
; --------------------------------------------------------------------------
PrintFrogsAndLives
PRINT2
	lda #INTERNAL_O     ; On Atari we're using "O" as the frog shape.
	ldx FrogsCrossed    ; number of times successfully crossed the rivers.
	beq FINLIV          ; then nothing to display. Skip to Lives.

SAVED_FROGGIES
	sta SCREENMEM+46,x  ; Write to screen. (second line, 16th position)
	dex                 ; Decrement number of frogs.
	bne SAVED_FROGGIES  ; then go back and display the next frog counter.

FINLIV ; Write the number of lives to screen memory
	lda NumberOfLives ; Get number of lives.
	clc               ; Add to value for  
	adc #INTERNAL_0   ; Atari internal code for '0'
	sta SCREENMEM+39  ; Write to screen. Last position ofz first line.

	rts


; ==========================================================================
; SET BOAT SPEED
; Set the animation timer for the game screen based on the 
; number of frogs that have been saved.
;
; A  and  X  will be saved.
; --------------------------------------------------------------------------
SetBoatSpeed
	mSaveRegAX

	ldx FrogsCrossed
	cpx #12                   ; Index is 0 to 11.   
	bcc GetSpeedByWayOfFrogs  ; anything bigger than that
	ldx #11                   ; must be truncated to the limit.
GetSpeedByWayOfFrogs
	lda ANIMATION_FRAMES,x    ; Set timer for animation based on frogs.
	jsr ResetTimers

	mRestoreRegAX

	rts


; ==========================================================================
; Display game screen
; --------------------------------------------------------------------------
DisplayGameScreen
PRINTSC 
	jsr ClearScreen 

;	ldy #PRINT_TEXT1_1
	ldx #2
PRINT ; Print TEXT1 -  beaches and boats, six times.
	jsr PrintToScreen

	inx
	inx
	inx
	iny 
;	cpy #PRINT_TEXT1_1+6  ; if we printed six times, (18 lines total) then we're done 
	bcc PRINT             ; Go back and print another set of lines.

; Print TEXT2 - Beach and Credits
;	ldy #PRINT_TEXT2
	ldx #21
	jsr PrintToScreen

; Print the Ported By Credit
;	ldy #PRINT_PORTBYTEXT
	ldx #24
	jsr PrintToScreen 

; Print the lives and score labels in the top two lines of the screen.
	ldy #PRINT_SCORE_TXT
	ldx #0
	jsr PrintToScreen

; Display the number of frogs that crossed the river.
	jsr PrintFrogsAndLives

; Set the animation timer for the game screen.
	jsr SetBoatSpeed

	; Reset frog position.
	ldy #$13           ; Y = #$13/19 (dec) 
	sty FrogColumn     ; Frog X coord

	rts



; ==========================================================================
; GAME OVER screen.
; Wait for a keypress.
; --------------------------------------------------------------------------
;INSTR ; Per PET Memory Map - Set integer value for SYS/GOTO ?
;	jsr ClearScreen 

; Print the lives and score labels in the top two lines of the screen.
;	ldy #PRINT_SCORE_TXT
;	jsr PrintToScreen

; Display the number of frogs that crossed the river.
;	jsr PrintFrogsAndLives

;	ldy #PRINT_GAMEOVER
;	jsr PrintToScreen

;INSTR1
;	jsr WaitKey           ; Atari polling the keyboard.

;	rts


; ==========================================================================
; Called once on program start.
; Use this to setup Atari display settings to imitate the   
; PET 4032's 40x25 display.
; --------------------------------------------------------------------------
GAMESTART
	; Atari initialization stuff...
	
	; Changing the Display List is potentially tricky.  If the update is 
	; interrupted by the Vertical blank, then it could mess up the display
	; list address and crash the Atari.  So, the code must make sure the 
	; system is not near the end of the screen to make the change.
	; The jiffy counter is updated during the vertical blank.  When the 
	; main code sees the counter change then it means the vertical blank is 
	; over, the electron beam is near the top of the screen thus there is 
	; now plenty of time to set the new display list pointer.  Technically, 
	; this should be done by managing SDMCTL too, but this is overkill for a 
	; program with only one display.

	jsr libScreenWaitFrame ; Wait for display to start next frame.

	; Safe to change Display list pointer now.  Would not be interrupted.
	lda #<DISPLAYLIST
	sta SDLSTL
	lda #>DISPLAYLIST
	sta SDLSTH

	; Tell the OS where screen memory starts 
	lda #<SCREENMEM ; low byte screen
	sta SAVMSC
	lda #>SCREENMEM ; hi byte screen
	sta SAVMSC+1

	lda #1
	sta CRSINH ; Turn off the displayed cursor.

	lda #0
	sta DINDEX ; Tell OS screen/cursor control is Text Mode 0
	sta LMARGN ; Set left margin to 0 (default is 2)

	lda #COLOR_GREEN ; Set screen base color dark green
	sta COLOR2       ; Background and
	sta COLOR4       ; Border
	lda #$0A
	sta COLOR1       ; Text brightness

	; End of Atari initialization stuff.

	; Continue with regular Pet Frogger initialization
	; Zero these values...
	lda #0 
	sta FlaggedHiScore
	sta LastKeyPressed

	lda #SCREEN_START  ; Set main game loop to start new game at title screen.
	sta CurrentScreen 

	jmp GameLoop ; Ready to go.  


; ==========================================================================
; RESET KEY SCAN TIMER and ANIMATION TIMER
; 
; A  is the time to set for animation.
; --------------------------------------------------------------------------
ResetTimers
	sta AnimateFrames

	pha ; preserve it for caller.
	lda #KEYSCAN_FRAMES
	sta KeyscanFrames
	pla ; get this back for the caller.

	rts


; ==========================================================================
; NEW GAME SETUP
; --------------------------------------------------------------------------
NewGameSetup
	lda #0
	sta FrogsCrossed       ; Zero the number of successful crossings.

	lda #<[SCREENMEM+$320] ; Low Byte, Frog position.
	sta FrogLocation      
	lda #>[SCREENMEM+$320] ; Hi Byte, Frog position.
	sta FrogLocation + 1

	ldy #$13               ; Y = 19 (dec)

	lda #INTERNAL_INVSPACE ; On Atari use inverse space for beach.
	sta LastCharacter      ; Preset the character under the frog.

	lda #$12               ; 18 (dec), number of screen rows of playfield.
	sta FrogRow
	lda #$30               ; 48 (dec), delay counter.
	sta DelayNumber

	lda #INTERNAL_O        ; On Atari we're using "O" as the frog shape.
	sta (FrogLocation),y   ; SCREENMEM + $320 + $13

	jsr ClearGameScores    ; Zero the score.  And high score if not set.

	rts


; ==========================================================================
; Clear the score digits to zeros.
; That is, internal screen code for "0" 
; If a high score is flagged, then do not clear high score.
; --------------------------------------------------------------------------
ClearGameScores
	ldx #$07           ; 8 digits. 7 to 0

CLEAR
	lda #INTERNAL_0    ; Atari internal code for "0"
	sta MyScore,x      ; Put zero/"0" in score buffer.
	ldy FlaggedHiScore ; Has a high score been flagged? ($FF) 
	bmi CLNEXT         ; If so, then skip this and go to the next digit.

	sta HiScore,x      ; Also put zero/"0" in the high score. 
	tay                ; Now Y also is zero/"0".
	lda #3             ; Reset number of 
	sta NumberOfLives  ; lives to 3.
	tya                ; A  is zero/"0" again.
	ldy #$13           ; Y = 19 (dec) (again)

CLNEXT
	dex                ; decrement index to score digits.
	bpl CLEAR          ; went from 0 to $FF? no, loop for next digit.

	rts


; ==========================================================================
; TOGGLE FLIP FLOP
;
; Flip toggle state 0, 1, 0, 1, 0, 1,....
;
; Ordinarily should be EOR with #1, but I don;t trust myself that
; Toggle state ends up being something greater than 1 due to some 
; moment of sloppiness, so the absolute, slower slogging about 
; with INC and AND is done here.
;
; Uses A, CPU flag status Z indicates 0 or 1
; --------------------------------------------------------------------------
ToggleFlipFlop
	inc ToggleState ; Add 1.  (says Capt Obvious)
	lda ToggleState
	and #1          ; Squash to only lowest bit -- 0, 1, 0, 1, 0, 1...
	sta ToggleState

	rts


; ==========================================================================
; GAME LOOP 
;
; The main loop for the game...
; Very vaguely like an event loop across the progressive game states 
; based on the current mode of the display.
;
; Rules:  "Continue" labels for the next screen/event block must  
;         be called with screen value in A.
; --------------------------------------------------------------------------

GameLoop
; ==========================================================================
; SCREEN START/NEW GAME
; Setup for New Game and do transition to Title screen.
; --------------------------------------------------------------------------
	lda CurrentScreen
	cmp #SCREEN_START
	bne ContinueTitleScreen ; SCREEN_START=0?  No? 

	jsr NewGameSetup        ; SCREEN_START, Yes. Setup for a new game.

	jsr DisplayTitleScreen  ; Draw title and game instructions.

	lda #60                 ; Text Blinking speed for prompt on Title screen.
	jsr ResetTimers

	lda #SCREEN_TITLE ; Next step is operating the title screen input.
	sta CurrentScreen

; ==========================================================================
; TITLE SCREEN
; The activity on the title screen is 
; 1) blinking the text and 
; 2) waiting for a key press.
; --------------------------------------------------------------------------
ContinueTitleScreen
	cmp #SCREEN_TITLE
	bne ContinueTransitionToGame

	lda AnimateFrames            ; Did animation counter reach 0 ?
	bne CheckTitleKey            ; no, then is a key pressed? 

	jsr ToggleFlipFlop           ; Yes! Let's toggle the flashing prompt

	bne TitlePromptInverse       ; If this is 1 then display inverse prompt

	ldy #PRINT_INST_TXT4         ; Display normal prompt
	ldx #23
	jsr PrintToScreen
	jmp ResetTitlePromptBlinking

TitlePromptInverse
	ldy #PRINT_INST_TXT4_INV     ; Display inverse prompt
	ldx #23
	jsr PrintToScreen

ResetTitlePromptBlinking
	lda #60                      ; Blinking speed.
	jsr ResetTimers

CheckTitleKey
	jsr CheckKey                 ; Get a key if timer permits.
	cmp #$FF                     ; Key is pressed?
	beq EndTitleScreen           ; Nothing pressed, done with title screen.

ProcessTitleScreenInput          ; a key is pressed. Prepare for the screen transition.
	lda #10                      ; Text moving speed.
	jsr ResetTimers

	lda #3                       ; Transition Loops from third row through 21st row.
	sta EventCounter

	lda #0                       ; Mark frog as safe location.
	sta FrogSafety

	lda #SCREEN_TRANS_GAME       ; Next step is operating the transition animation.
	sta CurrentScreen   

EndTitleScreen
	lda CurrentScreen            ; Yeah, redundant to when a key is pressed.

; ==========================================================================
; TRANSITION TO GAME SCREEN
; The Activity in the transition area, based on timer.
; 1) Progressively reprint the credits on lines from the top of the screen 
; to the bottom.
; 2) follow with a blank line to erase the highest line of trailing text.
; --------------------------------------------------------------------------
ContinueTransitionToGame
	cmp #SCREEN_TRANS_GAME
	bne ContinueGameScreen

	lda AnimateFrames        ; Did animation counter reach 0 ?
	bne EndTransitionToGame  ; Nope.  Nothing to do.
	lda #10                  ; yes.  Reset it.
	jsr ResetTimers

	ldy #PRINT_BLANK_TXT    ; erase top line
	ldx EventCounter
	jsr PrintToScreen

	inx                     ; next row.
	stx EventCounter        ; Save new row number
	ldy #PRINT_CREDIT_TXT   ; Print the culprits responsible
	jsr PrintToScreen

	cpx #21                 ; reached bottom of screen?
	bne EndTransitionToGame ; No.  Remain on this transition event next time.

	jsr DisplayGameScreen   ; Draw title and game instructions.; draw game screen.

	lda #SCREEN_GAME        ; Yes, change to game screen.
	sta CurrentScreen

EndTransitionToGame
	lda CurrentScreen

; ==========================================================================
; GAME SCREEN
; Play the game.
; 1) When the animation timer expires, shift the boat rows.
; 2) When the input timer allows, get a key.
; 3) Evaluate frog Movement
; 3.a) Determine exit to Win screen
; 3.b) Determine exit to Dead screen.
; --------------------------------------------------------------------------
ContinueGameScreen
	cmp #SCREEN_GAME
	bne ContinueTransitionToWin


CheckTitleKey
	jsr CheckKey         ; Get a key if timer permits.
	cmp #$FF             ; Key is pressed?
	bne ProcessKey       ; Something pressed, Do key input.

DELAY
	sta LastKeyPressed   ; Save $FF, for no key pressed.
	lda FrogColumn
	tya                  ; Whatever Y was, probably $13/19 (dec) again,
	pha                  ; and push that to the stack.  must be important.

	lda AnimateFrames    ; Does the timer allow the boats to move?
	bne NOTHINGTODOHERE
;	jsr MOVESC           ; Move the boats around.
	jsr AnimateBoats     ; Move the boats around.

;	ldx DelayNumber      ; Get the Delay counter.

DEL1
;	ldy #$FF             ; Reset Y to $FF/255 (dec)

;DEL
;	dey                  ; decrement Y counter
;	bne DEL              ; if Y is not 0, then do the decrement again.
;	dex                  ; decrement delay counter.
;	bne DEL1             ; If X is not 0, then wind up Y again and start over.

;	pla                  ; Pull original Y value
;	tay                  ; and return to Y.
	jmp AUTMVE           ; GOTO AUTOMVE


ProcessKey
KEY1 ; Process keypress
	pha                  ; A is a keypress, but the value of
;	lda #$FF             ; CH needs to be cleared.
;	sta CH
;	pla                  ; A has the original keypress again.  Continue....

	cmp LastKeyPressed   ; is this key the same as the last key?
	BEQ DELAY            ; Yes.  So, probably a key repeat, so ignore it and do delay.

	tax                  ; Save that key in X, too.
	lda LastCharacter    ; Get the last character (under the frog)
	sta (FrogLocation),y ; Erase the frog with the last character.

; Test for Left "4" key
	txa                  ; Restore the key press to A
	cmp #KEY_4           ; Atari "4", #24
	bne RIGHT            ; No.  Go test for Right.

	dey                  ; Move Y to left.
;	cpy #$FF             ; Did it move off the screen?
;	bne CORR             ; No.  GOTO CORR (Place frog on screen)
	bpl CORR             ; Not $FF.  GOTO CORR (Place frog on screen)
	iny                  ; Is $FF.  Correct by adding 1 to Y.

CORR
	jmp PLACE ; Place frog on screen (?)


RIGHT ; Test for Right "6" key
	cmp #KEY_6           ; Atari "6", #27
	bne UP               ; Not "6" key, so go test for Up.

	iny                  ; Move Y to right.
	cpy #$28             ; Did it move off screen? Position $28/40 (dec)
	bne CORR1            ; No.  GOTO CORR1  (Place frog on screen)
	DEY                  ; Yes.  Correct by subtracting 1 from Y.

CORR1    ; couldn't the BNE above just go to CORR in order to jump to PLACE?
	jmp PLACE


UP ; Test for Up "S" key
	cmp #KEY_S           ; Atari "S", #62
	beq UP1              ; Yes, go do UP.

; No.  key press is not a frog control key.  Replace frog where it came from.
	lda #INTERNAL_O      ; On Atari we're using "O" as the frog shape.
	sta (FrogLocation),y ; Return frog to screen
	jmp DELAY            ; Go to the delay

UP1 ; Move the frog a row up.
	lda #1               ; Represents "10" Since we don't need to add to the ones column.  
	sta ScoreToAdd       ; Save to add 1
	ldx #5               ; Offset from start of "00000000" to do the adding.
	stx NumberOfChars    ; Position offset in score.
	jsr SCORE            ; Deal with score update.

	lda FrogLocation     ; subtract $28/40 (dec) from 
	sec                  ; the address pointing to 
	sbc #$28             ; the frog.
	sta FrogLocation
	bcs CORR2
	dec FrogLocation + 1 

CORR2 ; decrement number of rows.
;	sec                  ; ummm.  Does carry affect dec? did not think so.
	dec FrogRow
	lda FrogRow     ; If more row are left to cross, then 
;	cmp #0               
	bne PLACE            ; redraw frog on screen. 

	jmp FROG             ; No more rows to cross. Update frog reward/stats.


; Get the character that will be under the frog.
PLACE
	lda (FrogLocation),y ; Get the character in the new position.
	sta LastCharacter    ; Save for later when frog moves.
	jmp CHECK


; Draw the frog on screen.
PLACE2 
	lda #INTERNAL_O       ; Atari internal code for "O" is frog.
	sta (FrogLocation),y ; Save to screen memory to display it.
	jmp DELAY            ; Slow down game speed.
	rts


; Will the Pet Frog land on the Beach?
CHECK
	lda LastCharacter      ; Is the character the beach?
	cmp #INTERNAL_INVSPACE ; Atari uses inverse space for beach
	bne CHECK1             ; not the beach?  Goto CHECK1
	jmp PLACE2             ; Draw the frog.


; Will the Pet Frog land in the boat?
CHECK1
	cmp #INTERNAL_BALL     ; Atari uses ball graphics, ctrl-t
	bne CHECK2             ; No?   GOTO CHECK2 to die.
	jmp PLACE2             ; Draw the frog.


; Safe locations discarded, so wherever the Frog will land, it is Baaaaad.
CHECK2
	jmp YRDD               ; Yer Dead!


	
	
	

EndGameScreen
	lda CurrentScreen   

; ==========================================================================
; TRANSITION TO WIN SCREEN
; The Activity in the transition area, based on timer.
; 1) Animate something.
; 2) End With display of WIN Screen.
; --------------------------------------------------------------------------
ContinueTransitionToWin
	cmp #SCREEN_TRANS_WIN
	bne ContinueWinScreen



EndTransitionToWin
	lda CurrentScreen  

; ==========================================================================
; WIN SCREEN
; The activity in the WIN screen.
; 1) blinking the text and 
; 2) waiting for a key press.
; --------------------------------------------------------------------------
ContinueWinScreen
	cmp #SCREEN_WIN
	bne ContinueTransitionToDead
	
	
	
EndWinScreen
	lda CurrentScreen 

; ==========================================================================
; TRANSITION TO DEAD SCREEN
; The Activity in the transition area, based on timer.
; 1) Animate something.
; 2) End With display of DEAD Screen.
; --------------------------------------------------------------------------
ContinueTransitionToDead
	cmp #SCREEN_TRANS_DEAD
	bne ContinueDeadScreen



EndTransitionToDead
	lda CurrentScreen  

; ==========================================================================
; DEAD SCREEN
; The activity in the DEAD screen.
; 1) blinking the text and 
; 2) waiting for a key press.
; 3.a) Evaluate to continue to game screen
; 3.b.) Evaluate to continue to Game Over
; --------------------------------------------------------------------------
ContinueDeadScreen
	cmp #SCREEN_DEAD
	bne ContinueTransitionToOver
	
	
	
EndDeadScreen
	lda CurrentScreen 

; ==========================================================================
; TRANSITION TO GAME OVER SCREEN
; The Activity in the transition area, based on timer.
; 1) Animate something.
; 2) End With display of GAME OVER Screen.
; --------------------------------------------------------------------------
ContinueTransitionToOver
	cmp #SCREEN_TRANS_OVER
	bne ContinueOverScreen



EndTransitionToOver
	lda CurrentScreen  

; ==========================================================================
; GAME OVER SCREEN
; The activity in the DEAD screen.
; 1) blinking the text and 
; 2) waiting for a key press.
; --------------------------------------------------------------------------
ContinueOverScreen
	cmp #SCREEN_OVER
	bne ContinueTransitionToTitle
	
	
	
EndOverScreen
	lda CurrentScreen 

; ==========================================================================
; TRANSITION TO TITLE 
; The Activity in the transition area, based on timer.
; 1) Animate something.
; 2) End With going to the Title Screen.
; --------------------------------------------------------------------------
ContinueTransitionToTitle
	cmp #SCREEN_TRANS_TITLE
	bne EndGameLoop



EndTransitionToTitle
	lda CurrentScreen  

; ==========================================================================
; END OF GAME EVENT LOOP
; --------------------------------------------------------------------------
EndGameLoop
	jsr TimerLoop    ; Wait for end of frame and update timers.

	jmp GameLoop

	rts





;START




;	jsr PRINTSC        ; Go clear screen and print game screen
;	ldy #$13           ; Y = 19 (dec) (again, again)


;KEY ; Read keyboard.  (I hate keyboard input.  TO DO - Use a joystick.)
;	lda CH             ; Atari get key pressed
;	cmp #$FF           ; Check for no key pressed (same for PET and Atari)
;	bne KEY1           ; Not $FF, then something is pressed.


;DELAY
	sta LastKeyPressed ; Save $FF, for no key pressed.
	tya                ; Whatever Y was, probably $13/19 (dec) again,
	pha                ; and push that to the stack.  must be important.
	jsr MOVESC         ; Move the boats around.

	ldx DelayNumber    ; Get the Delay counter.
DEL1
	ldy #$FF           ; Reset Y to $FF/255 (dec)

DEL
	dey                ; decrement Y counter
	bne DEL            ; if Y is not 0, then do the decrement again.
	dex                ; decrement delay counter.
	bne DEL1           ; If X is not 0, then wind up Y again and start over.

	pla                ; Pull original Y value
	tay                ; and return to Y.
	jmp AUTMVE         ; GOTO AUTOMVE


KEY1 ; Process keypress
	pha                  ; A is a keypress, but the value of
	lda #$FF             ; CH needs to be cleared.
	sta CH
	pla                  ; A has the original keypress again.  Continue....

	cmp LastKeyPressed   ; is this key the same as the last key?
	BEQ DELAY            ; Yes.  So, probably a key repeat, so ignore it and do delay.

	tax                  ; Save that key in X, too.
	lda LastCharacter    ; Get the last character (under the frog)
	sta (FrogLocation),y ; Erase the frog with the last character.

; Test for Left "4" key
	txa                  ; Restore the key press to A
	cmp #KEY_4           ; Atari "4", #24
	bne RIGHT            ; No.  Go test for Right.

	dey                  ; Move Y to left.
;	cpy #$FF             ; Did it move off the screen?
;	bne CORR             ; No.  GOTO CORR (Place frog on screen)
	bpl CORR             ; Not $FF.  GOTO CORR (Place frog on screen)
	iny                  ; Is $FF.  Correct by adding 1 to Y.

CORR
	jmp PLACE ; Place frog on screen (?)


RIGHT ; Test for Right "6" key
	cmp #KEY_6           ; Atari "6", #27
	bne UP               ; Not "6" key, so go test for Up.

	iny                  ; Move Y to right.
	cpy #$28             ; Did it move off screen? Position $28/40 (dec)
	bne CORR1            ; No.  GOTO CORR1  (Place frog on screen)
	DEY                  ; Yes.  Correct by subtracting 1 from Y.

CORR1    ; couldn't the BNE above just go to CORR in order to jump to PLACE?
	jmp PLACE


UP ; Test for Up "S" key
	cmp #KEY_S           ; Atari "S", #62
	beq UP1              ; Yes, go do UP.

; No.  key press is not a frog control key.  Replace frog where it came from.
	lda #INTERNAL_O      ; On Atari we're using "O" as the frog shape.
	sta (FrogLocation),y ; Return frog to screen
	jmp DELAY            ; Go to the delay

UP1 ; Move the frog a row up.
	lda #1               ; Represents "10" Since we don't need to add to the ones column.  
	sta ScoreToAdd       ; Save to add 1
	ldx #5               ; Offset from start of "00000000" to do the adding.
	stx NumberOfChars    ; Position offset in score.
	jsr SCORE            ; Deal with score update.

	lda FrogLocation     ; subtract $28/40 (dec) from 
	sec                  ; the address pointing to 
	sbc #$28             ; the frog.
	sta FrogLocation
	bcs CORR2
	dec FrogLocation + 1 

CORR2 ; decrement number of rows.
;	sec                  ; ummm.  Does carry affect dec? did not think so.
	dec FrogRow
	lda FrogRow     ; If more row are left to cross, then 
;	cmp #0               
	bne PLACE            ; redraw frog on screen. 

	jmp FROG             ; No more rows to cross. Update frog reward/stats.


; Get the character that will be under the frog.
PLACE
	lda (FrogLocation),y ; Get the character in the new position.
	sta LastCharacter    ; Save for later when frog moves.
	jmp CHECK


; Draw the frog on screen.
PLACE2 
	lda #INTERNAL_O       ; Atari internal code for "O" is frog.
	sta (FrogLocation),y ; Save to screen memory to display it.
	jmp DELAY            ; Slow down game speed.
	rts


; Will the Pet Frog land on the Beach?
CHECK
	lda LastCharacter      ; Is the character the beach?
	cmp #INTERNAL_INVSPACE ; Atari uses inverse space for beach
	bne CHECK1             ; not the beach?  Goto CHECK1
	jmp PLACE2             ; Draw the frog.


; Will the Pet Frog land in the boat?
CHECK1
	cmp #INTERNAL_BALL     ; Atari uses ball graphics, ctrl-t
	bne CHECK2             ; No?   GOTO CHECK2 to die.
	jmp PLACE2             ; Draw the frog.


; Safe locations discarded, so wherever the Frog will land, it is Baaaaad.
CHECK2
	jmp YRDD               ; Yer Dead!


; ==========================================================================
; Data to drive AUTOMVE routine.
; Byte value indicates direction of row movement.
; 0   = Beach line, no movement.
; 1   = first boat/river row, move right
; 255 = second boat/river row, move left.
; --------------------------------------------------------------------------
DATA
	.BYTE 0, 1, 255
	.BYTE 0, 1, 255
	.BYTE 0, 1, 255
	.BYTE 0, 1, 255
	.BYTE 0, 1, 255
	.BYTE 0, 1, 255

	brk

; Process automagical movement on the frog in the boat.
AUTMVE
	ldx FrogRow   ; Get the current row number.
	lda DATA,x         ; Get the movement flag for the row.
	cmp #0             ; Is it 0?  Nothing to do.  Bail and go back to keyboard polling..  
	beq RETURN         ; (ya know, the cmp was not actually necessary.)
	cmp #$FF           ; is it $ff?  then automatic right move.
	bne AUTRIG         ; (ya know, could have done  bmi AUTRIG without the cmp).
	dey                ; Move Frog left one character
	cpy #0             ; Is it at 0? (Why not check for $FF here (or bmi)?)
	bne RETURN         ; No.  Bail and go back to keyboard polling.
	jmp YRDD           ; Yup.  Ran out of river.   Yer Dead!

AUTRIG 
	iny                ; Move Frog right one character
	cpy #$28           ; Did it reach the right side ?    $28/40 (dec)
	bne RETURN         ; No.  Bail and go back to keyboard polling.
	jmp YRDD           ; Yup.  Ran out of river.   Yer Dead!

RETURN
	jmp KEY            ; Return to keyboard polling.





; Frog is dead.
YRDD
	lda #INTERNAL_ASTER  ; Atari ASCII $2A/42 (dec) Splattered Frog.
	sta (FrogLocation),y ; Road kill the frog.
	jsr DELAY1           ; Various pauses....
	jsr DELAY1           ; Should do this with  jiffy counters. future TO DO.
	jsr DELAY1
	jsr DELAY1
	jsr FILLSC           ; Fill screen with inverse blanks.

; Print the dead frog prompt.
;	ldy #PRINT_YRDDTX
	jsr PrintToScreen

; Decide   G A M E   O V E R-ish
GAMEOV
	lda #0
;	sta $9E              ; Zero a Pet interrupt  ?????
	jsr PRITSC           ; update display.
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	dec NumberOfLives    ; subtract a life.
	lda NumberOfLives
	cmp #0               ; 0 lives left means
	beq GOV              ; definitely game over.
	lda #$FF
	sta FlaggedHiScore   ; flag the high score
	jmp START1


GOV
	lda #$FF
	sta CH    ; Atari.  Make sure key is cleared.
	jmp GOVER ; G A M E   O V E R




FROG
	inc FrogsCrossed     ; Add to frogs successfully crossed the rivers.
	jsr FILLSC           ; Update the score display

FROG1 ; Print the frog wins text.
;	ldy #PRINT_FROGTXT
	jsr PrintToScreen

FROG2  ; More score maintenance.   and delays.
	jsr SCORE
	jsr PRITSC
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jmp NEXTFR


FILLSC  ; Setup pointer to screen. then fill screen
	lda #<[SCREENMEM+$50]  ; point to screen memory +80 bytes (2 lines from top)
	sta ScreenPointer
	lda #>[SCREENMEM+$50]
	sta ScreenPointer+1

; This was inside FILL, but only needs to be done once before the loop
	ldy #0
FILL ; Fill screen with the "beach" characters
	lda #INTERNAL_INVSPACE ; Atari beach character is inverse space.
	sta (ScreenPointer),y
	lda ScreenPointer      ; Increment  
	clc                    ; the  
	adc #1                 ; pointer 
	sta ScreenPointer      ; to  
	lda ScreenPointer+1    ; screen 
	adc #0                 ; memory.
	sta ScreenPointer+1    ; You know, inc lowbyte, bne FILL works instead of adc.
	cmp #>[SCREENMEM+$400] ; Did high byte reach $8400 (screen memory + 1K)?
	bne FILL               ; Nope, continue filling.

; Setup for score update.
	ldx #4
	lda #5

	stx NumberOfChars      ; Index into "00000000" to add the score.
	sta ScoreToAdd         ; Add 5 which represents "500" to the score.  Don't need 10s or 1s values, since they are 0.

	jsr PRINT2             ; Display frogs count
	ldy #0
	rts


; ==========================================================================
; Update starting frog position.
; --------------------------------------------------------------------------
NEXTFR
	lda DelayNumber        ; Subtract 3 from delay number...
	sec
	sbc #3
	sta DelayNumber

START1 ; Manage frog's starting postion.
	lda #<[SCREENMEM+$320] ; Set Frog Location pointer to $8320
	sta FrogLocation
	lda #>[SCREENMEM+$320]
	sta FrogLocation + 1

	jsr PRINTSC
	jsr MOVESC

	lda #INTERNAL_INVSPACE ; Atari: Beach character 
	sta LastCharacter      ; Prep space under frog

	lda #INTERNAL_O        ; Atari: using "O" as the frog shape.

	ldy #$13               ; Y = 19 (dec) the middle of screen
	sta (FrogLocation),y   ; Erase Frog starting position.
	lda #$12               ; A = 18 (dec)
	sta FrogRow       ; Save as number of rows to jump
	
	jmp KEY                ; GOTO Key input


; ==========================================================================
; D E  L   A    Y          L      O       O        P
; Count down X=255 to 0 by Y=255 times.  
; --------------------------------------------------------------------------
DELAY1
	ldx #$FF

DELA1
	ldy #$FF

DELA
	dey
	bne DELA

	dex
	bne DELA1
	rts


; ==========================================================================
; Add to score.
; --------------------------------------------------------------------------
SCORE
	mRegSaveAYX               ; Save A, X, and Y.

	ldx NumberOfChars ; index into "00000000" to add score.
	lda ScoreToAdd    ; value to add to the score
	clc
	adc MyScore,x
	sta MyScore,x

SCORE1                   ; (re)evaluate if carry occurred for the current position.
	lda MyScore,x
	cmp #[INTERNAL_0+10] ; Did math carry past the "9"?
	bcc PULL             ; if it does not carry , then go to exit.

; The score carried past "9", so it must be adjusted and
; the next/greater position is added.
UPDATE
	lda #INTERNAL_0 ; Atari internal code for "0".  
	sta MyScore,x   ; Reset current position to "0"
	dex             ; Go to previous position in score
	inc MyScore,x   ; Add 1 to the next digit.
	bne SCORE1      ; This cannot go from $FF to 0, so it must be not zero.
;	jmp SCORE1      ; go (re)evaluate carry for the current position.

PULL                     ; All done.
	mRegRestoreAYX  ; Restore Y, X, and A

	rts


; ==========================================================================
; Game Over - Prompt to go again.
; --------------------------------------------------------------------------
GOVER
	ldy #0

GOVER1                 ; Print the go again message.
;	ldy #PRINT_OVER
	jsr PrintToScreen

GOVER2
	jsr WaitKey        ; For Atari, wait for a key press.  returned in A
	cmp #KEY_Y         ; keyboard code for Y 
	bne GOVER3         ; Not "Y".

	jsr HISC           ; Manage high score
	lda #$FF           ; Re-init a few things. . . .
	sta FlaggedHiScore ;
	lda #0
	sta FrogsCrossed
	lda #3
	sta NumberOfLives
	jmp START          ; Back to start.

GOVER3
	jsr INSTR          ; Display instructions.
	jsr HISC           ; Manage high score
	lda #$FF
	sta FlaggedHiScore ; Re-init a few things. . . .
	lda #3
	sta NumberOfLives
	jmp START          ; Back to start.


; ==========================================================================
; Figure out if My Score is the High Score
; --------------------------------------------------------------------------
HISC
	lda #0

HISC2
	lda MyScore,x    ; Get my score
	clc
	cmp HiScore,x    ; Compare to high score
	beq NOT          ; Equals?  then sofar it is not high score
	bcs HISC1        ; Greater than.  Could be high score.

NOT
	inx              
	cpx #7           ; Are all 7 digits tested?
	bne HISC2        ; No, then go do next digit.
	rts              ; Yes.  Done.

HISC1                ; It is a high score.
	lda MyScore,x    ; Copy my score to high score
	sta HiScore,x
	inx
	cpx #7           ; if the first 7 digits are not done testing, then
	bne HISC1        ; go test next digit.

	rts


; ==========================================================================
; Check for a keypress based on timer state. 
;
; A  returns the key pressed.  or returns $FF for no key pressed.
; If the timer allows reading, and a key is found, then the timer is 
; reset for the time of the next key input cycle.
; --------------------------------------------------------------------------
CheckKey
	lda KeyscanFrames         ; Is keyboard timer delay  0?
	bne ExitCheckKeyNow       ; No. thus no key to scan.

	lda CH
	pha                       ; Save the key for later

	cmp #$FF                  ; No key pressed, so nothing to do.
	beq ExitCheckKey
	 
	lda #$FF                  ; Got a key.  Clear register for next key read
	sta CH

	lda #KEYSCAN_FRAMES       ; Reset keyboard timer for next key input.
	sta KeyscanFrames

ExitCheckKey                  ; exit with some kind of key value in A.
	pla                       ; restore the pressed key in A.
	rts

ExitCheckKeyNow               ; exit with no key value in A
	lda #$FF
	rts


; ==========================================================================
; Wait for a keypress. 
;
; A  returns the key pressed.
; --------------------------------------------------------------------------
WaitKey
	lda #$FF
	sta CH          ; Clear any pending key

WaitKeyLoop
	lda CH
	cmp #$FF        ; No key pressed
	beq WaitKeyLoop ; Loop until a key is pressed.

	pha             ; Save the key
	lda #$FF
	sta CH          ; Clear any pending key
	pla             ; return the pressed key in A.

	rts


;==============================================================================
;                                                           TIMERLOOP  A
;==============================================================================
; Primitive timer loop.
;
; When the game design is more Atari-ficated (planned Version 02) this is part 
; of the program's deferred Vertical Blank Interrupt routine.  This routine 
; services any display-oriented updates and notifications for the mainline 
; code that runs during the bulk of the frame.
;
; Main code calls this at the end of its cycle, then afterwards it restarts 
; its cycle.  
; This routine waits for the current frame to finish display, then 
; manages the timers/countdown values.
; It is the responsibility of the main line code to observe when timers
; reach 0 and reset them or act accordingly.
;
; All registers are preserved.
;==============================================================================

TimerLoop
	mRegSaveAYX

	lda DoTimers           ; Are timers turned on or off?
	beq ExitEventLoop      ; Off, skip it all.

	jsr libScreenWaitFrame ; Wait until end of frame

	lda KeyscanFrames      ; Is keyboard delay already 0?
	beq DoAnimateClock     ; Yes, do not decrement it again.
	dec KeyscanFrames      ; Minus 1.

DoAnimateClock
	lda AnimateFrames      ; Is animation countdown already 0?
	beq ExitEventLoop      ; Yes, do not decrement now.
	dec AnimateFrames      ; Minus 1

ExitEventLoop
	mRegRestoreAYX

	rts


;==============================================================================
;                                                       SCREENWAITFRAMES  A  Y
;==============================================================================
; Subroutine to wait for a number of frames.
;
; FYI:
; Calling with A = 1 is the same thing as directly calling ScreenWaitFrame.
;
; ScreenWaitFrames expects A to contain the number of frames.
;
; ScreenWaitFrames uses  Y
;==============================================================================
	
libScreenWaitFrames
	sty SAVEY           ;  Save what is here, can't go to stack due to tay 
	tay
	beq bExitWaitFrames

bLoopWaitFrames
	jsr libScreenWaitFrame

	dey
	bne bLoopWaitFrames ; Still more frames to count?   go 

bExitWaitFrames
	ldy SAVEY           ; restore Y
	rts                 ; No.  Clock changed means frame ended.  exit.


;==============================================================================
;                                                           SCREENWAITFRAME  A
;==============================================================================
; Subroutine to wait for the current frame to finish display.
;
; ScreenWaitFrame  uses A
;==============================================================================
	
libScreenWaitFrame
	pha                ; Save A, so caller is not disturbed.
	lda RTCLOK60       ; Read the jiffy clock incremented during vertical blank.

bLoopWaitFrame
	cmp RTCLOK60       ; Is it still the same?
	beq bLoopWaitFrame ; Yes.  Then the frame has not ended.

	pla                ; restore A
	rts                ; No.  Clock changed means frame ended.  exit.


; ==========================================================================
; When a custom character set is used, it would go here:
; --------------------------------------------------------------------------

;	ORG $7800 ; 1K from $7800 to $7BFF
;CHARACTERSET


; ==========================================================================
; Custom Character Set Planning . . . **Minimum setup.
;
;  1) **Frog
;  2) **Boat Front Right
;  3) **Boat Back Right
;  4) **Boat Front Left
;  5) **Boat Back Left
;  6) **Boat Seat
;  7) **Splattered Frog.
;  8)   Waves 1
;  9)   Waves 2
; 10)   Waves 3
; 11) **Beach 1
; 12)   Beach 2
; 13)   Beach 3
;
; --------------------------------------------------------------------------


; ==========================================================================
; Force the Atari to impersonate the PET 4032 by setting the 40-column
; text mode memory to the same fixed address.  This minimizes the 
; amount of code changes for screen memory.
;
; But, first we need a 25-line ANTIC Mode 2 text screen which means a  
; custom display list.
; 
; The Atari OS text printing is not being used, therefore the Atari screen 
; editor's 24-line limitation is not an issue. 
; --------------------------------------------------------------------------

	ORG $7FD8  ; $xxD8 to xxFF - more than enough space for Display List
	
DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_8, DL_BLANK_4 ; 20 blank scan lines.
	mDL_LMS DL_TEXT_2,SCREENMEM              ; Mode 2 text and Load Memory Scan for text/graphics
	.rept 24
		.byte DL_TEXT_2                      ; 24 more lines of Mode 2 text.
	.endr
	.byte DL_JUMP_VB
	.word DISPLAYLIST


; ==========================================================================
; Make Screen memory the same location the Pet uses for screen memory.
; --------------------------------------------------------------------------
	ORG $8000

SCREENMEM


; ==========================================================================
; Inform DOS of the program's Auto-Run address...
; --------------------------------------------------------------------------
	mDiskDPoke DOS_RUN_ADDR, GAMESTART
	
	
	END

