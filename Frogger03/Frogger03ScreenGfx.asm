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
; Version 03, May 2019
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

; Revised V03 Main Game Play Screen:
; FYI: Old boats.
; 8  | [QQQQ1        [QQQQ1       [QQQQ1      | TEXT1_2
; 9  |      <QQQQ0        <QQQQ0    <QQQQ0    | TEXT1_2
; New boats are larger to provide more safe surface for the larger 
; frog and to provide some additional graphics enhancement for 
; the boats.  Illustration below shows the entire memory needed 
; for scrolling.  Since boats on each row are identical, and 
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



; Game-specific Shapes:
;SHAPE_OFF   = 0
;SHAPE_FROG  = 1
;SHAPE_SPLAT = 2
;SHAPE_TOMB  = 3


; ==========================================================================
; Set the splattered frog on the screen.
;
; Write the splat frog character into screen memory.
; --------------------------------------------------------------------------

SetSplatteredOnScreen
;	lda #I_SPLAT
	lda #SHAPE_SPLAT
	sta FrogNewShape
;	bne UpdateFrogInScreenMemory

	rts


; ==========================================================================
; Set the frog on the screen.
;
; Write the Frog character into screen memory.
; --------------------------------------------------------------------------

SetFrogOnScreen
;	lda #I_FROG
	lda #SHAPE_SPLAT
	sta FrogNewShape
;	bne UpdateFrogInScreenMemory

	rts


; ==========================================================================
; Remove the frog from the screen.
;
; Restore the character that is under the frog.
;
; Note this falls right into UpdateFrogInMemory.
; --------------------------------------------------------------------------

RemoveFrogOnScreen
;	lda LastCharacter  ; Get the last character (under the frog)
	lda #0
	sta FrogNewShape

	rts


; N/A  ?  No frog in screen memory, but update P/M graphics?
; ==========================================================================
; Update the frog image in screen memory.
;
; Score/Lives, and the frog are the only place where screen memory
; is being changed.  The actual movements of boats does not move in
; screen memory.  Coarse scrolling is done by updating LMS in the
; Display List.
;
; The 80 characters of scrolling (twice the visible screen width) means
; there must be two frogs in the screen memory for the current row.
; One frog at the X location, one at the X location + 40. Whichever one
; is actually seen on screen depends on current scroll offset.  The scroll
; offset could be reset to the origin at any time, therefore the frog must
; be displayed in the adjusted place.
;
; In the future the Frog will be a P/M graphics object, and then this
; discussion is a complete non-issue as moving the frog will only require
; changing the P/MG HPOS value.
;
; A  is the byte value to store.
; It could be the frog, splattered frog, or the character under the frog.
; --------------------------------------------------------------------------

UpdateFrogInScreenMemory
;	ldy FrogRealColumn1  ; Current X coordinate
;	sta (FrogLocation),y ; Erase the frog with the last character.
;	ldy FrogRealColumn2  ; Current X coordinate of alternate scroll location
;	sta (FrogLocation),y ; Erase the frog with the last character.

	rts


; N/A  -  No frog in screen memory
; ==========================================================================
; Get the character from screen memory where the frog will reside.
; Save it to lastCharacter to restore as needed.
; --------------------------------------------------------------------------
;GetScreenMemoryUnderFrog
;	ldy FrogRealColumn1
;	lda (FrogLocation),y
;	sta lastCharacter

;	rts


; ==========================================================================
; Print the instruction/title screen text.
; Set state of the text line that is blinking.
; --------------------------------------------------------------------------

DisplayTitleScreen
	lda #DISPLAY_TITLE   ; Tell VBI to change screens.
	jsr ChangeScreen     ; Then copy the color tables.

	rts


; ==========================================================================
; Display the game screen.
; ==========================================================================
; The credits at the bottom of the screen is still always redrawn.
; From the title screen it is animated to move to the bottom of the
; screen.  But from the Win and Dead frog screens the credits
; are overdrawn.
; --------------------------------------------------------------------------

DisplayGameScreen
	mRegSaveAYX             ; Save A and Y and X, so the caller doesn't need to.

;	jsr ResetGamePlayfield ; initialize all game playfield LMS values.

	jsr SetBoatSpeed       ; Animation speed set by number of saved frogs

	; Display the current score and number of frogs that crossed the river.
	jsr CopyScoreToScreen
	jsr PrintFrogsAndLives

	lda #DISPLAY_GAME      ; Tell VBI to change screens.
	jsr ChangeScreen       ; Then copy the color tables.

	mRegRestoreAYX          ; Restore X, Y and A

	rts


; N/A  -  VBI continuously scrolls boats
; ==========================================================================
; ANIMATE BOATS
; ==========================================================================
; Move the lines of boats around either left or right.
; Changed logic for moving lines.  The original code moved all the
; rows going right then all the rows going left.
; This version does each line in order from the top to the bottom of
; the screen.  This is done on the chance that the code is racing the
; screen rendering and so we don't want main line execution to find
; a pattern where the code is updating a text line that is being
; displayed and we end up with tearing animation.
; --------------------------------------------------------------------------
;AnimateBoats
	; Update with working positions of the scrolling lines.

;	dec CurrentRightOffset ; subtract one to move screen contents right.
;	bpl IncLeftOffset      ; It did not go negative. Done. Go update screen.
;	lda #39                ; Fell off the end.  Restart.
;	sta CurrentRightOffset ; reset to scroll start.

;IncLeftOffset
;	inc CurrentLeftOffset  ; subtract one to move screen contents left.
;	lda CurrentLeftOffset
;	cmp #40                ; 40th position is identical to 0th,
;	bne UpdatePlayfieldLMS ; Did not go off the deep end. Done. Go update screen.
;	lda #0                 ; Fell off the end.  Restart.
;	sta CurrentLeftOffset  ; reset to scroll start.

;UpdatePlayfieldLMS
	; We could cleverly pull address for each LMS and update....
	; Why?  The address are known and only low bytes need to be updated,
	; So, then stuff them all directly.   This ends up being shorter than
	; cleverly looping through the LMS table.

	; A already is Left offset. Make X the Right offset.
;	ldx CurrentRightOffset

;	jsr UpdateGamePlayfield ; Update all the LMS offsets.

; CopyScoreToScreen MAY NEED TO BE SUBSTUITUTED FOR AnimateBoats in V03
;	jsr CopyScoreToScreen   ; Finish up by updating score display.

;	rts


; N/A  -  VBI continuously scrolls boats
; ==========================================================================
; UPDATE GAME PLAYFIELD
; Update Game screen LMS addresses and scrolling offset to specified
; values.
; ==========================================================================
;
; Note that only the low bytes needs to be reset as no line of data
; crosses over a page boundary.
;
; A  is Left scroll position
; X  is Right scroll position.
; --------------------------------------------------------------------------
;UpdateGamePlayfield

;	stx PF_LMS1 ; Right
;	sta PF_LMS2 ; Left

;	stx PF_LMS4 ; and so on
;	sta PF_LMS5

;	stx PF_LMS7
;	sta PF_LMS8

;	stx PF_LMS10
;	sta PF_LMS11

;	stx PF_LMS13
;	sta PF_LMS14

;	stx PF_LMS16
;	sta PF_LMS17

;	stx CurrentRightOffset
;	sta CurrentLeftOffset

;	rts


; N/A  -  VBI continuously scrolls boats
; ==========================================================================
; RESET GAME PLAYFIELD
; ==========================================================================
; Reset Game screen LMS addresses and scrolling offset to starting values.
; Note that only the low bytes needs to be reset as no line of data
; crosses over a page boundary.
;
; Used A, X and Y
; --------------------------------------------------------------------------
;ResetGamePlayfield

;	lda #$00               ; Reset the actual position trackers.
;	ldx #$00

;	jsr UpdateGamePlayfield

;	rts


; ==========================================================================
; COPY SCORE TO SCREEN
; ==========================================================================
; Copy the score from memory to screen positions.
; --------------------------------------------------------------------------
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; --------------------------------------------------------------------------
; Game Score and High Score.
; This stays here and is copied to screen memory, because the math could
; temporarily generate a non-numeric character when there is carry, and I
; don't want that (possibly) visible on the screen however short it may be.

MyScore .sb "00000000"
HiScore .sb "00000000"

CopyScoreToScreen
	ldx #7

DoUpdateScreenScore
	lda MyScore,x       ; Read from Score buffer
	sta SCREEN_MYSCORE,x
	lda HiScore,x       ; Read from Hi Score buffer
	sta SCREEN_HISCORE,x
	dex                 ; Loop 8 bytes - 7 to 0.
	bpl DoUpdateScreenScore

	rts


; ==========================================================================
; CLEAR SAVED FROGS
; Remove the number of saved frogs from the screen.
; ==========================================================================
; 1  |0000000:Score                 Hi:0000000| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; --------------------------------------------------------------------------

ClearSavedFrogs
	lda #INTERNAL_SPACE ; Blank space (zero)
	ldx #17

RemoveFroggies
	sta SCREEN_SAVED,x  ; Write to screen. (second line, 24th position)
	dex                 ; Decrement number of frogs.
	bne RemoveFroggies  ; then go back and display the next frog counter.

	sta FrogsCrossed      ; reset count to 0.
	sta FrogsCrossedIndex ; and the base index into difficulty arrays
	jsr SetBoatSpeed      ; just in case

	rts


; ==========================================================================
; PRINT FROGS AND LIVES
; Display the number of frogs that crossed the river and lives.
; There are two different character patterns that represent a frog 
; head used to indicate number of saved frogs. del/$7e and tab/$7f.
; These are alternated in the line, to make the 8-bit wide image 
; patterns discernible.  (The same image repeated looks a mess.)
; ==========================================================================
; 1  |0000000:Score                 Hi:0000000| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; --------------------------------------------------------------------------

PrintFrogsAndLives
	ldx FrogsCrossed    ; Number of times successfully crossed the rivers.
	beq WriteLives      ; then nothing to display. Skip to do lives.

	cpx #18             ; Limit saved frogs to the remaining width of screen
	bcc SavedFroggies
	ldx #17

SavedFroggies ; Write an alternating pattern of Frog1, Frog2 characters.
	lda #I_FROG1        ; On Atari we're using tab/$7f as a frog shape.
	sta SCREEN_SAVED,x  ; Write to screen. 
	dex                 ; Decrement number of frogs.
	beq WriteLives      ; Reached 0, stop adding frogs.
	lda #I_FROG2        ; On Atari we're using del/$7e as a frog shape.
	sta SCREEN_SAVED,x  ; Write to screen. 
	dex                 ; Decrement number of frogs.
	bne SavedFroggies   ; then go back and display the next frog counter.

WriteLives
	lda NumberOfLives   ; Get number of lives.
	clc                 ; Add to value for
	adc #INTERNAL_0     ; Atari internal code for '0'
	sta SCREEN_LIVES    ; Write to screen. *7th char on second line.)

	rts


; ==========================================================================
; ZERO CURRENT COLORS                                                 A  Y
; ==========================================================================
; Force all the colors in the current tables to black.
; Used before Fade up to game screen.
; --------------------------------------------------------------------------

ZeroCurrentColors
	ldy #22
	lda #0

LoopZeroColors
	sta COLBK_TABLE,y
	sta COLPF0_TABLE,y
	sta COLPF1_TABLE,y
	sta COLPF2_TABLE,y
	sta COLPF3_TABLE,y

	dey
	bpl LoopZeroColors

	jsr HideButtonPrompt

	rts


; ==========================================================================
; HIDE BUTTON PROMPT                                                   A
; ==========================================================================
; Tell the VBI to shut off the prompt.
;
; Uses A.   Preserves original value, so caller is not affected.
; --------------------------------------------------------------------------

HideButtonPrompt
	pha                     ; Save whatever is here.

	lda #0                  ; 0 == off
	sta EnablePressAButton  ; Tell VBI this is off.

	pla                     ; Get A back.

	rts                     ; bye.  Are there enough comments here?


; ==========================================================================
; CHANGE SCREEN                                                     A (Y)
; ==========================================================================
; Set a new display.
;
; 1. The Press Any Key Prompt is always disabled on the start of any screen.
; 2. Tell the VBI the screen ID.
; 3. Wait for the VBI to change the current display and update the
; 4. other pointers to the color tables.
; 5. Copy the color tables to the current lookups.
;
; A  is the DISPLAY_* value (defined elsewhere) for the desired display.
; Y  is used to turn off the Press A Button Prompt, and loop through 
;    the color tables.
; --------------------------------------------------------------------------

ChangeScreen
	jsr HideButtonPrompt           ; Always tell the VBI to stop the prompt.

	sta VBICurrentDL               ; Tell VBI to change to new display mode.

	; While waiting for the DLI to do its part, lets do something useful.
	; Display Win, Display Dead and Display Game Over are the same display lists.  
	; The only difference is the LMS to point to the big text.
	; So, reassign that here.
	pha                            ; Save Display number for later.
	tay
	lda DISPLAYLIST_GFXLMS_TABLE,y ; Get the new address.
	beq bCSSkipLMSUpdate           ; If it is 0 it is not for the update.  Skip this.
	sta GFX_LMS                    ; Save in the Win/Dead/Over display list.

bCSSkipLMSUpdate
	pla                            ; Get the display number back.

LoopChangeScreenWaitForVBI         ; Wait for VBI to signal the values changed.
	cmp VBICurrentDL               ; Is the DISPLAY value the same?
	beq LoopChangeScreenWaitForVBI ; Yes. Keep looping.

	; The VBI has changed the display and loaded page zero pointers.
	; Now update the DLI color tables.
	tay
	jsr CopyBaseColors

	rts


; ==========================================================================
; FLIP OFF EVERYTHING (MATCHING)                                   A  Y  X
; ==========================================================================
; Turn off a bit in the value keeping track of multiple bits 
; indicating which values match or do not match.
;
; Exit with 0 flag.
;
; A  is the mask to apply to the tracking bits.
; --------------------------------------------------------------------------

EverythingMatches 
	.byte 0 ; Bits indicate all colors match, then this row is done.
		    ; Bits $10, $8, $4, $2, $1 for COLBK, COLPF0, COLPF1, COLPF2, COLPF3

FlipOffEverything
	and EverythingMatches
	sta EverythingMatches    ; Save the finished flag.  
	lda #0                   ; So the caller can BEQ
	rts


; ==========================================================================
; INCREMENT GAME COLOR                                            A  Y  X
; ==========================================================================
; Merge the current luminance to the target color.
; Increment the current luminance.
;
; Inputs:
; A = target color
; Y = current color.
;
; Output:
; A = New current color.
; --------------------------------------------------------------------------

TempSaveColor   .byte 0
TempTargetColor .byte 0

; Such sloppiness....  gah!
IncrementGameColor      ; Y = current color.   A = target color
	sta TempTargetColor
	and #$F0            ; Extract target color part (to be joined to current luminance)
	sta TempSaveColor   ; Keep color
	tya                 ; A = Current color from Y.
	and #$0F            ; Extract current luminance.
	ora TempSaveColor   ; Join current luminance to target color for new current base color.
	cmp TempTargetColor ; Is the new save color already the same as the target?
	beq SkipIncCurrent  ; Do not change the value. 
	tay                 ; Current color back to Y for increments
	iny
	iny
	tya                 ; A = new current color.
SkipIncCurrent
	rts


; ==========================================================================
; INCREMENT TABLE COLORS                                          A  Y  X
; ==========================================================================
; Increment color table luminance values until they reach target values.
; Exit with 0 flag when all values are matching.
;
; X  is the index into the tables. 
; --------------------------------------------------------------------------

IncrementTableColors
	lda #%00011111       ; Flags indicate nothing matches yet.
	sta EverythingMatches

bDoTestCOLBK
	lda COLBK_TABLE,x        ; Get the current color. 
	cmp GAME_BACK_COLORS,x   ; Is it the same as the Target color?
	bne bDoIncCOLBK          ; No.  Go inc the luminance.
	lda #%00001111           ; Yes, turn off $10 .
	jsr FlipOffEverything    
	beq bDoTestCOLPF0        ; Do the next color.

bDoIncCOLBK
	tay                      ; Y = current color
	lda GAME_BACK_COLORS,x   ; A = target color
	jsr IncrementGameColor   ; Merge and increment color.
	sta COLBK_TABLE,x        ; Save the result.

bDoTestCOLPF0
	lda COLPF0_TABLE,x       ; Get the current color. 
	cmp GAME_COLPF0_COLORS,x ; Is it the same as the Target color?
	bne bDoIncCOLPF0         ; No.  Go inc the luminance.
	lda #%00010111           ; Yes, turn off $08 .
	jsr FlipOffEverything    
	beq bDoTestCOLPF1        ; Do the next color.

bDoIncCOLPF0
	tay                      ; Y = current color
	lda GAME_COLPF0_COLORS,x ; A = target color
	jsr IncrementGameColor   ; Merge and increment color.
	sta COLPF0_TABLE,x       ; Save the result.

bDoTestCOLPF1
	lda COLPF1_TABLE,x       ; Get the current color. 
	cmp GAME_COLPF1_COLORS,x ; Is it the same as the Target color?
	bne bDoIncCOLPF1         ; No.  Go inc the luminance.
	lda #%00011011           ; Yes, turn off $04.
	jsr FlipOffEverything    
	beq bDoTestCOLPF2        ; Do the next color.

bDoIncCOLPF1
	tay                      ; Y = current color
	lda GAME_COLPF1_COLORS,x ; A = target color
	jsr IncrementGameColor   ; Merge and increment color.
	sta COLPF1_TABLE,x       ; Save the result.

bDoTestCOLPF2
	lda COLPF2_TABLE,x       ; Get the current color. 
	cmp GAME_COLPF2_COLORS,x ; Is it the same as the Target color?
	bne bDoIncCOLPF2         ; No.  Go inc the luminance.
	lda #%00011101           ; Yes, turn off $02.
	jsr FlipOffEverything    
	beq bDoTestCOLPF3  ; Done With Everything.

bDoIncCOLPF2
	tay                      ; Y = current color
	lda GAME_COLPF2_COLORS,x ; A = target color
	jsr IncrementGameColor   ; Merge and increment color.
	sta COLPF2_TABLE,x       ; Save the result.

bDoTestCOLPF3
	lda COLPF3_TABLE,x       ; Get the current color. 
	cmp GAME_COLPF3_COLORS,x ; Is it the same as the Target color?
	bne bDoIncCOLPF3         ; No.  Go inc the luminance.
	lda #%00011110           ; Yes, turn off $01.
	jsr FlipOffEverything    
	beq bDoneWithEverything  ; Done With Everything.

bDoIncCOLPF3
	tay                      ; Y = current color
	lda GAME_COLPF3_COLORS,x ; A = target color
	jsr IncrementGameColor   ; Merge and increment color.
	sta COLPF3_TABLE,x       ; Save the result.

bDoneWithEverything
	lda EverythingMatches    ; If all flags are turned off the caller knows this row is done.

	rts


; ==========================================================================
; COPY BASE COLORS                                                    A Y
; ==========================================================================
; Copy the base colors for the current display.
;
; Y  is the DISPLAY_* value (defined elsewhere) for the desired display.
; --------------------------------------------------------------------------

CopyBaseColors
	; I'm so lazy.  Not bothering to be clever.
	; Just this or that or that or that...
	; Y was assigned the display number.
	beq CopyColors_Title ; 0 == DISPLAY_TITLE
	dey
	beq CopyColors_Game  ; 1 == DISPLAY_GAME
	dey
	beq CopyColors_Win   ; 2 == DISPLAY_WIN
	dey
	beq CopyColors_Dead  ; 3 == DISPLAY_DEAD
	dey
	beq CopyColors_Over  ; 4 == DISPLAY_OVER

	rts                  ; Will never get here, but makes me feel better.


; ==========================================================================
CopyColors_Title
 	ldx #25 ; Title

bLoopCopyColorsToTitle
	lda TITLE_BACK_COLORS,x
	sta COLBK_TABLE,x

	lda TITLE_TEXT_COLORS,x
	sta COLPF1_TABLE,x
	sta COLPF0_TABLE,x ; Only for Title, the COLPF0 graphics colors are in the text colors list.

	dex
	bpl bLoopCopyColorsToTitle

	rts  ; ChangeScreen is over.


; ==========================================================================
CopyColors_Game
	jsr ZeroCurrentColors ; "Game" starts at black screen and is faded up.

	rts ; ChangeScreen is over.


CopyColors_Win
	ldx #46 ; Dead, Win, Over have only background and COLPF0 lists.

bLoopCopyColorsToWin
	lda WIN_BACK_COLORS,x
	sta COLBK_TABLE,x

	lda WIN_COLPF0_COLORS,x ; 
	sta COLPF0_TABLE,x

	dex
	bpl bLoopCopyColorsToWin

	rts ; ChangeScreen is over.


; ==========================================================================
CopyColors_Dead
	ldx #46 ; Dead, Win, Over have only background and COLPF0 lists.

bLoopCopyColorsToDead
	lda DEAD_BACK_COLORS,x
	sta COLBK_TABLE,x

	lda DEAD_COLPF0_COLORS,x
	sta COLPF0_TABLE,x

	dex
	bpl bLoopCopyColorsToDead

	rts ; ChangeScreen is over.


; ==========================================================================
CopyColors_Over
	ldx #46 ; Dead, Win, Over have only background and COLPF0 lists.

bLoopCopyColorsTOver
	lda OVER_BACK_COLORS,x
	sta COLBK_TABLE,x

	lda OVER_COLPF0_COLORS,x
	sta COLPF0_TABLE,x

	dex
	bpl bLoopCopyColorsTOver

	rts ; ChangeScreen is over.


; ==========================================================================
; Redundant code section used for two separate loops in the Game Over event.
;
; --------------------------------------------------------------------------

GameOverGreyScroll
	sta COLBK_TABLE,y          ; Set line on screen
	tax                         ; X = A
	dex                         ; X = X + 1
	dex                         ; X = X + 1
	txa                         ; A = X
	and #$0F                    ; Keep this truncated to grey (black) $0 to $F
	iny                         ; Next line on screen.

	rts


; ==========================================================================
; Redundant code section used for two separate loops in the Dead Frog event.
;
; --------------------------------------------------------------------------

DeadFrogRedScroll
	lda DEAD_COLOR_SINE_TABLE,x ; Get another color
	sta COLBK_TABLE,y           ; Set line on screen
	inx                         ; Next color entry
	iny                         ; Next line on screen.

	rts

DEAD_COLOR_SINE_TABLE ; 20 entries.
	.byte COLOR_RED_ORANGE+6, COLOR_RED_ORANGE+8, COLOR_RED_ORANGE+10,COLOR_RED_ORANGE+12
	.byte COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+12
	.byte COLOR_RED_ORANGE+10,COLOR_RED_ORANGE+8, COLOR_RED_ORANGE+6, COLOR_RED_ORANGE+4
	.byte COLOR_RED_ORANGE+2, COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+0
	.byte COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+2, COLOR_RED_ORANGE+4


; ==========================================================================
; Support function.
; Redundant code section used for two separate places in the Win event.
; Subtract 4 from the current color.
; Reset to 238 if the limit 14 is reached.
;
; A  is the current color.   
; --------------------------------------------------------------------------
WinColorScroll
	sec
	sbc #4                      ; Subtract 4
 	cmp #14                     ; Did it pass the limit (minimum 18, minus 4 == 14)
	bne ExitWinColorScroll      ; No. We're done here.
	lda #238                    ; Yes.  Reset back to start.

ExitWinColorScroll
	rts


; ==========================================================================
; Supporting the support function. Decrement Title text colors.
;
; Separate luminance from color. 
; If luminance is already 0, then return color as 0.
; Decrement the luminance.
; Recombine with original color.
; 
; A = color value to adjust
; --------------------------------------------------------------------------
SAVE_PF  .byte 0
SAVE_PFC .byte 0

SliceColorAndLuma
	sta SAVE_PF               ; Save the incoming value
	and #$F0                  ; Mask out the luminance.
	sta SAVE_PFC              ; Save just the color part.

	lda SAVE_PF               ; Get the original value again.
	and #$0F                  ; Now check keep the luminance.
	beq ExitSliceColorAndLuma ; If it is 0, we can exit with A as color/lum 0.

	tay                       ; Y = A = Luminance
	dey                       ; Dec
	beq Reassemble_PF         ; If 0, then we're done.
	dey                       ; Dec twice to speed the transition.

Reassemble_PF
	tya                       ; A = Y = Luminance
	ora SAVE_PFC              ; join the color.

ExitSliceColorAndLuma
	rts


; ==========================================================================
; Support function. Decrement Title text colors.
; 
; Cut out of the EventTransitionToGame, it makes that shorter and more 
; readable, and allows the start to branch to the end/exit point.
;
; BEQ state is exit immediate exit. (Text value has reached 0)
; --------------------------------------------------------------------------
; === STAGE 1 ===
; ; Fade out text lines  from bottom to top.
; Fade out COLPF0 and COLPF1 at the same time.
; When luminance reaches 0, set color to 0. 
; Return flags the OR value of the COLPF0 and COLPF1.

FadeColPfToBlack
	ldx EventCounter2         ; Row counter decrementing.

	lda COLPF1_TABLE,x
	beq TryCOLPF0             ; It is already 0, so skip this.
	jsr SliceColorAndLuma
	sta COLPF1_TABLE,x

TryCOLPF0
	lda COLPF0_TABLE,x
	beq ExitFadeColPfToBlack  ; It is already 0, so skip this.
	jsr SliceColorAndLuma
	sta COLPF0_TABLE,x

ExitFadeColPfToBlack          ; Insure we're leaving with 0 for both colors 0.  Or !0 otherwise.
	lda COLPF0_TABLE,x        ; Get current color 0
	ora COLPF1_TABLE,x        ; ORA the value of color 0

	rts



;==============================================================================
;										DoBoatCharacterAnimation  A  X
;==============================================================================
; Based on the current frame value and the component value, copy 
; the 8 bytes from the animation table to the character image.
;
; ManageBoatAnimations takes care of determining if it is time to animate, 
; and the current component, and the frame counter.
; This function just uses the current values and copies the indicated 
; character image.
;
; When BoatyMcBoatCounter is 0, then animate based on BoatyComponent
; 0 = Right Boat Front
; 1 = Right Boat Back
; 2 = Left Boat Front
; 3 = Left Boat Back
;BoatyFrame         .byte 0  ; counts 0 to 7.
;BoatyMcBoatCounter .byte 2  ; decrement.  On 0 animate a component.
;BoatyComponent     .byte 0  ; 0, 1, 2, 3 one of the four boat parts.
; 
; The Boat Front is two characters.   One of the characters changes
; only on frame 2 and frame 6, so there is extra exception logic to 
; copy those frames when they occur.
;
; X = frame counter
; -----------------------------------------------------------------------------

DoBoatCharacterAnimation
; Zero is Right Front Boat.

	lda BoatyComponent               ; Get the component to animate
	bne TestBoaty1                   ; Non-zero means try 1, 2, 3

	lda RIGHT_BOAT_WATER_LOW,x       ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda RIGHT_BOAT_WATER_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_RFW*8] ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_RFW*8]
	sta VBIPointer2+1
	jsr BoatCsetCopy8                ; Copy the 8 bytes to the character set via the pointers set up.

; Part 2 for Right Front Boat.

	cpx #2                           ; Frame 2 and 6 have new images at front of boat.
	beq bCopyRightFrontBoat          ; Yes, this is 2. Copy new image
	cpx #6                           ; If not, then is it 6?
	bne ExitBoatCharacterAnimation   ; Not 6, so done with the frame animation.

bCopyRightFrontBoat
	lda RIGHT_BOAT_FRONT_LOW,x       ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda RIGHT_BOAT_FRONT_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_RF*8]  ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_RF*8]
	sta VBIPointer2+1
	jmp BoatCopy8                    ;  Go do the 8 byte copy to the character set via the pointers.

; One is Right Back Boat.

TestBoaty1
	cmp #1
	bne TestBoaty2                   ; Not 1.  So, not the Right back boat.

	lda RIGHT_BOAT_WAKE_LOW,x        ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda RIGHT_BOAT_WAKE_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_RBW*8] ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_RBW*8]
	sta VBIPointer2+1
	jmp BoatCopy8                    ;  Go do the 8 byte copy to the character set via the pointers.

; Two is Left Front Boat.

TestBoaty2
	cmp #2
	bne TestBoaty3

	lda LEFT_BOAT_WATER_LOW,x        ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda LEFT_BOAT_WATER_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_LFW*8] ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_LFW*8]
	sta VBIPointer2+1
	jsr BoatCsetCopy8                ; Copy the 8 bytes to the character set via the pointers set up.

; Part 2 for Left Front Boat.

	cpx #2                           ; Frame 2 and 6 have new images at front of boat.
	beq bCopyLeftFrontBoat           ; Yes, this is 2. Copy new image
	cpx #6                           ; If not, then is it 6?
	bne ExitBoatCharacterAnimation   ; Not 6, so done with the frame animation.

bCopyLeftFrontBoat
	lda LEFT_BOAT_FRONT_LOW,x        ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda LEFT_BOAT_FRONT_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_LF*8]  ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_LF*8]
	sta VBIPointer2+1
	jmp BoatCopy8                    ;  Go do the 8 byte copy to the character set via the pointers.

; Three is Left Back Boat.

TestBoaty3
;	cmp #3
;	bne EndOfBoatness               ; Process of Elimination.  Only 3 should be possible. 

	lda LEFT_BOAT_WAKE_LOW,x        ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda LEFT_BOAT_WAKE_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_LBW*8] ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_LBW*8]
	sta VBIPointer2+1

; Done with frame setup.  Now copy the frame.

BoatCopy8
	jsr BoatCsetCopy8            ;  Copy the 8 bytes to the character set via the pointers set up.

ExitBoatCharacterAnimation
	rts


;==============================================================================
;										BoatCsetCopy8  A  Y
;==============================================================================
; DoBoatCharacterAnimation set up zero page VBIPointer1 and VBIPointer2.
; Copy 8 bytes from pointer1 to pointer 2.
;
; Y = byte index.
; -----------------------------------------------------------------------------

BoatCsetCopy8
	ldy #0

	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y

	rts


;==============================================================================
;												PmgInit  A  X  Y
;==============================================================================
; One-time setup tasks to do Player/Missile graphics.
; -----------------------------------------------------------------------------

libPmgInit
	; get all Players/Missiles off screen.
	jsr libPmgMoveAllZero

	; clear all bitmap images
	jsr libPmgClearBitmaps

	; Tell ANTIC where P/M memory is located for DMA to GTIA
	lda #>PMADR
	sta PMBASE

	; Enable GTIA to accept DMA to the GRAFxx registers.
	lda #ENABLE_PLAYERS|ENABLE_MISSILES
	sta GRACTL

	; Set all the ANTIC screen controls and DMA options.
	lda #ENABLE_DL_DMA|PM_1LINE_RESOLUTION|ENABLE_PM_DMA|PLAYFIELD_WIDTH_NORMAL
	sta SDMCTL

	; Tell GTIA the various Player/Missile options and color controls
	; Turn on 5th Player (Missiles COLPF3), Multicolor players, and 
	; Priority bits %0001 put 5th Player below regular Players. 
	lda #FIFTH_PLAYER|MULTICOLOR_PM|%0001
	sta GPRIOR

	ldx #SHAPE_FROG ; Frog Shape
	jsr libPmgSetColors

	; Player 5 (the Missiles) is COLPF3, White.
	lda #COLOR_BLACK+$C
	sta COLOR3         ; OS shadow for color, no DLI changes.

	rts 


;==============================================================================
;											PmgMoveAllZero  A  X
;==============================================================================
; Simple hardware reset of all Player/Missile registers.
; Typically used only at program startup to zero everything
; and prevent any screen glitchiness on startup.
;
; Reset all Players and Missiles horizontal positions to 0, so
; that none are visible no matter the size or bitmap contents.
; Also reset sizes.
; -----------------------------------------------------------------------------

libPmgMoveAllZero
	lda #$00     ; 0 position
	ldx #$03     ; four objects, 3 to 0

bLoopZeroPMPosition
	sta HPOSP0,x ; Player positions 3, 2, 1, 0
	sta SIZEP0,x ; Player width 3, 2, 1, 0
	sta HPOSM0,x ; Missiles 3, 2, 1, 0 just to be sure.
	dex
	bpl bLoopZeroPMPosition

	sta SIZEM    ; and Missile size 3, 2, 1, 0

	; Zero a group of page 0 values:
	ldx #5
bPMAZClearCoords ; Clear coordinates, and shape index.
	sta FrogPMY,x
	dex
	bpl bPMAZClearCoords

	rts


;==============================================================================
;											PmgClearBitmaps  A  X
;==============================================================================
; Zero the bitmaps for all players and missiles
; -----------------------------------------------------------------------------

libPmgClearBitmaps
	lda #$00
	tax      ; count 0 to 255.

bCBloop
	sta MISSILEADR,x ; Missiles
	sta PLAYERADR0,x  ; Player 0
	sta PLAYERADR1,x  ; Player 1
	sta PLAYERADR2,x  ; Player 2
	sta PLAYERADR3,x  ; Player 3
	inx
	bne bCBloop       ; Count 1 to 255, then 0 breaks out of loop

	rts


;==============================================================================
;											PmgSetColors  A  X
;==============================================================================
; Load the P0-P3 colors based on shape identity.
; 
; X == SHAPE Identify  0 (off), 1, 2, 3...
; -----------------------------------------------------------------------------

libPmgSetColors
	txa   ; Object number
	asl   ; Times 2
	asl   ; Times 4
	tax   ; Back into index for referencing from table.

	lda BASE_PMCOLORS_TABLE,x       ; Get color(s) associated to object
	sta PCOLOR0                     ; Stuff in the Player color registers.
	lda BASE_PMCOLORS_TABLE+1,x
	sta PCOLOR1
	lda BASE_PMCOLORS_TABLE+2,x
	sta PCOLOR2
	lda BASE_PMCOLORS_TABLE+3,x
	sta PCOLOR3
                                 ; FYI, P5 color/COLPF3 is set by DLI 
	rts


; Game-specific Shapes:
;SHAPE_OFF   = 0
;SHAPE_FROG  = 1
;SHAPE_SPLAT = 2
;SHAPE_TOMB  = 3


;==============================================================================
;											EraseShape  A  X  Y
;==============================================================================
; Erase current Shape at current position.
; -----------------------------------------------------------------------------

EraseShape
	lda FrogShape
	beq ExitEraseShape  ; 0 is off.

	cmp #SHAPE_FROG
	bne bes_Test2
	jsr EraseFrog
	jmp ExitEraseShape

bes_Test2
	cmp #SHAPE_SPLAT
	bne bes_Test3
	jsr EraseSplat
	jmp ExitEraseShape

bes_Test3
	cmp #SHAPE_TOMB
	bne ExitEraseShape
	jsr EraseTomb

; Do not change FrogShape to FrogNewShape.   
; Drawing a new shape will transition New to Current.
ExitEraseShape
	lda FrogShape  ; return with value for caller.
	rts


;==============================================================================
;											EraseTomb  A  X  Y
;==============================================================================
; Erase Tomb at current position.
; -----------------------------------------------------------------------------

EraseTomb
	lda #0
	ldx FrogPMY            ; Old  Y
	ldy #22
	
bLoopET_Erase
	sta PLAYERADR0,x   ; main  1
	sta PLAYERADR1,x   ; main  2
	sta PLAYERADR2,x ; 
	sta PLAYERADR3,x ; 
	sta MISSILEADR,x ; 
	inx
	dey
	bpl bLoopEF_Erase

	rts


;==============================================================================
;											EraseSplat  A  X  Y
;==============================================================================
; Erase Splat at current position.
; -----------------------------------------------------------------------------

EraseSplat
	lda #0
	ldx FrogPMY            ; Old frog Y
	ldy #10
	
bLoopES_Erase
	sta PLAYERADR0,x   ; splat 1
	sta PLAYERADR1,x   ; splat 2
	inx
	dey
	bpl bLoopES_Erase

	rts


;==============================================================================
;											EraseFrog  A  X  Y
;==============================================================================
; Erase Frog at current position.
; -----------------------------------------------------------------------------

EraseFrog
	lda #0
	ldx FrogPMY            ; Old frog Y
	ldy #10
	
bLoopEF_Erase
	sta PLAYERADR0,x   ; main frog 1
	sta PLAYERADR1,x   ; main frog 2
	sta PLAYERADR2,x ; iris
	sta PLAYERADR3,x ; mouth
	sta MISSILEADR,x ; eyeballs
	inx
	dey
	bpl bLoopEF_Erase

	rts


;==============================================================================
;											DrawShape  A  X  Y
;==============================================================================
; Draw current Shape at current position.
; -----------------------------------------------------------------------------

DrawShape
	lda FrogNewShape
	beq ExitDrawShape  ; 0 is off.

	cmp #SHAPE_FROG
	bne bds_Test2
	jsr DrawFrog
	jmp ExitDrawShape

bds_Test2
	cmp #SHAPE_SPLAT
	bne bds_Test3
	jsr DrawSplat
	jmp ExitDrawShape

bds_Test3
	cmp #SHAPE_SPLAT
	bne ExitDrawShape
	jsr DrawTomb

ExitDrawShape
	lda FrogNewShape ; return value to caller.
	rts


;==============================================================================
;											DrawTomb   A  X  Y
;==============================================================================
; Draw Tomb at new position.
; -----------------------------------------------------------------------------

DrawTomb
	ldx FrogNewPMY            ; New frog Y
	ldy #22

bLoopDT_DrawTomb
	lda PLAYER0_GRAVE_DATA,y
	sta PLAYERADR0+22,x

	lda PLAYER1_GRAVE_DATA,y
	sta PLAYERADR1+22,x

	lda PLAYER2_GRAVE_DATA,y
	sta PLAYERADR2+22,x

	lda PLAYER3_GRAVE_DATA,y
	sta PLAYERADR3+22,x

	lda PLAYER5_GRAVE_DATA,y
	sta MISSILEADR+22,x

	dex
	dey
	bpl bLoopDT_DrawTomb

	rts


;==============================================================================
;											DrawSplat   A  X  Y
;==============================================================================
; Draw SplatteredFrog at new position.
; -----------------------------------------------------------------------------

DrawSplat
	ldx FrogNewPMY               
	ldy #10

bLoopDS_DrawSplatFrog
	lda PLAYER0_SPLATTER_DATA,y
	sta PLAYERADR0+10,x

	lda PLAYER1_SPLATTER_DATA,y
	sta PLAYERADR1+10,x

	dex
	dey
	bpl bLoopDS_DrawSplatFrog

	rts


;==============================================================================
;											DrawFrog  A  X  Y
;==============================================================================
; Draw Frog at new position.
; -----------------------------------------------------------------------------

DrawFrog
	ldx FrogNewPMY            ; New frog Y
	ldy #10

bLoopDF_DrawFrog
	lda PLAYER0_FROG_DATA,y
	sta PLAYERADR0+10,x

	lda PLAYER1_FROG_DATA,y
	sta PLAYERADR1+10,x

	lda PLAYER2_FROG_DATA,y
	sta PLAYERADR2+10,x

	lda PLAYER3_FROG_DATA,y
	sta PLAYERADR3+10,x

	lda PLAYER5_FROG_DATA,y
	sta MISSILEADR+10,x

	dex
	dey
	bpl bLoopDF_DrawFrog

	rts


;==============================================================================
;											UpdateFrogY  A  X  Y
;==============================================================================
; Move Y position.
; FYI: Removing a frog from display requires setting FrogShape == SHAPE_OFF,
; because re-analysis of position by the VBI will move the frog back into 
; the display.
; Update current Y position == new position.
; -----------------------------------------------------------------------------
; UpdateFrogY
	; ldx FrogPMY            ; Get current (old) position

	; ; Do new vertical repositioning.
	
	; ; 1) Erase frog from memory at current (old) position.
	; jsr EraseFrog

	; ; 2) Current position = new position
	; ldx FrogNewPMY         ; New frog Y...
	; stx FrogPMY            ; Set current Frog Y == New Frog Y

	; ; 3) load new frog image in the current (new) position
	; jsr DrawFrog

	; rts

	
;==============================================================================
;											PositionShape  A  X  Y
;==============================================================================
; Set HPOS coords of the shape parts. 
; -----------------------------------------------------------------------------

PositionShape
	lda FrogNewShape
	beq ExitPositionShape  ; 0 is off.

	cmp #SHAPE_FROG
	bne bps_Test2
	jsr PositionFrog
	jmp ExitPositionShape

bps_Test2
	cmp #SHAPE_SPLAT
	bne bps_Test3
	jsr PositionSplat
	jmp ExitPositionShape

bps_Test3
	cmp #SHAPE_TOMB
	bne ExitPositionShape
	jsr PositionTomb

ExitPositionShape
	lda FrogNewShape ; return value to caller.
	rts


;==============================================================================
;											PositionTomb  A  X  Y
;==============================================================================
; Move X position.
; Set sizes of parts.
; -----------------------------------------------------------------------------

PositionTomb
	ldx FrogNewPMX            ; New frog X...

	; Do horizontal repositioning.
	; Change frog HPOS.  Each part is not at 0 origin, so there are offsets...
	stx HPOSP0 ; + 0 is shadow on left
	inx
	inx
	stx HPOSM0 ; + 2 is p5 left part of tombstone
	inx
	inx
	stx HPOSP2 ; + 4 is part of RIP
	inx
	stx HPOSP3 ; + 5 is rest of the RIP
	inx
	inx
	stx HPOSP1 ; + 7 right side of tombstone

	ldx #0     ; Remove these other parts from visible display
	stx HPOSM3 ;  0 is p5 off 
	stx HPOSM2 ;  2 is p5 off 
	stx HPOSM1 ;  4 is p5 off 

	; Bonus extra...  
	; Force set  Player/Missile sizes
	ldx #PM_SIZE_NORMAL ; aka $00
	stx SIZEP0 ; Tombstone shadow
	stx SIZEP1 ; Frog parts 2
	stx SIZEP2 ; Frog colored iris
	stx SIZEP3 ; Frog mouth
	ldx #PM_SIZE_QUAD
	stx SIZEM  ; Missile 0 is left size of tombstone

	rts


;==============================================================================
;											PositionSplat  A  X  Y
;==============================================================================
; Move X position.
; Set sizes of parts.
; -----------------------------------------------------------------------------

PositionSplat
	ldx FrogNewPMX            ; New frog X...

	; Do horizontal repositioning.
	; Change frog HPOS.  Each part is not at 0 origin, so there are offsets...
	stx HPOSP0 ; + 0 is splat parts 1
	inx
	stx HPOSP1 ; + 1 is splat parts 2

	ldx #0     ; Remove these other parts from visible display
	stx HPOSP2 ;  0 is off
	stx HPOSP3 ;  0 is off
	stx HPOSM3 ;  0 is p5 off
	stx HPOSM2 ;  0 is p5 off
	stx HPOSM1 ;  0 is p5 off
	stx HPOSM0 ;  0 is p5 off

	; Bonus extra...  
	; Force set  Player/Missile sizes
	ldx #PM_SIZE_NORMAL ; aka $00
	stx SIZEP0 ; Splat parts 1
	stx SIZEP1 ; Splat parts 2

	rts


;==============================================================================
;											PositionFrog  A  X  Y
;==============================================================================
; Move X position.
; Set sizes of parts.
; -----------------------------------------------------------------------------

PositionFrog
	ldx FrogNewPMX            ; New frog X...

	; Do horizontal repositioning.
	; Change frog HPOS.  Each part is not at 0 origin, so there are offsets...
	stx HPOSP0 ; + 0 is frog parts 1
	stx HPOSP2 ; + 0 is frog eye iris
	stx HPOSP3 ; + 0 is frog mouth
	stx HPOSM3 ; + 0 is p5 frog eye balls
	inx
	stx HPOSP1 ; + 1 is frog parts 2
	inx
	stx HPOSM2 ; + 2 is p5 frog eye balls
	inx
	inx
	stx HPOSM1 ; + 4 is p5 frog eye balls
	inx
	inx
	stx HPOSM0 ; + 5 is p5 frog eye balls

	; Bonus extra...  
	; Force set  Player/Missile sizes
	lda #PM_SIZE_NORMAL ; aka $00
	sta SIZEP0 ; Frog parts 1
	sta SIZEP1 ; Frog parts 2
	sta SIZEP2 ; Frog colored iris
	sta SIZEP3 ; Frog mouth
	sta SIZEM  ; Eyeballs are Missile/P5 showing through the holes in head. (All need to be set 0)

	rts


;==============================================================================
;											UpdateFrog  A  X  Y
;==============================================================================
; Complete redisplay of the frog.  
; Erase old Frog position if needed.
; Load frog into PM Memory at the new position.
; Update current position == new position.
; Y positioning different from X positioning, since it must reload memory.
; -----------------------------------------------------------------------------
; UpdateFrog
	; ldx FrogNewPMY         ; New frog Y...
	; cpx FrogPMY            ; ...is different from Old frog Y?
	; beq bUFSkipFrogRedraw  ; No.  Skip erase/redraw.

	; jsr UpdateFrogY

; bUFSkipFrogRedraw
	; ldx FrogNewPMX            ; New frog X...
	; cpx FrogPMX               ; ...is different from Old frog X?
	; beq bUFSkipFrogReposition ; No.  Skip horizontal position update.

	; jsr UpdateFrogX


; bUFSkipFrogReposition
	; rts




;==============================================================================
; UPDATE SHAPE SPECS                                           A  X  Y
;==============================================================================
; Set all Current values to the New values.
; 
; On Exit X is the new shape. Useful if someone wants to call the color update.
; -----------------------------------------------------------------------------

UpdateShapeSpecs
	lda FrogNewPMX       ; New Y coord.
	sta FrogPMX

	lda FrogNewPMY       ; New X coord.
	sta FrogPMY 

	lda FrogNewRow       ; Also new Frog Row.
	sta FrogRow

	ldx FrogNewShape    ; And the shape is last.
	stx FrogShape

	rts


;==============================================================================
;											UpdateShape  A  X  Y
;==============================================================================
; Complete redisplay of the object/shape.  
; Erase old object/shape position if needed.
; Load new object/shape into PM Memory at the new position.
; Update current position == new position.
; Y positioning different from X positioning, since it must reload memory.
; Update current shape = new shape.
; -----------------------------------------------------------------------------

UpdateShape
	jsr EraseShape       ; Remove old shape at the old vertical Y position.

	jsr DrawShape        ; Draw NEW shape at new vertical Y position.
	jsr PositionShape    ; Move shape to new horizontal X position. (and set sizes).

	jsr UpdateShapeSpecs ; Commit the new shape and the new X and Y coords.
	;  UpdateShapeSpecs returns the new shape number in X.
	jsr libPmgSetColors  ; Set colors for this object.  Depends on X = Shape number.

ExitUpdateShape
	rts

