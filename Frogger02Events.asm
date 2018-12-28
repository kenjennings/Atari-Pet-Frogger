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
; Frogger EVENTS 
;
; All the routines to run for each screen/state.
; --------------------------------------------------------------------------


; Screen enumeration states for current processing condition.
; Note that the order here does not imply the only order of 
; movement between screens/event activity.  The enumeration 
; could be entirely random.
SCREEN_START       = 0  ; Entry Point for New Game setup..
SCREEN_TITLE       = 1  ; Credits and Instructions.
SCREEN_TRANS_GAME  = 2  ; Transition animation from Title to Game.
SCREEN_GAME        = 3  ; GamePlay 
SCREEN_TRANS_WIN   = 4  ; Transition animation from Game to Win.
SCREEN_WIN         = 5  ; Crossed the river!
SCREEN_TRANS_DEAD  = 6  ; Transition animation from Game to Dead.
SCREEN_DEAD        = 7  ; Yer Dead!
SCREEN_TRANS_OVER  = 8  ; Transition animation from Dead to Game Over.
SCREEN_OVER        = 9  ; Game Over.
SCREEN_TRANS_TITLE = 10 ; Transition animation from Game Over to Title.

; Screen Order/Path
;                       +-------------------------+
;                       V                         |
; Screen Title ---> Game Screen -+-> Win Screen  -+
;       ^               ^        |
;       |               |        +-> Dead Screen -+-> Game Over -+
;       |               |                         |              |
;       |               +-------------------------+              |
;       +--------------------------------------------------------+


; ==========================================================================
; Event process SCREEN START/NEW GAME
; Setup for New Game and do transition to Title screen.
; --------------------------------------------------------------------------
EventScreenStart
	jsr ClearGameScores     ; Zero the score.  And high score if not set.

	jsr DisplayTitleScreen  ; Draw title and game instructions.

	jsr CopyTitleColorsToDLI
	
	lda #BLINK_SPEED        ; Text Blinking speed for prompt on Title screen.
	jsr ResetTimers

	lda #SCREEN_TITLE       ; Next step is operating the title screen input.
	sta CurrentScreen

	rts


; ==========================================================================
; Event Process TITLE SCREEN
; The activity on the title screen is 
; Blink Prompt for ANY key.
; Wait for Key.
; Setup for next transition.
; --------------------------------------------------------------------------
EventTitleScreen
	jsr RunPromptForAnyKey     ; Blink Prompt to press ANY key.  check key.
	beq EndTitleScreen         ; Nothing pressed, done with title screen.

ProcessTitleScreenInput        ; a key is pressed. Prepare for the screen transition.
	jsr SetupTransitionToGame

EndTitleScreen
	lda CurrentScreen          ; Yeah, redundant to when a key is pressed.

	rts


; ==========================================================================
; Event Process TRANSITION TO GAME SCREEN
; The Activity in the transition area, based on timer.
; 1) Progressively reprint the credits on lines from the top of the screen 
; to the bottom.
; 2) follow with a blank line to erase the highest line of trailing text.
; --------------------------------------------------------------------------
EventTransitionToGame
	lda AnimateFrames        ; Did animation counter reach 0 ?
	bne EndTransitionToGame  ; Nope.  Nothing to do.
	lda #CREDIT_SPEED        ; yes.  Reset it.
	jsr ResetTimers

	ldy #PRINT_BLANK_TXT    ; erase top line
	ldx EventCounter
	jsr PrintToScreen

	inx                     ; next row.
	stx EventCounter        ; Save new row number
	ldy #PRINT_CREDIT_TXT   ; Print the culprits responsible
	jsr PrintToScreen

	cpx #22                 ; reached bottom of screen?
	bne EndTransitionToGame ; No.  Remain on this transition event next time.

	jsr SetupGame

EndTransitionToGame
	lda CurrentScreen

	rts


; ==========================================================================
; Event Process GAME SCREEN
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
EventGameScreen
; ==========================================================================
; GAME SCREEN - Keyboard Input Section
; --------------------------------------------------------------------------
	jsr CheckKey             ; Get a key if timer permits.
	cmp #$FF                 ; Key is pressed?
	beq CheckForAnim         ; Nothing pressed, Skip the input section.

	sta LastKeyPressed       ; Save key.

	ldy FrogColumn           ; Current X coordinate
	lda LastCharacter        ; Get the last character (under the frog)
	sta (FrogLocation),y     ; Erase the frog with the last character.

ProcessKey ; Process keypress
	lda LastKeyPressed       ; Restore the key press to A

	cmp #KEY_4               ; Testing for Left "4" key, #24
	bne RightKeyTest         ; No.  Go test for Right.

	dey                      ; Move Y to left.
	sty FrogColumn
	bpl SaveNewFrogLocation  ; Not $FF.  Go place frog on screen.
	iny                      ; It is $FF.  Correct by adding 1 to Y.
	sty FrogColumn
	bpl SaveNewFrogLocation  ; Place frog on screen

RightKeyTest 
	cmp #KEY_6               ; Testing for Right "6", #27
	bne UpKeyTest            ; Not "6" key, so go test for Up.

	iny                      ; Move Y to right.
	cpy #$28                 ; Did it move off screen? Position $28/40 (dec)
	sty FrogColumn
	bne SaveNewFrogLocation  ; No.  Go place frog on screen.
	dey                      ; Yes.  Correct by subtracting 1 from Y.
	sty FrogColumn
	bne SaveNewFrogLocation  ; Corrected.  Go place frog on screen.

UpKeyTest ; Test for Up "S" key
	cmp #KEY_S               ; Atari "S", #62 ?
	bne ReplaceFrogOnScreen  ; No.  Replace Frog on screen.  Try boat animation.
	jsr FrogMoveUp           ; Yes, go do UP.
	beq DoSetupForFrogWins   ; No more rows to cross. Update to frog Wins!

; Row greater than 0.  Evaluate good/bad jump. 
SaveNewFrogLocation
	lda (FrogLocation),y     ; Get the character in the new position.
	sta LastCharacter        ; Save for later when frog moves.
	sty FrogColumn
	
; Will the Pet Frog land on the Beach?
	cmp #INTERNAL_INVSPACE   ; Atari uses inverse space for beach
	beq ReplaceFrogOnScreen  ; The beach is safe. Draw the frog.

; Will the Pet Frog land in the boat?
CheckBoatLanding
	cmp #INTERNAL_BALL       ; Atari uses ball graphics, ctrl-t
	beq ReplaceFrogOnScreen  ; Yes.  Safe!  Draw the frog.  

; Safe locations have been accounted.
; Wherever the Frog will land now, it is Baaaaad.
DoSetupForYerDead
	jsr SetupTransitionToDead
	bne EndGameScreen        ; last action in function is lda/sta a non-zero value.

	; Safe location at the far beach.  the Frog is saved.
DoSetupForFrogWins
	jsr SetupTransitionToWin
	bne EndGameScreen        ; last action in function is lda/sta a non-zero value.

; Replace frog on screen, continue with boat animation.
ReplaceFrogOnScreen
	lda #INTERNAL_O          ; Atari internal code for "O" is frog.
	sta (FrogLocation),y     ; Save to screen memory to display it.

; ==========================================================================
; GAME SCREEN - Screen Animation Section
; --------------------------------------------------------------------------
CheckForAnim
	lda AnimateFrames        ; Does the timer allow the boats to move?
	bne EndGameScreen        ; Nothing at this time. Exit.

	jsr SetBoatSpeed         ; Reset timer for animation based on number of saved frogs.

	jsr AnimateBoats         ; Move the boats around.
	jsr AutoMoveFrog         ; GOTO AUTOMVE
	lda FrogSafety           ; Whay does Schrodinger have to say?
	bne DoSetupForYerDead    ; Nooooooo!

EndGameScreen
	lda CurrentScreen  

	rts


; ==========================================================================
; Event Process TRANSITION TO WIN
; The Activity in the transition area, based on timer.
; 1) wipe screen from top to middle, and bottom to middle
; 2) Display the Frogs SAVED!
; 3) Setup to do the Win screen event.
; --------------------------------------------------------------------------
EventTransitionToWin
	lda AnimateFrames        ; Did animation counter reach 0 ?
	bne EndTransitionToWin   ; Nope.  Nothing to do.

	lda #WIN_FILL_SPEED      ; yes.  Reset it. (60 / 6 == 10 updates per second)
	jsr ResetTimers

	ldx EventCounter         ; Row number for text.
	cpx #13                  ; From 2 to 12, erase from top to middle
	beq DoSwitchToWins       ; When at 13 then fill screen is done.

	ldy #PRINT_BLANK_TXT_INV ; inverse blanks.  
	jsr PrintToScreen

	lda #26                  ; Subtract Row number for text from 26 (26-2 = 24)
	sec
	sbc EventCounter
	tax

	jsr PrintToScreen        ; And print the inverse blanks again.

	inc EventCounter
	bne EndTransitionToWin   ; Nothing else to do here.

; Clear screen is done.   Display the big prompt.
DoSwitchToWins 
	jsr PrintWinFrogGfx      ; Copy the big text announcement to screen

	jsr SetupWin             ; Setup for Wins screen (which only waits for input )
	
EndTransitionToWin
	lda CurrentScreen

	rts


; ==========================================================================
; Event Process WIN SCREEN
; The Activity in the transition area, based on timer.
; Blink Prompt for ANY key.
; Wait for Key.
; Setup for next transition.
; --------------------------------------------------------------------------
EventWinScreen
	jsr RunPromptForAnyKey ; Blink Prompt to press ANY key.  check key.
	beq EndWinScreen       ; Nothing pressed, done with title screen.

ProcessWinScreenInput      ; a key is pressed. Prepare for the screen transition.
	jsr SetupTransitionToGame 

EndWinScreen
	lda CurrentScreen      ; Yeah, redundant to when a key is pressed.

	rts


; ==========================================================================
; Event Process TRANSITION TO DEAD
; The Activity in the transition area, based on timer.
; 1) Wait (1.5 sec) to observe splattered frog. (timer set from prior event)
; 2) Wipe screen from sides to center.
; 3) Print the big yer dead text.  
; 4) setup for get any key on the Dead screen.
; --------------------------------------------------------------------------
EventTransitionToDead
	lda AnimateFrames           ; Did animation counter reach 0 ?
	bne EndTransitionToDead     ; Nope.  Nothing to do.

	lda #DEAD_FILL_SPEED        ; yes.  Reset it. (drawing speed)
	jsr ResetTimers

	ldy EventCounter            ; column number for text.
	cpy #20                     ; From 0 to 19, erase from left to middle.
	beq DoTransitionToDeadPart2 ; wipe done. continue to big dead text.        

; PART 1 -- Wipe the screen from sides to center.
DoTransitionToDeadPart1         ; Have not reached the end, wipe more screen
	ldx #4                      ; use as line index. 2 (*2) to 24 (*2)

LoopDeadTransition
	jsr LoadScreenPointerFromX  ; Load ScreenPointer From X index.  duh.
	stx SAVEX                   ; Keep for later.

	lda #INTERNAL_INVSPACE      ; inverse space
	sta (ScreenPointer),y       ; stuff into column Y from the left.
	sty SAVEY                   ; Save the Y column.
	lda #39                     ; Subtract ...
	sec                         ; the column...
	sbc SAVEY                   ; from 39...
	tay                         ; for the right side.
	lda #INTERNAL_INVSPACE
	sta (ScreenPointer),y       ; And stuff into column Y from the right.

	cpx #50 ; Lines 0 to 24 times 2.  Line 25 times 2 is the exit.
	bne LoopDeadTransition

	inc EventCounter            ; Set for next run to the next column
	bne EndTransitionToDead     ; And this turn is done.

; PART 2 -- Clear screen is done.  
DoTransitionToDeadPart2
	jsr PrintDeadFrogGfx        ; Display the Big Dead Frog Text.

	jsr SetupDead               ; Setup for Dead screen (wait for input loop)

EndTransitionToDead
	lda CurrentScreen

	rts


; ==========================================================================
; Event Process DEAD SCREEN
; The Activity in the transition area, based on timer.
;
; --------------------------------------------------------------------------
EventDeadScreen
	jsr RunPromptForAnyKey     ; Blink Prompt to press ANY key.  check key.
	beq EndDeadScreen          ; Nothing pressed, done with this pass on the screen.

ProcessDeadScreenInput         ; a key is pressed. Prepare for the screen transition.
	lda NumberOfLives          ; Have we run out of frogs?
	beq SwitchToGameOver       ; Yes.  Game Over.

	jsr SetupTransitionToGame  ; Go back to game screen.
	bne EndDeadScreen

SwitchToGameOver
	jsr SetupTransitionToGameOver

EndDeadScreen
	lda CurrentScreen          ; Yeah, redundant to when a key is pressed.

	rts


; ==========================================================================
; Event Process TRANSITION TO OVER
; The Activity in the transition area, based on timer.
; 1) Progressively reprint the credits on lines from the top of the screen 
; to the bottom.
; 2) follow with a blank line to erase the highest line of trailing text.
; --------------------------------------------------------------------------
EventTransitionGameOver
	lda AnimateFrames          ; Did animation counter reach 0 ?
	bne EndTransitionGameOver  ; Nope.  Nothing to do.

	dec EventCounter                ; Decrement pass counter.
	beq DoTransitionToGameOverPart2 ; When this reaches 0 finish the screen

	lda #RES_IN_SPEED          ; Running animation loop. Reset timer.
	jsr ResetTimers

	; Randomize display of Game Over
	ldy #16                    ; Do 16 random characters per pass.
GetRandomX
	lda RANDOM                 ; Get a random value.
	and #$7F                   ; Mask it down to 0 to 127 value
	cmp #118                   ; Is it more than 118?
	bcs GetRandomX             ; Yes, retry it.
	tax                        ; The index into the image and screen buffers.
	lda GAME_OVER_GFX,x        ; Get image byte
	beq SkipGameOverEOR        ; if this is 0 just copy to screen
	eor SCREENMEM+400,x        ; Exclusive Or with screen
SkipGameOverEOR
	sta SCREENMEM+400,x        ; Write to screen
	dey                 
	bne GetRandomX             ; Do another random character in this turn.
	beq EndTransitionGameOver

	; Finish up. 
DoTransitionToGameOverPart2
	jsr PrintGameOverGfx       ;  Draw Big Game Over

	jsr SetupGameOver 

EndTransitionGameOver
	lda CurrentScreen

	rts


; ==========================================================================
; Event Process GAME OVER SCREEN
; The Activity in the transition area, based on timer.
;
; --------------------------------------------------------------------------
EventGameOverScreen
	jsr RunPromptForAnyKey     ; Blink Prompt to press ANY key.  check key.
	beq EndGameOverScreen      ; Nothing pressed, done with title screen.

ProcessGameOverScreenInput     ; a key is pressed. Prepare for the screen transition.
	jsr SetupTransitionToTitle

EndGameOverScreen
	lda CurrentScreen          ; Yeah, redundant to when a key is pressed.

	rts


; ==========================================================================
; Event Process TRANSITION TO TITLE
; The Activity in the transition area, based on timer.
; 1) Progressively reprint the credits on lines from the top of the screen 
; to the bottom.
; 2) follow with a blank line to erase the highest line of trailing text.
; --------------------------------------------------------------------------
EventTransitionToTitle
	lda AnimateFrames        ; Did animation counter reach 0 ?
	bne EndTransitionToTitle ; Nope.  Nothing to do.
	lda #TITLE_SPEED         ; yes.  Reset it.
	jsr ResetTimers

	ldy #PRINT_BLANK_TXT     ; erase top line
	ldx EventCounter
	jsr PrintToScreen

	inx                      ; next row.
	stx EventCounter         ; Save new row number
	cpx #25                  ; reached bottom of screen?
	bne EndTransitionToTitle ; No.  Remain on this transition event next time.

	jsr ClearKey
	
	lda #SCREEN_START        ; Yes, change to beginning of event cycle/start new game.
	sta CurrentScreen

EndTransitionToTitle
	lda CurrentScreen

	rts

