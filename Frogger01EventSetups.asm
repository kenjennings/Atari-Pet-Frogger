; ==========================================================================
; SETUPS 
;
; All the routines to move from the current screen/state to the 
; a different screen/state.
; --------------------------------------------------------------------------



; ==========================================================================
; SETUP TRANSITION TO GAME SCREEN 
;
; Prep values to run the game screen.
;
; Uses A, X 
; --------------------------------------------------------------------------
SetupTransitionToGame
	lda #10                      ; Line draw speed
	jsr ResetTimers

	lda #3                       ; Transition Loops from third row through 21st row.
	sta EventCounter

	lda #SCREEN_TRANS_GAME       ; Next step is operating the transition animation.
	sta CurrentScreen   

	rts


; ==========================================================================
; SETUP GAME SCREEN 
;
; Prep values to run the game screen.
;
; Uses A, X 
; --------------------------------------------------------------------------
SetupGame
	jsr DisplayGameScreen   ; Draw game screen.

	lda #0
	sta FrogSafety          ; Schrodinger's current frog is known to be alive.

	lda #SCREEN_GAME        ; Yes, change to game screen.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP TRANSITION TO WIN SCREEN 
;
; Prep values to run the Transition Event for the Win screen
;
; Uses A, X 
; --------------------------------------------------------------------------
SetupTransitionToWin
	jsr Add500ToScore

	lda #6                 ; Animation moving speed.
	jsr ResetTimers

	lda #0                  ; Zero event controls.
	sta EventCounter
	sta EventStage

	lda #SCREEN_TRANS_WIN   ; Next step is operating the transition animation.
	sta CurrentScreen   

	rts


; ==========================================================================
; SETUP WIN SCREEN 
;
; Prep values to run the Win screen
;
; Uses A, X 
; --------------------------------------------------------------------------
SetupWin
	lda #60                 ; Text Blinking speed for prompt on WIN screen.
	jsr ResetTimers

	lda #SCREEN_WIN         ; Change to wins screen.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP TRANSITION TO DEAD SCREEN 
;
; Prep values to run the Transition Event for the dead frog.
; Splat frog.  
; Set timer to 1.5 second wait.
;
; Uses A, X 
; --------------------------------------------------------------------------
SetupTransitionToDead
	; splat the frog:
	lda #INTERNAL_ASTER  ; Atari ASCII $2A/42 (dec) Splattered Frog.
	sta (FrogLocation),y ; Road kill the frog.

	lda #90                 ; Initial delay moving speed.
	jsr ResetTimers

	lda #0                  ; Zero event controls.
	sta EventCounter
	sta EventStage

	lda #SCREEN_TRANS_DEAD  ; Next step is operating the transition animation.
	sta CurrentScreen   

	rts


; ==========================================================================
; SETUP DEAD SCREEN 
;
; Prep values to run the Dead screen
;
; Uses A, X 
; --------------------------------------------------------------------------
SetupDead
	lda #60                 ; Text Blinking speed for prompt on DEAD screen.
	jsr ResetTimers

	lda #SCREEN_DEAD         ; Change to dead screen.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP TRANSITION TO GAME OVER SCREEN 
;
; Prep values to run the Transition Event for the Game Over.
;
; Uses A, X 
; --------------------------------------------------------------------------
SetupTransitionToGameOver
	lda #2                           ; Animation moving speed.
	jsr ResetTimers

	lda #180
	sta EventCounter

	lda #SCREEN_TRANS_OVER         ; Change to game over transition.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP GAME OVER SCREEN 
;
; Prep values to run the Game Over screen
;
; Uses A, X 
; --------------------------------------------------------------------------
SetupGameOver
	lda #60                 ; Text Blinking speed for prompt on DEAD screen.
	jsr ResetTimers

	lda #SCREEN_OVER         ; Change to dead screen.
	sta CurrentScreen

	rts







