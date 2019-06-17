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

WOBBLEX_SPEED    = 2   ; Speed of flying objects on Title and Game Over.
WOBBLEY_SPEED    = 3   ; Speed of flying objects on Title and Game Over.

FROG_WAKE_SPEED  = 150 ; Initial delay about 2 sec for frog corpse '*' viewing/mourning
DEAD_FADE_SPEED  = 4   ; Fade the game screen to black for Dead Frog
DEAD_CYCLE_SPEED = 5   ; Speed of color animation on Dead screen

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
; CHECK INPUT
; ==========================================================================
; Check for input from the controller....
;
; Eliminate Down direction.
; Eliminate conflicting directions.
; Add trigger to the input stick value.
;
; STICK0 Joystick bits that matter:  
; ----1111  OR  "NA NA NA NA Right Left Down Up".
; A zero value bit means joystick is pushed in that direction.
; 
; Wow, but this became a sloppy mess of bit flogging.
; But it does replace several functions of key reading shenanigans.
; Description of the over-engineered bit twiddling below:
; 
; Cook the bits to turn on the directions we care about and zero the other
; bits, therefore, if resulting stick value is 0 then it means no input.
; - Down input is ignored (masked out).
; - Since up movement is the most likely to result in death the up movement
;    must be exclusively up.  If a horizontal movement is also on at the
;    same time then the up movement will be masked out.
;
; Arcade controllers with individual buttons would allow accidentally 
; (or intentionally) pushing both left and right directions at the same 
; time.  To avoid unnecessary fiddling with the frog in this situation 
; eliminate both motions if both are engaged.
;
; STRIG0 Button
; 0 is button pressed., !0 is not pressed.
; If STRIG0 input then set bit $10 (OR ---1----  for trigger.
;
; Return  A  with InputStick value of cooked Input bits where the 
; direction and trigger set are 1 bits.  
; Resulting Bit values:   
; 00011101  OR  "NA NA NA Trigger Right Left NA Up"
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
; Frame-critical tasks:
; Force steady state of DLI.
; Manage switching displays.
;
; Optional Input: VBICurrentDL  
; ID number for new Display sent by Main.  Reset to -1 by VBI.
; DISPLAY_TITLE = 0
; DISPLAY_GAME  = 1
; DISPLAY_WIN   = 2
; DISPLAY_DEAD  = 3
; DISPLAY_OVER  = 4
;
; Output: CurrentDL 
; Set by VBI to the display number when the Display is changed.
;==============================================================================

MyImmediateVBI

; ======== Manage Changing Display List ========
	lda VBICurrentDL            ; Did Main code signal to change displays?
	bmi VBIResetDLIChain        ; -1, No, just restore current DLI chain.

VBISetupDisplay
	tax                         ; Use VBICurrentDL  as index to tables.

	lda DISPLAYLIST_LO_TABLE,x  ; Copy Display List Pointer
	sta SDLSTL                  ; for the OS
	lda DISPLAYLIST_HI_TABLE,x
	sta SDLSTH

	lda DLI_LO_TABLE,x          ; Copy Display List Interrupt chain table starting address
	sta ThisDLIAddr
	lda DLI_HI_TABLE,x
	sta ThisDLIAddr+1

	lda GPRIOR_TABLE,x          ; Title/Game/Splash displays use P/M objects differently.
	sta GPRIOR

	stx CurrentDL               ; Let Main know this is now the current screen.
	lda #$FF                    ; Turn off the signal from Main to change screens.
	sta VBICurrentDL

VBIResetDLIChain
	ldy #0
	lda (ThisDLIAddr),y         ; Grab 0 entry from this DLI chain
	sta VDSLST                  ; and restart the DLI routine.
	lda #>TITLE_DLI
	sta VDSLST+1

	iny                         ; !!! Start at 1, because entry 0 provided the starting DLI address !!!
	sty ThisDLI 
	; This means indexed pulls from the color tables are +1 from the current DLI.

; Stage colors and hscrol for first DLI into page 0 
; to make selecting these faster during the DLI.
	jsr SetupAllColors

ExitMyImmediateVBI

	jmp SYSVBV ; Return to OS.  XITVBV for Deferred interrupt.



;==============================================================================
;                                                           MyDeferredVBI
;==============================================================================
; Deferred Vertical Blank Interrupt.
;
; Tasks that tolerate more laziness.  In fact, most of the screen activity
; occurs here.
;
; Manage death of frog. 
; Fine Scroll the boats.
; Update Player/Missile object display.
; Perform the boat parts animations.
; Manage timers and countdowns.
; Scroll the line of credit text.
; Blink the Press Button prompt if enabled.
;==============================================================================

MyDeferredVBI

; ======== Manage Frog Death  ========
; Here we are at the end of the frame.  Collision is checked first.  
; Actual movement processing happens last.
; If the CURRENT position of the frog is on a moving boat row, 
; then go collect the collision information with the "safe" area of the boat 
; (the horizontal lines).
; The collision check code will flag the death accordingly.
; The Flag-Of-Death (FrogSafety) tells the Main code to splatter the frog 
; shape, and start the other activities to announce death.

ManageDeathOfASalesfrog
	lda CurrentDL                ; Get current display list
	cmp #DISPLAY_GAME            ; Is this the Game display?
	bne EndOfDeathOfASalesfrog   ; No. So no collision processing. 

	ldx FrogRow                  ; What screen row is the frog currently on?
	lda MOVING_ROW_STATES,x      ; Is the current Row a boat row?
	beq EndOfDeathOfASalesfrog   ; No. So skip collision processing. 

	jsr CheckRideTheBoat         ; Make sure the frog is riding the boat.  Otherwise it dies.

EndOfDeathOfASalesfrog
	sta HITCLR                   ; Always reset the P/M collision bits for next frame.


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


; ======== Manage InputScanFrames Delay Counter ========
DoManageInputClock
	lda InputScanFrames          ; Is input delay already 0?
	beq DoAnimateClock           ; Yes, do not decrement it again.
	dec InputScanFrames          ; Minus 1.

; ======== Manage Main code's timer.  Decrement while non-zero. ========
; It is MAIN's job to act when the timer is 0, and reset it if needed.
DoAnimateClock
	lda AnimateFrames            ; Is animation countdown already 0?
	beq DoAnimateClock2          ; Yes, do not decrement now.
	dec AnimateFrames            ; Minus 1

; ======== Manage Another Main code timer.  Decrement while non-zero. ========
; It is MAIN's job to act when the timer is 0, and reset it if needed.
DoAnimateClock2
	lda AnimateFrames2           ; Is animation countdown already 0?
	beq DoAnimateEyeballs        ; Yes, do not decrement now.
	dec AnimateFrames2           ; Minus 1

; ======== Manage Frog Eyeball motion ========
; If the timer is non-zero, Change eyeball position and force redraw.
DoAnimateEyeballs
	lda FrogRefocus              ; Is the eye move counter greater than 0?
	beq EndOfClockChecks         ; No, Nothing else to do here.
	dec FrogRefocus              ; Subtract 1.
	bne EndOfClockChecks         ; Has not reached 0, so nothing left to do here.
	lda #1                       ; Inform the Frog renderer  
	sta FrogEyeball              ; to use the default/centered eyeball.
	sta FrogUpdate               ; Mandatory redraw.

EndOfClockChecks


; ======== Reposition the Frog (or Splat). ========
; At this point everyone and their cousin have been giving their advice 
; about the frog position.  The main code changed position based on joystick
; input.  The VBI change position if the frog was on a scrolling boat row.
; Here, finally apply the position and move the frog image.
MaintainFrogliness
	lda FrogUpdate               ; Nonzero means something important needs to be updated.
	bne SimplyUpdatePosition

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
; thus only one part of a boat is animated on any given vertical blank.
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


; ======== Manage scrolling the Credits text ========
ScrollTheCreditLine              ; Scroll the text identifying the perpetrators
	dec ScrollCounter            ; subtract from scroll delay counter
	bne EndOfScrollTheCredits    ; Not 0 yet, so no scrolling.
	lda #2                       ; Reset counter to original value.
	sta ScrollCounter

	jsr FineScrollTheCreditLine  ; Do the business.

EndOfScrollTheCredits


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


TITLE_DLI_BLACKOUT  ; DLI Sets background to Black for blank area.
;	mStart_DLI
	pha
;	jmp SetBlack_DLI
	lda #COLOR_BLACK     ; Black for background and text background.
	sta WSYNC            ; sync to end of scan line
	sta COLBK            ; Write new border color.
	sta COLPF2           ; Write new background color

;	jmp Exit_DLI_WithoutYPrep

	tya
	pha
	ldy ThisDLI

	jmp SetupAllOnNextLine_DLI ; Load colors for next DLI and end.


; Since there is no text in blank lines, it does not matter that COLPF1 is written before WSYNC.
; Also, since text characters are not defined to the top/bottom edge of the character it is 
; safe to change COLPF1 in a sloppy way.

TITLE_DLI_4 ; DLI sets COLPF1 text luminance from the table, COLBK and COLPF2 to start a text block.
TITLE_DLI_TEXTBLOCK
	mStart_DLI

;	lda COLPF1_TABLE,y   ; Get text color (luminance)
	lda ColorPf1         ; Get text luminance from zero page.
	sta COLPF1           ; write new text luminance.

;	lda COLBK_TABLE,y   ; For Text Background.
	lda ColorBak        ; Get background from zero page.
	sta WSYNC
	sta COLBK
	sta COLPF2

;	jmp Exit_DLI

	jmp SetupAllOnNextLine_DLI ; Load colors for next DLI and end.


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

;Also apparently not used?
;
;GAME_DLI_1 
;	mStart_DLI

;	lda COLPF1_TABLE,y   ; Get text color (luminance)
;	sta WSYNC
;	sta COLPF1           ; write new text luminance.

;;	jmp Exit_DLI

;;	jmp SetupAllOnNextLine_DLI  ; iny, and load all colors.



; BEACH 0
; Sets colors for the first Beach line. 
; This is a little different from the other transitions to Beaches.  
; Here, ALL colors must be set. 
; In the later transitions from Boats to the Beach  COLPF0 should 
; be setup as the same color as in the previous line of boats.
; COLBAK is temporarily set to the value of COLPF0 to make a full
; scan line of "sky" color matching the COLPF0 sky color for the 
; beach line that follows.
; COLBAK's real land color is set last as it is the color used in the 
; lower part of the beach characters.
;
; Set Wide screen for Beach.

GAME_DLI_BEACH0 
GAME_DLI_2 ; DLI 2 sets COLPF0,1,2,3,BK for first Beach.
	; custom startup to deal with a possible timing problem.
	pha 
	; for the extra scan line get the sky color for the Beach 
	; (usually prior water color) instead of COLBK.
	lda ColorPF0 ; from Page 0.
	sta WSYNC
	; Top of the line is sky or blue water from row above.   
	; Make background temporarily match the playfield drawn this on the next line.
	sta COLBK
	sta COLPF0

; Make Beach lines full horizontal overscan.  Looks more interesting-er.
;	lda #ENABLE_DL_DMA|PM_1LINE_RESOLUTION|ENABLE_PM_DMA|PLAYFIELD_WIDTH_WIDE
;	sta DMACTL

	tya
	pha
	ldy ThisDLI

	jmp LoadAlmostAllColors_DLI


; After much hackery, code gymnastics, and refactoring, these two 
; routines for boats now work out to the same code.

; Boats Right 1, 4, 7, 10 . . . .
; Sets colors for the Boat lines coming from a Beach line.
; This starts on the Beach line which is followed by one blank scan line 
; before the Right Boats.

; Boats Left 2, 5, 8, 11 . . . .
; Sets colors for the Left Boat lines coming from a Right Boat line.
; This starts on the ModeC line which is followed by one blank scan line 
; before the Left Boats.
; The Mode C line uses only COLPF0 to match the previous water, and the 
; following "sky".
; Therefore, the color of the line is automatically matched to both prior and 
; the next lines without changing COLPF0.  (For the fading purpose COLPF0
; does need to get reset on the following blank line. 

; HSCROL is set early for the boats.  Followed by all color registers.
 
; Set Wide screen for Beach?

GAME_DLI_BEACH2BOAT ; DLI sets HS, BK, COLPF3,2,1,0 for the Right Boats.
GAME_DLI_BOAT2BOAT  ; DLI sets HS, BK, COLPF3,2,1,0 for the Left Boats.

	mStart_DLI

	lda NextHSCROL    ; Get boat fine scroll.
	pha
	
	lda ColorBak
	sta WSYNC
	sta COLBK
	
	pla 
;	lda NextHSCROL    ; Get boat fine scroll.
	sta HSCROL        ; Ok to set now as this line does not scroll.



; Reset the scrolling water line to normal width
;	lda #ENABLE_DL_DMA|PM_1LINE_RESOLUTION|ENABLE_PM_DMA|PLAYFIELD_WIDTH_NORMAL
;	sta WSYNC
;	sta DMACTL

	jmp LoadAlmostAllBoatColors_DLI ; set colors.  setup next row.




; Boats Left 2, 5, 8, 11 . . . .
; Sets colors for the Left Boat lines coming from a Right Boat line.
; This starts on the ModeC line which is followed by one blank scan line 
; before the Left Boats.
; The Mode C line uses only COLPF0 to match the previous water, and the 
; following "sky".
; Therefore, the color of the line is automatically matched to both prior and 
; the next lines without changing COLPF0.  (For the fading purpose it does 
; need to get reset on the following blank line. 
; HSCROL is set early for the boats.  Followed by all color registers.
 
; Set Wide screen for Beach?

;GAME_DLI_BOAT2BOAT ; DLI sets HS, BK, COLPF3,2,1,0 for the Left Boats.

;	mStart_DLI

;	lda NextHSCROL    ; Get boat fine scroll.
;	sta HSCROL        ; Ok to set now as this line does not scroll.

;	lda ColorBak
;	sta WSYNC
;	sta COLBK

;	jmp LoadAlmostAllBoatColors_DLI ; set colors.  setup next row.


; Make Beach lines full horizontal overscan.  Looks more interesting-er.
;	lda #ENABLE_DL_DMA|PM_1LINE_RESOLUTION|ENABLE_PM_DMA|PLAYFIELD_WIDTH_WIDE
;	sta DMACTL


; BEACH 3, 6, 9, 12 . . . .
; Sets colors for the Beach lines coming from a boat line. 
; This is different from line 0, because the DLI starts with only one scan line
; of Mode C pixels (COLPF0) between the boats, and the Beach.
; The line uses only COLPF0 to match the previous water, and the following "sky".
; Therefore, the color of the line is automatically matched to both prior and 
; the next lines without changing COLPF0.  (For the fading purpose it does 
; need to get set. 
; Since the beam is in the middle of an already matching color this opearates
; without WSYNC up front to set all the color registers as quickly as possible. 
; COLBAK can be re-set to its beach color last as it is the color used in the 
; lower part of the characters.
 
; Set Wide screen for Beach?

GAME_DLI_BOAT2BEACH ; DLI sets COLPF1,2,3,COLPF0, BK for the Beach.

	mStart_DLI

	; custom startup to deal with a possible timing problem.
;	pha 

	lda ColorPF0 ; from Page 0.
	; Different from BEACH0, because no WSYNC right here.
	; Top of the line is sky or blue water from row above.   
	; Make background temporarily match the playfield drawn this on the next line.
	sta COLBK
	sta COLPF0

; Make Beach lines full horizontal overscan.  Looks more interesting-er.
;	lda #ENABLE_DL_DMA|PM_1LINE_RESOLUTION|ENABLE_PM_DMA|PLAYFIELD_WIDTH_WIDE
;	sta DMACTL

;	tya
;	pha
;	ldy ThisDLI

	jmp LoadAlmostAllColors_DLI


; ; BOATS 
; ; Startup is beachline + 1 blank
; ; Starts on BEACH line or Blank Line. 
; ; Therefore setup and sync should have time to work
; ; and an entire blank scan line follows before the boats.
; GAME_DLI_3 ; DLI 3 sets COLPF0,1,2,3,BK and HSCROL for Boats.
; ;	mStart_DLI

	; ; custom startup to deal with a possible timing problem.
	; pha 
	; ; for the extra line Get color Rocks (or water color) instead of COLBK
	; lda ColorBak      ; Get color background;  Page 0.
	; pha
	; lda NextHSCROL    ; Get boat fine scroll.

	; sta WSYNC
	; sta HSCROL
	; pla
	; sta COLBK

	; tya
	; pha
	; ldy ThisDLI

;	jmp LoadAllColors_DLI



; GAME_DLI_5 ; Needs to set HSCROL for credits, then call to set text color.  LAST DLI on screen.
	; mRegSaveAY

; ;	lda CreditHSCROL      ; HScroll for credits.
; ;	sta HSCROL

	; jmp DLI_SPC2_SetCredits ; Finish by setting text luminance.


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
	pha

	lda ColorPF1         ; Get text color (luminance)
	pha                  ; Save for after WSYNC

SetBlack_DLI
	lda #COLOR_BLACK     ; Black for background and text background.
	sta WSYNC            ; sync to end of scan line
	sta COLBK            ; Write new border color.
	sta COLPF2           ; Write new background color
	pla
	sta COLPF1           ; write new text color.

; Finish by loading the next DLI's colors.  The second score line preps the Beach.
; This is redundant (useless) (time-wasting) work when not on the game display, 
; but this is also not damaging.
	tya
	pha
	ldy ThisDLI

	jmp SetupAllOnNextLine_DLI ; Load colors for next DLI and end.



;==============================================================================
; EXIT DLI.
;==============================================================================
; Common code called/jumped to by most DLIs.
; JMP here is 3 byte instruction to execute 11 bytes of common DLI closure.
; Update the interrupt pointer to the address of the next DLI.
; Increment the DLI counter used to index the various tables.
; Restore registers and exit.
; -----------------------------------------------------------------------------

Exit_DLI_WithoutYPrep ; Called by code that did not save Y
	tya
	pha
	ldy ThisDLI

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
	ldy #$0C             ; luminance for text.  Hardcoded.  Always visible on all screens.
	lda #COLOR_BLACK     ; color for background.

	sta WSYNC            ; sync to end of scan line

	sty COLPF1           ; Write text luminance for credits.
	sta COLBK            ; Write new border color.
	sta COLPF2           ; Write new background color

	lda CreditHSCROL      ; HScroll for credits.
	sta HSCROL

	lda #<DoNothing_DLI  ; Stop DLI Chain.  VBI will restart the chain.
	sta VDSLST
	lda #>DoNothing_DLI  ; Stop DLI Chain.  VBI will restart the chain.
	sta VDSLST+1

	mRegRestoreAY

	rti

;==============================================================================
; EXIT DLI.
;==============================================================================
; Common code called/jumped to by most DLIs.
; JMP here is 3 byte instruction to execute 11 bytes of common DLI closure.
; Update the interrupt pointer to the address of the next DLI.
; Increment the DLI counter used to index the various tables.
; Restore registers and exit.
; -----------------------------------------------------------------------------

LoadAllColors_DLI

	lda ColorPF0   ; Get color Rocks 1   
	sta COLPF0

LoadAlmostAllColors_DLI
	lda ColorBak   ; Get real background color again. (To repair the color for the Beach background)
	sta WSYNC
	sta COLBK

	lda ColorPF1   ; Get color Rocks 2
	sta COLPF1
	lda ColorPF2   ; Get color Rocks 3 
	sta COLPF2
	lda ColorPF3   ; Get color water (needed for fade-in)
	sta COLPF3



SetupAllOnNextLine_DLI
	iny

SetupAllColors_DLI
	jsr SetupAllColors

	dey

	jmp Exit_DLI


; Called by Beach 2 Boat
LoadAlmostAllBoatColors_DLI
	lda ColorPF1   
	sta COLPF1
	lda ColorPF2   
	sta COLPF2
	lda ColorPF3   
	sta COLPF3
	lda ColorPF0 
	sta COLPF0

	jmp SetupAllOnNextLine_DLI


;==============================================================================
; SET UP ALL COLORS                                                       A  Y
;==============================================================================
; Given value of Y, pull that entry from the color and scroll tables
; and store in the page 0 copies.
; This is called at the end of a DLI to prepare for the next DLI in an attempt
; to optimize the start of the next DLI's using the values.  
; (Because for some reason Altirra is glitching the game screen, but 
; Atari800 seems OK.)
; -----------------------------------------------------------------------------
SetupAllColors
	lda COLPF0_TABLE,y   ; Get color Rocks 1   
	sta ColorPF0
	lda COLPF1_TABLE,y   ; Get color Rocks 2
	sta ColorPF1
	lda COLPF2_TABLE,y   ; Get color Rocks 3 
	sta ColorPF2
	lda COLPF3_TABLE,y   ; Get color water (needed for fade-in)
	sta ColorPF3
	lda HSCROL_TABLE,y   ; Get boat fine scroll.
	sta NextHSCROL
	lda COLBK_TABLE,y    ; Get background color .
	sta ColorBak

	rts

