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
; TIMER STUFF AND INPUT
;
; Miscellaneous:
; Timer ranges
; Key Values
; Tick Tock value,
; Count downs,
; DLI and VBI routines.
; Prompt for Button press.
;
; --------------------------------------------------------------------------

; ==========================================================================
; Animation speeds of various displayed items.   Number of frames to wait...
; --------------------------------------------------------------------------
BLINK_SPEED      = 3  ; Speed of updated to Press A Button prompt.

TITLE_SPEED      = 2  ; Scrolling speed for title. 
TITLE_WIPE_SPEED = 0  ; Title screen to game screen fade speed.

FROG_WAKE_SPEED  = 95 ; Initial delay 1.5 sec for frog corpse '*' viewing/mourning
DEAD_FADE_SPEED  = 4  ; Fade the game screen to black for Dead Frog
DEAD_CYCLE_SPEED = 6  ; Speed of color animation on Dead screen

WIN_FADE_SPEED   = 4  ; Fade the game screen to black to show Win
WIN_CYCLE_SPEED  = 5  ; Speed of color animation on Win screen 

GAME_OVER_SPEED  = 12  ; Speed of Game over Res in animation


; Timer values.  NTSC.
; About 9-ish Inputs per second.
; After processing input (from the joystick) this is the number of frames
; to count before new input is accepted.  This prevents moving the frog at
; 60 fps and compensates for any jitter/uneven toggling of the joystick
; bits by flaky controllers.
; At 9 events per second the frog moves horizontally 18 color clocks, max. 
INPUTSCAN_FRAMES = $07 ; previously $09

; Based on number of frogs, how many frames between the boats' 
; character-based coarse scroll movement:
; ANIMATION_FRAMES .byte 30,25,20,18,15,13,11,10,9,8,7,6,5,4,3
;
; Fine scroll increments 4 times faster to equal one character 
; movement per timer above. 
;
; Minimum coarse scroll speed was 2 character per second, or 8 
; color clocks per second, or between 7 and 8 frames per color clock.
; The fine scroll will start at 10 frames per color clock.
;
; Maximum coarse scroll speed (3 frames == 20 character movements 
; per second) was the equivalent of 4 color clocks in 3 frames.
; The fine scroll speed will max out at 1 color clock per frame.
;
; The Starting speed is slower than the coarse scrolling version.
; It ramps up to maximum speed in fewer levels/rescued frogs, and 
; the maximum speed is slightly slower than the fastest coarse scroll
; speed (still, this is 60 FPS fine scroll which is faaast.)

ANIMATION_FRAMES .by 10 9 8 7 6 5 4 3 2 1 0
ANIMATION_INCR   .by 1  1 1 1 1 1 1 1 1 1 1

MAX_FROG_SPEED=10


; Timer values.  PAL ?? guesses...
; About 7 keys per second.
; KEYSCAN_FRAMES = $07
; based on number of frogs, how many frames between boat movements...
;ANIMATION_FRAMES .byte 25,21,17,14,12,11,10,9,8,7,6,5


; ==========================================================================
; RESET KEY SCAN TIMER and ANIMATION TIMER
;
; A  is the time to set for animation.
; --------------------------------------------------------------------------
ResetTimers
	sta AnimateFrames

	pha ; preserve it for caller.

	lda InputScanFrames
	bne EndResetTimers

	lda #INPUTSCAN_FRAMES
	sta InputScanFrames

EndResetTimers
	pla ; get this back for the caller.

	rts


; ==========================================================================
; Check for input from the controller....
;
; Eliminate Down direction.
; Eliminate conflicting directions.
; Add trigger to the input stick value.
;
; STICK0 Joystick Bits:  00001111
; "NA NA NA NA Right Left Down Up", 0 bit means joystick is pushed.
; Cook the bits to turn on the directions we care about and zero the other
; bits, therefore, if stick value is 0 then it means no input.
; - Down input is ignored (masked out).
; - Since up movement is the most likely to result in death the up movement
;    must be exclusively up.  If a horizontal movement is also on at the
;    same time then the up movement will be masked out.
;
; Arcade controllers with individual buttons would allow both left and
; right to be pressed at the same time.  To avoid unnecessary fiddling
; with the frog in this situation eliminate both motions if both are
; engaged.
;
; STRIG0 Button
; 0 is button pressed., !0 is not pressed.
; If STRIG0 input then set bit $10 for trigger.
;
; Return  A  with InputStick value of cooked Input bits where the direction
; and trigger set are 1 bits.  Bit values:   00011101
; "NA NA NA Trigger Right Left NA Up"
;
; Wow, but this became a sloppy mess of bit flogging.
; But it does replace several functions of key reading shenanigans.
; --------------------------------------------------------------------------
CheckInput
	lda InputScanFrames       ; Is input timer delay  0?
	bne SetNoInput            ; No. thus nothing to scan. (and exit)

	jsr SetNoInput            ; Make sure the official stick read starts with no input.
	lda STICK0                ; The OS nicely separates PIA nybbles for us

ChefOfJoystickBits  ; Cook STICK0 into the safe stick directions.  Flip input bits.
	eor #%00001111            ; Reverse direction bits.
	and #%00001101            ; Mask out the Down.
	sta InputStick            ; Save it.
	beq AddTriggerInput       ; No movement.  Add trigger button if pressed.

; Fix Up+Right Bits
	and #%00001001            ; Looking at only Up and Right
	cmp #%00001001            ; Are both bits set ?
	bne FixUpLeftBits         ; no, go try same for Up and Left.
	lda InputStick
	and #%00001100            ; turn off the UP bit.
	sta InputStick            ; Save it.

FixUpLeftBits
	lda InputStick
	and #%00000101            ; Looking at only Up and Left
	cmp #%00000101            ; Are both bits set ?
	bne FixLeftRightBits      ; Nope.  Go check if left and right are on.
	lda InputStick
	and #%00001100            ; turn off the UP bit.
	sta InputStick            ; Save it.

FixLeftRightBits              ; Don't allow Left and Right to be on together.
	lda InputStick
	and #%00001100            ; Looking at only Up and Left
	cmp #%00001100            ; Are both bits set ?
	bne AddTriggerInput       ; Nope.  Go do something else.
	lda InputStick
	and #%00000001            ; turn off the Left and Right bits.
	sta InputStick            ; Save it.

AddTriggerInput
	lda STRIG0                ; 0 is button pressed., !0 is not pressed.
	bne DoneWithBitCookery    ; if non-zero, then no button pressed.

	lda InputStick            ; Return the input value.
	ora #%00010000            ; Turn on 5th bit/$10 for trigger.
	sta InputStick

DoneWithBitCookery            ; Some input was captured?
	lda InputStick            ; Return the input value?
	beq ExitCheckInput        ; No, nothing happened here.  Just exit.

	lda #INPUTSCAN_FRAMES     ; Because there was input collected, then
	sta InputScanFrames       ; reset the input timer.

ExitInputCollection ; Input occurred
	lda #0                    ; Kill the attract mode flag
	sta ATRACT                ; to prevent color cycling.

	lda InputStick            ; Return the input value.
	rts

SetNoInput
	lda #0
	sta InputStick
ExitCheckInput
	rts


;==============================================================================
;                                                           SCREENWAITFRAME  A
;==============================================================================
; Subroutine to wait for the current frame to finish display.
;
; ScreenWaitFrame  uses A
;==============================================================================

libScreenWaitFrame
	pha                ; Save A, so caller is not disturbed.
	lda RTCLOK60       ; Read the jiffy clock incremented during vertical blank.

bLoopWaitFrame
	cmp RTCLOK60       ; Is it still the same?
	beq bLoopWaitFrame ; Yes.  Then the frame has not ended.

	pla                ; restore A
	rts                ; No.  Clock changed means frame ended.  exit.



;==============================================================================
;                                                           MyImmediateVBI
;==============================================================================
; Immediate Vertical Blank Interrupt.
;
; Frame-critical tasks. 
; Force steady state of DLI.
; Manage switching displays.
;==============================================================================

MyImmediateVBI


; ======== Manage Changing Display List ========
	lda VBICurrentDL            ; Main code signals to change screens?
	bmi VBIResetDLIChain        ; -1, No, restore current DLI chain.

VBISetupDisplay
	tax                         ; Use VBICurrentDL  as index to tables.

	lda DISPLAYLIST_LO_TABLE,x  ; Copy Display List Pointer
	sta SDLSTL                  ; for the OS
	lda DISPLAYLIST_HI_TABLE,x
	sta SDLSTH

	lda DLI_LO_TABLE,x          ; Display List Interrupt chain table starting address
	sta ThisDLIAddr
	lda DLI_HI_TABLE,x          ; Display List Interrupt chain table starting address
	sta ThisDLIAddr+1

;	lda COLOR_BACK_LO_TABLE,x   ; Get pointer to the source color table
;	sta COLPF2POINTER
;	lda COLOR_BACK_HI_TABLE,x
;	sta COLPF2POINTER+1

;	lda COLOR_TEXT_LO_TABLE,x   ; Get pointer to the source text table
;	sta COLPF1POINTER
;	lda COLOR_TEXT_HI_TABLE,x
;	sta COLPF1POINTER+1

	lda #$FF                      ; Turn off the signal to change screens.
	sta VBICurrentDL

VBIResetDLIChain
	ldy #0
	lda (ThisDLIAddr),y      ; Grab 0 entry from this DLI chain
	sta VDSLST               ; and restart the DLI routine.
;	lda #>TITLE_DLI
;	sta VDSLST+1

	iny                     ; !!! Start at 1, because 0 provided the entry point !!!
	sty ThisDLI 

ExitMyImmediateVBI
	jmp SYSVBV ; Return to OS.  XITVBV for Deferred interrupt.



;==============================================================================
;                                                           MyDeferredVBI
;==============================================================================
; Deferred Vertical Blank Interrupt.
;
; Tasks that tolerate more laziness...
; Manage timers and countdowns.
; Scroll the line of credit text.
; Blink the Press Button prompt if enabled.
;==============================================================================

MyDeferredVBI
; ======== Manage InputScanFrames ========

; Set Frog position per main directions.

	lda InputScanFrames      ; Is input delay already 0?
	beq DoAnimateClock       ; Yes, do not decrement it again.
	dec InputScanFrames      ; Minus 1.

; ======== Manage AnimateFrames ========
DoAnimateClock
	lda AnimateFrames       ; Is animation countdown already 0?
	beq ScrollTheCreditLine ; Yes, do not decrement now.
	dec AnimateFrames       ; Minus 1

; ======== Manage scrolling the current credit line ========
ScrollTheCreditLine               ; scroll the text identifying the perpetrators
	dec ScrollCounter             ; subtract from scroll delay counter
	bne ManagePressAButtonPrompt  ; Not 0 yet, so no scrolling.
	lda #1                        ; Reset counter to original value.
	sta ScrollCounter
	; Yeah, ANTIC supports fine horizontal scrolling 16 color clocks or 
	; 4 text characters at a time.  But, this is a little more simple 
	; code if we scroll only one character per each coarse scroll.

	dec CreditHSCROL             ; Subtract one color clock from the left (aka fine scroll).
	beq ResetCreditScroll        ; If it is 0, then time for the next coarse scroll.
	
	lda CreditHSCROL             ; Not zero.  Get current value.
	bne UpdateCreditHSCROL       ; And go update the hardware fine scroll register.
	
ResetCreditScroll                ; Fine Scroll reached 0, so coarse scroll the text.
	inc SCROLL_CREDIT_LMS        ; Move text left one character position.
	lda SCROLL_CREDIT_LMS
	cmp #<END_OF_CREDITS         ; Did coarse scroll position reach the end of the text?
	bne RestartCreditHSCROL      ; No.  We are donewith coarse scroll, now reset fine scroll. 

	lda #<SCROLLING_CREDIT        ; Yes, restart coarse scroll to the beginning position.
	sta SCROLL_CREDIT_LMS
	
RestartCreditHSCROL               ; Reset the 
	lda #4                        ; horizontal fine 
	sta CreditHSCROL              ; scrolling.

UpdateCreditHSCROL
	sta HSCROL                    ; Update the hardware fine scroll register.
	
; ======== Manage the prompt flashing for Press A Button ========
ManagePressAButtonPrompt
	lda EnablePressAButton
	bne DoAnimateButtonTimer ; Not zero is enabled.
	; Prompt is off.  Zero everything.
	sta PressAButtonColor      ; Set background
	sta PressAButtonText      ; Set text.
	sta PressAButtonFrames   ; This makes sure it will restart as soon as enabled.
	beq DoCheesySoundService  

; Note that the Enable/Disable behavior connected to the timer mechanism 
; means that the action will occur when this timer executes with value 1 
; or 0. At 1 it will be decremented to become 0. The value 0 is evaluated 
; immediately.
DoAnimateButtonTimer
	lda PressAButtonFrames   
	beq DoPromptColorchange  ; Timer is Zero.  Go switch colors.
	dec PressAButtonFrames   ; Minus 1
	bne DoCheesySoundService ; if it is still non-zero end this section.

DoPromptColorchange
	jsr ToggleButtonPrompt   ; Manipulates colors for prompt.

DoCheesySoundService         ; World's most inept sound sequencer.
	jsr SoundService

ExitMyDeferredVBI
	jmp XITVBV  ; Return to OS.  SYSVBV for Immediate interrupt.


; ==========================================================================
; TOGGLE PressAButtonState 
; --------------------------------------------------------------------------
TogglePressAButtonState
	inc PressAButtonState    ; Add 1.  (says Capt Obvious)
	lda PressAButtonState
	and #1                   ; Keep only lowest bit -- 0, 1, 0, 1, 0, 1...
	sta PressAButtonState

	rts


; ==========================================================================
; TOGGLE BUTTON PROMPT
; Fade the prompt up and down. 
;
; PressAButtonState...
; If  0, then fading background down to dark.  (and text light)  
; If  1, then fading background up to light  (and text dark) 
; When background reaches 0 luminance change the color.
;
; On entry, the first choice may end up being black/white.  
; The code generally tries to exclude black/white, but on 
; entry this may occur depending on prior state. (fadeouts, etc.)
;
; A  is used for background color
; X  is used for text color.
; --------------------------------------------------------------------------
ToggleButtonPrompt
	lda #BLINK_SPEED            ; Text Fading speed for prompt
	sta PressAButtonFrames      ; Reset the frame counter.

	lda PressAButtonState       ; Up or down?
	bne PromptFadeUp            ; 1 == up.

	; Prompt Fading the background down.
	lda PressAButtonColor         ; Get the current background color.
	AND #$0F                    ; Look at only the luminance.
	bne RegularPromptFadeDown   ; Not 0 yet, do a normal job on it.

SetNewPromptColor
	lda RANDOM                  ; A random color and then prevent same 
	eor PressAButtonColor         ; value by chewing on it with the original color.
	and #$F0                    ; Mask out the luminance for Dark.
	beq SetNewPromptColor       ; Do again if black/color 0 turned up
	sta PressAButtonColor         ; Set background.
	jsr TogglePressAButtonState ; Change fading mode to up (1)
	bne SetTextAsInverse        ; Text Brightness inverse from the background

RegularPromptFadeDown
	dec PressAButtonColor         ; Subtract 1 from the color (which is the luminance)
	jmp SetTextAsInverse        ; And reset the text to accordingly.

PromptFadeUp
	lda PressAButtonColor
	AND #$0F                    ; Look at only the luminance.
	cmp #$0F                    ; Is it is at max luminance now?
	bne RegularPromptFadeUp     ; No, do the usual fade.

	jsr TogglePressAButtonState ; Change fading mode to down.
	rts

RegularPromptFadeUp
	inc PressAButtonColor         ; Add 1 to the color (which is the luminance)
	; and fall into setting the text luminance setup....

SetTextAsInverse  ; Make the text luminance the opposite of the background.
	lda PressAButtonColor         ; Background color...
	eor #$0F                    ; Not (!) the background color's luminance.
	sta PressAButtonText         ; Use as the text's luminance.
	rts


; ==========================================================================
; RUN PROMPT FOR BUTTON
; Maintain blinking timer.
; Update/blink text on line 23.
; Return 0/BEQ when the any key is not pressed.
; Return !0/BNE when the any key is pressed.
;
; On Exit:
; A  contains key press.
; CPU flags are comparison of key value to $FF which means no key press.
; --------------------------------------------------------------------------
RunPromptForButton
	lda #1
	sta EnablePressAButton   ; Tell VBI to the prompt flashing is enabled.

	jsr CheckInput           ; Get input. Non Zero means there is input.
	and #%00010000           ; Strip it down to only the joystick button.
	beq ExitRunPrompt        ; If 0, then do not play sound.

	ldx #2                   ; Button pressed. Set Pokey channel 2 to tink sound.
	ldy #SOUND_TINK
	jsr SetSound 

	lda #%00010000       ; Set the button is pressed.

ExitRunPrompt
	rts


	.align $0100


;==============================================================================
;                                                           MyDLI
;==============================================================================
; Display List Interrupts
;
; Note the DLIs don't care where the ThisDLI index ends as 
; this is managed by the VBI.
;==============================================================================

; shorthand for starting DLI  (that do not JMP immediately to common code)
	.macro mStart_DLI
		mregSaveAY

		ldy ThisDLI
	.endm

; Note that the Title screen uses the COLBK table for both COLBK and COLPF2.


; This is called on a blank line and the background should already be black.  
; This just makes sure everything is correct.
; Since there is no text here (in blank line), it does not matter that COLPF1 is written before WSYNC.

; Save 3 bytes.  Use Score_DLI directly in the DLI address table.  duh.

; TITLE_DLI ; DLI sets COLPF1, COLPF2, COLBK for score text. 
;	jmp Score_DLI


; Save 3 bytes.  Use COLPF0_COLBK_DLI directly in the DLI address table.  duh.

; TITLE_DLI_1 ; DLI sets COLBK and COLPF0 for title graphics.
;	jmp COLPF0_COLBK_DLI

; Save 3 bytes.  Use COLPF0_COLBK_DLI directly in the DLI address table.  duh.

; TITLE_DLI_2 ; DLI sets only COLPF0 for title graphics.
;	jmp COLPF0_COLBK_DLI


TITLE_DLI_3 ; DLI Sets background to Black for blank area.
	mStart_DLI

	jmp SetBlack_DLI


; Since there is no text here (in blank line), it does not matter that COLPF1 is written before WSYNC.

TITLE_DLI_4 ; DLI sets COLPF1 text luminance from the table, COLBK and COLPF2 to start a text block.
	mStart_DLI

	lda COLPF1_TABLE,y   ; Get text color (luminance)
	sta COLPF1           ; write new text luminance.

	lda COLBK_TABLE,y   ; For Text Background.
	sta WSYNC
	sta COLBK
	sta COLPF2

	jmp Exit_DLI


TITLE_DLI_5 ; DLI sets only COLPF1 text luminance from the table. (e.g. for fading)
GAME_DLI_1
	mStart_DLI

	lda COLPF1_TABLE,y   ; Get text color (luminance)
	sta WSYNC
	sta COLPF1           ; write new text luminance.

	jmp Exit_DLI


; Save 3 bytes.  Use DLI_SPC1 directly in the DLI address table.  duh.

;TITLE_DLI_SPC1 ; How to solve getting from point A to point B with only a low byte address update
;	jmp DLI_SPC1



; GAME DLIs

; This is called on a blank line and the background should already be black.  
; Since there is no text here (in blank line), it does not matter that COLPF1 is written before WSYNC.
; Since the game fades the screen COLPF1 must pull from the table.

; SCORES 1
; GAME_DLI ; DLI sets COLPF1, COLPF2, COLBK for score text. 
;	jmp Score_DLI

; SCORES 2
; GAME_DLI_1 ; DLI 1 sets COLPF1 for text. (e.g. for fading)
;	jmp TITLE_DLI_5


; BEACH
; Slow and easy as DLIs go.  DLI Starts on a text line, does sync and has a whole 
; blank scan line to finish everything else.  
; Collect Player/Playfield collisions.
; Set Wide screen for Beach.

GAME_DLI_2 ; DLI 2 sets COLPF0,1,2,3,BK for Beach.
	mStart_DLI

	lda COLPF0_TABLE,y   ; for the extra line Get color Rocks (or water color) instead of COLBK
	sta WSYNC
	; Top of the line is sky or blue water from row above.   
	; Make background temporarily match the playfield drawing this on the next line.
	sta COLBK
	sta COLPF0
	
	lda #ENABLE_DL_DMA|PM_1LINE_RESOLUTION|ENABLE_PM_DMA|PLAYFIELD_WIDTH_WIDE
	sta DMACTL
		
	jmp SetupAlmostAllColors_DLI

; BOATS 1
; Slow and easy as DLIs go.  DLI Starts on a text line, does sync and has a whole 
; blank scan line to finish everything else.  
; Collect Player/Playfield collisions.
; Set Normal width screen for Boats.

GAME_DLI_25 ; DLI 2 sets COLPF0,1,2,3,BK for first line of boats.
	mStart_DLI

	lda COLBK_TABLE,y   ; Get color Rocks 1   
	sta WSYNC
	sta COLBK
	
	lda #ENABLE_DL_DMA|PM_1LINE_RESOLUTION|ENABLE_PM_DMA|PLAYFIELD_WIDTH_NORMAL
	sta DMACTL
	
	lda HSCROL_TABLE,y   ; Get boat fine scroll.
	sta HSCROL
	
SetupAllColors_DLI
	lda COLPF0_TABLE,y   ; Get color Rocks 1   
	sta COLPF0

SetupAlmostAllColors_DLI
	lda COLPF1_TABLE,y   ; Get color Rocks 2
	sta COLPF1
	lda COLPF2_TABLE,y   ; Get color Rocks 3 
	sta COLPF2

	lda COLBK_TABLE,y   ; Get real background color again. (To repair the color for the Beach background)
	sta WSYNC
	sta COLBK

	lda P0PF             ; Get Player 0 collision with playfield
	ora P1PF             ; Add Player 1 collision 
	sta PXPF_TABLE,y     ; Save for later reference

	sta HITCLR           ; clear Player/Playfield collisions from here.

	jmp Exit_DLI

; BOATS 2
; Slow and easy as DLIs go.  DLI Starts on a text line, does sync and has a whole 
; blank scan line to finish everything else.  
; Collect Player/Playfield collisions.
GAME_DLI_3 ; DLI 3 sets COLPF0,1,2,3,BK and HSCROL for Boats.
	mStart_DLI

	lda COLBK_TABLE,y    ; Get Water 2 color
	sta WSYNC
	sta COLBK

	lda HSCROL_TABLE,y   ; Get boat fine scroll.
	sta HSCROL

	jmp SetupAllColors_DLI


; Save 3 bytes.  Use TITLE_DLI_3 directly in the DLI address table.  duh.

; GAME_DLI_4 ; Set background to black.
;	jmp TITLE_DLI_3 ; re-use what is done already....



GAME_DLI_5 ; Needs to set HSCROL for credits, then call to set text color.  LAST DLI on screen.
	mRegSaveAY

	lda CreditHSCROL      ; HScroll for credits.
	sta HSCROL

	jmp DLI_SPC2_SetCredits ; Finish by setting text luminance.



; SPLASH DLIs

; The three graphics screen (Saved, Dead Frog, and Game Over) have exactly the
; same display list structure and DLIs.  
; Sets background color and the COLPF0 pixel color.  
; Table driven.  
; Perfectly re-usable for anywhere Map Mode 9 or Blank instructions are 
; being managed.  In the case of blank lines you just don't see the pixel 
; color change, so it does not matter what is in the COLPF0 color table. 

COLPF0_COLBK_DLI
	mStart_DLI

	lda COLPF0_TABLE,y   ; Get pixels color
	pha
	lda COLBK_TABLE,y    ; Get background color
	sta WSYNC
	sta COLBK            ; Set background
	pla
	sta COLPF0           ; Set pixels.

	jmp Exit_DLI



; Used on multiple screens.  JMP here.
; This is called on a blank line and the background should already be black.  
; Since there is no text here (in blank line), it does not matter that COLPF1 is written before WSYNC.
; Since the game fades the screen COLPF1 must pull from the table.
Score_DLI
	mStart_DLI

	lda COLPF1_TABLE,y   ; Get text color (luminance)
	sta COLPF1           ; write new text color.

SetBlack_DLI
	lda #COLOR_BLACK     ; Black for background and text background.
	sta WSYNC            ; sync to end of scan line
	sta COLBK            ; Write new border color.
	sta COLPF2           ; Write new background color

; Exit DLI.
; JMP here is 3 byte instruction to execute 11 bytes of common DLI closure.
Exit_DLI
	lda (ThisDLIAddr), y ; update low byte for next chained DLI.
	sta VDSLST

	inc ThisDLI          ; next DLI.

	mRegRestoreAY

DoNothing_DLI ; We can jump here to not do anything or to stop the DLI chain.
	rti



; DLI to set colors for the Prompt line.  
; And while we're here do the HSCROLL for the scrolling credits.
; Then link to DLI_SPC2 to set colors for the scrolling line.
; Since there is no text here (in blank line), it does not matter that COLPF1 is written before WSYNC.

DLI_SPC1  ; DLI sets COLPF1, COLPF2, COLBK for Prompt text. 
	pha ; aka pha

	lda PressAButtonText  ; Get text color (luminance)
	sta COLPF1            ; write new text luminance.
	
	lda PressAButtonColor ; Black for background and text background.
	sta WSYNC             ; sync to end of scan line
	sta COLBK             ; Write new border color.
	sta COLPF2            ; Write new background color

	lda CreditHSCROL      ; HScroll for credits.
	sta HSCROL

; Unfortunately, DLI_SPC2 landed +8 bytes into the next page.  So full address needs to be set...
	lda #<DLI_SPC2        ; Update the DLI vector for the last routine for credit color.
	sta VDSLST
	lda #>DLI_SPC2        ; Update the DLI vector for the last routine for credit color.
	sta VDSLST+1
	
	pla ; aka pla

	rti



; DLI to set colors for the Scrolling credits.   ALWAYS the last DLI on screen.

DLI_SPC2  ; DLI just sets black for background COLBK, COLPF2, and text luminance for scrolling text.
	mRegSaveAY

DLI_SPC2_SetCredits      ; Entry point to make this shareable by other caller.
	ldy #$0C             ; luminance for text
	lda #COLOR_BLACK     ; color for background.

	sta WSYNC            ; sync to end of scan line

	sty COLPF1           ; Write text luminance for credits.
	sta COLBK            ; Write new border color.
	sta COLPF2           ; Write new background color

	lda #<DoNothing_DLI  ; Stop DLI Chain.  VBI will restart the chain.
	sta VDSLST
	lda #>DoNothing_DLI  ; Stop DLI Chain.  VBI will restart the chain.
	sta VDSLST+1
	
	mRegRestoreAY

	rti


