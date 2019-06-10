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
; SCREEN GRAPHICS
;
; This should contain everything that pertains to changes in visible screen 
; components.  
; Managing the score/status lines.
; Managing scrolling boats/display lists.
; Maintaining the Player/missile objects, and moving the objects around. 
; Updating color table contents for each of the displays.

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


; ==========================================================================
; D I S P L A Y S   A N D   P L A Y F I E L D 
; ==========================================================================

; ==========================================================================
; DISPLAY TITLE SCREEN
; ==========================================================================
; Show the instruction/title screen.
; --------------------------------------------------------------------------

DisplayTitleScreen
	lda #DISPLAY_TITLE   ; Tell VBI to change screens.
	jsr ChangeScreen     ; Then copy the color tables.

	rts


; ==========================================================================
; DISPLAY GAME SCREEN
; ==========================================================================
; Display the game screen.  (duh)
; --------------------------------------------------------------------------

DisplayGameScreen
	mRegSaveAYX             ; Save A and Y and X, so the caller doesn't need to.

;	jsr SetBoatSpeed       ; Animation speed set by number of saved frogs

	; Display the current score and number of frogs that crossed the river.
	jsr CopyScoreToScreen
	jsr PrintFrogsAndLives

	lda #DISPLAY_GAME      ; Tell VBI to change screens.
	jsr ChangeScreen       ; Then copy the color tables.

	mRegRestoreAYX          ; Restore X, Y and A

	rts


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
; ==========================================================================
; Remove the number of saved frogs from the screen.
;
; 1  |0000000:Score                 Hi:0000000| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; --------------------------------------------------------------------------

ClearSavedFrogs
	lda #INTERNAL_SPACE ; Blank space (zero)
	ldx #16

RemoveFroggies
	sta SCREEN_SAVED,x  ; Write to screen. (second line, 24th position)
	dex                 ; Decrement number of frogs.
	bne RemoveFroggies  ; then go back and display the next frog counter.

	sta FrogsCrossed      ; reset count to 0.
	sta FrogsCrossedIndex ; and the base index into difficulty arrays
;	jsr SetBoatSpeed      ; just in case

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
	jsr HideButtonPrompt              ; Always tell the VBI to stop the prompt.

	sta VBICurrentDL                  ; Tell VBI to change to new display mode.

	; While waiting for the DLI to do its part, lets do something useful.
	; Display Win, Display Dead and Display Game Over are the same display lists.  
	; The only difference is the LMS to point to the big text.
	; So, reassign that here.
	pha                               ; Save Display number for later.
	tay
	lda DISPLAYLIST_GFXLMS_TABLE,y    ; Get the new address.
	beq bCSCheckScreenBorders         ; If it is 0 it is not for the update.  Skip this.
	sta GFX_LMS                       ; Save in the Win/Dead/Over display list.

	; ALSO, the Game screen needs the mask borders pon the left and right sides
	; of the screen.   Determine if we need to do it or not do it and then
	; draw or erase the borders accordingly.

bCSCheckScreenBorders
	lda DISPLAY_NEEDS_BORDERS_TABLE,y ; Does this display need the P/m graphics borders? 
	beq bCSNoBorders                  ; If it is 0 it is not needed.  Erase it this.
	jsr DrawGameBorder                ; Game screen needs left and right sides masked.
	jmp bCSContinueUpdate

bCSNoBorders
	jsr EraseGameBorder

	; Back to checking on what the VBI has accomplished...
bCSContinueUpdate
	pla                               ; Get the display number back.

LoopChangeScreenWaitForVBI            ; Wait for VBI to signal the values changed.
	cmp VBICurrentDL                  ; Is the DISPLAY value the same?
	beq LoopChangeScreenWaitForVBI    ; Yes. Keep looping.

	; The VBI has changed the display and loaded page zero pointers.
	; Now update the DLI color tables.
	tay
	jsr CopyBaseColors

	rts


; ==========================================================================
; C O L O R   T A B L E S
; ==========================================================================

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
; I'm sure there's a smarter way to drive this off a list of data
; and make this smaller code.
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
; --------------------------------------------------------------------------

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
; You know, a marginally smart person would have made this code smaller 
; by using  another list of values based on component number to provide the 
; base pointers to the arrays of addresses for the source and target
; character maps.
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
; Without the cpy/bne loop overhead *  8 bytes.
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
; F I N E   S C R O L L I N G
;==============================================================================

; ==========================================================================
; Perpetually Scrolling Credits
; 
; The credits appear at the bottom line of the screen and continue 
; scrolling forever.
; 
; Yeah, not entirely the most efficient fine scroll.
; ANTIC supports fine horizontal scrolling 16 color clocks or 4 text
; characters at a time.  But, the actual credit text length is variable
; every time I change the string, so it is more simple code to fine scroll
; only one character at a time before a coarse scroll.  Still, the way the 
; Atari coarse scrolls makes this a mind-bogglingly, low-overhead activity
; compared to any other 8-bit.  Only update one pointer instead of rewriting 
; the screen data to coarse scroll.
; --------------------------------------------------------------------------

FineScrollTheCreditLine          ; scroll the text identifying the perpetrators
	dec CreditHSCROL             ; Subtract one color clock from the left (aka fine scroll).
	bne ExitScrollTheCredits     ; It is not yet 0.  Nothing else to do here.

ResetCreditScroll                ; Fine Scroll reached 0, so coarse scroll the text.
	inc SCROLL_CREDIT_LMS        ; Move text left one character position.
	lda SCROLL_CREDIT_LMS
	cmp #<END_OF_CREDITS         ; Did coarse scroll position reach the end of the text?
	bne RestartCreditHSCROL      ; No.  We are done with coarse scroll, now reset fine scroll. 

	lda #<SCROLLING_CREDIT       ; Yes, restart coarse scroll to the beginning position.
	sta SCROLL_CREDIT_LMS

RestartCreditHSCROL              ; Reset the 
	lda #4                       ; horizontal fine 
	sta CreditHSCROL             ; scrolling.

ExitScrollTheCredits
	rts


;==============================================================================
; F I N E   S C R O L L I N G   B O A T S
;==============================================================================

; Offsets from first LMS low byte in Display List to 
; the subsequent LMS low byte of each boat line. (VBI)
; For the Right Boats this is the offset from PF_LMS1.
; For the Left Boats this is the offset from PF_LMS2.
BOAT_LMS_OFFSET 
	.by 0 0 0 0 17 17 0 34 34 0 51 51 0 68 68 0 85 85 

; Index into DLI's HSCROL table for each boat row. 
BOAT_HS_TABLE
	.by 0 4 5 0 7 8 0 10 11 0 13 14 0 16 17 0 19 20

; ==========================================================================
; RIGHT BOAT FINE SCROLLING
; 
; Start Scroll position = LMS + 12 (decrement), HSCROL 0  (Increment)
; End   Scroll position = LMS + 0,              HSCROL 15
;
; X and Y are current row to analyze.
; --------------------------------------------------------------------------

RightBoatFineScrolling
	; Easier to push the frog first before the actual fine scrolling.
	cpy FrogRow             ; Are we on the frog's row?
	bne DoFineScrollRight   ; No.  Continue with boat scroll.
	clc
	lda FrogNewPMX
	adc (BoatMovePointer),y ; Increment the position same as HSCROL distance.
	sta FrogNewPMX

DoFineScrollRight
	ldx BOAT_HS_TABLE,y     ; X = Get the index into HSCROL table.
	lda HSCROL_TABLE,x      ; Get value of HSCROL.
	clc
	adc (BoatMovePointer),y ; Increment the HSCROL.
	cmp #16                 ; Shift past scroll limit?
	bcs DoCoarseScrollRight ; Yes.  Need to coarse scroll.
	sta HSCROL_TABLE,x      ; No. Save the updated HSCROL.
	rts                     ; Done.  No coarse scroll this time.

	; HSCROL wrapped over 15.  Time to coarse scroll by subtracting 4 from LMS.
DoCoarseScrollRight
;	sec  ; Got here via bcs
	sbc #16                 ; Fix the new HSCROL
	sta HSCROL_TABLE,x      ; Save the updated HSCROL.
	ldx BOAT_LMS_OFFSET,y   ; X = Get the index to the LMS in the Display List for this line.
	lda PF_LMS1,x           ; Get the actual LMS low byte.
	sec
	sbc #4                  ; Subtract 4 from LMS in display list.
	bpl SaveNewRightLMS     ; If still positive (0), then good to update LMS
	lda #12                 ; LMS went negative. Reset to start position.
SaveNewRightLMS
	sta PF_LMS1,x           ; Update LMS pointer.

EndOfRightBoat
	rts


; ==========================================================================
; LEFT BOAT FINE SCROLLING
; 
; Start Scroll position = LMS + 0 (increment), HSCROL 15  (Decrement)
; End   Scroll position = LMS + 12,            HSCROL 0
;
; X and Y are current row to analyze/scroll.
; --------------------------------------------------------------------------

LeftBoatFineScrolling
	; Easier to push the frog first before the actual fine scrolling.
	cpy FrogRow             ; Are we on the frog's row?
	bne DoFineScrollLeft    ; No.  Continue with boat scroll.
	sec
	lda FrogNewPMX
	sbc (BoatMovePointer),y ; Increment the position same as HSCROL distance.
	sta FrogNewPMX

DoFineScrollLeft
	ldx BOAT_HS_TABLE,y     ; X = Get the index into HSCROL table.
	lda HSCROL_TABLE,x      ; Get value of HSCROL.
	sec
	sbc (BoatMovePointer),y ; Decrement the HSCROL
	bmi DoCoarseScrollLeft  ; It went negative, must reset and coarse scroll
	sta HSCROL_TABLE,x      ; It's OK. Save the updated HSCROL.
	rts                     ; Done.  No coarse scroll this time.

	; HSCROL wrapped below 0.  Time to coarse scroll by Adding 4 to LMS.
DoCoarseScrollLeft
	adc #16                 ; Re-wrap over 0 into the positive.
	sta HSCROL_TABLE,x      ; Save the updated HSCROL.
	ldx BOAT_LMS_OFFSET,y   ; X = Get the index to the LMS in the Display List for this line.
	lda PF_LMS2,x           ; Get the actual LMS low byte.
	clc
	adc #4                  ; Add 4 to LMS in display list.
	cmp #13                 ; Is it greater than max (12)? 
	bcc SaveNewLeftLMS      ; No.  Good to update LMS.
	lda #0                  ; LMS greater than 12. Reset to start position.
SaveNewLeftLMS
	sta PF_LMS2,x           ; Update LMS pointer.

EndOfLeftBoat
	rts


;==============================================================================
; P R E S S   J O Y S T I C K   B U T T O N   P R O M P T
;==============================================================================

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


;==============================================================================
; TOGGLE PressAButtonState 
;==============================================================================
; Flip the fade up/fade down state.

TogglePressAButtonState
	lda PressAButtonState    ; Get button state
	eor #$FF                 ; Invert the value
	sta PressAButtonState    ; Save new value.

	rts


;==============================================================================
; TOGGLE BUTTON PROMPT
;==============================================================================
; Fade the prompt colors up and down. 
;
; PressAButtonState...
; If  0, then fading background down to dark.  (and text light)  
; If  1, then fading background up to light  (and text dark) 
; When background reaches 0 luminance change the color.
;
; On entry, the first choice may end up being black/white.  
; The code generally tries to exclude black/white, but on 
; entry this may occur depending on prior state. (fadeouts, etc.)
;
; A  is used for background color
; X  is used for text color.
; --------------------------------------------------------------------------

ToggleButtonPrompt
	lda #BLINK_SPEED            ; Text Fading speed for prompt
	sta PressAButtonFrames      ; Reset the frame counter.

	lda PressAButtonState       ; Up or down?
	bne PromptFadeUp            ; >0 == up.

	; Prompt Fading the background down.
	lda PressAButtonColor         ; Get the current background color.
	AND #$0F                    ; Look at only the luminance.
	bne RegularPromptFadeDown   ; Not 0 yet, do a normal job on it.

SetNewPromptColor
	lda RANDOM                  ; A random color and then prevent same 
	eor PressAButtonColor         ; value by chewing on it with the original color.
	and #$F0                    ; Mask out the luminance for Dark.
	beq SetNewPromptColor       ; Do again if black/color 0 turned up
	sta PressAButtonColor         ; Set background.
	jsr TogglePressAButtonState ; Change fading mode to up (1)
	bne SetTextAsInverse        ; Text Brightness inverse from the background

RegularPromptFadeDown
	dec PressAButtonColor         ; Subtract 1 from the color (which is the luminance)
	jmp SetTextAsInverse        ; And reset the text to accordingly.

PromptFadeUp
	lda PressAButtonColor
	AND #$0F                    ; Look at only the luminance.
	cmp #$0F                    ; Is it is at max luminance now?
	bne RegularPromptFadeUp     ; No, do the usual fade.

	jsr TogglePressAButtonState ; Change fading mode to down.
	rts

RegularPromptFadeUp
	inc PressAButtonColor         ; Add 1 to the color (which is the luminance)
	; and fall into setting the text luminance setup....

SetTextAsInverse  ; Make the text luminance the opposite of the background.
	lda PressAButtonColor         ; Background color...
	eor #$0F                    ; Not (!) the background color's luminance.
	sta PressAButtonText         ; Use as the text's luminance.

	rts


;==============================================================================
; RUN PROMPT FOR BUTTON
;==============================================================================
; Maintain blinking timer.
; Update/blink text on line 23.
; Return 0/BEQ when the any key is not pressed.
; Return !0/BNE when the any key is pressed.
;
; On Exit:
; A  contains key press.
; CPU flags are comparison of key value to $FF which means no key press.
; --------------------------------------------------------------------------

RunPromptForButton
	lda #1
	sta EnablePressAButton   ; Tell VBI to the prompt flashing is enabled.

	jsr CheckInput           ; Get input. Non Zero means there is input.
	and #%00010000           ; Strip it down to only the joystick button.
	beq ExitRunPrompt        ; If 0, then do not play sound.

	ldx #2                   ; Button pressed. Set Pokey channel 2 to tink sound.
	ldy #SOUND_TINK
	jsr SetSound 

	lda #%00010000       ; Set the button is pressed.

ExitRunPrompt
	rts


;==============================================================================
; P L A Y E R / M I S S I L E   G R A P H I C S
;==============================================================================
; Game-specific Shapes:
; SHAPE_OFF   = 0
; SHAPE_FROG  = 1
; SHAPE_SPLAT = 2
; SHAPE_TOMB  = 3

; ==========================================================================
; SET SPLATTERED ON SCREEN
; ==========================================================================
; Show the splattered frog image on the screen...
;
; This does not bother changing the FrogUpdate for the VBI, since 
; this activity should only occur when frog animation is already 
; underway.
; --------------------------------------------------------------------------

SetSplatteredOnScreen

	lda #SHAPE_SPLAT
	sta FrogNewShape

	rts


; ==========================================================================
; SET FROG ON SCREEN
; ==========================================================================
; Show the frog image on the screen...
;
; Set default eyeball shape.  
; Enable updates for the VBI.
; Write the Frog character into screen memory.
; --------------------------------------------------------------------------

SetFrogOnScreen

	lda #SHAPE_FROG
	sta FrogNewShape ; Set new shape
	lda #1
	sta FrogEyeball  ; Set default eyeball shape (1 is default/centered)

	sta FrogUpdate   ; and finally enable VBI to do P/M redraw. (>0 is ON)

	rts


; ==========================================================================
; REMOVE FROG ON SCREEN
; ==========================================================================
; Remove the frog from the screen...
;
; VBI will update other values, and the shape ID.
; --------------------------------------------------------------------------

RemoveFrogOnScreen
	lda #$FF           ; (<0 is shutdown)
	sta FrogUpdate     ; Signal VBI to erase and do not redraw. 

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

	; Ordinarily, GPRIOR would be set here.
	; However, GTIA GPRIOR varies by Display.
	; The VBI will manage the values based on the current Display List.

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
; Also useful when the program wants to turn off the current 
; player image.
;
; Reset all Players and Missiles horizontal positions to 0, so
; that none are visible no matter the size or bitmap contents.
; Zero all colors.
; Also reset sizes to zero.
; -----------------------------------------------------------------------------

libPmgMoveAllZero
	lda #$00                ; 0 position
	ldx #$03                ; four objects, 3 to 0

bLoopZeroPMPosition
	sta HPOSP0,x            ; Player positions 3, 2, 1, 0
	sta SIZEP0,x            ; Player width 3, 2, 1, 0
	sta HPOSM0,x            ; Missiles 3, 2, 1, 0 just to be sure.
	sta PCOLOR0,x           ; And black the colors.
	dex
	bpl bLoopZeroPMPosition

	sta SIZEM               ; and Missile size 3, 2, 1, 0

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

	rts


; ==========================================================================
; WOBBLE DE WOBBLE                           A  X  
; ==========================================================================
; Frog (etc) Gymnastics.
; On the title screen the frog moves in a sine path from  +88 to +160.
; This value is centered at 128, the middle of the screen.
; The data from the sine generator is 0 to $80  (0 to 80).
; The center of the screen should be 128,128. 
; So, the value to add to center the sine motion on the screen is:
; 128 - (80 / 2) ==  88. 
; Minus 4 for the width/height of the Frog == 84
; Add that to current values to position the frog.
; The rate of updates between X and Y values differs, so the 
; frog does not travel in a circle, but a distorted arc.
; The frog Y center position is offset slightly differently from 
; the X Center.
; This same code is used for the Tomb/gravestone on the GameOver screen.
; --------------------------------------------------------------------------

WOBBLE_SINE_TABLE
	.by $28 $2c $30 $34 $37 $3b $3e $41 
	.by $44 $47 $49 $4b $4d $4e $4f $50 
	.by $50 $50 $4f $4e $4d $4b $49 $47 
	.by $44 $41 $3e $3b $37 $34 $30 $2c 
	.by $28 $24 $20 $1c $19 $15 $12 $0f 
	.by $0c $09 $07 $05 $03 $02 $01 $00 
	.by $00 $00 $01 $02 $03 $05 $07 $09 
	.by $0c $0f $12 $15 $19 $1c $20 $24 

WobbleDeWobble
	lda AnimateFrames        ; Get the countdown timer for X movement.
	bne CheckOnAnimateY      ; Not 0.  No X movement.  Go try Y movement.

	lda #WOBBLEX_SPEED       ; Reset the X movement timer.
	sta AnimateFrames        

	jsr WobbleDeWobbleX_Now  ; Do the actual X wobble work.

CheckOnAnimateY
	lda AnimateFrames2       ; Get the countdown timer for Y movement.
	bne EndWobbleDeWobble    ; Not 0.  No Y movement.  Depart.

	lda #WOBBLEY_SPEED       ; Reset the Y movement timer.
	sta AnimateFrames2

	jsr WobbleDeWobbleY_Now  ; Do the actual X wobble work.

EndWobbleDeWobble
	rts


; Working parts of the Wobble, callable by others.

WobbleDeWobbleX_Now          ; jsr here to force wobble coordinates
	inc WobbleX              ; Increment Index for X offset
	lda WobbleX              ; Get new X index
	and #$3F                 ; Limit to 0 to 63.
;	sta WobbleX              ; Remarkably, the Base-2-ness of the size plus the AND above make this STA unnecessary.
	tax                      ; X = Index for X movement
	lda WOBBLE_SINE_TABLE,x  ; Get current path value for Horizontal placement.
	clc
	adc WobOffsetX           ; Add to offset for placement.
	sta FrogNewPMX           ; Tell VBI where to draw the object.

	rts


; Working parts of the Wobble, callable by others.

WobbleDeWobbleY_Now          ; jsr here to force wobble coordinates

	inc WobbleY              ; Increment Index for Y offset.
	lda WobbleY              ; Get new Y index
	and #$3F                 ; Limit to 0 to 63.
;	sta WobbleY              ; Remarkably, the Base-2-ness of the size plus the AND above make this STA unnecessary.
	tax                      ; X = Index for Y movement
	lda WOBBLE_SINE_TABLE,x  ; Get current path value for Vertical placement.
	clc
	adc WobOffsetY           ; Add to offset for placement.
	sta FrogNewPMY           ; Tell VBI where to draw the object.

	rts


;==============================================================================
;											CheckRidetheBoat    A 
;==============================================================================
; Collision processing the prior frame results is utterly trivial.
;
; The caller should make this check for collisions only when the  
; Frog is in a Boat row.
;
; Here's how life and death works:
; As long as a frog part (Player 0 or 1) is touching the colored, horizontal 
; lines (COLPF2) on the boat, then the frog lives.
;
; This is easy, because the Atari identifies exactly what playfield 
; color is involved in the collision.  
; On other systems we're lucky to get a bit that says a sprite collided 
; with a pixel. Then we would have to do a series of coordinate bounding 
; box checks to see if the frog is in a safe position on a boat.
; 
; In the event of a rare border condition where the frog lost the collision  
; attachment on the past frame AND the player has directed the frog move to 
; the next row in the coming frame, then grace is applied to ignore the 
; collision results and keep the frog alive.  
;
; Output: 
; FrogSafety = 0  ; Life
; FrogSafety = 1  ; Death
; -----------------------------------------------------------------------------

CheckRideTheBoat
	lda FrogSafety               ; Is the frog already dead ?
	bne ExitCheckRideTheBoat     ; Yes.   No need to check.

	lda P0PF                     ; Get Player 0 collision with playfield
	ora P1PF                     ; OR with Player 1 collision with playfield
	and #COLPMF2_BIT             ; Keep only the collision with COLPF2 (lines on the boats)
	bne ExitCheckRideTheBoat     ; 1 == touching the lines. Therefore Frog is safe.

	; Oops.  The frog is off a boat. 
	; Frog must die. Unless, the frog must live. :-) 
	; If the Frog is moving to the next row on the next frame, then 
	; disregard the collision failure to permit the frog to live.

	lda FrogRow                  ; Get the current Row number.
	cmp FrogNewRow               ; Is the new Row the same?  
	bne ExitCheckRideTheBoat     ; No.  Life!

	inc FrogSafety               ; Yes.  Die, Frog, Die!

	; The rest of the VBI motion processing will happily drag the frog  
	; corpse along with the moving boats/water.
	; It is MAIN's job to change the image to the splattered frog.

ExitCheckRideTheBoat
	rts


;==============================================================================
;											EraseShape  A  X  Y
;==============================================================================
; Erase current Shape at current position.
; -----------------------------------------------------------------------------

EraseShape
	lda FrogShape       ; Current shape?
	beq ExitEraseShape  ; 0 is off. Nothing to Erase.

	; Note that if there is animation here is where the frame change 
	; would be evaluated to be followed by the position check if the 
	; frame does not change.

	ldy FrogUpdate     ; If -1, then update/erase is mandatory.
	bmi bes_Test1

	cmp FrogNewShape       ; Is it different from the old shape?
	bne bes_Test1          ; Yes.  Erase is mandatory.

	ldy FrogNewPMY      ; Get new position.
	cpy FrogPMY         ; Is it the same as the old position?
	beq ExitEraseShape  ; Yes.  Nothing to erase here.

bes_Test1
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
;											EraseGameBorder  A  X  Y
;==============================================================================
; Erase Shape in Missile memory.
; -----------------------------------------------------------------------------

EraseGameBorder
	ldx #[177]

begb_LoopFillBorder
	lda #$00
	sta PLAYERADR3+43,x
	
	lda MISSILEADR+43,x
	and #%00111111
	sta MISSILEADR+43,x
	
	dex
	bne begb_LoopFillBorder

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
	sta PLAYERADR0,x  ; main frog 1
	sta PLAYERADR1,x  ; main frog 2, mouth, pupil
	sta PLAYERADR2,x  ; eyeball
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

	ldy FrogUpdate        ; Is update mandatory?
	bmi ExitDrawShape     ; Update is forced off.
	beq bds_CheckInMotion ; Update is neutral.
	bpl bds_Test1         ; FrogUpdate >0 means redraw is required.
	
	; Note that if there is animation here is where the frame change 
	; would be evaluated to be followed by the position check if the 
	; frame does not change.

bds_CheckInMotion
	cmp FrogShape          ; Is it different from the old shape?
	bne bds_Test1          ; Yes.  Redraw is mandatory.

	ldy FrogNewPMY      ; Get new position.
	cpy FrogPMY         ; Is it the same as the old position?
	beq ExitDrawShape   ; Yes.  Nothing to draw here.

bds_Test1
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
	cmp #SHAPE_TOMB
	bne ExitDrawShape
	jsr DrawTomb

ExitDrawShape
	lda FrogNewShape ; return value to caller.
	rts

;==============================================================================
;											DrawGameBorder  A  X  Y
;==============================================================================
; Show the black border that masks the left and right sides of the background.
;
; Draw Shape in Player/Missile memory.
; Set color of border to Black.
; Set position of Player/Missile.
; Set size of Player and Missile.
; -----------------------------------------------------------------------------

DrawGameBorder

	lda #$00
	sta PCOLOR3

	ldx #177

bdgb_LoopFillBorder
	lda #$C0
	sta PLAYERADR3+43,x
	
	lda MISSILEADR+43,x
	ora #$C0
	sta MISSILEADR+43,x
	
	dex
	bne bdgb_LoopFillBorder

	lda #[PLAYFIELD_RIGHT_EDGE_NORMAL+1]
	sta HPOSP3
	
	lda #[PLAYFIELD_LEFT_EDGE_NORMAL-8]
	sta HPOSM3
	
	lda #PM_SIZE_QUAD
	sta SIZEP3
	
	lda #%11000000
	sta SIZEM

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

;	lda PLAYER2_FROG_DATA,y
;	sta PLAYERADR2+10,x

;	lda PLAYER3_FROG_DATA,y
;	sta PLAYERADR3+10,x

;	lda PLAYER5_FROG_DATA,y
;	sta MISSILEADR+10,x

	dex
	dey
	bpl bLoopDF_DrawFrog

	; Player 2 is the eyeball whites
	ldx FrogNewPMY             ; Reload new frog Y
	lda #$EE
	sta PLAYERADR2+2,x
	sta PLAYERADR2+3,x
	sta PLAYERADR2+4,x

	; Player 1 also contains the animated pupil.
	lda FrogEyeball            ; What shape is the eye pupil?
	asl
	asl
	tay

	lda PLAYER1_EYE_DATA,y
	sta PLAYERADR1+2,x
	iny
	lda PLAYER1_EYE_DATA,y
	sta PLAYERADR1+3,x
	iny
	lda PLAYER1_EYE_DATA,y
	sta PLAYERADR1+4,x

	rts


;==============================================================================
;											PositionShape  A  X  Y
;==============================================================================
; Set HPOS coords of the shape parts. 
; -----------------------------------------------------------------------------

PositionShape
	ldy FrogNewShape       ; Get new shape
	cpy FrogShape          ; Is it different from the old shape?
	bne bps_Test0          ; Yes.   Reposition is mandatory.

	ldy FrogNewPMX         ; Get new position.
	cpy FrogPMX            ; Is it the same as the old position?
	beq ExitPositionShape  ; Yes.  Nothing to draw here.

bps_Test0
	cmp #SHAPE_OFF
	bne bps_Test1
	jsr libPmgMoveAllZero ; Zero all P/M HPOS, and sizes.
	jmp ExitPositionShape

bps_Test1
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
	stx HPOSP3 ; + 4 is part of RIP
	inx
	stx HPOSP2 ; + 5 is rest of the RIP
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

	lda CurrentDL
	cmp #DISPLAY_GAME
	beq bps_SkipZeroP3  ; Do not remove P3 on the game screen.

	stx HPOSP3 ;  0 is off
	stx HPOSM3 ;  0 is p5 off

bps_SkipZeroP3
	stx HPOSP2 ;  0 is p5 off
	stx HPOSM2 ;  0 is p5 off
	stx HPOSM1 ;  0 is p5 off
	stx HPOSM0 ;  0 is p5 off

	; Bonus extra...  
	; Force set  Player/Missile sizes
	ldx #PM_SIZE_NORMAL ; aka $00
	stx SIZEP0 ; Splat parts 1
	stx SIZEP1 ; Splat parts 2
	stx SIZEP2 ; Splat parts 2

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
;	stx HPOSP3 ; + 0 is frog mouth
;	stx HPOSM3 ; + 0 is p5 frog eye balls
	inx
	stx HPOSP1 ; + 1 is frog parts 2
	stx HPOSP2 ; + 0 is frog eye iris
;	inx
;	stx HPOSM2 ; + 2 is p5 frog eye balls
;	inx
;	inx
;	stx HPOSM1 ; + 4 is p5 frog eye balls
;	inx
;	inx
;	stx HPOSM0 ; + 5 is p5 frog eye balls

	ldx #0     ; Remove these other parts from visible display
	lda CurrentDL
	cmp #DISPLAY_GAME
	beq bps_DoNoMoveMask

	stx HPOSP3 ; On the game screen these need to stay to mask the left/right borders.
	stx HPOSM3

bps_DoNoMoveMask 
	stx HPOSM2 ;  0 is off
	stx HPOSM1 ;  0 is off
	stx HPOSM0 ;  0 is off

	; Bonus extra...  
	; Force set  Player/Missile sizes
	lda #PM_SIZE_NORMAL ; aka $00
	sta SIZEP0 ; Frog parts 1
	sta SIZEP1 ; Frog parts 2
	sta SIZEP2 ; Frog eyeball 

;	sta SIZEP3 ; Frog mouth
;	sta SIZEM  ; Eyeballs are Missile/P5 showing through the holes in head. (All need to be set 0)

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

	ldx FrogNewShape    ; And the shape.
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
; Frog Update controls parts to do (because Main trying to erase the 
; shape is arguing with the VBI)
; FrogUpdate 0 = no changes.  
;            1 = Any reason to change position... 
;           -1 = erase, stop, and no further updates. 
; -----------------------------------------------------------------------------

UpdateShape
	lda FrogUpdate       ; 
	beq ExitUpdateShape  ; 0 == no movement.  skip all.

	jsr EraseShape       ; Remove old shape at the old vertical Y position.
	lda FrogUpdate        
	bpl b_usRedrawShape  ; >0 = continue   

	lda #SHAPE_OFF       ; <0 = stop, so stop doing things after the erase.
	sta FrogUpdate       ; Erased above, therefore stop everything further.
	sta FrogNewShape     ; SHAPE_OFF is 0.  Make all shapes off.
	sta FrogShape
	beq ExitUpdateShape

b_usRedrawShape
	jsr DrawShape        ; Draw NEW shape at new vertical Y position.
	jsr PositionShape    ; Move shape to new horizontal X position. (and set sizes).

ExitUpdateShape
	jsr UpdateShapeSpecs ; Commit the new shape and the new X and Y coords.
	;  UpdateShapeSpecs returns the new shape number in X.
	jsr libPmgSetColors  ; Set colors for this object.  Depends on X = Shape number.

	rts


;==============================================================================
;											ProcessNewShapePosition
;==============================================================================
; Limit new positions to the game playfield area.
; Call the main routine to redraw the object.
; -----------------------------------------------------------------------------

ProcessNewShapePosition
	lda FrogNewPMX      ; Is the new X different
	cmp #MIN_FROGX      ; Is PM X smaller than the minimum?
	bcs CheckHPOSMax    ; No.  

	lda #MIN_FROGX      ; Yes.  Reset X
	sta FrogNewPMX      ; to the minimum.
	bne UpdateTheFrog   ; render it.

CheckHPOSMax
	cmp #MAX_FROGX+1    ; Is PM X bigger than the maximum?
	bcc UpdateTheFrog   ; No.

	lda #MAX_FROGX      ; Yes.  Reset X
	sta FrogNewPMX      ; to the maximum.

UpdateTheFrog
	jsr UpdateShape     ; then FrogPMX == FrogNewPMX. FrogPMY == FrogNewPMY. FrogRow=FrogNewRow.

	rts

