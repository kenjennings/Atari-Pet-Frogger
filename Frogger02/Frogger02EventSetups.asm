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
; SETUPS
;
; All the routines to move to a different screen/state.
; --------------------------------------------------------------------------


; ==========================================================================
; SETUP TRANSITION TO TITLE
;
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

	lda #1
	sta EventCounter         ; Declare stage 1 behavior for scrolling.

	lda #<TITLE_MEM1         ; Initialize the
	sta SCROLL_TITLE_LMS0    ; Display List
	lda #<[TITLE_MEM2]       ; LMS 
	sta SCROLL_TITLE_LMS1    ; Addresses
	lda #<[TITLE_MEM3]       ; for scrolling
	sta SCROLL_TITLE_LMS2    ; in the title.

	lda #DISPLAY_TITLE       ; Tell VBI to change screens. 
	jsr ChangeScreen         ; Then copy the color tables.

	lda #SCREEN_TRANS_TITLE  ; Change to Title Screen transition.
	sta CurrentScreen

	rts


; ==========================================================================
; SETUP TRANSITION TO GAME SCREEN
;
; Prep values to run the game screen.
;
; Uses A, X
; --------------------------------------------------------------------------
SetupTransitionToGame
	lda #CREDIT_SPEED       ; Credit Draw Speed
	jsr ResetTimers

	lda #24
	sta EventCounter2       ; Prep the first transition loop. 

	lda #1                  ; First transition stage: Loop from bottom to top
	sta EventCounter

	lda #0                  ; Make background black for the Prompt text.
	sta COLPF2_TABLE+23    
	lda #$0C                ; Set prompt text luminance.
	sta COLPF1_TABLE+23

	lda #SCREEN_TRANS_GAME  ; Next step is operating the transition animation.
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
	lda #0
	sta FrogSafety          ; Schrodinger's current frog is known to be alive.

	lda #INTERNAL_SPACE     ; Default position.
	sta LastCharacter       ; Preset the character under the frog.

	lda #<PLAYFIELD_MEM18   ; Low Byte, Frog position.
	sta FrogLocation
	lda #>PLAYFIELD_MEM18   ; Hi Byte, Frog position.
	sta FrogLocation + 1

	lda #18                 ; 18 (dec), number of screen rows of game field. 
	sta FrogRow

	ldy #19                 ; Frog horizontal coordinate, Y = 19 (dec)
	sty FrogColumn          ; Logical X coordinate
	sty FrogRealColumn1     ; On a Beach row the physical locations are the same
	sty FrogRealColumn2     ; If a scroll row then they are different.

	lda #I_FROG             ; On Atari we're using $7F as the frog shape.
	sta (FrogLocation),y    ; PLAYFIELD_MEM18 (beach) + $13/19 (dec)

;	lda #0                  ; Scrolling LMS offset
;	tax                     ; and for the LMS in other direction.
;	jsr UpdateGamePlayfield ; Reset Game screen to initial position.

;	lda #DISPLAY_GAME       ; Tell VBI to change screens. 
;	jsr ChangeScreen        ; Then copy the color tables.

	lda #SCREEN_GAME        ; Yes, change to game screen event.
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

	jsr CopyScoreToScreen   ; Update the screen information
	jsr PrintFrogsAndLives     

;	lda #WIN_FILL_SPEED     ; Animation moving speed.
;	jsr ResetTimers

;	lda #2                  ; start wiping screen at line 2 (0, 1, 2)
;	sta EventCounter

	lda #DISPLAY_WIN        ; Tell VBI to change screens. 
	jsr ChangeScreen        ; Then copy the color tables.

;	jsr ClearKey

;	jsr CopyWinColorsToDLI

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
	lda #BLINK_SPEED    ; Text Blinking speed for prompt on Title screen.
	jsr ResetTimers

;	jsr ClearKey

	lda #SCREEN_WIN     ; Change to wins screen.
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
	lda #I_SPLAT            ; Atari ASCII $2A/42 (dec) Splattered Frog.
	sta (FrogLocation),y    ; Road kill the frog.

	dec NumberOfLives       ; subtract a life.
	jsr CopyScoreToScreen   ; Update the screen information
	jsr PrintFrogsAndLives     

	inc FrogSafety          ; Schrodinger knows the frog is dead.
	lda #FROG_WAKE_SPEED    ; Initial delay 1.5 sec for frog corpse '*' viewing/mourning
	jsr ResetTimers

	lda #0                  ; Zero event controls.
	sta EventCounter

	lda #DISPLAY_DEAD       ; Tell VBI to change screens. 
	jsr ChangeScreen        ; Then copy the color tables.

;	jsr ClearKey

;	jsr CopyDeadColorsToDLI

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
	lda #BLINK_SPEED     ; Text Blinking speed for prompt on Title screen.
	jsr ResetTimers

;	jsr ClearKey
	
	lda #SCREEN_DEAD     ; Change to dead screen.
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
	lda #RES_IN_SPEED      ; Animation moving speed.
	jsr ResetTimers

	lda #60                ; Number of times to do the Game Over EOR effect
	sta EventCounter

	lda #DISPLAY_OVER      ; Tell VBI to change screens. 
	jsr ChangeScreen       ; Then copy the color tables.

;	jsr ClearKey

;	jsr CopyOverColorsToDLI 

	lda #SCREEN_TRANS_OVER ; Change to game over transition.
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
	lda #BLINK_SPEED     ; Text Blinking speed for prompt on Title screen.
	jsr ResetTimers

;	jsr ClearKey
	
	lda #SCREEN_OVER     ; Change to Game Over screen.
	sta CurrentScreen

	rts


