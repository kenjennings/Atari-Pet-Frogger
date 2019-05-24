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
; SETUPS
; ==========================================================================
; All the routines to move to a different screen/event state.
; --------------------------------------------------------------------------


; ==========================================================================
; SETUP TRANSITION TO TITLE
; ==========================================================================
; Prep values to begin the Transition Event for the Title Screen. That is:
; Initialize scrolling line in title text.
; Tell VBI to switch to title screen.
;
; Transition events:
; Stage 1: Scroll in the Title. (three lines, one at a time.)
; Stage 2: Brighten line 4 luminance.
; Stage 3: Initialize setup for Press Button on Title screen.
;
; Uses A, X
; --------------------------------------------------------------------------

SetupTransitionToTitle

	lda #TITLE_SPEED         ; Animation moving speed.
	jsr ResetTimers

	jsr HideButtonPrompt     ; Tell VBI the prompt flashing is disabled.
	jsr EraseFrog            ; Specifically zero the object (from Game Over)

	lda #1
	sta EventCounter         ; Declare stage 1 behavior for scrolling.

	lda #DISPLAY_TITLE       ; Tell VBI to change screens.
	jsr ChangeScreen         ; Then copy the color tables.

	lda #SCREEN_TRANS_TITLE  ; Change to Title Screen transition.
	sta CurrentScreen

	lda #0                  ; Zero "old" position to trigger Updates to redraw first time.
	sta FrogPMX
	sta FrogPMY
	sta FrogShape           ; 0 is "off"  (it would already be off by default)

	lda #OFF_FROGX          ; Set new X position to middle of screen.
	sta WobOffsetX
	sta FrogNewPMX

	lda #OFF_FROGY          ; Set new Y position to origin. (row 18)
	sta WobOffsetY
	sta FrogNewPMY

	lda #SHAPE_FROG         ; Set new frog shape.
	sta FrogNewShape

	rts


; ==========================================================================
; SETUP TRANSITION TO GAME SCREEN
; ==========================================================================
; Prep values to run the game screen.
;
; Uses A, X
; --------------------------------------------------------------------------

SetupTransitionToGame

	lda #TITLE_WIPE_SPEED   ; Speed of fade/dissolve for transition
	jsr ResetTimers

	jsr HideButtonPrompt   ; Tell VBI the prompt flashing is disabled.
	jsr EraseFrog          ; Specifically zero the object.

	lda #24
	sta EventCounter2       ; Prep the first transition loop.

	lda #1                  ; First transition stage: Loop from bottom to top
	sta EventCounter

	lda #SCREEN_TRANS_GAME  ; Next step is operating the transition animation.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP GAME SCREEN
; ==========================================================================
; Prep values to run the game screen.
;
; The actual game display was switched on by the Trans Game event.
;
; Uses A, X
; --------------------------------------------------------------------------

SetupGame

	lda #0
	sta FrogSafety          ; Schrodinger's current frog is known to be alive.

	jsr HideButtonPrompt   ; Tell VBI the prompt flashing is disabled on the game screen.

	lda #18                 ; 18 (dec), number of screen rows of game field.
	sta FrogNewRow
	sta FrogRow

	lda #0                  ; Zero "old" position to trigger Updates to redraw first time.
	sta FrogPMX
	sta FrogPMY
	sta FrogShape           ; 0 is "off"  (it would already be off by default)

	lda #MID_FROGX          ; Set new X position to middle of screen.
	sta FrogNewPMX

	lda #MAX_FROGY          ; Set new Y position to origin. (row 18)
	sta FrogNewPMY

	lda #SHAPE_FROG         ; Set new frog shape.
	sta FrogNewShape

	jsr PlayWaterFX         ; Start water noises.  Now.

	lda #SCREEN_GAME        ; Yes, change to game screen event.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP TRANSITION TO WIN SCREEN
; ==========================================================================
; Prep values to run the Transition Event for the Win screen
;
; Uses A, X
; --------------------------------------------------------------------------

SetupTransitionToWin

	jsr Add500ToScore

	jsr CopyScoreToScreen   ; Update the screen information
	jsr PrintFrogsAndLives

	lda #DISPLAY_WIN        ; Tell VBI to change screens.
	jsr ChangeScreen        ; Then copy the color tables.

	jsr libPmgClearBitmaps  ; Get rid of frog.

	ldx #3                  ; Setup channel 3 to play Ode To Joy for saving the frog.
	ldy #SOUND_JOY
	jsr SetSound 

	lda #SCREEN_TRANS_WIN   ; Next step is operating the transition animation.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP WIN SCREEN
; ==========================================================================
; Prep values to run the Win screen
;
; Uses A, X
; --------------------------------------------------------------------------

SetupWin

	lda #WIN_CYCLE_SPEED    ; 
	jsr ResetTimers

	lda #238                ; Color scrolling 238 to 16
	sta EventCounter

	lda #SCREEN_WIN         ; Change to wins screen.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP TRANSITION TO DEAD SCREEN
; ==========================================================================
; Prep values to run the Transition Event for the dead frog.
; Splat frog.
; Set timer to 1.5 second wait.
;
; Uses A, X
; --------------------------------------------------------------------------

SetupTransitionToDead

	jsr SetSplatteredOnScreen ; splat the frog:

	dec NumberOfLives       ; subtract a life.
	jsr CopyScoreToScreen   ; Update the screen information
	jsr PrintFrogsAndLives

;	inc FrogSafety          ; Schrodinger knows the frog is dead.
	lda #FROG_WAKE_SPEED    ; Initial delay 3 sec for frog corpse viewing/mourning
	jsr ResetTimers

	lda #1                  ; Set Stage 1 in the fading control.
	sta EventCounter

	ldx #3                  ; Setup channel 3 to play funeral dirge for the dead frog.
	ldy #SOUND_DIRGE
	jsr SetSound 

	; In this case we do not want the Transition to change to the next 
	; display immediately as the player must have time to view and 
	; mourn the splattered frog remains laying in state.  There will be 
	; a pause of about 1.5 seconds for player's tears. 

	lda #SCREEN_TRANS_DEAD  ; Next step is operating the transition animation.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP DEAD SCREEN
; ==========================================================================
; Prep values to run the Dead screen
;
; Uses A, X
; --------------------------------------------------------------------------

SetupDead

	lda #DEAD_CYCLE_SPEED     ; Animation moving speed.
	jsr ResetTimers
	
	lda #DISPLAY_DEAD        ; Tell VBI to change screens.
	jsr ChangeScreen         ; Then copy the color tables.

	jsr libPmgClearBitmaps   ; Scrape splattered frog off screen.

;	jsr RemoveFrogOnScreen   ; Remove the frog (corpse) from the screen

	lda #0                   ; Color cycling index for dead.
	sta EventCounter

	lda #SCREEN_DEAD         ; Change to dead screen event.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP TRANSITION TO GAME OVER SCREEN
; ==========================================================================
; Prep values to run the Transition Event for the Game Over.
;
; Fade out all lines of the Dead Screen.  
; Fade in the lines of the Game Over Screen.
;
; This seems gratuitous, but it is necessary, because the screen can 
; be switched so fast that the user pressing the button on the Dead 
; Screen may not be able to release the button fast enough and end 
; up immediately dismissing the game over screen.  Not feeling enterprising,
; so just use the Dead value for fading.
;
; Uses A, X
; --------------------------------------------------------------------------

SetupTransitionToGameOver

	lda #DEAD_FADE_SPEED   ; Animation moving speed.
	jsr ResetTimers 

	lda #1                 ; set Stage 1 for fade out.
	sta EventCounter

	lda #16                ; Set number of times to loop the fade.
	sta EventCounter2

	jsr HideButtonPrompt   ; Tell VBI the prompt flashing is disabled.
	jsr EraseFrog          ; Specifically zero the object.

	lda #SCREEN_TRANS_OVER ; Change to transition to Game Over.
	sta CurrentScreen

	lda #0                  ; Zero "old" position to trigger Updates to redraw first time.
	sta FrogPMX
	sta FrogPMY
	sta FrogShape           ; 0 is "off"  (it would already be off by default)

	lda #OFF_TOMBX          ; Set new X position to middle of screen.
	sta WobOffsetX
	sta FrogNewPMX

	lda #OFF_TOMBY          ; Set new Y position to origin. (row 18)
	sta WobOffsetX
	sta FrogNewPMY

	lda #SHAPE_TOMB         ; Set new tomb shape.
	sta FrogNewShape

	rts


; ==========================================================================
; SETUP GAME OVER SCREEN
;
; Prep values to run the Game Over screen
;
; Uses A, X
; --------------------------------------------------------------------------

SetupGameOver

	lda #GAME_OVER_SPEED   ; Animation moving speed.
	jsr ResetTimers

	lda #SCREEN_OVER       ; Change to Game Over screen.
	sta CurrentScreen

	lda #0                ; base color for down color scroll
	sta EventCounter

	rts
