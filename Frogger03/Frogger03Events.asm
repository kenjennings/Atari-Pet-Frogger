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
; Version 03, June 2019
;
; --------------------------------------------------------------------------

; ==========================================================================
; Frogger EVENTS
;
; All the routines to run for each screen/state.
; --------------------------------------------------------------------------

; Note that there is no mention in this code for scrolling the credits
; text.  This is entirely handled by the Vertical blank routine.  Every
; display list ends with common instructions that show the scrolling 
; credit text. The VBI routine updates the common Display List's LMS 
; pointer to the text.  Since the VBI is in control of this on all screens
; it means every display has continuous, seamless scrolling credit text 
; even when the display changes, and no matter what else is happening.

; Screen enumeration states for current processing condition.
; Note that the order here does not imply the only order of
; movement between screens/event activity.  The enumeration
; could be entirely random.

EVENT_INIT        = 0  ; One Time initialization.

EVENT_START       = 1  ; Entry Point for New Game setup.
EVENT_TITLE       = 2  ; Credits and Instructions.

EVENT_TRANS_GAME  = 3  ; Transition animation from Title to Game.
EVENT_GAME        = 4  ; GamePlay

EVENT_TRANS_WIN   = 5  ; Transition animation from Game to Win.
EVENT_WIN         = 6  ; Crossed the river!

EVENT_TRANS_DEAD  = 7  ; Transition animation from Game to Dead.
EVENT_DEAD        = 8  ; Yer Dead!

EVENT_TRANS_OVER  = 9  ; Transition animation from Dead to Game Over.
EVENT_OVER        = 10  ; Game Over.

EVENT_TRANS_TITLE = 11 ; Transition animation from Game Over to Title.

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
; The Game Starting Point.  Event Entry 0.
; Called only once at start.  
; Transition to Title from here and all other events 
; will use non-zero events.
; --------------------------------------------------------------------------
EventGameInit
	; Atari initialization stuff...

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

	lda #<Score_DLI; TITLE_DLI ; Set DLI vector. (will be reset by VBI on screen setup)
	sta VDSLST
	lda #>Score_DLI; TITLE_DLI
	sta VDSLST+1
	
	lda #[NMI_DLI|NMI_VBI]     ; Turn On DLIs
	sta NMIEN

	; Changing the Display List is potentially tricky.  If the update is
	; interrupted by the Vertical blank, then it could mess up the display
	; list address and crash the Atari.
	;
	; So, this problem is solved by giving responsibility for Display List
	; changes to a custom Vertical Blank Interrupt. The main code simply
	; writes a byte to a page 0 location monitored by the Vertical Blank
	; Interrupt and this directs the interrupt to change the current
	; display list.  Easy-peasy and never updated at the wrong time.

	ldy #<MyImmediateVBI       ; Add the VBI to the system (Display List dictatorship)
	ldx #>MyImmediateVBI
	lda #6                     ; 6 = Immediate VBI
	jsr SETVBV                 ; Tell OS to set it

	ldy #<MyDeferredVBI        ; Add the VBI to the system (Lazy hippie timers, colors, sound.)
	ldx #>MyDeferredVBI
	lda #7                     ; 7 = Deferred VBI
	jsr SETVBV                 ; Tell OS to set it

	lda #0
;	sta COLOR4                 ; Border color, 0 is black.
	sta FlaggedHiScore
	sta InputStick             ; no input from joystick

;	lda #COLOR_BLACK+$E        ; COLPF3 is white on all screens.
;	sta COLOR3

	jsr libPmgInit             ; Will also reset SDMACTL settings for P/M DMA

	lda #4                     ; Quick hack to init the scrolling credits.
	sta HSCROL

	jsr SetupTransitionToTitle ; will set CurrentEvent = EVENT_TRANS_TITLE

	rts                         ; And now ready to go to main game loop . . . .


; ==========================================================================
; Event Process TRANSITION TO TITLE
; The setup for Transition to Title will turned on the Title Display.
; Stage 1: Scroll in the Title graphic. (three lines, one at a time.)
; Stage 2: Brighten line 4 luminance.
; Stage 3: Initialize setup for Press Button on Title screen.
; --------------------------------------------------------------------------

EventTransitionToTitle
	lda AnimateFrames          ; Did animation counter reach 0 ?
	bne EndTransitionToTitle   ; Nope.  Nothing to do.
	lda #TITLE_SPEED           ; yes.  Reset it.
	jsr ResetTimers

	lda EventCounter           ; What stage are we in?
	cmp #1
	bne TestTransTitle2        ; Not the Title Scroll, try next stage

	; === STAGE 1 ===
	; Each line is 40 spaces followed by the graphics.
	; Scroll each one one at a time.
;	lda SCROLL_TITLE_LMS0    
;	cmp #<[TITLE_MEM1+40]      ; Reached the slide maximum ?
;	beq NowScroll2             ; Yes.  Skip this line slide.

	jsr ToPlayFXScrollOrNot    ; Start slide sound playing if not playing now.

;	inc SCROLL_TITLE_LMS0      ; Top line slide in progress.
;	bne EndTransitionToTitle   ; Result of inc above is always non-zero. Go to end of event.

;NowScroll2
;	lda SCROLL_TITLE_LMS1
;	cmp #<[TITLE_MEM2+40]      ; Reached the slide maximum ?
;	beq NowScroll3             ; Yes.  Skip this line slide.

;	jsr ToPlayFXScrollOrNot    ; Start slide sound playing if not playing now.

;	inc SCROLL_TITLE_LMS1      ; Middle line slide in progress.
;	bne EndTransitionToTitle   ; Result of inc above is always non-zero. Go to end of event.

;NowScroll3
;	lda SCROLL_TITLE_LMS2
;	cmp #<[TITLE_MEM3+40]      ; Reached the slide maximum ?
;	beq FinishedNowSetupStage2 ; Yes.  All 3 lines moved.  Now do the glowing line.

;	jsr ToPlayFXScrollOrNot    ; Start slide sound playing if not playing now.
;
;	inc SCROLL_TITLE_LMS2      ; Bottom line slide in progress.
;	bne EndTransitionToTitle   ; Result of inc above is always non-zero. Go to end of event.

FinishedNowSetupStage2
	ldx #0                     ; Setup channel 0 to play saber A sound.
	ldy #SOUND_HUM_A
	jsr SetSound 
	ldx #1                     ; Setup channel 1 to play saber B sound.
	ldy #SOUND_HUM_B
	jsr SetSound

	lda #2                     ; Set stage 2 as next part of Title screen event...
	sta EventCounter
	bne EndTransitionToTitle

	; === STAGE 2 ===
	; Ramp up luminance of line 4.
TestTransTitle2
	cmp #2
	bne TestTransTitle3

GlowingTitleUnderline
;	lda COLPF1_TABLE+5         ; Get the text brightness of line 4.
;	cmp #$0E                   ; It is maximum brightness?
;	beq FinishedNowSetupStage3 ; Yes.  Time for the next stage.
;	inc COLPF1_TABLE+5         ; No. Increment brightness.
;	bne EndTransitionToTitle   ; Result of inc above is always non-zero. Go to end of event.

FinishedNowSetupStage3
	lda #3                    ; Set stage 3 as next part of Title screen event...
	sta EventCounter
	bne EndTransitionToTitle

	; === STAGE 3 ===
	; Set Up Press Any Button and get ready to run title screen/event.
TestTransTitle3
	cmp #3
	bne EndTransitionToTitle  ; Really shouldn't get to that point

	lda #EVENT_START         ; Yes, change to event to start new game.
	sta CurrentEvent

EndTransitionToTitle
	jsr WobbleDeWobble         ; Frog drawing spirograph art on the title.
;	lda CurrentEvent

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

	jsr ClearSavedFrogs     ; Erase the saved frogs from the screen. (Zero the count)
	jsr PrintFrogsAndLives  ; Update the screen memory.

	lda #EVENT_TITLE       ; Next step is operating the title screen input.
	sta CurrentEvent

	rts


; ==========================================================================
; Event Process TITLE SCREEN
; The activity on the title screen is
; 1) Blink Prompt for ANY key.
; 2) Wait for joystick button.
; 3) Setup for next transition.
; --------------------------------------------------------------------------
EventTitleScreen
	jsr WobbleDeWobble         ; Frog drawing spirograph art on the title.
	jsr RunPromptForButton     ; Blink Prompt to press Joystick button and check input.
	beq EndTitleScreen         ; Nothing pressed, done with title screen.

ProcessTitleScreenInput        ; Button pressed. Prepare for the screen transition.
	jsr SetupTransitionToGame

	; This was part of the Start event, but after the change to keep the 
	; scores displayed on the title screen it would end up erasing the 
	; last game score as soon as the title transition animation completed.
	; Therefore resetting the score is deferred until leaving the Title.
	jsr ClearGameScores     ; Zero the score.  And high score if not set.

EndTitleScreen
;	lda CurrentEvent

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
	; Fade out COLPF0 and COLPF1 at the same time.
	; When luminance reaches 0, set color to 0. 
	; When COLPF0/COLPF1 reach 0 then change COLPF2/COLBK to COLOR_BLACK.
	jsr FadeColPfToBlack     ; Returns color 0 | color 1, then ....
	bne EndTransitionToGame  ; ... If either color is non-zero, done for this pass.

ZeroCOLPF2                   ; FadeColPfToBlack returned 0, so the text (and pixel) is 0.  
	lda #0                   ; Therefore, zero the background(s).
	sta COLPF2_TABLE,x
	sta COLBK_TABLE,x

	dec EventCounter2
	bne EndTransitionToGame ; 1 is the last entry. 0 is stop looping.

	; Finished stage 1, now setup Stage 2
	jsr CopyScoreToScreen   ; Make sure the score is updated in Game screen memory.
	jsr PrintFrogsAndLives  ; And the frog list.
	lda #2                  ; Go to next phase TestTransGame2
	sta EventCounter
	lda #0
	sta EventCounter2 ; return to 0.
	beq EndTransitionToGame

	; === STAGE 2 ===
	; Setup Game screen display.
	; Set all colors to black.
TestTransGame2
	cmp #2
	bne TestTransGame3

	; Reset the game screen positions, Scrolling LMS offsets
;	jsr ResetGamePlayfield

	lda #DISPLAY_GAME        ; Tell VBI to change screens.
	jsr ChangeScreen         ; Then copy the color tables.

;	lda #DISPLAY_GAME
;	jsr ZeroCurrentColors    ; But, insure the screen starts black.

	; Finished stage 2, now setup Stage 3
	lda #3
	sta EventCounter
	lda #1
	sta EventCounter2 ; return to 0.
	beq EndTransitionToGame

	; === STAGE 3 ===
	; Fade in text lines from top to bottom.
	; This looked so simple on paper. 
	; Now that there are four colors per line the 
	; fade up to the target values is much more complicated.
	; Read the mess that is IncrementTableColors elsewhere.
TestTransGame3
	cmp #3
	bne EndTransitionToGame

	ldx EventCounter2
	jsr IncrementTableColors ; Complicated fade up of four color registers.
	bne EndTransitionToGame  ; All colors do not match yet. Be back later to do more.

TransGameNextLine            ; All colors match on this line.  Do next line.
	inc EventCounter2        ; Next screen line.
	lda EventCounter2
	cmp #23                  ; Reached the limit?  
	bne EndTransitionToGame  ; No.  Finish this pass.

	; Finished stage 3, now go to the main event.
	lda #EVENT_START         ; Yes, change to event to start new game.
	sta CurrentEvent

	lda #BLINK_SPEED          ; Text Blinking speed for prompt ?
	jsr ResetTimers

	jsr SetupGame

EndTransitionToGame
;	lda CurrentEvent

	rts


; ==========================================================================
; Event Process GAME SCREEN
; Play the game.
; 
; Many of the things in Version 02 have become non-events 
; in Version 03 for the main line code.  The MAIN game logic is 
; now very simple due to things moving the VBI...
; When the input timer allows, get controller input.
; 2) Process frog Movement per controller.
; 2.a) Determine exit to Win screen
; 2.b) Determine exit to Dead screen.
; All the hard stuff is in the VBI...
; VBI determines frog death conditions.
; VBI scrolls boats.
; VBI moves frog if frog is on a boat row.
; VBI animates boat parts.
; --------------------------------------------------------------------------
EventGameScreen
; ==========================================================================
; GAME SCREEN - Joystick Input Section
; --------------------------------------------------------------------------
	; VBI manages frog falling off the boats.
	lda FrogSafety           ; Did the VBI flag the Shrodinger's frog is dead?
	bne DoSetupForYerDead    ; Yes.  No input allowed.  Start the funeral.

	jsr CheckInput           ; Get cooked stick or trigger if timer permits.
	beq EndOfJoystickMoves   ; Nothing pressed, Skip the input section.

; P/M graphics do not need "removal" 
;	jsr RemoveFrogOnScreen   ; Remove the frog from the screen (duh)

ProcessJoystickInput         ; Reminder: Input Bits: "0 0 0 Trigger Right Left 0 Up"
	lda InputStick           ; Get the cooked joystick state... 

UpStickTest
	ror                      ; Roll out low bit. UP
	bcc LeftStickTest        ; No bit. Try Left.

	lda #3                   ; Eyeballs left
	jsr FrogEyeFocus

	jsr FrogMoveUp           ; Yes, go do UP. Subtract from FrogRow and PM Y position.
	beq DoSetupForFrogWins   ; Returned 0.  No more rows to cross. Update to frog Wins!
	bne FrogHasMoved         ; Row greater than 0.  Done with this.


LeftStickTest
	ror                      ; Roll out empty bit. DOWN (it is unused)
	ror                      ; Roll out low bit. LEFT
	bcc RightStickTest       ; No bit. Try Right.

	lda #0                   ; Eyeballs left
	jsr FrogEyeFocus

	ldy FrogPMX              ; Get current Frog position
	dey                      ; - minus 2 color clocks is 1/2 character.
	dey

	sty FrogNewPMX           ; Save as new suggested location.
	
	bne FrogHasMoved         ; Done here.  Frog moved.  Always branches.


RightStickTest
	ror                      ; Roll out low bit. RIGHT
	bcc EndOfJoystickMoves   ; No bit.  Replace Frog on screen.  Try boat animation.

	lda #2                   ; Eyeballs Right
	jsr FrogEyeFocus

	ldy FrogPMX              ; Get current Frog position
	iny                      ; - plus 2 color clocks. is 1/2 character.
	iny 
	sty FrogNewPMX           ; Save as new suggested location.
	bne FrogHasMoved         ; Done here.  Frog moved.  Always branches.

	; Safe location at the far beach.  the Frog is saved.
DoSetupForFrogWins
	jsr SetupTransitionToWin
	bne EndGameScreen        ; last action in function is lda/sta a non-zero value.

FrogHasMoved
	jsr PlayThump            ; Sound for when frog moves.
	jsr CopyScoreToScreen    ; Make sure the score is in sync.

EndOfJoystickMoves

	jsr ToReplayFXWaterOrNot ; Time to replay the water noises?
	jmp EndGameScreen        ; Done with game loop.

	
DoSetupForYerDead
	jsr SetupTransitionToDead
	bne EndGameScreen        ; last action in function is lda/sta a non-zero value.

; VBI does these now.
;	jsr AnimateBoats         ; Move the boats around.
;	jsr AutoMoveFrog         ; Move the frog relative to boats.

EndGameScreen
;	lda CurrentEvent

	rts


; ==========================================================================
; Event Process TRANSITION TO WIN
; V03 currently removes the transition to Win screen.
; Now, just does immediate switch to the Win screen.
;
; Prior version...
; The Activity in the transition area, based on timer.
; 1) wipe screen from top to middle, and bottom to middle.
; 2) Display the Frogs SAVED!
; 3) Setup to do the Win screen event.
; --------------------------------------------------------------------------
EventTransitionToWin
	jsr SetupWin             ; Setup for Wins screen 

EndTransitionToWin
;	lda CurrentEvent

	rts


; ==========================================================================
; Event Process WIN SCREEN
;
; Scroll Rainbow colors on screen while waiting for a button press.
; Scroll up at top. light to dark.  
; Scroll down at bottom.  Dark to light.
; Do not use $0x or $Fx  (Min 16, max 238)
; 
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

; ======================== T O P ========================  
; Color scrolling skips the black/grey/white values.  
; The scrolling uses values 238 to 18 step -4
	lda EventCounter            ; Get starting value from last frame
	jsr WinColorScrollUp        ; Subtract 4 and reset to start if needed.
	sta EventCounter            ; Save it for next time.

	ldy #1 ; Color the Top 20 lines of screen...
LoopTopWinScroll
	sta COLBK_TABLE,y           ; Set color for line on screen
	jsr WinColorScrollUp        ; Subtract 4 and reset to start if needed.

	iny                         ; Next line on screen.
	cpy #21                     ; Reached the 20th (21st table entry) line?
	bne LoopTopWinScroll        ; No, continue looping.

	pha                         ; Save current color to use as start value later.

; ======================== M I D D L E ========================  
; Background/COLBK in the text section is static in the color tables.
; Manipulate current color to make it the "inverse" color for the Text.
	eor #$F0                    ; Invert color bits for the middle SAVED text.
	and #$F0                    ; Truncate luminance bits.
	ora #$02                    ; Start at +2.

	ldy #26                     ; Start at bottom of text going backwards.
bews_LoopTextColors
	sta COLPF0_TABLE,Y          ; Use as manipulated color for 
	clc                         ; the six lines of giant label "text."
	adc #2                      ; brightness:  2, 4, 6, 8, A, C
	dey
	cpy #20
	bne bews_LoopTextColors

; ======================== B O T T O M ========================  
	pla                         ; Get the color back for scrolling the bottom. 

; Color scrolling skips the black/grey/white values.  
; The scrolling uses values 18 to 238 step +4
	ldy #27                     ; Bottom 20 lines of screen (above prompt and credits.)
LoopBottomWinScroll             ; Scroll colors in opposite direction
	jsr WinColorScrollDown      ; Add 4, and reset to start if needed.
	sta COLBK_TABLE,y          ; Set color for line on screen
	iny                         ; Next line on screen.
	cpy #47                     ; Reached the end, 20th line after text? 
	bne LoopBottomWinScroll     ; No, continue looping.
	beq EndWinScreen            ; Yes. Done. Nothing left to do. Exit now. 

ProcessWinScreenInput           ; Button is pressed. Prepare for the screen transition.
	jsr SetupTransitionToGame

EndWinScreen
;	lda CurrentEvent           ; Yeah, redundant to when a key is pressed.

	rts







; ==========================================================================
; Event Process TRANSITION TO DEAD
; The Activity in the transition area, based on timer.
; 0) On Entry, wait (2 sec) to observe splattered frog. (timer set in 
;    the setup event)
; 1) Greyscale for all playfield lines, except frog's line.
; 2) Allow another 2 seconds of waiting.
; 3) Launch the Dead Frog Display.
; --------------------------------------------------------------------------

EventTransitionToDead
	lda AnimateFrames        ; Did animation counter reach 0 ? (1.5 sec delay)
	bne EndTransitionToDead  ; Nope.  Nothing to do.
	lda #FROG_WAKE_SPEED     ; yes.  Reset it. (2 more seconds) to wait for stage 2
	jsr ResetTimers

	lda EventCounter         ; What stage are we in?
	cmp #1
	bne TestTransDead2       ; Not the Playfield blackout, try next stage

; ======== Stage 1 ========
; Grey the playfield.   Leave frog line alone. 
	ldx #18

LoopDeadToBlack
	cpx FrogRow             ; Is X the same as Frog Row?
	beq SkipGreyFrog        ; Yes, do not grey this line.
;	bne SkipRedFrog         ; No.  Skip setting row to red.
;	lda #COLOR_PINK         ; Really, it is like red.
;	bne SkipBlackFrog       ; Skip over choosing black.
SkipRedFrog
	lda #COLOR_BLACK        ; Choose black instead.
SkipBlackFrog
; A subroutine, because it is too much code for the EventTransitionToDead
; branches to reach around. 
	jsr GreyEachColorTable  

SkipGreyFrog
	dex                     ; Next row.
	bpl LoopDeadToBlack     ; 18 to 0...

	; Do the empty green grass rows, too.  Logically, the frog cannot die 
	; on row 18 or row 0, so we must know that A still contains #BLACK.  
;	sta COLPF2_TABLE+2
;	sta COLPF2_TABLE+21

	lda #2
	sta EventCounter         ; Identify Stage 2 
	bne EndTransitionToDead  ; Nothing else to do.
	; When the first mourning timer ran out, it was reset to FROG_WAKE_SPEED again, 
	; so it will be another 2 seconds before Stage 2 can start. 

; ======== Stage 2 ========
; Ready to go to the Dead screen.
TestTransDead2
	jsr SetupDead            ; Setup for Dead screen (wait for input loop)

EndTransitionToDead
;	lda CurrentEvent

	rts


; ==========================================================================
; Event Process DEAD SCREEN
; 0a) While no button, animate the background colors. 
; 0b) If Button Press, then start fade to black.
; 1) Black background for scrolling colors.
; 2) Fade background colors behind text.
; 3) Fade text colors to black.
; 4) Determine transition to Game or GameOver.
; --------------------------------------------------------------------------
EventDeadScreen
	lda EventStage              ; Stage 0 is waiting for input
	bne DeadScreenCheckTimers   ; Not stage 0, skip button check

	jsr RunPromptForButton      ; Check button press.
	beq DeadScreenCheckTimers   ; No input, continue with timer checks.

ProcessDeadScreenInput          ; Button is pressed. 
	jsr HideButtonPrompt        ; Turn off the prompt
	inc EventStage              ; Setup Stage 1 for the screen fading ...

DeadScreenCheckTimers
	; Check timers.  Animate colors per the stage.
	lda AnimateFrames           ; Did animation counter reach 0 ?
	bne EndDeadScreen           ; Nope.  Nothing to do.
	lda #DEAD_CYCLE_SPEED       ; yes.  Reset animation timer.
	jsr ResetTimers

	lda EventStage   
DeadStageZero                   ; Stage 0  cycling the background.
;	cmp #0
	bne DeadStageOne            ; non zero is stage 1 or 2 or 3 or ...

	jsr DeadFrogRain
	beq EndDeadScreen           ; Stage 1 is set by the input handling earlier.


DeadStageOne ; and Two and Three for the fade out effects.
	jsr CommonSplashFade ; Do Stage 1, 2, 3.  On exit, expect A = EventStage

;DeadStageOne                    ; Stage 1 is set background black.             
;	cmp #1
;	bne DeadStageTwo

;	jsr BlackSplashBackground   ; Set non-text background to black.

;	lda #$0e
;	sta EventCounter ; Luminance matching for fade
;	lda #2
;	sta EventStage
;	bne EndDeadScreen


;DeadStageTwo                   ; Stage 2 is fading the text background
;	cmp #2
;	bne DeadStageThree

;	jsr FadeSplashTextBackground
;	bpl EndDeadScreen

;	lda #$0e
;	sta EventCounter ; Luminance matching for fade
;	lda #3
;	sta EventStage
;	bne EndDeadScreen


;DeadStageThree                   ; Stage 3 is fading the text 
;	cmp #3
;	bne DeadStageFour

;	jsr FadeSplashText
;	bpl EndDeadScreen

;	lda #4
;	sta EventStage
;	bne EndDeadScreen


; The actual end.

DeadStageFour                  ; Evaluate return to game, or game over.
	cmp #4
	bne EndDeadScreen
	
	lda NumberOfLives           ; Have we run out of frogs?
	beq SwitchToGameOver        ; Yes.  Game Over.

	jsr SetupTransitionToGame   ; Go back to game screen.
	bne EndDeadScreen

SwitchToGameOver
	jsr SetupTransitionToGameOver

EndDeadScreen
;	lda CurrentEvent          ; Yeah, redundant to when a key is pressed.

	rts


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

; Fade to black the playfield background...
; Wipe bottom to top to black.
	ldx EventCounter2              ; Get the screen row.  Expected to be non-zero.
	cpx #26                        ; Did this reach the text lines in the middle?
	bne DoContinueGameOverFadeLoop ; No.
	ldx #20                        ; Yes, skip over the text lines.
DoContinueGameOverFadeLoop
	lda #0                         ; Zero/Black
	sta COLPF0_TABLE,x             ; Background.
	sta COLBK_TABLE,x              ; Pixel, if present.

	dex                            ; Next time do the row above,
	stx EventCounter2              ; and save it.
	bne EndTransitionGameOver      ; Non zero. Next Loop will continue this Stage.

	; End of fade.  Setup to the Game Over screen. 
DoneWithTranOver               ; call counter is 0.  go to game over.
	jsr SetupGameOver

EndTransitionGameOver
;	lda CurrentEvent

	rts


; ==========================================================================
; Event Process GAME OVER SCREEN
; The Activity in the transition area, based on timer.
;
; --------------------------------------------------------------------------
EventGameOverScreen
	jsr WobbleDeWobble              ; tomb drawing spirograph art on the game over.
	jsr RunPromptForButton          ; Check button press.
	bne ProcessGameOverScreenInput  ; Button pressed.  Run the dead exit section.

	; Animate the scrolling.
	lda AnimateFrames               ; Did animation counter reach 0 ?
	bne EndGameOverScreen           ; No. Nothing to do.
	lda #GAME_OVER_SPEED            ; yes.  Reset animation timer.
	jsr ResetTimers

	ldx EventCounter            ; Get starting color index.
	inx                         ; Next index. 
	cpx #20                     ; Did index reach the repeat?
	bne SkipZeroDeadCycle       ; Nope.
	ldx #0                      ; Yes, restart at 0.
SkipZeroDeadCycle
	stx EventCounter            ; And save for next time.

	ldy #1 ; Top 20 lines of screen...
LoopTopDeadSine
	jsr DeadFrogRedScroll       ; Increments and color stuffing.
	cpx #20
	bne SkipZeroDeadCycle2
	ldx #0
SkipZeroDeadCycle2
	cpy #47 ; #21                     ; Reached the 21th line?
	bne LoopTopDeadSine         ; No, continue looping.

	; ldy #27 ; Bottom 9 lines of screen (above prompt and credits.
; LoopBottomDeadSine
	; jsr DeadFrogRedScroll       ; Increments and color stuffing.
	; cpx #20
	; bne SkipZeroDeadCycle3
	; ldx #0
; SkipZeroDeadCycle3
	; cpy #47                     ; Reached the 23rd line?
	; bne LoopBottomDeadSine      ; No, continue looping.

	beq EndGameOverScreen       ; Yes.  Exit now. 

ProcessGameOverScreenInput      ; a key is pressed. Prepare for the screen transition.
	lda #$FF
	sta FrogUpdate              ; Tell VBI to erase and stop redrawing the animated object.
	jsr libScreenWaitFrame      ; Let's wait to the end of the frame to prevent the setup from confusing cleanup.
	jsr SetupTransitionToTitle

EndGameOverScreen
;	lda CurrentEvent           ; Yeah, redundant to when a key is pressed.

	rts

