; ==========================================================================
; TIMER STUFF AND INPUT
;
; Miscellaneous:
; Tick Tock value,
; Count downs,
; Check for Key I/O,
; Wait for start of frame.
;
; --------------------------------------------------------------------------

; Timer values.  NTSC.
; About 7 keys per second.
KEYSCAN_FRAMES = $09

; based on number of frogs, how many frames between boat movements...
ANIMATION_FRAMES .byte 30,25,20,18,15,13,11,10,9,8,7,6

; Timer values.  PAL ?? guesses...
; About 7 keys per second.
; KEYSCAN_FRAMES = $07
; based on number of frogs, how many frames between boat movements...
;ANIMATION_FRAMES .byte 25,21,17,14,12,11,10,9,8,7,6,5


; Keyboard codes for keyboard game controls.
KEY_S = 62
KEY_Y = 43
KEY_6 = 27
KEY_4 = 24


; ==========================================================================
; RESET KEY SCAN TIMER and ANIMATION TIMER
;
; A  is the time to set for animation.
; --------------------------------------------------------------------------
ResetTimers
	sta AnimateFrames

	pha ; preserve it for caller.

	lda KeyscanFrames
	bne EndResetTimers
	
	lda #KEYSCAN_FRAMES
	sta KeyscanFrames

EndResetTimers
	pla ; get this back for the caller.

	rts


; ==========================================================================
; RESET ANIMATION TIMER
;
; A  is the time to set for animation.
; --------------------------------------------------------------------------
ResetAnimateTimer
	sta AnimateFrames

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
; Check for a keypress based on timer state.
;
; A  returns the key pressed.  or returns $FF for no key pressed.
; If the timer allows reading, and a key is found, then the timer is
; reset for the time of the next key input cycle.
;
; Return with flags set for CMP #$FF ; BEQ = No key
; --------------------------------------------------------------------------
CheckKey
	lda KeyscanFrames         ; Is keyboard timer delay  0?
	bne ExitCheckKeyNow       ; No. thus no key to scan.

	lda CH
	pha                       ; Save the key for later

	cmp #$FF                  ; No key pressed, so nothing to do.
	beq ExitCheckKey

	jsr ClearKey              ; Clear register/timer for next key read.

ExitCheckKey                  ; exit with some kind of key value in A.
	pla                       ; restore the pressed key in A.
	cmp #$FF                  ; set flags for not matching $FF no key value
	rts

ExitCheckKeyNow               ; exit with no key value in A
	lda #$FF
	cmp #$FF                  ; set flags for matching $FF no key value
	rts


; ==========================================================================
; Clear Current/Pending Key
;
; This should only be called 
; 1) when a successful read has just occurred to empty the key 
;    buffer and rest the key scan timer.
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
	pha             ; Save whatever is in A
	lda #$FF
	sta CH          ; Clear any pending key

	lda #KEYSCAN_FRAMES ; Reset keyboard timer for next key input.
	sta KeyscanFrames
	
	pla             ; restore  whatever was in A.
	
	rts
	

; ==========================================================================
; Wait for a keypress.
;
; A  returns the key pressed.
; --------------------------------------------------------------------------
WaitKey
	lda #$FF
	sta CH          ; Clear any pending key

WaitKeyLoop
	lda CH
	cmp #$FF        ; No key pressed
	beq WaitKeyLoop ; Loop until a key is pressed.

	jsr ClearKey

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

	lda DoTimers           ; Are timers turned on or off?
	beq ExitEventLoop      ; Off, skip it all.

	jsr libScreenWaitFrame ; Wait until end of frame

	lda KeyscanFrames      ; Is keyboard delay already 0?
	beq DoAnimateClock     ; Yes, do not decrement it again.
	dec KeyscanFrames      ; Minus 1.

DoAnimateClock
	lda AnimateFrames      ; Is animation countdown already 0?
	beq ExitEventLoop      ; Yes, do not decrement now.
	dec AnimateFrames      ; Minus 1

ExitEventLoop
	mRegRestoreAYX

	rts


;==============================================================================
;                                                       SCREENWAITFRAMES  A  Y
;==============================================================================
; Subroutine to wait for a number of frames.
;
; FYI:
; Calling with A = 1 is the same thing as directly calling ScreenWaitFrame.
;
; ScreenWaitFrames expects A to contain the number of frames.
;
; ScreenWaitFrames uses  Y
;==============================================================================

libScreenWaitFrames
	sty SAVEY           ;  Save what is here, can't go to stack due to tay
	tay
	beq bExitWaitFrames

bLoopWaitFrames
	jsr libScreenWaitFrame

	dey
	bne bLoopWaitFrames ; Still more frames to count?   go

bExitWaitFrames
	ldy SAVEY           ; restore Y
	rts                 ; No.  Clock changed means frame ended.  exit.


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

	