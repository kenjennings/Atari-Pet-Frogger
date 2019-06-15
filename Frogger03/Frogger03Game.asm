; ==========================================================================
; Pet Frogger
; (c) November 1983 by John C. Dale, aka Dalesoft
; for the Commodore Pet 4032
; ==========================================================================
; Ported (parodied) to Atari 8-bit computers
; by Ken Jennings (if this were 1983, aka FTR Enterprises)
; ==========================================================================
; Version 00, November 2018
; Version 01, December 2018
; Version 02, February 2019
; Version 03, June 2019
; ==========================================================================

EVENT_TARGET_TABLE
	.word EventGameInit-1           ; 0  = EVENT_INIT
	.word EventScreenStart-1        ; 1  = EVENT_START
	.word EventTitleScreen-1        ; 2  = EVENT_TITLE
	.word EventTransitionToGame-1   ; 3  = EVENT_TRANS_GAME
	.word EventGameScreen-1         ; 4  = EVENT_GAME    
	.word EventTransitionToWin-1    ; 5  = EVENT_TRANS_WIN 
	.word EventWinScreen-1          ; 6  = EVENT_WIN      
	.word EventTransitionToDead-1   ; 7  = EVENT_TRANS_DEAD  
	.word EventDeadScreen-1         ; 8  = EVENT_DEAD      
	.word EventTransitionGameOver-1 ; 9  = EVENT_TRANS_OVER 
	.word EventGameOverScreen-1     ; 10 = EVENT_OVER      
	.word EventTransitionToTitle-1  ; 11 = EVENT_TRANS_TITLE


; ==========================================================================
; The Game Entry Point where AtariDOS calls for startup.
; 
; And the perpetual loop calling the game's event dispatch routine.
; The code needs this routine as a starting place, so that the 
; routines called from the subroutine table have a place to return
; to.  Otherwise the RTS from those routines would be at the 
; top level and exit the game.
; --------------------------------------------------------------------------

GameStart

	jsr GameLoop 

	jmp GameStart ; Do While More Electricity


; ==========================================================================
; GAME LOOP
;
; The main event dispatch loop for the game... said Capt Obvious.
; Very vaguely like an event loop or state loop across the progressive
; game states which are (loosely) based on the current mode of
; the display.
;
; Each event sets CurrentEvent to change to another event target.
; --------------------------------------------------------------------------

GameLoop
	jsr libScreenWaitFrame     ; Wait for end of frame, start of new frame.

; Due to the frame sync above, at this point the code
; is running at/near the top of the screen refresh.

	lda CurrentEvent           ; Get the current event
	asl                        ; Times 2 for size of address
	tax                        ; Use as index

	lda EVENT_TARGET_TABLE+1,x ; Get routine high byte
	pha                        ; Push to stack
	lda EVENT_TARGET_TABLE,x   ; Get routine low byte 
	pha                        ; Push to stack

	rts                        ; Forces alling the address pushed on the stack.

	; When the called routine ends with rts, it will return to the place 
	; that called this routine which is up in GameStart.

; ==========================================================================
; END OF GAME EVENT LOOP
; --------------------------------------------------------------------------




; ==========================================================================
; TRANSITION TO TITLE
; Setup Transition to Title routine turned on the title display.
; Stage 1: Scroll in the Title.
; Stage 2: Brighten line 4 luminance.
; Stage 3: Initialize setup for Press Button on Title screen.
; --------------------------------------------------------------------------
;ContinueTransitionToTitle
;	cmp #EVENT_TRANS_TITLE
;	bne ContinueStartNewGame

;	jsr EventTransitionToTitle

; ==========================================================================
; Event process SCREEN START/NEW GAME
; Clear the Game Scores and get ready for the Press A Button prompt.
;
; Sidebar: This is oddly inserted between Transition to Title and the
; Title to finish internal initialization per game, due to doofus-level
; lack of design planning, blah blah.
; The title screen has already been presented by Transition To Title.
; --------------------------------------------------------------------------
;ContinueStartNewGame
;	cmp #EVENT_START
;	bne ContinueTitleScreen ; EVENT_START=0?  No?

;	jsr EventScreenStart

; ==========================================================================
; Event Process TITLE SCREEN
; The activity on the title screen is
; 1) Blink Prompt for ANY key.
; 2) Wait for joystick button.
; 3) Setup for next transition.
; --------------------------------------------------------------------------
;ContinueTitleScreen
;	cmp #EVENT_TITLE
;	bne ContinueTransitionToGame

;	jsr EventTitleScreen

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
;ContinueTransitionToGame
;	cmp #EVENT_TRANS_GAME
;	bne ContinueGameScreen

;	jsr EventTransitionToGame

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
;ContinueGameScreen
;	cmp #EVENT_GAME
;	bne ContinueTransitionToWin

;	jsr EventGameScreen

; ==========================================================================
; Event Process TRANSITION TO WIN
; The Activity in the transition area, based on timer.
; 1) wipe screen from top to middle, and bottom to middle
; 2) Display the Frogs SAVED!
; 3) Setup to do the Win screen event.
; --------------------------------------------------------------------------
;ContinueTransitionToWin
;	cmp #EVENT_TRANS_WIN
;	bne ContinueWinScreen

;	jsr EventTransitionToWin

; ==========================================================================
; Event Process WIN SCREEN
; Scroll colors on screen while waiting for a button press.
; Setup for next transition.
; --------------------------------------------------------------------------
;ContinueWinScreen
;	cmp #EVENT_WIN
;	bne ContinueTransitionToDead

;	jsr EventWinScreen

; ==========================================================================
; Event Process TRANSITION TO DEAD
; The Activity in the transition area, based on timer.
; 0) On Entry, wait (1.5 sec) to observe splattered frog. (timer set in 
;    the setup event)
; 1) Black background for all playfield lines, turn frog's line red.
; 2) Fade playfield text to black.
; 2) Launch the Dead Frog Display.
; --------------------------------------------------------------------------
;ContinueTransitionToDead
;	cmp #EVENT_TRANS_DEAD
;	bne ContinueDeadScreen

;	jsr EventTransitionToDead

; ==========================================================================
; Event Process DEAD SCREEN
; The Activity is in the transition event, based on timer.
; Run an animated scroll driven by the data in the sine table.
; --------------------------------------------------------------------------
;ContinueDeadScreen
;	cmp #EVENT_DEAD
;	bne ContinueTransitionToOver

;	jsr EventDeadScreen

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
;ContinueTransitionToOver
;	cmp #EVENT_TRANS_OVER
;	bne ContinueOverScreen

;	jsr EventTransitionGameOver


; ==========================================================================
; Event Process GAME OVER SCREEN
; The Activity in the transition area, based on timer.
; --------------------------------------------------------------------------
;ContinueOverScreen
;	cmp #EVENT_OVER
;	bne EndGameLoop

;	jsr EventGameOverScreen

; ==========================================================================
; END OF GAME EVENT LOOP
; --------------------------------------------------------------------------
;EndGameLoop

;	jmp GameLoop     ; rinse, repeat, forever.

;	rts
