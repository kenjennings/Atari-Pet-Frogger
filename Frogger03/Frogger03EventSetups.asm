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
; Version 03, August 2019
; ==========================================================================

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

	lda #60
	sta AnimateFrames4       ; Title screen flashing.
	lda #0
	sta EventCounter2        ; First label (score flashes)
	sta EventStage           ; Drawing Title.
	jsr TitleRender          ; 0 is erase title.
	jsr TitleSetOrigin       ; Make sure left buffer is visible.

	jsr HideButtonPrompt     ; Tell VBI the prompt flashing is disabled.
	jsr RemoveFrogOnScreen   ; Remove the frog (from Game Over) if visible 

	lda #1
	sta EventStage           ; Declare stage 1 behavior for Title Screen.

	lda #DISPLAY_TITLE       ; Tell VBI to change displays. VBI will reset origin.
	jsr ChangeScreen         ; Then copy the color tables.  

	lda #EVENT_TRANS_TITLE   ; Change to Title Screen transition.
	sta CurrentEvent

	lda #OFF_FROGX           ; Set new X position to middle of screen.
	sta WobOffsetX

	lda #OFF_FROGY           ; Set new Y position to origin. (row 18)
	sta WobOffsetY

	jsr WobbleDeWobbleX_Now  ; Force immediate calculation of new X position.
	jsr WobbleDeWobbleY_Now  ; Force immediate calculation of new Y position.

	jsr SetFrogOnScreen      ; set Frog shape, set eye position, turn on VBI updates.
                             ; and finally enable VBI to start P/M redraw. (>0 is ON)

	rts


; ==========================================================================
; SETUP TRANSITION TO GAME SCREEN
; ==========================================================================
; Prep values to run the game screen.
;
; Uses A, X
; --------------------------------------------------------------------------

SetupTransitionToGame

	lda #TITLE_WIPE_SPEED  ; Speed of fade/dissolve for transition
	jsr ResetTimers

	jsr HideButtonPrompt   ; Tell VBI the prompt flashing is disabled.

	lda #$FF               ; Remove the animated thing from display.
	sta FrogUpdate         ; This cause VBI to erase and not redraw.

	lda #25
	sta EventCounter2      ; Prep the first transition loop.

	lda CurrentDL
	cmp #DISPLAY_DEAD
	beq GameStartAtTwo     ; This is Dead display.  Skip ahead to Part Two.
	cmp #DISPLAY_WIN
	beq GameStartAtTwo     ; This is Win display.  Skip ahead to Part Two.

GameStartAtOne             ; Not Dead, Not Win.  Must be OVER, or other.
	lda #1                 ; First transition stage: Loop from bottom to top
	sta EventStage
	bne TransitionToGameSetEvent

GameStartAtTwo ; Coming here from WIN will end up with black Scores/Status text.
	           ; Fix this first by restoring the original colors. 
	lda GAME_COLPF1_COLORS+1
	sta COLPF1_TABLE+1
	lda GAME_COLPF1_COLORS+2
	sta COLPF1_TABLE+2
	; setup for fade in Game screen.
	lda #2
	sta EventStage

TransitionToGameSetEvent
	lda #EVENT_TRANS_GAME  ; Next step is operating the transition animation.
	sta CurrentEvent

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
	sta FrogSafety         ; Schrodinger's current frog is known to be alive.

	jsr HideButtonPrompt   ; Tell VBI the prompt flashing is disabled on the game screen.

	lda #0                 ; Zero "old" position to trigger Updates to redraw first time.
	sta FrogPMX
	sta FrogPMY
	sta FrogShape          ; 0 is "off"  (it would already be off by default)

	ldx #18                ; 18 (dec), number of screen rows of game field.
	stx FrogNewRow
	stx FrogRow

	lda FROG_PMY_TABLE,x   ; Get the new Player/Missile Y position based on row number.
	sta FrogNewPMY         ; Update Frog position on screen. 

	lda #MID_FROGX         ; Set new X position to middle of screen.
	sta FrogNewPMX

	jsr SetFrogOnScreen    ; set Frog shape, set eye position, turn on VBI updates.

	jsr PlayWaterFX        ; Start water noises.  Now.

	lda #EVENT_GAME        ; Yes, change to game screen event.
	sta CurrentEvent

	rts


; ==========================================================================
; SETUP TRANSITION TO WIN SCREEN
; ==========================================================================
; Prep values to run the Transition Event for the Win screen
;
; The Ode To Joy winning song is played on two channels started a 
; frame apart (1/60th sec NTSC).  Hopefully this makes a ringing/echo 
; kind of effect.
;
; Uses A, X
; --------------------------------------------------------------------------

SetupTransitionToWin

	jsr Add500ToScore

	lda #DISPLAY_WIN        ; Tell VBI to change screens.
	jsr ChangeScreen        ; Then copy the color tables.

	ldx #3                  ; Setup channel 3 to play Ode To Joy for saving the frog.
	ldy #SOUND_JOY
	jsr SetSound 

	jsr libScreenWaitFrame  ; Wait for a frame.

	ldx #2                  ; Setup channel 2 to play Ode To Joy for saving the frog.
	ldy #SOUND_JOY
	jsr SetSound 

	lda #EVENT_TRANS_WIN   ; Next step is operating the transition animation.
	sta CurrentEvent

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

	lda #238                ; Color scrolling 238 to 16;  Light to dark. Increment.
	sta EventCounter

	lda #0
	sta EventStage          ; Stage 0 is color scrolling and input checking.

	lda #EVENT_WIN          ; Change to wins screen.
	sta CurrentEvent
	
	rts


; ==========================================================================
; SETUP TRANSITION TO DEAD SCREEN
; ==========================================================================
; Prep values to run the Transition Event for the dead frog.
; Splat frog.
; Set timer to 1.5 second wait.
;
; VBI established Schrodinger knows the frog is dead.
;
; Uses A, X
; --------------------------------------------------------------------------

SetupTransitionToDead

	jsr SetSplatteredOnScreen  ; splat the frog:

	dec NumberOfLives       ; subtract a life.
	lda #COLOR_PURPLE+$F    ; Flash the Lives counter label.
	sta COLPM0_TABLE+1
	sta COLPM1_TABLE+1
	jsr CopyScoreToScreen   ; Update the screen information
	jsr PrintFrogsAndLives

	lda #FROG_WAKE_SPEED    ; Initial delay 2 sec for frog corpse viewing/mourning
	jsr ResetTimers

	lda #1                  ; Set Stage 1 in the fading control.
	sta EventStage

	ldx #3                  ; Setup channel 3 to play funeral dirge for the dead frog.
	ldy #SOUND_DIRGE
	jsr SetSound 

	; In this case we do not want the Transition to change to the next 
	; display immediately as the player must have time to view and 
	; mourn the splattered frog remains laying in state.  There will be 
	; a pause of about 1.5 seconds for player's tears. 

	lda #EVENT_TRANS_DEAD  ; Next step is operating the transition animation.
	sta CurrentEvent

	rts


; ==========================================================================
; SETUP DEAD SCREEN
; ==========================================================================
; Prep values to run the Dead screen
;
; Uses A, X
; --------------------------------------------------------------------------

SetupDead

	jsr RemoveFrogOnScreen  ; Scrape splattered frog off screen.

	lda #DEAD_CYCLE_SPEED   ; Animation moving speed.
	jsr ResetTimers

	lda #DISPLAY_DEAD       ; Tell VBI to change screens.
	jsr ChangeScreen        ; Then copy the color tables.

	lda #0                  ; Color cycling index for dead.
	sta EventCounter
	sta EventStage          ; Stage 0 is background color scroll.

	lda #EVENT_DEAD         ; Change to dead screen event.
	sta CurrentEvent

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

	jsr HideButtonPrompt   ; Tell VBI the prompt flashing is disabled.

	lda #EVENT_TRANS_OVER ; Change to transition to Game Over.
	sta CurrentEvent

	rts


; ==========================================================================
; SETUP GAME OVER
; ==========================================================================
; Setup the Game Over screen
;
; Prep values to run the Game Over screen
;
; Uses A, X
; --------------------------------------------------------------------------

SetupGameOver

	lda #GAME_OVER_SPEED    ; Animation moving speed.
	jsr ResetTimers

	lda #DISPLAY_OVER       ; Tell VBI to change screens.
	jsr ChangeScreen        ; Then copy the color tables.

	lda #0                  ; base color for sine scroll. 
	sta EventCounter
	sta EventStage          ; And set stage 0 for color scroll and waiting for input.
                
	sta FrogPMX             ; Zero "old" position to trigger Updates to redraw first time.
	sta FrogPMY
	sta FrogShape           ; 0 is "off"  (it would already be off by default)

	lda #OFF_TOMBX          ; Set new X position to middle of screen.
	sta WobOffsetX

	lda #OFF_TOMBY          ; Set new Y position to origin. (row 18)
	sta WobOffsetX

	lda #SHAPE_TOMB         ; Set new tomb shape.
	sta FrogNewShape

	jsr WobbleDeWobbleX_Now ; Force immediate calculation of new X position.
	jsr WobbleDeWobbleY_Now ; Force immediate calculation of new Y position.

	lda #1
	sta FrogUpdate

	lda #EVENT_OVER         ; Change to Game Over screen.
	sta CurrentEvent

	rts
