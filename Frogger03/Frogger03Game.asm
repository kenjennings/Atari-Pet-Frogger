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
	; writes a byte to a page 0 location monitored by the Vertical Blank
	; Interrupt and this directs the interrupt to change the current
	; display list.  Easy-peasy and never updated at the wrong time.

	lda #AUDCTL_CLOCK_64KHZ    ; Set only this one bit for clock.
	sta AUDCTL                 ; Global POKEY Audio Control.
	lda #3                     ; Set SKCTL to 3 to stop possible cassette noise. 
	sta SKCTL                  ; So say Mapping The Atari and De Re Atari.
	jsr StopAllSound           ; Zero all AUDC and AUDF

	lda #>CHARACTER_SET        ; Set custom character set.  Global to game, forever.
	sta CHBAS

	lda #NMI_VBI               ; Turn Off DLI
	sta NMIEN

	lda #0
	sta ThisDLI

	lda #<Score_DLI; TITLE_DLI            ; Set DLI vector. (will be reset by VBI on screen setup)
	sta VDSLST
	lda #>Score_DLI; TITLE_DLI
	sta VDSLST+1
	
	lda #[NMI_DLI|NMI_VBI]     ; Turn On DLIs
	sta NMIEN

	ldy #<MyImmediateVBI       ; Add the VBI to the system (Display List dictatorship)
	ldx #>MyImmediateVBI
	lda #6                     ; 6 = Immediate VBI
	jsr SETVBV                 ; Tell OS to set it

	ldy #<MyDeferredVBI        ; Add the VBI to the system (Lazy hippie timers, colors, sound.)
	ldx #>MyDeferredVBI
	lda #7                     ; 7 = Deferred VBI
	jsr SETVBV                 ; Tell OS to set it

	lda #0
	sta COLOR4                 ; Border color, 0 is black.
	sta FlaggedHiScore
	sta InputStick             ; no input from joystick

	lda #COLOR_BLACK+$E        ; COLPF3 is white on all screens.
	sta COLOR3

	jsr libPmgInit             ; Will also reset SDMACTL settings for P/M DMA

	lda #4                     ; Quick hack to init the scrolling credits.
	sta HSCROL

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
	jsr libScreenWaitFrame    ; Wait for end of frame, start of new frame.

; Due to the frame sync above, at this point the code
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
; Event process SCREEN START/NEW GAME
; Clear the Game Scores and get ready for the Press A Button prompt.
;
; Sidebar: This is oddly inserted between Transition to Title and the
; Title to finish internal initialization per game, due to doofus-level
; lack of design planning, blah blah.
; The title screen has already been presented by Transition To Title.
; --------------------------------------------------------------------------
ContinueStartNewGame
	cmp #SCREEN_START
	bne ContinueTitleScreen ; SCREEN_START=0?  No?

	jsr EventScreenStart

; ==========================================================================
; Event Process TITLE SCREEN
; The activity on the title screen is
; 1) Blink Prompt for ANY key.
; 2) Wait for joystick button.
; 3) Setup for next transition.
; --------------------------------------------------------------------------
ContinueTitleScreen
	cmp #SCREEN_TITLE
	bne ContinueTransitionToGame

	jsr EventTitleScreen

; ==========================================================================
; Event Process TRANSITION TO GAME SCREEN
; The Activity in the transition area, based on timer.
; Stage 1) Fade out text lines  from bottom to top.
;          Decrease COLPF1 brightness from bottom   to top.
;          When COLPF1 reaches 0 change COLPF2 to COLOR_BLACK.
; Stage 2) Setup Game screen display.  Set all colors to black.
; Stage 3) Fade in text lines from top to bottom.
;          Decrease COLPF1 brightness from top to bottom.
;          When COLPF1 reaches 0 change COLPF2 to COLOR_BLACK.
; --------------------------------------------------------------------------
ContinueTransitionToGame
	cmp #SCREEN_TRANS_GAME
	bne ContinueGameScreen

	jsr EventTransitionToGame

; ==========================================================================
; Event Process GAME SCREEN
; Play the game.
; 1) When the input timer allows, get controller input.
; 2) Evaluate frog Movement
; 2.a) Determine exit to Win screen
; 2.b) Determine exit to Dead screen.
; 3) When the animation timer expires, shift the boat rows.
; 3.a) Determine if frog hits screen border to go to Dead screen.
; As a timer based pattern the controller input is first.
; Joystick input updates the frog's logical and physical position
; and updates screen memory.
; The animation update forces an automatic logical movement of the
; frog as the frog moves with the boats and remains static relative
; to the boats.
; --------------------------------------------------------------------------
ContinueGameScreen
	cmp #SCREEN_GAME
	bne ContinueTransitionToWin

	jsr EventGameScreen

; ==========================================================================
; Event Process TRANSITION TO WIN
; The Activity in the transition area, based on timer.
; 1) wipe screen from top to middle, and bottom to middle
; 2) Display the Frogs SAVED!
; 3) Setup to do the Win screen event.
; --------------------------------------------------------------------------
ContinueTransitionToWin
	cmp #SCREEN_TRANS_WIN
	bne ContinueWinScreen

	jsr EventTransitionToWin

; ==========================================================================
; Event Process WIN SCREEN
; Scroll colors on screen while waiting for a button press.
; Setup for next transition.
; --------------------------------------------------------------------------
ContinueWinScreen
	cmp #SCREEN_WIN
	bne ContinueTransitionToDead

	jsr EventWinScreen

; ==========================================================================
; Event Process TRANSITION TO DEAD
; The Activity in the transition area, based on timer.
; 0) On Entry, wait (1.5 sec) to observe splattered frog. (timer set in 
;    the setup event)
; 1) Black background for all playfield lines, turn frog's line red.
; 2) Fade playfield text to black.
; 2) Launch the Dead Frog Display.
; --------------------------------------------------------------------------
ContinueTransitionToDead
	cmp #SCREEN_TRANS_DEAD
	bne ContinueDeadScreen

	jsr EventTransitionToDead

; ==========================================================================
; Event Process DEAD SCREEN
; The Activity is in the transition event, based on timer.
; Run an animated scroll driven by the data in the sine table.
; --------------------------------------------------------------------------
ContinueDeadScreen
	cmp #SCREEN_DEAD
	bne ContinueTransitionToOver

	jsr EventDeadScreen

; ==========================================================================
; Event Process TRANSITION TO OVER
;
; Fade out all lines of the Dead Screen.  
; Fade in the lines of the Game Over Screen.
;
; This seems gratuitous, but it is necessary, because the screen can 
; be switched so fast that the user pressing the button on the Dead 
; Screen may not be able to release the button fast enough and end 
; up immediately dismissing the game over screen.  
;
; 1) Fade display to black.
; 2) Switch to Game Over display.
; 3) Fade in the Game Over text. 
; $) Switch to the Game Over event.
;
; Not feeling enterprising, so just use the Fade value from the Dead event.
; --------------------------------------------------------------------------
ContinueTransitionToOver
	cmp #SCREEN_TRANS_OVER
	bne ContinueOverScreen

	jsr EventTransitionGameOver


; ==========================================================================
; Event Process GAME OVER SCREEN
; The Activity in the transition area, based on timer.
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
