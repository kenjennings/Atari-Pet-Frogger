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
; About 7 Inputs per second.
; After processing input (from the joystick) this is the number of frames
; to count before new input is accepted.  This prevents moving the frog at
; 60 fps and compensates for any jitter/uneven toggling of the joystick
; bits by flaky controllers.
INPUTSCAN_FRAMES = $09

; based on number of frogs, how many frames between boat movements...
ANIMATION_FRAMES .byte 30,25,20,18,15,13,11,10,9,8,7,6,5,4,3

MAX_FROG_SPEED=14


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
;                                                           MyDLI
;==============================================================================
; Display List Interrupt
;
; Get background color from table.
; Get text luminance from table.
; sync display.
; Store background color.
; store text color (luminance.)
; Increment index for next call.
;
; Note the DLIs don't care where the index ends as this is managed by the VBI.
;==============================================================================

; DLI to set colors for the Prompt line.  
; And while we're here do the HSCROLL for the scrolling credits.
; Then link to DLI_SPC2 to set colors for the scrolling line.
; Since there is no text here (in blank line), it does not matter that COLPF1 is written before WSYNC.

DLI_SPC1  ; DLI sets COLPF1, COLPF2, COLBK for Prompt text. 
	mRegSaveA

	lda PressAButtonText  ; Get text color (luminance)
	sta COLPF1            ; write new text luminance.
	
	lda PressAButtonColor ; Black for background and text background.
	sta WSYNC             ; sync to end of scan line
	sta COLBK             ; Write new border color.
	sta COLPF2            ; Write new background color

	lda CreditHSCROL      ; HScroll for credits.
	sta HSCROL

	lda #<DLI_SPC2        ; Update the DLI vector for the last routine for credit color.
	sta VDSLST
	lda #>DLI_SPC2 
	sta VDSLST+1

	mRegRestoreA

	rti


; DLI to set colors for the Scrolling credits.   
; There is no need to link to another DLI, since we trust the VBI to reset to the beginning.

DLI_SPC2  ; DLI just sets black for background COLBK, COLPF2, and text luminance for scrolling text.
	mRegSaveAX

	lda #0C              ; luminance for text
	ldx #COLOR_BLACK     ; color for background.

	sta WSYNC            ; sync to end of scan line

	sta COLPF1           ; Write text luminance for credits.
	stx COLBK            ; Write new border color.
	stx COLPF2           ; Write new background color

	mRegRestoreA

	rti



MyDLI

	mRegSaveAX

	ldx ThisDLI
	lda COLPF2_TABLE,x   ; Get background color;
	sta WSYNC            ; sync to end of scan line
	sta COLPF2           ; Write new background color
	lda COLPF1_TABLE,x   ; Get text color (luminance)
	sta COLPF1           ; write new text color.

	inc ThisDLI          ; next DLI.

	mRegRestoreAX

	rti

; Other thoughts....
; or if the writes are not fast enough...
;	ldx ThisDLI
;	lda COLPF1_TABLE,x   ; Get text color (luminance)
;	pha                  ; save on stack
;	lda COLPF2_TABLE,x   ; Get background color;
;	sta WSYNC            ; sync to end of scan line
;	sta COLPF2           ; Write new background color
;	pla                  ; and restore from stack
;	sta COLPF1           ; write new text color.

; or if fine scrolling is used...
;	ldx ThisDLI
;	lda COLPF1_TABLE,x   ; Get text color (luminance)
;	pha                  ; save on stack
;	lda COLPF2_TABLE,x   ; Get background color;
;   pha                  ; save on stack
;   lda HSCROLL_TABLE,x  ; Get fine scroll offset
;	sta WSYNC            ; sync to end of scan line
;	sta HSCROL           ; Write new fine scroll position
;   pla                  ; and restore from stack
;	sta COLPF2           ; Write new background color
;	pla                  ; and restore from stack
;	sta COLPF1           ; write new text color.

; The only way to speed that up is to have 25 specific DLI routines, one for
; each screen line, and then use immediate mode load (lda #00 ; sta foo).
; Then the code would need a lookup table of addresses to directly update the
; immediate mode values in the routines.

	.align $0100

; This is called on a blank line and the background should already be black.  
; This just makes sure everything is correct.
; Since there is no text here (in blank line), it does not matter that COLPF1 is written before WSYNC.

TITLE_DLI ; DLI sets COLPF1, COLPF2, COLBK for score text. 
	mRegSaveAX

	ldx ThisDLI
	
	lda COLPF1_TABLE,x   ; Get text color (luminance)
	sta COLPF1           ; write new text color.
	
	lda #COLOR_BLACK     ; Black for background and text background.
	sta WSYNC            ; sync to end of scan line
	sta COLBK            ; Write new border color.
	sta COLPF2           ; Write new background color

	lda TITLE_DLI_CHAIN_TABLE, x ; update low byte for next chained DLI.
	sta VDSLST

	inc ThisDLI          ; next DLI.

	mRegRestoreAX

	rti


TITLE_DLI_1 ; DLI sets COLBK and COLPF0 for title graphics.
	mRegSaveAX

	ldx ThisDLI

	lda #COLOR_ORANGE_GREEN  ; For variety, adjusted the color two hues up on the pallette.
	sta WSYNC
	sta COLBK

	lda COLPF1_TABLE,x ; Borrowing for the text (luminance table) (BTW, this is COLOR_GREEN)
	sta COLPF0         ; But using for Color 0.

	lda TITLE_DLI_CHAIN_TABLE, x ; update low byte for next chained DLI.
	sta VDSLST

	inc ThisDLI          ; next DLI.

	mRegRestoreAX

	rti


TITLE_DLI_2 ; DLI sets only COLPF0 for title graphics.
	mRegSaveAX

	ldx ThisDLI

	lda COLPF1_TABLE,x ; Borrowing for the text (luminance table) (BTW, this is COLOR_GREEN)
	sta WSYNC
	sta COLPF0         ; But using for Color 0.

	lda TITLE_DLI_CHAIN_TABLE, x ; update low byte for next chained DLI.
	sta VDSLST

	inc ThisDLI          ; next DLI.

	mRegRestoreAX

	rti


TITLE_DLI_3 ; DLI Sets background to Black for blank area.
	mRegSaveAX

	lda #COLOR_BLACK     ; Black for background and text background.
	sta WSYNC            ; sync to end of scan line
	sta COLBK            ; Write new border color.

	ldx ThisDLI

	lda TITLE_DLI_CHAIN_TABLE, x ; update low byte for next chained DLI.
	sta VDSLST

	inc ThisDLI          ; next DLI.

	mRegRestoreAX

	rti


; Since there is no text here (in blank line), it does not matter that COLPF1 is written before WSYNC.

TITLE_DLI_4 ; DLI sets COLPF1 text luminance from the table, COLBK and COLPF2 to AQUA for Instructions text.
	mRegSaveAX

	ldx ThisDLI

	lda COLPF1_TABLE,x   ; Get text color (luminance)
	sta COLPF1           ; write new text luminance.

	lda #COLOR_AQUA      ; For Text Background.
	sta WSYNC
	sta COLBK
	sta COLPF2

	lda TITLE_DLI_CHAIN_TABLE, x ; update low byte for next chained DLI.
	sta VDSLST

	inc ThisDLI          ; next DLI.

	mRegRestoreAX

	rti


TITLE_DLI_5 ; DLI sets only COLPF1 text luminance from the table.
	mRegSaveAX

	ldx ThisDLI

	lda COLPF1_TABLE,x   ; Get text color (luminance)
	sta WSYNC
	sta COLPF1           ; write new text luminance.

	lda TITLE_DLI_CHAIN_TABLE, x ; update low byte for next chained DLI.
	sta VDSLST

	inc ThisDLI          ; next DLI.

	mRegRestoreAX

	rti


TITLE_DLI_SPC1
	jmp DLI_SPC1



















;TITLE_DLI_1 ; DLI sets COLPF2, COLBK for score text.  Mode 4 Text is different from Mode 2 text.
	mRegSaveAX

	ldx ThisDLI
	lda COLPF2_TABLE,x   ; Get background color;
	sta WSYNC            ; sync to end of scan line
	sta COLBK            ; Write new background color
	lda COLPF1_TABLE,x   ; Get text color (luminance)
	sta COLPF2           ; write new text color.

	lda TITLE_DLI_CHAIN_TABLE, x ; update low byte for next chained DLI.
	sta VDSLST

	inc ThisDLI          ; next DLI.

	mRegRestoreAX

	rti

	
;TITLE_DLI_2 ; DLI sets COLPF2 for title text.  Mode 4 Text is different from Mode 2 text.
	mRegSaveAX

	ldx ThisDLI
	lda COLPF1_TABLE,x   ; Get text color (luminance)
	sta WSYNC            ; sync to end of scan line
	sta COLPF2           ; write new text color.

	lda TITLE_DLI_CHAIN_TABLE, x ; update low byte for next chained DLI.
	sta VDSLST

	inc ThisDLI          ; next DLI.

	mRegRestoreAX

	rti
	
	
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
	lda #$00                 ; Initialize.
	sta ThisDLI              ; Make the DLI index restart at 0.

; ======== Manage Changing Display List ========
	lda VBICurrentDL            ; Main code signals to change screens?
	bmi ExitMyImmediateVBI      ; Negative value is no change. Exit.

	tax                         ; Use this as index to tables.

	lda DISPLAYLIST_LO_TABLE,x  ; Copy Display List Pointer
	sta SDLSTL                  ; for the OS
	lda DISPLAYLIST_HI_TABLE,x
	sta SDLSTH

	lda COLOR_BACK_LO_TABLE,x   ; Get pointer to the source color table
	sta COLPF2POINTER
	lda COLOR_BACK_HI_TABLE,x
	sta COLPF2POINTER+1

	lda COLOR_TEXT_LO_TABLE,x   ; Get pointer to the source text table
	sta COLPF1POINTER
	lda COLOR_TEXT_HI_TABLE,x
	sta COLPF1POINTER+1

	lda #$FF                      ; Turn off the signal to change screens.
	sta VBICurrentDL

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
	lda #1                      ; Reset counter to original value.
	sta ScrollCounter
	; Yeah, ANTIC support fine horizontal scrolling 16 color clocks or 
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
	sta COLPF2_TABLE+23      ; Set background
	sta COLPF1_TABLE+23      ; Set text.
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
	lda COLPF2_TABLE+23         ; Get the current background color.
	AND #$0F                    ; Look at only the luminance.
	bne RegularPromptFadeDown   ; Not 0 yet, do a normal job on it.

SetNewPromptColor
	lda RANDOM                  ; A random color and then prevent same 
	eor COLPF2_TABLE+23         ; value by chewing on it with the original color.
	and #$F0                    ; Mask out the luminance for Dark.
	beq SetNewPromptColor       ; Do again if black/color 0 turned up
	sta COLPF2_TABLE+23         ; Set background.
	jsr TogglePressAButtonState ; Change fading mode to up (1)
	bne SetTextAsInverse        ; Text Brightness inverse from the background

RegularPromptFadeDown
	dec COLPF2_TABLE+23         ; Subtract 1 from the color (which is the luminance)
	jmp SetTextAsInverse        ; And reset the text to accordingly.

PromptFadeUp
	lda COLPF2_TABLE+23
	AND #$0F                    ; Look at only the luminance.
	cmp #$0F                    ; Is it is at max luminance now?
	bne RegularPromptFadeUp     ; No, do the usual fade.

	jsr TogglePressAButtonState ; Change fading mode to down.
	rts

RegularPromptFadeUp
	inc COLPF2_TABLE+23         ; Add 1 to the color (which is the luminance)
	; and fall into setting the text luminance setup....

SetTextAsInverse  ; Make the text luminance the opposite of the background.
	lda COLPF2_TABLE+23         ; Background color...
	eor #$0F                    ; Not (!) the background color's luminance.
	sta COLPF1_TABLE+23         ; Use as the text's luminance.
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
