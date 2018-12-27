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
; The Entry Point.
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

	lda #NMI_VBI ; Turn Off DLI
	sta NMIEN

	ldy #<MyDeferredVBI  ; Add the deferred VBI to the system
	ldx #>MyDeferredVBI
	lda #7               ; 7 = Deferred VBI 
	jsr SETVBV           ; Tell OS to set it

	jsr libScreenWaitFrame ; Wait for display to start next frame.

	; Now it is safe to change Display list pointer.  
	; This should  not be interrupted.
	lda #<DISPLAYLIST
	sta SDLSTL
	lda #>DISPLAYLIST
	sta SDLSTH

	lda #<MyDLI ; Set DLI vector.
	sta VDSLST
	lda #>MyDLI
	sta VDSLST+1
	
	lda #[NMI_DLI|NMI_VBI] ; Turn On DLI
	sta NMIEN

	; Tell the OS where screen memory starts
	lda #<SCREENMEM    ; low byte screen
	sta SAVMSC
	lda #>SCREENMEM    ; hi byte screen
	sta SAVMSC+1

	lda #1
	sta CRSINH         ; Turn off the displayed cursor.

	lda #0
	sta DINDEX         ; Tell OS screen/cursor control is Text Mode 0
	sta LMARGN         ; Set left margin to 0 (default is 2)

	; These colors will not matter due to the DLIs.
	lda #COLOR_GREEN   ; Set screen base color dark green
	sta COLOR2         ; Background and
	lda #0
	sta COLOR4         ; Border
	lda #$0A
	sta COLOR1         ; Text brightness

	; Zero these values...
	lda #0
	sta FlaggedHiScore
	sta LastKeyPressed

	lda #SCREEN_START  ; Set main game loop to start new game at title screen.
	sta CurrentScreen

; Ready to go to main game loop . . . .

; ==========================================================================
; GAME LOOP
;
; The main loop for the game... said Capt Obvious.
; Very vaguely like an event loop or state loop across the progressive
; game states which are (more or less) based on the current mode of
; the display.
;
; Rules:  "Continue" labels for the next screen/event block must
;         be called with screen value in A.  Therefore, each Event
;         routine must end by lda CurrentScreen.
; --------------------------------------------------------------------------

GameLoop
	lda CurrentScreen
; ==========================================================================
; SCREEN START/NEW GAME
; Setup for New Game and do transition to Title screen.
; --------------------------------------------------------------------------
	cmp #SCREEN_START
	bne ContinueTitleScreen ; SCREEN_START=0?  No?

	jsr EventScreenStart

; ==========================================================================
; TITLE SCREEN
; The activity on the title screen is
; 1) blinking the text and
; 2) waiting for a key press.
; --------------------------------------------------------------------------
ContinueTitleScreen
	cmp #SCREEN_TITLE
	bne ContinueTransitionToGame

	jsr EventTitleScreen

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

	jsr EventTransitionToGame

; ==========================================================================
; GAME SCREEN
; Play the game.
; 1) When the input timer allows, get a key.
; 2) Evaluate frog Movement
; 2.a) Determine exit to Win screen
; 2.b) Determine exit to Dead screen.
; 3) When the animation timer expires, shift the boat rows.
; 3.a) Determine if frog hits screen border to go to Dead screen.
; As a timer based pattern the key input is first.
; Keyboard input updates the frog's logical and physical position
; and updates screen memory.
; The animation update forces an automatic movement of the frog
; logically, as the frog moves with the boats and remains static
; relative to the boats.
; --------------------------------------------------------------------------
ContinueGameScreen
	cmp #SCREEN_GAME
	bne ContinueTransitionToWin

	jsr EventGameScreen

; ==========================================================================
; TRANSITION TO WIN SCREEN
; The Activity in the transition area, based on timer.
; 1) Animate something.
; 2) End With display of WIN Screen.
; --------------------------------------------------------------------------
ContinueTransitionToWin
	cmp #SCREEN_TRANS_WIN
	bne ContinueWinScreen

	jsr EventTransitionToWin

; ==========================================================================
; WIN SCREEN
; The activity in the WIN screen.
; 1) blinking the text and
; 2) waiting for a key press.
; --------------------------------------------------------------------------
ContinueWinScreen
	cmp #SCREEN_WIN
	bne ContinueTransitionToDead

	jsr EventWinScreen

; ==========================================================================
; TRANSITION TO DEAD SCREEN
; The Activity in the transition area, based on timer.
; 1) Animate something.
; 2) End With display of DEAD Screen.
; --------------------------------------------------------------------------
ContinueTransitionToDead
	cmp #SCREEN_TRANS_DEAD
	bne ContinueDeadScreen

	jsr EventTransitionToDead

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

	jsr EventDeadScreen

; ==========================================================================
; TRANSITION TO GAME OVER SCREEN
; The Activity in the transition area, based on timer.
; 1) Animate something.
; 2) End With display of GAME OVER Screen.
; --------------------------------------------------------------------------
ContinueTransitionToOver
	cmp #SCREEN_TRANS_OVER
	bne ContinueOverScreen

	jsr EventTransitionGameOver

; ==========================================================================
; GAME OVER SCREEN
; The activity in the DEAD screen.
; 1) blinking the text and
; 2) waiting for a key press.
; --------------------------------------------------------------------------
ContinueOverScreen
	cmp #SCREEN_OVER
	bne ContinueTransitionToTitle

	jsr EventGameOverScreen

; ==========================================================================
; TRANSITION TO TITLE
; The Activity in the transition area, based on timer.
; 1) Animate something.
; 2) End With going to the Title Screen.
; --------------------------------------------------------------------------
ContinueTransitionToTitle
	cmp #SCREEN_TRANS_TITLE
	bne EndGameLoop

	jsr EventTransitionToTitle

; ==========================================================================
; END OF GAME EVENT LOOP
; --------------------------------------------------------------------------
EndGameLoop
	jsr TimerLoop    ; Wait for end of frame and update the timers.

	jmp GameLoop     ; rinse, repeat, forever.

	rts

