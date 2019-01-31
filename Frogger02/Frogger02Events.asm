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
; Frogger EVENTS
;
; All the routines to run for each screen/state.
; --------------------------------------------------------------------------

; Note that there is no mention in this code for scrolling the credits
; text.  This is entirely handled by the Vertical blank routine.  Every
; display list is the same length and every Display List ends with an LMS
; pointing to the Credit text.  The VBI routine updates the current
; Display List's LMS pointer to the current scroll value.  Since the VBI
; also controls what display is current it always means whatever is on
; Display is guaranteed to have the correct scroll value.  It should seem
; like the credit text is independent of the rest of the display as it will
; update continuously no matter what else is happening.

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
; Event Process TRANSITION TO TITLE
; The setup for Transition to Title will turned on the Title Display.
; Stage 1: Scroll in the Title graphic. (three lines, one at a time.)
; Stage 2: Brighten line 4 luminance.
; Stage 3: Initialize setup for Press Button on Title screen.
; --------------------------------------------------------------------------
EventTransitionToTitle
	lda AnimateFrames        ; Did animation counter reach 0 ?
	bne EndTransitionToTitle ; Nope.  Nothing to do.
	lda #TITLE_SPEED         ; yes.  Reset it.
	jsr ResetTimers

	lda EventCounter         ; What stage are we in?
	cmp #1
	bne TestTransTitle2      ; Not the Title Scroll, try next stage

	; === STAGE 1 ===
	; Each line is 40 spaces followed by the graphics.
	; Scroll each one one at a time.
	lda SCROLL_TITLE_LMS0
	cmp #<[TITLE_MEM1+40]
	beq NowScroll2
	inc SCROLL_TITLE_LMS0
	bne EndTransitionToTitle

NowScroll2
	lda SCROLL_TITLE_LMS1
	cmp #<[TITLE_MEM2+40]
	beq NowScroll3
	inc SCROLL_TITLE_LMS1
	bne EndTransitionToTitle

NowScroll3
	lda SCROLL_TITLE_LMS2
	cmp #<[TITLE_MEM3+40]
	beq FinishedNowSetupStage2
	inc SCROLL_TITLE_LMS2
	bne EndTransitionToTitle

FinishedNowSetupStage2
	lda #2
	sta EventCounter
	bne EndTransitionToTitle

	; === STAGE 2 ===
	; Ramp up luminance of line 4.
TestTransTitle2
	cmp #2
	bne TestTransTitle3

	lda COLPF1_TABLE+3
	cmp #$0E               ; It is maximum brightness?
	beq FinishedNowSetupStage3
	inc COLPF1_TABLE+3
	bne EndTransitionToTitle

FinishedNowSetupStage3
	lda #3
	sta EventCounter
	bne EndTransitionToTitle

	; === STAGE 3 ===
	; Set Up Press Any Button  and get ready to runtitle.
TestTransTitle3
	cmp #3
	bne EndTransitionToTitle  ; Really shouldn't get to that point

	lda #SCREEN_START         ; Yes, change to event to start new game.
	sta CurrentScreen

EndTransitionToTitle
	lda CurrentScreen

	rts


; ==========================================================================
; Event process SCREEN START/NEW GAME
; Clear the Game Scores and get ready for the Press A Button prompt.
;
; Sidebar: This is oddly inserted between Transition to Title and the
; Title to finish internal initialization per game, due to doofus-level
; lack of design planning, blah blah.
; The title screen has already been presented by Transition To Title.
; --------------------------------------------------------------------------
EventScreenStart            ; This is New Game and Transition to title.

	jsr ClearGameScores     ; Zero the score.  And high score if not set.
	jsr CopyScoreToScreen   ; And put into screen memory.

	jsr ClearSavedFrogs     ; Erase the saved frogs from the screen. (Zero the count)
	jsr PrintFrogsAndLives  ; Update the screen memory.

	lda #SCREEN_TITLE       ; Next step is operating the title screen input.
	sta CurrentScreen

	rts


; ==========================================================================
; Event Process TITLE SCREEN
; The activity on the title screen is
; 1) Blink Prompt for ANY key.
; 2) Wait for joystick button.
; 3) Setup for next transition.
; --------------------------------------------------------------------------
EventTitleScreen
	jsr RunPromptForButton     ; Blink Prompt to press ANY key.  check button.
	beq EndTitleScreen         ; Nothing pressed, done with title screen.

ProcessTitleScreenInput        ; Button pressed. Prepare for the screen transition.
	jsr SetupTransitionToGame

EndTitleScreen
	lda CurrentScreen

	rts


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
EventTransitionToGame
	lda AnimateFrames        ; Did animation counter reach 0 ?
	bne EndTransitionToGame  ; Nope.  Nothing to do.
	lda #TITLE_WIPE_SPEED    ; yes.  Reset it.
	jsr ResetTimers

	lda EventCounter         ; What stage are we in?
	cmp #1
	bne TestTransGame2       ; Not the fade out, try next stage

	; === STAGE 1 ===
	; Fade out text lines  from bottom to top.
	; Decrease COLPF1 brightness.
	; When COLPF1 reaches 0 change COLPF2 to COLOR_BLACK.
	; Decrement twice here, because once was not fast enough.
	; The fade and wipe was becoming boring.
	ldx EventCounter2
	lda COLPF1_TABLE,x
	beq ZeroCOLPF2
	dec COLPF1_TABLE,x
	beq ZeroCOLPF2
	dec COLPF1_TABLE,x
	bne EndTransitionToGame
ZeroCOLPF2
	lda #0
	sta COLPF2_TABLE,x

	dec EventCounter2
	bpl EndTransitionToGame

	; Finished stage 1, now setup Stage 2
	lda #2
	sta EventCounter
	inc EventCounter2 ; return to 0.
	beq EndTransitionToGame

	; === STAGE 2 ===
	; Setup Game screen display.
	; Set all colors to black.
TestTransGame2
	cmp #2
	bne TestTransGame3

	; Reset the game screen positions, Scrolling LMS offsets
	jsr ResetGamePlayfield

	lda #DISPLAY_GAME        ; Tell VBI to change screens.
	jsr ChangeScreen         ; Then copy the color tables.

	jsr ZeroCurrentColors    ; Need the screen to start black.

	; Finished stage 2, now setup Stage 3
	lda #3
	sta EventCounter
	lda #0
	sta EventCounter2 ; return to 0.
	beq EndTransitionToGame

	; === STAGE 3 ===
	; Fade in text lines from top to bottom.
	; change COLPF2 to target color.
	; Increase COLPF1 brightness.
	; When COLPF1 reaches target move to next line.
	; Increment twice here, because once was not fast enough.
	; The fade and wipe was becoming boring.
TestTransGame3
	cmp #3
	bne EndTransitionToGame

	ldx EventCounter2
	lda GAME_BACK_COLORS,x ; (redundantly) copy the background color.
	sta COLPF2_TABLE,x

	cmp #23 ; must skip prompt line to keep it visibly off
	beq SkipThePromptLine
	lda COLPF1_TABLE,x
	cmp GAME_TEXT_COLORS,x
SkipThePromptLine
	beq TransGameNextLine

	inc COLPF1_TABLE,x       ; Increase text brightness.

	lda COLPF1_TABLE,x 
	cmp GAME_TEXT_COLORS,x   ; Is it at target brighness?
	beq TransGameNextLine

	inc COLPF1_TABLE,x       ; Twice to speed this up.
	bne EndTransitionToGame  ; (thus targets must all be even numbers)

TransGameNextLine
	inc EventCounter2        ; next screen line.
	lda EventCounter2
	cmp #25                  ; Reached the limit.  all 24 lines are done.
	bne EndTransitionToGame

	; Finished stage 3, now go to the main event.
	lda #SCREEN_START         ; Yes, change to event to start new game.
	sta CurrentScreen

	lda #BLINK_SPEED          ; Text Blinking speed for prompt on Title screen.
	jsr ResetTimers

	jsr SetupGame

EndTransitionToGame
	lda CurrentScreen

	rts


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
EventGameScreen
; ==========================================================================
; GAME SCREEN - Keyboard Input Section
; --------------------------------------------------------------------------
	jsr CheckInput           ; Get cooked stick or trigger if timer permits.
	beq CheckForAnim         ; Nothing pressed, Skip the input section.

	jsr RemoveFrogOnScreen   ; Remove the frog from the screen (duh)

ProcessJoystickInput         ; Reminder: Input Bits: "0 0 0 Trigger Right Left 0 Up"
	lda InputStick           ; Get the cooked joystick state... 

UpStickTest
	ror                      ; Roll out low bit. UP
	bcc LeftStickTest        ; No bit. Try Left.

	jsr FrogMoveUp           ; Yes, go do UP. Subtract from FrogRow.
	beq DoSetupForFrogWins   ; No more rows to cross. Update to frog Wins!
	bne SaveNewFrogLocation  ; Row greater than 0.  Evaluate good/bad position.

LeftStickTest
	ror                      ; Roll out empty bit. DOWN (it is unused)
	ror                      ; Roll out low bit. LEFT
	bcc RightStickTest       ; No bit. Try Right.

	ldy FrogColumn           ; Get "logical" apparent screen position.
	beq SaveNewFrogLocation  ; Already 0. Can't move left. Redraw frog.
	dey                      ; Move Y to left.
	sty FrogColumn
	bpl SaveNewFrogLocation  ; Place frog on screen

RightStickTest
	ror                      ; Roll out low bit. RIGHT
	bcc ReplaceFrogOnScreen  ; No bit.  Replace Frog on screen.  Try boat animation.

	ldy FrogColumn           ; Get "logical" apparent screen position.
	cpy #39                  ; Is it at limit?
	beq SaveNewFrogLocation  ; At limit. Can't move right. Redraw frog.
	iny                      ; Move Y to right.
	sty FrogColumn

; Row greater than 0.  Evaluate good/bad jump.
SaveNewFrogLocation
	jsr WhereIsThePhysicalFrog ; Update Frog Real Positions and the LastCharacter found there.

; Will the Pet Frog land on the Beach or a seat in the boat?
	cmp #I_SPACE             ; = $00 ; space, also safe beach spot.
	beq ReplaceFrogOnScreen  ; The beach is safe. Draw the frog.
	cmp #I_BEACH1            ; = $02 ;  beach rocks
	beq ReplaceFrogOnScreen  ; The beach is safe. Draw the frog.
	cmp #I_BEACH2            ; = $0F ;  beach rocks
	beq ReplaceFrogOnScreen  ; The beach is safe. Draw the frog.
	cmp #I_BEACH3            ; = $1B ;  beach rocks
	beq ReplaceFrogOnScreen  ; The beach is safe. Draw the frog.
	cmp #I_SEATS             ; I_SEATS   = $0B ; +, boat seats
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
	jsr SetFrogOnScreen ; redraw the frog where it belongs

; ==========================================================================
; GAME SCREEN - Screen Animation Section
; --------------------------------------------------------------------------
CheckForAnim
	lda AnimateFrames        ; Does the timer allow the boats to move?
	bne EndGameScreen        ; Nothing at this time. Exit.

	jsr SetBoatSpeed         ; Reset timer for animation based on number of saved frogs.

	jsr AnticipateFrogDeath  ; Will the frog die when the boat moves?
	bne DoSetupForYerDead    ; Shrodinger says apparently so.  dead frog.

	jsr AnimateBoats         ; Move the boats around.
	jsr AutoMoveFrog         ; Move the frog relative to boats.

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
	jsr SetupWin             ; Setup for Wins screen 

EndTransitionToWin
	lda CurrentScreen

	rts


; ==========================================================================
; Event Process WIN SCREEN
; Scroll colors on screen while waiting for a button press.
; Setup for next transition.
; --------------------------------------------------------------------------
EventWinScreen
	jsr RunPromptForButton      ; Check button press.
	bne ProcessWinScreenInput   ; Button pressed.  Run the Win exit section..

	; While there is no input, then animate colors.
	lda AnimateFrames           ; Did animation counter reach 0 ?
	bne EndWinScreen            ; Nope.  Nothing to do.
	lda #WIN_CYCLE_SPEED        ; yes.  Reset animation timer.
	jsr ResetTimers

; Color scrolling skips the black/grey/white.  
; The scrolling uses values 238 to 18 step -4
	lda EventCounter            ; Get starting value from last frame
	jsr WinColorScroll          ; Subtract 4 and reset to start if needed.
	sta EventCounter            ; Save it for next time.

	ldy #0 ; Color the Top 9 lines of screen...
LoopTopWinScroll
	sta COLPF2_TABLE,y          ; Set color for line on screen
	jsr WinColorScroll          ; Subtract 4 and reset to start if needed.

	iny                         ; Next line on screen.
	cpy #9                      ; Reached the 9th line?
	bne LoopTopWinScroll        ; No, continue looping.

	pha                         ; Save to use as start value later.

	eor #$F0                    ; Invert color bits for the middle SAVED text.
	and #$F0                    ; Truncate luminace bits.
	sta COLPF2_TABLE+10         ; Use as background color for 
	sta COLPF2_TABLE+11         ; the three lines of text.
	sta COLPF2_TABLE+12

	pla                         ; Get the color back for scolling the bottom. 

	ldy #14                     ; Bottom 9 lines of screen (above prompt and credits.)
LoopBottomWinScroll             ; Scroll colors in opposite direction
	clc
	adc #4                      ; Add 4 to the color.
	cmp #242                    ; Reached limit? (238 + 4)
	bne SkipDownScrollReset     ; No. Continue.
	lda #18                     ; Yes. Reset back to start.
SkipDownScrollReset
	sta COLPF2_TABLE,y          ; Set color for line on screen
	iny                         ; Next line on screen.
	cpy #23                     ; Reached the 23rd line?
	bne LoopBottomWinScroll     ; No, continue looping.
	beq EndWinScreen            ; Yes.  Nothing left to do. Exit now. 

ProcessWinScreenInput           ; Button is pressed. Prepare for the screen transition.
	jsr SetupTransitionToGame

EndWinScreen
	lda CurrentScreen           ; Yeah, redundant to when a key is pressed.

	rts


; ==========================================================================
; Redundant code section used for two separate places in the Win event.
; Subtract 4 from the current color.
; Reset to 238 if the limit 14 is reached.
;
; A  is the current color.   
; --------------------------------------------------------------------------
WinColorScroll
	sec
	sbc #4                      ; Subtract 4
 	cmp #14                     ; Did it pass the limit (minimum 18, minus 4 == 14)
	bne ExitWinColorScroll      ; No. We're done here.
	lda #238                    ; Yes.  Reset back to start.

ExitWinColorScroll
	rts


; ==========================================================================
; Event Process TRANSITION TO DEAD
; The Activity in the transition area, based on timer.
; 0) On Entry, wait (1.5 sec) to observe splattered frog. (timer set in 
;    the setup event)
; 1) Black background for all playfield lines, turn frog's line red.
; 2) Fade playfield text to black.
; 2) Launch the Dead Frog Display.
; --------------------------------------------------------------------------
EventTransitionToDead
	lda AnimateFrames        ; Did animation counter reach 0 ?
	bne EndTransitionToDead  ; Nope.  Nothing to do.
	lda #DEAD_FADE_SPEED     ; yes.  Reset it. (fade speed)
	jsr ResetTimers

	lda EventCounter         ; What stage are we in?
	cmp #1
	bne TestTransDead2       ; Not the Playfield blackout, try next stage

; ======== Stage 1 ========
; Black the playfield background.   Make frog line red.
	ldx #18

LoopDeadToBlack
	cpx FrogRow             ; Is X the same as Frog Row?
	bne SkipRedFrog         ; No.  Skip setting row to red.
	lda #COLOR_PINK         ; Really, it is like red.
	bne SkipBlackFrog       ; Skip over choosing black.
SkipRedFrog
	lda #COLOR_BLACK        ; Choose black instead.
SkipBlackFrog
	sta COLPF2_TABLE+3,x    ; Set playfield row to black (or red)
	dex                     ; Next row.
	bpl LoopDeadToBlack     ; 18 to 0...

	; Do the empty green grass rows, too.  Logically, the frog cannot die 
	; on row 18 or row 0, so we must know that A still contains #BLACK.  
	sta COLPF2_TABLE+2
	sta COLPF2_TABLE+21

	lda #2
	sta EventCounter         ; Identify Stage 2
	lda #$18
	sta EventCounter2        ; Prep the instance count.
	; Fade speed was set earlier. 
	bne EndTransitionToDead  ; Nothing else to do.

; ======== Stage 2 ========
; Fade the text out on all playfield lines EXCEPT the frog line.
TestTransDead2
	ldx #18

LoopDeadFadeText
	cpx FrogRow             ; Is X the same as Frog Row?
	beq SkipDeadFade        ; Yes.  Skip fading this row.
	ldy COLPF1_TABLE+3,x    ; Get text color. 
	beq SkipDeadFade        ; If it is 0 now, then do not decrement.
	dey
	sty COLPF1_TABLE+3,x    ; Save text color. 
SkipDeadFade
	dex                     ; Next row.
	bpl LoopDeadFadeText    ; 18 to 0...

	; Fade the empty green grass rows, too.
	ldy COLPF1_TABLE+2
	beq SkipFadeGrass1
	dey 
	sty COLPF1_TABLE+2
SkipFadeGrass1
	ldy COLPF1_TABLE+21
	beq SkipFadeGrass2
	dey 
	sty COLPF1_TABLE+21
SkipFadeGrass2

; Control loop, exit from stage 2
	dec EventCounter2        ; Decrement counter.
	bpl EndTransitionToDead  ; It was not zero before.  So, just exit here. 

TestTransDead3 ; Used up the fading iterations. Go to Dead screen now. 
	jsr SetupDead            ; Setup for Dead screen (wait for input loop)

EndTransitionToDead
	lda CurrentScreen

	rts


; ==========================================================================
; Event Process DEAD SCREEN
; The Activity is in the transition event, based on timer.
; Run an animated scroll driven by the data in the sine table.
; --------------------------------------------------------------------------
EventDeadScreen
	jsr RunPromptForButton      ; Check button press.
	bne ProcessDeadScreenInput  ; Button pressed.  Run the dead exit section..

	; While there is no input, then animate colors.
	lda AnimateFrames           ; Did animation counter reach 0 ?
	bne EndDeadScreen           ; Nope.  Nothing to do.
	lda #DEAD_CYCLE_SPEED       ; yes.  Reset animation timer.
	jsr ResetTimers

	ldx EventCounter            ; Get starting color index.
	inx                         ; Next index. 
	cpx #20                     ; Did index reach the repeat?
	bne SkipZeroDeadCycle       ; Nope.
	ldx #0                      ; Yes, restart at 0.
SkipZeroDeadCycle
	stx EventCounter            ; And save for next time.

	ldy #0 ; Top 9 lines of screen...
LoopTopDeadSine
	jsr DeadFrogRedScroll       ; Increments and color stuffing.
	cpy #9                      ; Reached the 9th line?
	bne LoopTopDeadSine         ; No, continue looping.

	ldy #14 ; Bottom 9 lines of screen (above prompt and credits.
LoopBottomDeadSine
	jsr DeadFrogRedScroll       ; Increments and color stuffing.
	cpy #23                     ; Reached the 23rd line?
	bne LoopBottomDeadSine      ; No, continue looping.
	beq EndDeadScreen           ; Yes.  Exit now. 

; Button was pressed, so we're done with this event.
; Evaluate to return to the game, or if game is over.
ProcessDeadScreenInput          ; A key is pressed. Prepare for the next screen.
	lda NumberOfLives           ; Have we run out of frogs?
	beq SwitchToGameOver        ; Yes.  Game Over.

	jsr SetupTransitionToGame   ; Go back to game screen.
	bne EndDeadScreen

SwitchToGameOver
	jsr SetupTransitionToGameOver

EndDeadScreen
	lda CurrentScreen          ; Yeah, redundant to when a key is pressed.

	rts


; ==========================================================================
; Redundant code section used for two separate loops in the Dead Frog event.
;
; --------------------------------------------------------------------------
DeadFrogRedScroll
	lda DEAD_COLOR_SINE_TABLE,x ; Get another color
	sta COLPF2_TABLE,y          ; Set line on screen
	inx                         ; Next color entry
	iny                         ; Next line on screen.

	rts


DEAD_COLOR_SINE_TABLE
	.byte COLOR_RED_ORANGE+7, COLOR_RED_ORANGE+9, COLOR_RED_ORANGE+11,COLOR_RED_ORANGE+13
	.byte COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+13
	.byte COLOR_RED_ORANGE+11,COLOR_RED_ORANGE+9, COLOR_RED_ORANGE+7, COLOR_RED_ORANGE+5
	.byte COLOR_RED_ORANGE+3, COLOR_RED_ORANGE+1, COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+0
	.byte COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+1, COLOR_RED_ORANGE+3, COLOR_RED_ORANGE+5
	.byte COLOR_RED_ORANGE+7, COLOR_RED_ORANGE+9, COLOR_RED_ORANGE+11,COLOR_RED_ORANGE+13
	.byte COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+13
	.byte COLOR_RED_ORANGE+11,COLOR_RED_ORANGE+9, COLOR_RED_ORANGE+7, COLOR_RED_ORANGE+5
	.byte COLOR_RED_ORANGE+3, COLOR_RED_ORANGE+1, COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+0
	.byte COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+1, COLOR_RED_ORANGE+3, COLOR_RED_ORANGE+5


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
EventTransitionGameOver
	lda AnimateFrames         ; Did animation counter reach 0 ?
	bne EndTransitionGameOver ; Nope.  Nothing to do.
	lda #DEAD_FADE_SPEED      ; yes.  Reset it.
	jsr ResetTimers

	lda EventCounter
	cmp #1
	bne TestTransOver2
; ======== Stage 1 ========
; Fade to black the playfield background...
; Where text is greater than 0, then fade that too.
; When text is 0, then background color can be 0.
	jsr TransGameOverStage1Scroll

	dec EventCounter2
	bne EndTransitionGameOver

	; End of Stage 1.  Now setup to fade in Game Over.
	lda #DISPLAY_OVER          ; Tell VBI to change screens.
	jsr ChangeScreen           ; Then copy the color tables.

; Force the base background color without luminance for all the lines.
	ldx #24
DoCopyBaseColors
	lda OVER_BACK_COLORS,x
	and #$F0
	sta COLPF2_TABLE,x
	lda #0
	sta COLPF1_TABLE,x
	dex
	bpl DoCopyBaseColors

	lda #2
	sta EventCounter           ; Identify Stage 2
	lda #0
	sta EventCounter2          ; Prep the instance count.

	beq EndTransitionGameOver  ; Nothing else to do.

; ======== Stage 2 ========
; Fade in Game Over text.
TestTransOver2
	cmp #2
	bne EndTransitionGameOver

	ldx #24
DoFadeUpOverText
	lda COLPF1_TABLE,x
	cmp OVER_TEXT_COLORS,x
	beq DoNextLineFadeUp
	inc OVER_TEXT_COLORS,x
DoNextLineFadeUp
	dex
	bpl DoFadeUpOverText

	inc EventCounter2
	lda EventCounter2
	cmp #16  ; That's enough of that.
	bne EndTransitionGameOver

DoneWithTranOver
	jsr SetupGameOver

EndTransitionGameOver
	lda CurrentScreen

	rts


; ==========================================================================
; Transition Game Over Stage 1  Scroll
; The code in EventTransitionGameOver is too long to make a branch to the
; end of the routine.  So, the code for the Stage 1 fading is cut out 
; into this routine.
;
; --------------------------------------------------------------------------
TransGameOverStage1Scroll

	ldx #24
LoopOverToBlack
	lda COLPF1_TABLE,x      ; Get the text brightness.
	and #$0F                ; Look at only luminance.
	beq DoFadeCOLPF2        ; Already 0.  Just do background.
	tay                     ; Y = A
	dey                     ; Decrement Text luminance
	bmi BlackOutCOLPF1      ; If it went negative, then we're done.
	dey                     ; Decrement Text luminance
	bmi BlackOutCOLPF1      ; If it went negative, then we're done.
	sty COLPF1_TABLE,x      ; Save the updated value in the color table.
	
; Yes, this is a little inconsistent.  The pass when the text 
; luminance reaches 0 will end up skipping the fade on the background. 
; Meh.  I don't think anyone will notice.
DoFadeCOLPF2
	lda COLPF2_TABLE,x      ; Get the color.
	pha                     ; Save for later.
	and #$0F                ; Look at only the luminance
	beq ZeroTableColors     ; Zero luminance, so zero table entries.          

	; Luminance is >0, thetrefore decrement.
	tay                     ; Fade out the background brighness.
	dey                     ; Decrement background luminance
	bmi BlackOutCOLPF2      ; If it went negative, then we're done.
	dey                     ; Decrement background luminance
	bmi BlackOutCOLPF2      ; If it went negative, then we're done.
	sty SAVEY               ; Save the new luminance.
	pla                     ; get the original color back.
	and #$F0                ; Get the color of the background.
	ora SAVEY               ; combine the new lumninance.
	sta COLPF2_TABLE,x      ; update the background color.

ZeroTableColors
	pla                     ; luminance is 0.  Fix the stack.
BlackOutCOLPF2             
	lda #COLOR_BLACK        ; Black out background (and the text below)
	sta COLPF2_TABLE,x
BlackOutCOLPF1 
	lda #COLOR_BLACK        ; Black out the text.  Redundantly. 
	sta COLPF1_TABLE,x
	beq DoOverNextLine      ; Done with this line.



DoOverNextLine
	dex                     ; Next row.
	bpl LoopOverToBlack     ; 24 to 0...

rts


; ==========================================================================
; Event Process GAME OVER SCREEN
; The Activity in the transition area, based on timer.
;
; --------------------------------------------------------------------------
EventGameOverScreen
	jsr RunPromptForButton          ; Check button press.
	bne ProcessGameOverScreenInput  ; Button pressed.  Run the dead exit section.

	; Animate the scrolling.
	lda AnimateFrames               ; Did animation counter reach 0 ?
	bne EndGameOverScreen           ; No. Nothing to do.
	lda #GAME_OVER_SPEED            ; yes.  Reset animation timer.
	jsr ResetTimers

	dec EventCounter                ; Decrement base color 
	dec EventCounter                ; Twice.  (need to use even numbers.)
	lda EventCounter                ; Get value 
	and #$0F                        ; Keep this truncated to grey (black) $0 to $F
	sta EventCounter                ; Save it for next time.

	ldy #0 ; Top 9 lines of screen...
LoopTopOverGrey
	jsr GameOverGreyScroll      ; Increments and color stuffing.
	cpy #9                      ; Reached the 9th line?
	bne LoopTopOverGrey         ; No, continue looping.

	ldy #14 ; Bottom 9 lines of screen (above prompt and credits.
LoopBottomOverGrey
	jsr GameOverGreyScroll      ; Increments and color stuffing.
	cpy #23                     ; Reached the 23rd line?
	bne LoopBottomOverGrey      ; No, continue looping.
	beq EndGameOverScreen

ProcessGameOverScreenInput      ; a key is pressed. Prepare for the screen transition.
	jsr SetupTransitionToTitle

EndGameOverScreen
	lda CurrentScreen           ; Yeah, redundant to when a key is pressed.

	rts

; ==========================================================================
; Redundant code section used for two separate loops in the Game Over event.
;
; --------------------------------------------------------------------------
GameOverGreyScroll
	sta COLPF2_TABLE,y          ; Set line on screen
	tax                         ; X = A
	inx                         ; X = X + 1
	inx                         ; X = X + 1
	txa                         ; A = X
	and #$0F                    ; Keep this truncated to grey (black) $0 to $F
	iny                         ; Next line on screen.

	rts
