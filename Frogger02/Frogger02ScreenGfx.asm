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
; 13 |the seats in the boats.                 | INSTXT_1
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


	rts


; ==========================================================================
; Print the big text announcement for dead frog.
; --------------------------------------------------------------------------
PrintDeadFrogGfx


	rts


; ==========================================================================
; Print the big text announcement for Winning frog.
; --------------------------------------------------------------------------
PrintWinFrogGfx


	rts


; ==========================================================================
; Print the big text announcement for Game Over.
; --------------------------------------------------------------------------
PrintGameOverGfx


	rts


; ==========================================================================
; Set the splattered frog on the screen.
;
; Write the splat frog character into screen memeory.
; --------------------------------------------------------------------------
SetSplatteredOnScreen
	lda #I_SPLAT
	bne UpdateFrogInScreenMemory

; ==========================================================================
; Set the frog on the screen.
;
; Write the Frog character into screen memeory.
; --------------------------------------------------------------------------
SetFrogOnScreen
	lda #I_FROG
	bne UpdateFrogInScreenMemory

; ==========================================================================
; Remove the frog from the screen.
;
; Restore the character that is under the frog.
;
; Note this falls right into UpdateFrogInMemory.
; --------------------------------------------------------------------------
RemoveFrogOnScreen
	lda lastCharacter  ; Get the last character (under the frog)

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
	ldy FrogRealColumn1  ; Current X coordinate
	sta (FrogLocation),y ; Erase the frog with the last character.
	ldy FrogRealColumn2  ; Current X coordinate of alternate scroll location
	sta (FrogLocation),y ; Erase the frog with the last character.

	rts


; ==========================================================================
; Get the character from screen memory where the frog will reside.
; Save it to lastCharacter to restore as needed.
; --------------------------------------------------------------------------
GetScreenMemoryUnderFrog
	ldy FrogRealColumn1
	lda (FrogLocation),y
	sta lastCharacter

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
; The credits at the bottom of the screen is still always redrawn.
; From the title screen it is animated to move to the bottom of the
; screen.  But from the Win and Dead frog screens the credits
; are overdrawn.
; --------------------------------------------------------------------------
DisplayGameScreen
	mRegSaveAYX             ; Save A and Y and X, so the caller doesn't need to.

	jsr ResetGamePlayfield ; initialize all game playfield LMS values.

	jsr SetBoatSpeed       ; Animation speed set by number of saved frogs

	lda #DISPLAY_GAME      ; Tell VBI to change screens.
	jsr ChangeScreen       ; Then copy the color tables.

	; Display the current score and number of frogs that crossed the river.
	jsr CopyScoreToScreen
	jsr PrintFrogsAndLives

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
;	lda SCREEN_ADDR,x      ; Get screen row address low byte.
;	sta ScreenPointer
;	inx
;	lda SCREEN_ADDR,x      ; Get screen row address high byte.
;	sta ScreenPointer+1
;	inx                    ; doing this for consistency so the next call pulls correct row

	rts


; ==========================================================================
; Load Playfield Pointer From X
;
; Parameters:
; X = row number on screen 0 to 18.
;
; Used by code:
; A = used to load/store
; --------------------------------------------------------------------------
LoadPlayfieldPointerFromX
	lda PLAYFIELD_MEM_LO_TABLE,x      ; Get screen row address low byte.
	sta ScreenPointer
	lda PLAYFIELD_MEM_HI_TABLE,x      ; Get screen row address high byte.
	sta ScreenPointer+1

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
; First, need to check if the frog will become killed offscreen.  that means it is
; dead now where it is and boat scrolling must not go any further.

	; Update with working positions of the scrolling lines.

	dec CurrentRightOffset ; subtract one from position to move screen contents right.
	bpl IncLeftOffset      ; Did not go negative, so does not need reset.
	lda #39                ; Fell off the end. Jump forward a screen.
	sta CurrentRightOffset ; reset to scroll start.

IncLeftOffset
	inc CurrentLeftOffset  ; Add one to  position  to move screen contents left.
	lda CurrentLeftOffset
	cmp #40                ; 40th position is identical to 0th,
	bne UpdatePlayfieldLMS
	lda #0                 ; so, go back to origination point,
	sta CurrentLeftOffset  ; reset to scroll start.

UpdatePlayfieldLMS
	; We could cleverly pull address for each LMS and update....
	; Why?  The address are known and only low bytes need to be updated,
	; So, so stuff them all directly.   This ends up being shorter than
	; cleverly looping through the LMS table.

	; A already is Left offset. Make X the Right offset.
	ldx CurrentRightOffset

	jsr UpdateGamePlayfield ; Update all the LMS offsets.


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
	sta SCREEN_MYSCORE,x
	lda HiScore,x       ; Read from Hi Score buffer
	sta SCREEN_HISCORE,x
	dex                 ; Loop 8 bytes - 7 to 0.
	bpl DoUpdateScreenScore

	rts


; ==========================================================================
; CLEAR SAVED FROGS
; Remove the number of saved frogs from the screen.
;
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
;
; 1  |0000000:Score                 Hi:0000000| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; --------------------------------------------------------------------------
PrintFrogsAndLives
	lda #I_FROG         ; On Atari we're using del/$7f as the frog shape.
	ldx FrogsCrossed    ; Number of times successfully crossed the rivers.
	beq WriteLives      ; then nothing to display. Skip to do lives.

	cpx #18             ; Limit saved frogs to the remaining width of screen
	bcc SavedFroggies
	ldx #17

SavedFroggies
	sta SCREEN_SAVED,x  ; Write to screen. (second line, 24th position)
	dex                 ; Decrement number of frogs.
	bne SavedFroggies   ; then go back and display the next frog counter.

WriteLives
	lda NumberOfLives   ; Get number of lives.
	clc                 ; Add to value for
	adc #INTERNAL_0     ; Atari internal code for '0'
	sta SCREEN_LIVES    ; Write to screen. *7th char on second line.)

	rts


; ==========================================================================
; UPDATE GAME PLAYFIELD
; Update Game screen LMS addresses and scrolling offset to specified
; values.
;
; Note that only the low bytes needs to be reset as no line of data
; crosses over a page boundary.
;
; A  is Right scroll position
; X  is Left scroll position.
; --------------------------------------------------------------------------
UpdateGamePlayfield

	stx PF_LMS1
	sta PF_LMS2

	stx PF_LMS4
	sta PF_LMS5

	stx PF_LMS7
	sta PF_LMS8

	stx PF_LMS10
	sta PF_LMS11

	stx PF_LMS13
	sta PF_LMS14

	stx PF_LMS16
	sta PF_LMS17

	stx CurrentLeftOffset
	sta CurrentRightOffset

	rts


; ==========================================================================
; RESET GAME PLAYFIELD
; Reset Game screen LMS addresses and scrolling offset to starting values.
; Note that only the low bytes needs to be reset as no line of data
; crosses over a page boundary.
;
; Used A, X and Y
; --------------------------------------------------------------------------
ResetGamePlayfield

	lda #$00               ; Reset the actual position trackers.
	ldx #$39

	jsr UpdateGamePlayfield

	rts


; ==========================================================================
; ZERO CURRENT COLORS                                                 A  Y
; --------------------------------------------------------------------------
; Force all the colors in the current table to black.
;
; Needed because the ChangeScreen routine automatically populates the
; current color table and when I want to fade up the game screen
; it needs to start that loop from black colors.
;
; --------------------------------------------------------------------------
ZeroCurrentColors
	ldy #24
	lda #0
LoopZeroColors
	sta COLPF2_TABLE,y
	sta COLPF1_TABLE,y
	dey
	bpl LoopZeroColors
	rts


; ==========================================================================
; HIDE BUTTON PROMPT                                                   A
; --------------------------------------------------------------------------
; In case of sloppy programmer, force color black to
; hide the Prompt for Button on setup.
;
; Uses A
; --------------------------------------------------------------------------

HideButtonPrompt
	lda #COLOR_BLACK
	sta COLPF2_TABLE+23
	sta COLPF1_TABLE+23

	rts


; ==========================================================================
; CHANGE SCREEN                                                        A
; --------------------------------------------------------------------------
; Set a new display.
;
; Tell the VBI the screen ID.
; Wait for the VBI to change the current display and update the
; other pointers to the color tables.
; Copy the color tables to the current lookups.
;
; A  is the DISPLAY_* value (defined below) corresponding to the screen.
; --------------------------------------------------------------------------

ChangeScreen
	sta VBICurrentDL               ; Tell VBI to change to new mode.

LoopChangeScreenWaitForVBI
	cmp VBICurrentDL               ; Is the value unchanged?
	beq LoopChangeScreenWaitForVBI ; Yes.

	; The VBI has changed the display and loaded page zero pointers.
	; Now update the color tables.

	ldy #24
LoopCopyColors
	lda (COLPF2Pointer),y
	sta COLPF2_TABLE,y
	lda (COLPF1Pointer),y
	sta COLPF1_TABLE,y
	dey
	bpl LoopCopyColors

	rts


