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
; The Entry Point.
; Called once on program start.
; Use this to setup Atari display settings to imitate the
; PET 4032's 40x25 display.
; --------------------------------------------------------------------------
GAMESTART
	; Atari initialization stuff...

	; Changing the Display List is potentially tricky.  If the update is
	; interrupted by the Vertical blank, then it could mess up the display
	; list address and crash the Atari.
	;
	; So, this problem is solved by giving responsibility for Display List
	; changes to a custom Vertical Blank Interrupt. The main code simply
	; writes a byte to a page 0 location monitored by the vertical blank
	; interrupt and this directs the interrupt to change the current
	; display list.  Easy-peasy and never updated at the wrong time.

	lda #<CHARACTER_SET        ; Set custom character set.  Global to game, forever.
	sta CHBAS

	lda #NMI_VBI               ; Turn Off DLI
	sta NMIEN

	lda #<MyDLI                ; Set DLI vector.
	sta VDSLST
	lda #>MyDLI
	sta VDSLST+1

	lda #[NMI_DLI|NMI_VBI]     ; Turn On DLI
	sta NMIEN

	ldy #<MyImmediateVBI       ; Add the VBI to the system
	ldx #>MyImmediateVBI
	lda #6                     ; 6 = Immediate VBI
	jsr SETVBV                 ; Tell OS to set it

	lda #0
	sta COLOR4                 ; Border color, 0 is black.
	sta FlaggedHiScore
	sta InputStick             ; no input from joystick

	jsr SetupTransitionToTitle ; will set CurrentScreen = SCREEN_TRANS_TITLE

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
	jsr TimerLoop    ; Wait for end of frame to update the timers.

; Due to the timer sync above, now here at this point the code
; is running at/near the top of the screen refresh.

	lda CurrentScreen

; ==========================================================================
; TRANSITION TO TITLE
; Setup Transition to Title routine turned on the title display.
; Stage 1: Scroll in the Title.
; Stage 2: Brighten line 4 luminance.
; Stage 3: Initialize setup for Press Button on Title screen.
; --------------------------------------------------------------------------
ContinueTransitionToTitle
	cmp #SCREEN_TRANS_TITLE
	bne ContinueStartNewGame

	jsr EventTransitionToTitle

; ==========================================================================
; SCREEN START/NEW GAME
; Setup for New Game.  (Internal value updates)
; --------------------------------------------------------------------------
ContinueStartNewGame
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
	bne EndGameLoop

	jsr EventGameOverScreen

; ==========================================================================
; END OF GAME EVENT LOOP
; --------------------------------------------------------------------------
EndGameLoop

	jmp GameLoop     ; rinse, repeat, forever.

	rts

