; ==========================================================================
; SETUPS
;
; All the routines to move to a different screen/state.
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
;	jsr NewGameSetup
	lda #0
	sta FrogsCrossed        ; Zero the number of successful crossings.
	sta FrogSafety          ; Schrodinger's current frog is known to be alive.

	lda #$12                ; 18 (dec), number of screen rows of playfield.
	sta FrogRow

	lda #$30                ; 48 (dec), delay counter.
	sta DelayNumber

	lda #INTERNAL_INVSPACE ; On Atari use inverse space for beach.
	sta LastCharacter      ; Preset the character under the frog.

	lda #<[SCREENMEM+$320] ; Low Byte, Frog position.
	sta FrogLocation
	lda #>[SCREENMEM+$320] ; Hi Byte, Frog position.
	sta FrogLocation + 1

	ldy #$13               ; Frog horizontal coordinate, Y = 19 (dec)

	jsr ClearGameScores    ; Zero the score.  And high score if not set.

	jsr DisplayGameScreen   ; Draw game screen.

	lda #INTERNAL_O        ; On Atari we're using "O" as the frog shape.
	sta (FrogLocation),y   ; SCREENMEM + $320 + $13

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

	inc FrogSafety          ; Schrodinger knows the frog is dead.
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
	lda #60                 ; Text Blinking speed for prompt on Game Over screen.
	jsr ResetTimers

	lda #SCREEN_OVER         ; Change to Game Over screen.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP TRANSITION TO TITLE
;
; Prep values to run the Transition Event for the Title Screen.
;
; Uses A, X
; --------------------------------------------------------------------------
SetupTransitionToTitle
	lda #10                        ; Animation moving speed.
	jsr ResetTimers

	lda #2
	sta EventCounter                ; start wiping screen at line 2

	lda #SCREEN_TRANS_TITLE         ; Change to Title Screen transition.
	sta CurrentScreen

	rts

