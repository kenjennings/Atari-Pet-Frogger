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
; Version 03, April 2019
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



; ==========================================================================
; Set the splattered frog on the screen.
;
; Write the splat frog character into screen memeory.
; --------------------------------------------------------------------------
SetSplatteredOnScreen
;	lda #I_SPLAT
	bne UpdateFrogInScreenMemory

; ==========================================================================
; Set the frog on the screen.
;
; Write the Frog character into screen memeory.
; --------------------------------------------------------------------------
SetFrogOnScreen
;	lda #I_FROG
	bne UpdateFrogInScreenMemory

; ==========================================================================
; Remove the frog from the screen.
;
; Restore the character that is under the frog.
;
; Note this falls right into UpdateFrogInMemory.
; --------------------------------------------------------------------------
RemoveFrogOnScreen
;	lda LastCharacter  ; Get the last character (under the frog)

; ==========================================================================
; Update the frog image in screen memeory.
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


; ==========================================================================
; Get the character from screen memory where the frog will reside.
; Save it to lastCharacter to restore as needed.
; --------------------------------------------------------------------------
GetScreenMemoryUnderFrog
;	ldy FrogRealColumn1
;	lda (FrogLocation),y
;	sta lastCharacter

	rts


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

	jsr ResetGamePlayfield ; initialize all game playfield LMS values.

	jsr SetBoatSpeed       ; Animation speed set by number of saved frogs

	; Display the current score and number of frogs that crossed the river.
	jsr CopyScoreToScreen
	jsr PrintFrogsAndLives

	lda #DISPLAY_GAME      ; Tell VBI to change screens.
	jsr ChangeScreen       ; Then copy the color tables.

	mRegRestoreAYX          ; Restore X, Y and A

	rts


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
AnimateBoats
	; Update with working positions of the scrolling lines.

	dec CurrentRightOffset ; subtract one to move screen contents right.
	bpl IncLeftOffset      ; It did not go negative. Done. Go update screen.
	lda #39                ; Fell off the end.  Restart.
	sta CurrentRightOffset ; reset to scroll start.

IncLeftOffset
	inc CurrentLeftOffset  ; subtract one to move screen contents left.
	lda CurrentLeftOffset
	cmp #40                ; 40th position is identical to 0th,
	bne UpdatePlayfieldLMS ; Did not go off the deep end. Done. Go update screen.
	lda #0                 ; Fell off the end.  Restart.
	sta CurrentLeftOffset  ; reset to scroll start.

UpdatePlayfieldLMS
	; We could cleverly pull address for each LMS and update....
	; Why?  The address are known and only low bytes need to be updated,
	; So, then stuff them all directly.   This ends up being shorter than
	; cleverly looping through the LMS table.

	; A already is Left offset. Make X the Right offset.
	ldx CurrentRightOffset

	jsr UpdateGamePlayfield ; Update all the LMS offsets.

	jsr CopyScoreToScreen   ; Finish up by updating score display.

	rts


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
UpdateGamePlayfield

	stx PF_LMS1 ; Right
	sta PF_LMS2 ; Left

	stx PF_LMS4 ; and so on
	sta PF_LMS5

	stx PF_LMS7
	sta PF_LMS8

	stx PF_LMS10
	sta PF_LMS11

	stx PF_LMS13
	sta PF_LMS14

	stx PF_LMS16
	sta PF_LMS17

	stx CurrentRightOffset
	sta CurrentLeftOffset

	rts


; ==========================================================================
; RESET GAME PLAYFIELD
; ==========================================================================
; Reset Game screen LMS addresses and scrolling offset to starting values.
; Note that only the low bytes needs to be reset as no line of data
; crosses over a page boundary.
;
; Used A, X and Y
; --------------------------------------------------------------------------
ResetGamePlayfield

	lda #$00               ; Reset the actual position trackers.
	ldx #$00

	jsr UpdateGamePlayfield

	rts


; Game Score and High Score.
; This stays here and is copied to screen memory, because the math could
; temporarily generate a non-numeric character when there is carry, and I
; don't want that (possibly) visible on the screen however short it may be.
MyScore .sb "00000000"
HiScore .sb "00000000"

; ==========================================================================
; Copy the score from memory to screen positions.
; ==========================================================================
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; --------------------------------------------------------------------------
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

	sta FrogsCrossed    ; reset count to 0.

	rts


; ==========================================================================
; PRINT FROGS AND LIVES
; Display the number of frogs that crossed the river and lives.
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
	lda #I_FROG1        ; On Atari we're using tab/$7f as the frog shape.
	sta SCREEN_SAVED,x  ; Write to screen. 
	dex                 ; Decrement number of frogs.
	beq WriteLives
	lda #I_FROG2        ; On Atari we're using del/$7e as the frog shape.
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
; Force all the colors in the current table to black.
;
; --------------------------------------------------------------------------
ZeroCurrentColors
	ldy #23
	lda #0
LoopZeroColors
	sta COLPF2_TABLE,y
	sta COLPF1_TABLE,y
	dey
	bpl LoopZeroColors

	jsr HideButtonPrompt
	rts


; ==========================================================================
; HIDE BUTTON PROMPT                                                   A
; ==========================================================================
; In case of sloppy programmer, tell the VBI to shut off the prompt.
;
; Uses A
; --------------------------------------------------------------------------

HideButtonPrompt
	lda #0 
	sta EnablePressAButton  

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
; Y  is used to turn off the Press A Button Prompt, and loop throrugh 
;    the color tables.
; --------------------------------------------------------------------------

ChangeScreen
	ldy #0
	sty EnablePressAButton         ; Always tell the VBI to stop the prompt.

	sta VBICurrentDL               ; Tell VBI to change to new mode.

LoopChangeScreenWaitForVBI
	cmp VBICurrentDL               ; Is the value unchanged?
	beq LoopChangeScreenWaitForVBI ; Yes.

	; The VBI has changed the display and loaded page zero pointers.
	; Now update the color tables.

	lda #0               ; Always force prompt line to off, 0 color
	sta COLPF2_TABLE+23
	sta COLPF1_TABLE+23
	sta COLPF2_TABLE+24
	lda #$0C               ; And the credits on.
	sta COLPF1_TABLE+24

	ldy #22
LoopCopyColors
	lda (COLPF2Pointer),y
	sta COLPF2_TABLE,y
	lda (COLPF1Pointer),y
	sta COLPF1_TABLE,y
	dey
	bpl LoopCopyColors

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
	; Priority bits put 5th Player below regular Players. 
	lda #FIFTH_PLAYER|MULTICOLOR_PM|%0001 
	sta GPRIOR

	ldx #1 ; Frog Shape
	jsr libPmgSetColors

	; Player 5 (the Missiles) is COLPF3, White.
	lda #COLOR_BLACK+$C
	sta COLOR3         ; OS shadow for color, no DLI changes.

	; Set Player/Missile sizes
	lda #PM_SIZE_NORMAL
	sta SIZEP0
	sta SIZEP1
	sta SIZEP2
	sta SIZEP3

	lda #PM_SIZE_QUAD ; Eyeballs are Missile/P5 showing through the holes in head.
	sta SIZEM

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
; -----------------------------------------------------------------------------
libPmgSetColors
	txa
	asl
	asl
	tax

	lda BASE_PMCOLORS_TABLE,x
	sta PCOLOR0
	lda BASE_PMCOLORS_TABLE+1,x
	sta PCOLOR1
	lda BASE_PMCOLORS_TABLE+2,x
	sta PCOLOR2
	lda BASE_PMCOLORS_TABLE+3,x
	sta PCOLOR3

	rts


;==============================================================================
;											PmgSetColors  A  X
;==============================================================================
