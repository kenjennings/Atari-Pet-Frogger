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
; TIMER STUFF AND INPUT
;
; Miscellaneous:
; Timer ranges
; Key Values
; Tick Tock value,
; Count downs,
; Check for Key I/O,
; Wait for start of frame.
;
; --------------------------------------------------------------------------

; ==========================================================================
; Animation speeds of various displayed items.   Number of frames to wait...
; --------------------------------------------------------------------------
BLINK_SPEED      = 36 ; blinking Press Any Key text
TITLE_WIPE_SPEED = 0  ; Title wipe speed
DEAD_FILL_SPEED  = 3  ; Fill the Screen for Dead Frog
WIN_FILL_SPEED   = 4  ; Fill screen for Win
FROG_WAKE_SPEED  = 90 ; Initial delay 1.5 sec for frog corpse '*' viewing/mourning
RES_IN_SPEED     = 2  ; Speed of Game over Res in animation
TITLE_SPEED      = 2  ; Fill screen to present title

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


; Keyboard codes for keyboard game controls.
;KEY_S = 62
;KEY_Y = 43
;KEY_6 = 27
;KEY_4 = 24


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
; TOGGLE FLIP FLOP
;
; Flip toggle state 0, 1, 0, 1, 0, 1,....
;
; Ordinarily should be EOR with #1, but I don't trust myself that
; Toggle state ends up being something greater than 1 due to some
; moment of sloppiness, so the absolute, slower slogging about
; with INC and AND is done here.
;
; Uses A, CPU flag status Z indicates 0 or 1
; --------------------------------------------------------------------------
ToggleFlipFlop
	inc ToggleState ; Add 1.  (says Capt Obvious)
	lda ToggleState
	and #1          ; Squash to only lowest bit -- 0, 1, 0, 1, 0, 1...
	sta ToggleState

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
; Wow, but this became a sloppy mess.
; --------------------------------------------------------------------------
CheckInput
	lda InputScanFrames       ; Is input timer delay  0?
	bne SetNoInput            ; No. thus nothing to scan. (and exit)

	jsr SetNoInput           ; Make sure the official stick starts with no input.

ProcessJoystickBits
	lda STICK0                ; The OS nicely separates PIA nybbles for us
	and #%00001111            ; Make sure only low bits kept.  (Is this necessary?)
	cmp #$0F                  ; Any direction is moved?
	beq AddTriggerInput       ; No.  If the trigger button is pressed, then add that.

ChefOfJoystickBits  ; Cook STICK0 into the safe stick directions.
; Flip input bits.
	eor #%00001111            ; Reverse direction bits.
	and #%00001101            ; Mask out the Down.
	sta InputStick            ; Save it.

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
	beq ExitInputCollection   ; No, nothing happened here.  Just exit.

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
	rts


; ==========================================================================
; Check for a keypress based on timer state.
;
; A  returns the key pressed.  or returns $FF for no key pressed.
; If the timer allows reading, and a key is found, then the timer is
; reset for the time of the next key input cycle.
;
; Return with flags set for CMP #$FF ; BEQ = No key
; --------------------------------------------------------------------------
CheckKey
;	lda KeyscanFrames         ; Is keyboard timer delay  0?
;	bne ExitCheckKeyNow       ; No. thus no key to scan.

;	lda CH
;	pha                       ; Save the key for later

;	cmp #$FF                  ; No key pressed, so nothing to do.
;	beq ExitCheckKey

;	jsr ClearKey              ; Clear register/timer for next key read.

;ExitCheckKey                  ; exit with some kind of key value in A.
;	pla                       ; restore the pressed key in A.
;	cmp #$FF                  ; set flags for not matching $FF no key value
	rts

;ExitCheckKeyNow               ; exit with no key value in A
;	lda #$FF
;	cmp #$FF                  ; set flags for matching $FF no key value
	rts


; ==========================================================================
; Clear Input.
;
; Joystick and trigger input is real-time on-off without
; a buffer, so there is substantially less purpose for this
; routine than the same need for keyboard input.
;
; All it really does is reset the input scan timer.
; --------------------------------------------------------------------------
ClearInput
	pha                 ; Save whatever is in A

	lda #INPUTSCAN_FRAMES     ; Because there was input collected, then
	sta InputScanFrames       ; reset the input timer.

	pla                 ; restore  whatever was in A.

	rts


; ==========================================================================
; Clear Current/Pending Key
;
; This should only be called
; 1) when a successful read has just occurred to empty the key
;    buffer and reset the key scan timer.
; 2) when we do not want a keystroke entered in the recent past to be
;    automatically read when we get to the next opportunity to read the
;    keyboard.
;    i.e.  When there was animation occurring which occupies human wait
;    time and the code will soon enter an event area that will read a
;    character.
;    e.g. Press Any Key To Continue.
;
; Reset CH to no key read value.  Reset the timer too while we're here.
; --------------------------------------------------------------------------
ClearKey
;	pha                 ; Save whatever is in A
;	lda #$FF
;	sta CH              ; Clear any pending key

;	lda #KEYSCAN_FRAMES ; Reset keyboard timer for next key input.
;	sta KeyscanFrames

;	pla                 ; restore  whatever was in A.

	rts


;==============================================================================
;                                                           TIMERLOOP  A
;==============================================================================
; Primitive timer loop.
;
; When the game design is more Atari-ficated (planned Version 02) this is part
; of the program's deferred Vertical Blank Interrupt routine.  This routine
; services any display-oriented updates and notifications for the mainline
; code that runs during the bulk of the frame.
;
; Main code calls this at the end of its cycle, then afterwards it restarts
; its cycle.
; This routine waits for the current frame to finish display, then
; manages the timers/countdown values.
; It is the responsibility of the main line code to observe when timers
; reach 0 and reset them or act accordingly.
;
; All registers are preserved.
;==============================================================================

TimerLoop
	mRegSaveAYX

	jsr libScreenWaitFrame ; Wait until end of frame

ExitEventLoop
	mRegRestoreAYX

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
; Get text luminace from table.
; sync display.
; Store background color.
; store text color (luminance.)
; Increment index for next call.
;
; Note the DLIs don't care where the index ends as this is managed by the VBI.
;==============================================================================

MyDLI

	mRegSaveAX

	ldx ThisDLI
	lda COLPF2_TABLE,x   ; Get background color;
	sta WSYNC            ; sync to end of scan line
	sta COLPF2           ; Write new background color
	lda COLPF1_TABLE,x   ; Get text color (luminance)
	sta COLPF1           ; write new text color.

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
	inc ThisDLI          ; next DLI.

	mRegRestoreAX

	rti


;==============================================================================
;                                                           MyImmediateVBI
;==============================================================================
; Vertical Blank Interrupt.
;
; Manage timers and countdowns.
; Force steady state of DLI.
; Manage switching displays.
; Scroll the line of credit text.
;==============================================================================

MyImmediateVBI
	lda #$00                 ; Initialize.
	tay                      ; I want Y = 0 too.
	sta ThisDLI              ; Make the DLI index restarts at 0.

; ======== Manage InputScanFrames ========
	lda InputScanFrames      ; Is input delay already 0?
	beq DoAnimateClock       ; Yes, do not decrement it again.
	dec InputScanFrames      ; Minus 1.

; ======== Manage AnimateFrames ========
DoAnimateClock
	lda AnimateFrames       ; Is animation countdown already 0?
	beq DoDisplayListSwitch ; Yes, do not decrement now.
	dec AnimateFrames       ; Minus 1
	
; ======== Manage Changing Display List ========
DoDisplayListSwitch
	lda VBICurrentDL            ; Main code signals to change screens?
	bmi ScrollTheCreditLine     ; Negative value is no change.

	tax                         ; Use this as index to tables.

	lda DISPLAYLIST_LO_TABLE,x  ; Copy Display List Pointer.
	sta SDLSTL                  ; One for the OS
	sta CurrentDLPointer        ; One in page 0 for the code.
	lda DISPLAYLIST_HI_TABLE,x
	sta SDLSTH
	sta CurrentDLPointer+1

	lda COLOR_BACK_LO_TABLE,x   ; Get pointer to the source color table
	sta COLPF2POINTER
	lda COLOR_BACK_HI_TABLE,x
	sta COLPF2POINTER+1

	lda COLOR_TEXT_LO_TABLE,x   ; Get pointer to the source text table
	sta COLPF1POINTER
	lda COLOR_TEXT_HI_TABLE,x
	sta COLPF1POINTER+1

	lda PLAYFIELD_LMS_SCROLL_LO_TABLE,x ; Get the pointer to the LMS for the scrolling credit line.
	sta CurrentCreditLMS
	lda PLAYFIELD_LMS_SCROLL_HI_TABLE,x
	sta CurrentCreditLMS+1

	lda ScrollCredit              ; Update current screen to have the current credit scroll value.
	sta (CurrentCreditLMS),y

	stx CurrentDL                 ; Tell main code the new screen is set.

	lda #$FF                      ; Turn off the signal to change screens.
	sta VBICurrentDL

; ======== Manage scrolling the current credit line ========
ScrollTheCreditLine               ; scroll the text identifying the perpetrators
	dec ScrollCounter             ; subtract from scroll delay counter
	bne ManagePressAButtonPrompt  ; Not 0 yet, so no scrolling.
	lda #6                        ; Reset counter to original value.
	sta ScrollCounter

	inc ScrollCredit              ; Move text left one position.
	lda ScrollCredit
	cmp #<EXTRA_BLANK_MEM         ; Did scroll position reach the end of the text?
	bne UpdateCurrentScrollCredit ; No.  Just update with current value.

	lda #<SCROLLING_CREDIT        ; Yes, restart scroll from the beginning position.
	sta ScrollCredit

UpdateCurrentScrollCredit    ; Note that only the low byte of the LMS needs to be updated, since all the
	sta (CurrentCreditLMS),y ; text of the scrolling line fits inside one page of memory.

; ======== Manage the prompt flashing for Press A Button ========
ManagePressAButtonPrompt
	lda EnablePressAButton
	bne DoAnimateButtonTimer ; Not zero is enabled.
	; Prompt is off.  Zero everything.
	sta COLPF2_TABLE+23      ; Set background
	sta COLPF1_TABLE+23      ; Set text.
	sta PressAButtonFrames   ; This makes sure it will restart as soon as enabled.
	beq ExitMyImmediateVBI

; Note that the Enable/Disable behavior connected to the timer mechanism 
; means that the action will occur when this timer executes with value 1 
; or 0. At 1 it will be decremented to become 0. The value 0 is evaluated 
; immediately.
DoAnimateButtonTimer
	lda PressAButtonFrames   
	beq DoPromptColorchange  ; Timer is Zero.  Go switch colors.
	dec PressAButtonFrames   ; Minus 1
	bne ExitMyImmediateVBI   ; if it is still non-zero end this section.

DoPromptColorchange
	lda #BLINK_SPEED         ; Text Blinking speed for prompt
	sta PressAButtonFrames   ; Reset the delay counter.

	inc PressAButtonState    ; Add 1.  (says Capt Obvious)
	lda PressAButtonState
	and #1                   ; Squash to only lowest bit -- 0, 1, 0, 1, 0, 1...
	sta PressAButtonState

	jsr ToggleButtonPrompt   ; Switches colors for prompt randomly.

ExitMyImmediateVBI
	jmp SYSVBV ; Return to OS.  XITVBV for Deferred interrupt.

