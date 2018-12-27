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

; Timer values.  NTSC.
; About 7 keys per second.
KEYSCAN_FRAMES = $09

; based on number of frogs, how many frames between boat movements...
ANIMATION_FRAMES .byte 30,25,20,18,15,13,11,10,9,8,7,6,5,4,3

MAX_FROG_SPEED=14


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
	pha                 ; Save whatever is in A
	lda #$FF
	sta CH              ; Clear any pending key

	lda #KEYSCAN_FRAMES ; Reset keyboard timer for next key input.
	sta KeyscanFrames
	
	pla                 ; restore  whatever was in A.
	
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
	pha                  ; Save for a moment.
	lda COLPF1_TABLE,x   ; Get text color (luminance)
	tax                  ; X = text color (luminance)
	pla                  ; A = background color.
	sta WSYNC            ; sync to end of scan line
	sta COLPF2           ; Write new background color
	stx COLPF1           ; write new text color.
	inc ThisDLI          ;

	mRegRestoreAX
	
	rti
	
	
;==============================================================================
;                                                           MyDeferredVBI
;==============================================================================
; Vertical Blank Interrupt.
;
; Manage timers and countdowns.
; Force steady state of DLI.
;==============================================================================

MyDeferredVBI
	lda #$00
	sta ThisDLI
	
	jmp XITVBV ; Return to OS.

	