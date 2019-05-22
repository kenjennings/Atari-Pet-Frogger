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
; Version 03, May 2019
;
; --------------------------------------------------------------------------

; ==========================================================================
; TIMER STUFF AND INPUT
;
; Miscellaneous:
; Timer ranges
; Joystick input,
; Tick Tock values,
; Count downs,
; DLI and VBI routines.
; Prompt for Button press.
;
; --------------------------------------------------------------------------

; ==========================================================================
; Animation speeds of various displayed items.   Number of frames to wait...
; --------------------------------------------------------------------------
BLINK_SPEED      = 3   ; Speed of updates to Press A Button prompt.

TITLE_SPEED      = 2   ; Scrolling speed for title. 
TITLE_WIPE_SPEED = 0   ; Title screen to game screen fade speed.

FROG_WAKE_SPEED  = 190 ; Initial delay about 3 sec for frog corpse '*' viewing/mourning
DEAD_FADE_SPEED  = 4   ; Fade the game screen to black for Dead Frog
DEAD_CYCLE_SPEED = 6   ; Speed of color animation on Dead screen

WIN_FADE_SPEED   = 4   ; Fade the game screen to black to show Win
WIN_CYCLE_SPEED  = 5   ; Speed of color animation on Win screen 

GAME_OVER_SPEED  = 12  ; Speed of Game over Res in animation


; Timer values.  NTSC.
; About 9-ish Inputs per second.
; After processing input (from the joystick) this is the number of frames
; to count before new input is accepted.  This prevents moving the frog at
; 60 fps and maybe compensates for any jitter/uneven toggling of the joystick
; bits by flaky controllers.
; At 9 events per second the frog moves horizontally 18 color clocks, max. 
INPUTSCAN_FRAMES = $07 ; previously $09

; Originally, this was coarse scroll movement and the frog moved the 
; width of a character.  
; Based on number of frogs, how many frames between the boats' 
; character-based coarse scroll movement:
; ANIMATION_FRAMES .byte 30,25,20,18,15,13,11,10,9,8,7,6,5,4,3
;
; Fine scroll increments 4 times to equal one character 
; movement per timer above. Frog movement is two color clocks,
; or half a character per horizontal movement.
;
; Minimum coarse scroll speed was 2 characters per second, or 8 
; color clocks per second, or between 7 and 8 frames per color clock.
; The fine scroll will start at 7 frames per color clock.
;
; Maximum coarse scroll speed (3 frames == 20 character movements 
; per second) was the equivalent of 4 color clocks in 3 frames.
; The fine scroll speed will max out at 3 color clockw per frame.
;
; The Starting speed is slower than the coarse scrolling version.
; It ramps up to maximum speed in fewer levels/rescued frogs, and 
; the maximum speed is faster than the fastest coarse scroll
; speed (60 FPS fine scroll is faaast.)

; FYI -- SCROLLING RANGE
; Boats Right ;   64
; Start Scroll position = LMS + 12 (decrement), HSCROL 0  (Increment)
; End   Scroll position = LMS + 0,              HSCROL 15
; Boats Left ; + 64 
; Start Scroll position = LMS + 0 (increment), HSCROL 15  (Decrement)
; End   Scroll position = LMS + 12,            HSCROL 0

; Difficulty Progression Enhancement.... Each row can have its own frame 
; counter and scroll distance. 
; (and by making rows closer to the bottom run faster it produces a 
; kind of parallax effect. almost).

MAX_FROG_SPEED = 13 ; Number of difficulty levels (which means 14)

; About the arrays below.  18 bytes per row instead of 19:
; FrogRow ranges from 0 to 18 which is 19 rows.  The first and
; last rows are always have values 0.  When reading a row from the array,
; the index will overshoot the end of a row (18th entry) and read the 
; beginning of the next row as the 19th entry.  Since both always 
; use values 0, they are logically overlapped.  Therefore, each array 
; row needs only 18 bytes instead of 19.  Only the last row needs 
; the trailing 19th 0 added.
; 14 difficulty levels is the max, because of 6502 indexing.
; 18 bytes per row * 14 levels is 252 bytes.
; More levels would require more pointer expression to reach each row
; rather than simply (BOAT_FRAMES),Y.

BOAT_FRAMES ; Number of frames to wait to move boat. (top to bottom) (Difficulty 0 to 13)
	.by 0 7 7 0 7 7 0 7 7 0 7 7 0 7 7 0 7 7   ; Difficulty 0 
	.by 0 7 7 0 7 7 0 7 7 0 5 5 0 5 5 0 5 5   ; Difficulty 1 
	.by 0 7 7 0 7 7 0 5 5 0 5 5 0 3 3 0 3 3   ; Difficulty 2
	.by 0 7 7 0 7 5 0 5 5 0 3 3 0 3 2 0 2 2   ; Difficulty 3 
	.by 0 5 5 0 5 3 0 3 3 0 2 2 0 2 2 0 1 1   ; Difficulty 4 
	.by 0 5 5 0 3 3 0 3 2 0 2 2 0 1 1 0 1 1   ; Difficulty 5 
	.by 0 5 3 0 3 3 0 2 2 0 2 1 0 1 1 0 1 0   ; Difficulty 6 
	.by 0 3 3 0 3 2 0 2 2 0 1 1 0 1 0 0 0 0   ; Difficulty 7
	.by 0 3 3 0 2 2 0 1 1 0 1 1 0 0 0 0 0 0   ; Difficulty 8
	.by 0 3 2 0 2 1 0 1 1 0 0 0 0 0 0 0 0 0   ; Difficulty 9
	.by 0 2 2 0 1 1 0 1 0 0 0 0 0 0 0 0 0 0   ; Difficulty 10
	.by 0 2 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0   ; Difficulty 11
	.by 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0   ; Difficulty 12
	.by 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ; Difficulty 13

BOAT_SHIFT  ; Number of color clocks to scroll boat. (add or subtract)
	.by 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1   ; Difficulty 0
	.by 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1   ; Difficulty 1
	.by 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1   ; Difficulty 2
	.by 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1   ; Difficulty 3
	.by 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1   ; Difficulty 4
	.by 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1   ; Difficulty 5
	.by 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1   ; Difficulty 6
	.by 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1   ; Difficulty 7
	.by 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1   ; Difficulty 8
	.by 0 1 1 0 1 1 0 1 1 0 1 1 0 1 2 0 2 2   ; Difficulty 9
	.by 0 1 1 0 1 1 0 1 1 0 1 1 0 2 2 0 2 2   ; Difficulty 10
	.by 0 1 1 0 1 1 0 1 1 0 2 2 0 2 2 0 2 2   ; Difficulty 11
	.by 0 1 1 0 1 1 0 2 2 0 2 2 0 2 2 0 2 2   ; Difficulty 12
	.by 0 1 1 0 2 2 0 2 2 0 2 3 0 2 3 0 3 3 0 ; Difficulty 13

MOVING_ROW_STATES ; 19 entries describing boat directions. Beach (0), Right (1), Left (FF) directions.
	.by 0 1 $FF 0 1 $FF 0 1 $FF 0 1 $FF 0 1 $FF 0 1 $FF 0

; Offsets from first LMS low byte in Display List to 
; the subsequent LMS low byte of each boat line. (VBI)
; For the Right Boats this is the offset from PF_LMS1.
; For the Left Boats this is the offset from PF_LMS2.
BOAT_LMS_OFFSET 
	.by 0 0 0 0 12 12 0 24 24 0 36 36 0 48 48 0 60 60 

; Index into DLI's HSCROL table for each boat row. (needed by VBI)
BOAT_HS_TABLE
	.by 0 4 5 0 7 8 0 10 11 0 13 14 0 16 17 0 19 20


; PAL Timer values.  PAL ?? guesses...
; About 7 keys per second.
; KEYSCAN_FRAMES = $07
; based on number of frogs, how many frames between boat movements...
;ANIMATION_FRAMES .byte 25,21,17,14,12,11,10,9,8,7,6,5
; Not really sure what to do about the new model using the 
; BOAT_FRAMES/BOAT_SHIFT lists.
; PAL would definitely be a different set of speeds.


; ==========================================================================
; RESET INPUT SCAN TIMER and ANIMATION TIMER
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

ChefOfJoystickBits            ; Cook STICK0 into the safe stick directions.  Flip input bits.
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

	lda #$FF                      ; Turn off the signal to change screens.
	sta VBICurrentDL
	stx CurrentDL                 ; Let everyone know what is the current screen.

VBIResetDLIChain
	ldy #0
	lda (ThisDLIAddr),y      ; Grab 0 entry from this DLI chain
	sta VDSLST               ; and restart the DLI routine.
	lda #>TITLE_DLI
	sta VDSLST+1

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

; ======== Manage InputScanFrames Delay Counter ========
	lda InputScanFrames          ; Is input delay already 0?
	beq DoAnimateClock           ; Yes, do not decrement it again.
	dec InputScanFrames          ; Minus 1.

; ======== Manage Main code's timer.  Decrement while non-zero. ========
DoAnimateClock
	lda AnimateFrames            ; Is animation countdown already 0?
	beq EndOfClockChecks         ; Yes, do not decrement now.
	dec AnimateFrames            ; Minus 1

EndOfClockChecks

; ======== Manage scrolling the Credits text ========
ScrollTheCreditLine              ; Scroll the text identifying the perpetrators
	dec ScrollCounter            ; subtract from scroll delay counter
	bne EndOfScrollTheCredits    ; Not 0 yet, so no scrolling.
	lda #2                       ; Reset counter to original value.
	sta ScrollCounter

	jsr FineScrollTheCreditLine  ; Do the business.

EndOfScrollTheCredits

; ======== Manage Frog Death  ========
; Here we are at the end of the frame.  If the CURRENT position of the frog 
; is on a moving boat row, then collect the collision information with the "safe" 
; area of the boat (the horizontal lines), and flag the death accordingly.
; The Flag-Of-Death tells the Main code to splatter the frog shape, and 
; start the other activities to announce death.

ManageDeathOfASalesfrog
	lda CurrentDL                ; Get current display list
	cmp #DISPLAY_GAME            ; Is this the Game display?
	bne EndOfDeathOfASalesfrog   ; No. So no collision processing. 

	jsr CheckRideTheBoat         ; Make sure the frog is riding the boat.  Otherwise it dies.

EndOfDeathOfASalesfrog
	sta HITCLR                   ; Always reset the P/M collision bits.


; ======== Manage Boat fine scrolling ========
; Atari scrolling is such low overhead. 
; (Evaluate frog shift if it is on a boat row).
; On a boat row...
; Update a fine scroll register.
; Update a coarse scroll register sometimes.
; Done.   
; Scrolling is practically free.  
; It may be easier only on an Amiga.
ManageBoatScrolling
	lda CurrentDL                 ; Get current display list
	cmp #DISPLAY_GAME             ; Is this the Game display?
	bne EndOfBoatScrolling        ; No.  Skip the scrolling logic.

	ldy #1                        ; Current Row.  Row 0 is the safe zone, no scrolling happens there.

; Common code to each row. 
; Loop through rows.
; If is is a moving row, then check the row's timer/frame counter.
; If the timer is over, then reset the timer and fine scroll the row (moving the frog with it as needed.)
LoopBoatScrolling
	; Need row in X and Y due to different 6502 addressing modes in the timer and scroll functions.
	tya                           ; A = Y, Current Row 
	tax                           ; X = A, Current Row.  dec zeropage,x, darn you cpu.

	lda MOVING_ROW_STATES,y       ; Get the current Row State
	beq EndOfScrollLoop           ; Not a scrolling row.  Go to next row.
	php                           ; Save the + or - status until later.
	; We know this is either left or right, so this block is common code
	; to update the row's speed counter based on the row entry.
	lda CurrentBoatFrames,x       ; Get the row's frame delay value.
	beq ResetBoatFrames           ; If BoatFrames is 0, time to make the donuts.
	dec CurrentBoatFrames,x       ; Not zero, so decrement
	plp                           ; oops.  got to dispose of that.
	jmp EndOfScrollLoop           

ResetBoatFrames
	lda (BoatFramesPointer),y     ; Get master value for row's frame delay
	sta CurrentBoatFrames,x       ; Restart the row's frame speed delay.

	plp                           ; Get the current Row State (again.)
	bmi LeftBoatScroll            ; 0 already bypassed.  1 = Right, -1 (FF) = Left.

	jsr RightBoatFineScrolling    ; Do Right Boat Fine Scrolling.  (and frog X update) 
	jmp EndOfScrollLoop           ; end of this row.  go to the next one.

LeftBoatScroll
	jsr LeftBoatFineScrolling     ; Do Left Boat Fine Scrolling.  (and frog X update) 

EndOfScrollLoop                  ; end of this row.  go to the next one.
	iny                          ; Y reliably has Row.  X was changed.
	cpy #18                      ; Last entry is beach.  Do not bother to go further.
	bne LoopBoatScrolling        ; Not 18.  Process the next row.

EndOfBoatScrolling


; ======== Reposition the Frog (or Splat). ========
; At this point everyone and their cousin have been giving their advice 
; about the frog position.  The main code changed position based on joystick
; input.  The VBI change position if the frog was on a scrolling boat row.
; Here, finally apply the position and move the frog image.
MaintainFrogliness
	lda FrogNewShape             ; Get the new frog shape.
	beq NoFrogUpdate             ; 0 is off, so no movement there at all, so skip all

; ==== Frog and boat position gyrations are done.  ==== Is there actual movement?
SimplyUpdatePosition
	jsr ProcessNewShapePosition ; limit object to screen.  redraw the object.

NoFrogUpdate


; ======== Animate Boat Components ========
; Parts of the boats are animated to look like they're moving 
; through the water.
; When BoatyMcBoatCounter is 0, then animate based on BoatyComponent
; 0 = Right Boat Front
; 1 = Right Boat Back
; 2 = Left Boat Front
; 3 = Left Boat Back
;BoatyFrame         .byte 0  ; counts 0 to 7.
;BoatyMcBoatCounter .byte 2  ; decrement.  On 0 animate a component.
;BoatyComponent     .byte 0  ; 0, 1, 2, 3 one of the four boat parts.
ManageBoatAnimations
	dec BoatyMcBoatCounter           ; subtract from scroll delay counter
	bne ExitBoatyness                ; Not 0 yet, so no animation.

	; One of the boat components will be animated. 
	lda #2                           ; Reset counter to original value.
	sta BoatyMcBoatCounter

	ldx BoatyFrame                   ; going to load a frame, which one?
	jsr DoBoatCharacterAnimation     ; load the frame for the current component.

; Finish by setting up for next frame/component.
	inc BoatyComponent           ; increment to next visual component for next time.
	lda BoatyComponent           ; get it to mask it 
	and #$03                     ; mask it to value 0 to 3
	sta BoatyComponent           ; Save it.
	bne ExitBoatyness            ; it is non-zero, so no new frame counter.

; Whenever the boat component returns to 0, then update the frame counter...
	inc BoatyFrame               ; next frame.
	lda BoatyFrame               ; get it to mask it.
	and #$07                     ; mask it to 0 to 7
	sta BoatyFrame               ; save it.

ExitBoatyness


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
	jmp XITVBV               ; Return to OS.  SYSVBV for Immediate interrupt.



	.align $0100 ; Make the DLIs start in the same page to simplify chaining.

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

TITLE_DLI ; DLI sets COLPF1, COLPF2, COLBK for score text. 
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


; Save 3 bytes.  Use DLI_SPC1 directly in the DLI address table.  duh.

;TITLE_DLI_SPC1 ; How to solve getting from point A to point B with only a low byte address update
;	jmp DLI_SPC1



;==============================================================================
; GAME DLIs
;==============================================================================

; This is called on a blank line and the background should already be black.  
; Since there is no text here (in blank line), it does not matter that COLPF1 is written before WSYNC.
; Since the game fades the screen COLPF1 must pull from the table.

; SCORES 1
; GAME_DLI ; DLI sets COLPF1, COLPF2, COLBK for score text. 
;	jmp Score_DLI

; SCORES 2
; GAME_DLI_1 ; DLI 1 sets COLPF1 for text. (e.g. for fading)
;	jmp TITLE_DLI_5


; A tiny version of TITLE_DLI_4.
; DLI sets only COLPF1 text luminance from the table. (e.g. for fading)
GAME_DLI_1 
	mStart_DLI

	lda COLPF1_TABLE,y   ; Get text color (luminance)
	sta WSYNC
	sta COLPF1           ; write new text luminance.

	jmp Exit_DLI



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
	; Make background temporarily match the playfield drawn this on the next line.
	sta COLBK
	sta COLPF0

	; Make Beach lines full horizontal overscan.  Looks more interesting-er.

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

	; Reset the scrolling water line to normal width. 
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
	lda COLPF3_TABLE,y   ; Get color water (needed for fade-in)
	sta COLPF3

	lda COLBK_TABLE,y   ; Get real background color again. (To repair the color for the Beach background)
	sta WSYNC
	sta COLBK

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


;==============================================================================
; SPLASH DLIs
;==============================================================================

;==============================================================================
; COLPF0_COLBK_DLI                                                     A
;==============================================================================
; The three graphics screen (Saved, Dead Frog, and Game Over) have exactly the
; same display list structure and DLIs.  
; Sets background color and the COLPF0 pixel color.  
; Table driven.  
; Perfectly re-usable for anywhere Map Mode 9 or Blank instructions are 
; being managed.  In the case of blank lines you just don't see the pixel 
; color change, so it does not matter what is in the COLPF0 color table. 
; -----------------------------------------------------------------------------

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


;==============================================================================
; SCORE DLI                                                            A 
;==============================================================================
; Used on multiple screens.  JMP here.
; This is called on a blank line and the background should already be black.  
; Since there is no text here (in blank line), it does not matter that 
; COLPF1 is written before WSYNC.
; Since the game fades the screen COLPF1 must pull from the table.
; -----------------------------------------------------------------------------

Score_DLI
	mStart_DLI

	lda COLPF1_TABLE,y   ; Get text color (luminance)
	sta COLPF1           ; write new text color.

SetBlack_DLI
	lda #COLOR_BLACK     ; Black for background and text background.
	sta WSYNC            ; sync to end of scan line
	sta COLBK            ; Write new border color.
	sta COLPF2           ; Write new background color
	; Fall through to Exit_DLI. . .


;==============================================================================
; EXIT DLI.
;==============================================================================
; Common code called/jumped to by most DLIs.
; JMP here is 3 byte instruction to execute 11 bytes of common DLI closure.
; Update the interrupt pointer to the address of the next DLI.
; Increment the DLI counter used to index the various tables.
; Restore registers and exit.
; -----------------------------------------------------------------------------

Exit_DLI
	lda (ThisDLIAddr), y ; update low byte for next chained DLI.
	sta VDSLST

	inc ThisDLI          ; next DLI.

	mRegRestoreAY

DoNothing_DLI ; In testing mode jump here to not do anything or to stop the DLI chain.
	rti


;==============================================================================
; DLI_SPC1                                                            A 
;==============================================================================
; DLI to set colors for the Prompt line.  
; And while we're here do the HSCROLL for the scrolling credits.
; Then link to DLI_SPC2 to set colors for the scrolling line.
; Since there is no text here (in blank line), it does not matter 
; that COLPF1 is written before WSYNC.
; -----------------------------------------------------------------------------

DLI_SPC1  ; DLI sets COLPF1, COLPF2, COLBK for Prompt text. 
	pha                   ; aka pha

	lda PressAButtonText  ; Get text color (luminance)
	sta COLPF1            ; write new text luminance.

	lda PressAButtonColor ; For background and text background.
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

	pla                   ; aka pla

	rti


;==============================================================================
; DLI_SPC2                                                            A  Y
;==============================================================================
; DLI to set colors for the Scrolling credits.   
; ALWAYS the last DLI on screen.
; -----------------------------------------------------------------------------

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


