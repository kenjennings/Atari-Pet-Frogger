; ==========================================================================
; Pet Frogger
; (c) November 1983 by John C. Dale, aka Dalesoft
;
; ==========================================================================
; Ported (parodied) to Atari 8-bit computers
; November 2018 by Ken Jennings (if this were 1983, aka FTR Enterprises)
;
; --------------------------------------------------------------------------
; Version 00.
; As much of the Pet code is used as possible.
; In most places only the barest minimum of changes are made to deal with
; the differences on the Atari.  Notable changes:
; * References to fixed addresses are changed to meaningful labels.  This
;   includes page 0 variables, and score values.
; * Kernel call $FFD2 is replaced with "fputc" subroutine for Atari.
; * The Atari screen is a full screen editor, so cursor movement off the
;   right edge of the screen is different from the Pet requiring an extra
;   "DOWN" character to move the cursor to next lines.
; * Direct write to screen memory uses different internal code values, not
;   ASCII/ATASCII values.
; * Direct keyboard scanning is different requiring Atari to clear the
;   OS value in order to get the next character.  Also, key codes are
;   different on the Atari (and not ASCII or Internal codes.)
; * Given the differences in clock speed and frame rates between the
;   UK Pet 4032 the game is intended for and the NTSC Atari to which it is
;   ported the timing values in the delays are altered to scale the game
;   speed more like the original on the Pet.
;
; --------------------------------------------------------------------------
; Version 01.  December 2018
; Atari-specific optimizations, though limited.  Most of the program
; still could assemble on a Pet (with changes for values and registers).
; The only doubt I have is monitoring for the start of a frame where the
; Atari could monitor vcount or the jiffy counter.  Not sure how the Pet
; could do this.
; * No IOCB printing to screen.  All screen writing is directly to
;   screen memory.  This greatly speeds up the Title screen and game
;   playfield presentation.  It also shrinks that code a little.
; * New screens added when successfully crossing the river, dying, and
;   for game over.  The Huge text on these screens is constructed from
;   Atari-specific graphics/control characters.
; * Code is reorganized into an event/timer loop operation to modularize
;   game functions and facilitate future Atari-fication and other features.
;
; --------------------------------------------------------------------------


; ==========================================================================
; Random blabbering across the versions of Pet Frogger concerning
; differences between Atari and Pet, and the code considerations:
;
; Version 00 commentary. . . .
; It appears text printing on the Pet treats the screen like a typewriter.
; "Right" cursor movement used to move through full line width will cause
; the cursor to wrap around to the next line.  "Down" also moves to the next
; line.  I don't know for certain, but for printing purposes the program
; code makes it seem like character printing on the PET does not support
; direct positioning of the cursor other than "Home".

; Printing for the Atari version implemented similarly by sending single
; characters to the screen editor, E: device, channel 0.  The Atari'
; full screen editor does things differently.   Moving off the right edge
; of the screen returns the cursor to the left edge of the screen on the
; same line.  (Full screen editor, remember).  Therefore the Atari needs
; an extra "Down" cursor inserted where code expects the cursor on the
; Pet to be on the following line.  It looks like replacing the "Right"
; cursor movements with a blank space should accomplish the same thing,
; but for the sake of minimal changes Version 00 of the port retains the
; Pet's idea of cursor movement.

; Also, depending on how the text is printed the Atari editor can relate
; several adjacent physical lines as one logical line. Great for editing
; text lines longer than 40 characters, not so good when printing wraps the
; cursor from one line to the next.  Printing a character through the end of
; the screen line (aka the right margin) extends the current line as a
; logical line into the next screen line which pushes the content in lines
; below that further down the screen.

; Since some code does direct manipulation of the screen memory, I wonder
; why all the screen code didn't just do the same.  Copy from source to
; destination is easier (or at least more consistent) than printing.
; Changing all the text handling to use direct write is number one on
; the short list of Version 01 optimizations.

; The "BRK" instruction, byte value $00, is used as the end of string
; sentinel in the data.  This conflicts with the Atari character value
; $00 which is the graphics heart that the display uses in place of the
; "o" in "Dalesoft".  The end of string sentinel is changed to the Atari
; End Of Line character, $9B, which does not conflict with anything else
; in the code for printing or data.

; None of the game displays use the entire 25 lines available on the PET.
; The only time the game writes to the entire screen is when it fills the
; screen with the block graphics upon the frog's demise.  This conveniently
; leaves the 25th line free for the "ported by" credit.  But the Atari only
; displays 24 lines of text!?!  Gasp!  Not true.  The NTSC Atari can do up
; to 30 lines of text.  Only the OS printing routines are limited to 24
; lines of text.  The game's 25 screen lines is accomplished on the Atari
; with a custom display list that also designates screen memory starting at
; $8000 which is the same location the Pet uses for its display.
; --------------------------------------------------------------------------

; ==========================================================================
; Ideas for Atari-specific version improvements, Version 01 and beyond!:
; * Remove all printing.  Replace with direct screen writes.  This will
;   be much faster.
; * Timing delay loops are imprecise.  Use the OS jiffy clock (frame
;   counter) to maintain timing, and while we're here make timing tables
;   for NTSC and PAL.
; * Joystick controls.  I hate the keyboard.  The joystick is free and
;   easy on the Atari.
; * Color... Simple version: a DLI for each line could make separate text
;   line colors for beach lines vs boat lines (and credit text lines.)
; * Sound..  Some simple splats, plops, beeps, water sloshings.
; * Custom character set that looks more like beach, boats, water, and frog.
; * Horizontal Fine scrolling text allows smoother movements for the boats.
; * Player Missile Frog. This would make frog placement v the boat
;   positions easier when horizontal scrolling is in effect, not to mention
;   extra color for the frog.
; * Stir, rinse, repeat -- more extreme of all of the above: more color,
;   more DLI, more custom character sets, isometric perspective.
;   Game additions -- pursuing enemies, alternate boat shapes, lily pads,
;   bonus objects to collect, variable/changing boat speeds.  Heavy metal
;   chip tune soundtrack unrelated to frogs that has no good reason for
;   drowning out the game sound effects.  Boss battles.  Online multi-
;   player death matches.  Game Achievements.  In-game micro transaction
;   payments for upgrades and abilities.  Yeah, that's the ticket.
; --------------------------------------------------------------------------

; ==========================================================================
; Atari System Includes (MADS assembler)
	icl "ANTIC.asm" ; Display List registers
	icl "GTIA.asm"  ; Color Registers.
	icl "POKEY.asm" ;
	icl "OS.asm"    ;
	icl "DOS.asm"   ; LOMEM, load file start, and run addresses.
; --------------------------------------------------------------------------

; ==========================================================================
; Macros (No code/data declared)
	icl "macros.asm"
	
; --------------------------------------------------------------------------

; ==========================================================================
; Declare some Page Zero variables.
; The Atari OS owns the first half of Page Zero.

; The Atari load file format allows loading from disk to anywhere in
; memory, therefore indulging in this evilness to define Page Zero
; variables and load directly into them at the same time...
; --------------------------------------------------------------------------
	ORG $88

MovesCars       .word $00 ; = Moves Cars

FrogLocation    .word $00 ; = Pointer to start of Frog's current row in screen memory.
FrogColumn      .byte $00 ; = Frog X coord
FrogRow         .word $00 ; = Frog Y row position (on the playfield not counting score lines)
FrogLastColumn  .byte $00 ; = Frog's last X coordinate
FrogLastRow     .byte $00 ; = Frog's last Y row position
LastCharacter   .byte 0   ; = Last Character Under Frog

FrogSafety      .byte 0   ; = 0 When Frog OK.  !0 == Yer Dead.
DelayNumber     .byte 0   ; = Delay No. (Hi = Slow, Low = Fast)

FrogsCrossed    .byte 0   ; = Number Of Frogs crossed
ScoreToAdd      .byte 0   ; = Number To Be Added to Score

NumberOfChars   .byte 0   ; = Number Of Characters Across
FlaggedHiScore  .byte 0   ; = Flag For Hi Score.  0 = no high score.  $FF = High score.
NumberOfLives   .byte 0   ; = Is Number Of Lives

LastKeyPressed  .byte 0   ; = Remember last key pressed
ScreenPointer   .word $00 ; = Pointer to location in screen memory.
TextPointer     .word $00 ; = Pointer to text message to write.
TextLength      .word $00 ; = Length of text message to write.

; Timers and event control.
DoTimers        .byte $00 ; = 0 means stop timer features.  Return from event polling. Main line
						  ; code would inc DoTimers to make sure accidental animation does not
						  ; occur while the code switches between screens.  This will become
						  ; more important when the game logic is enhanced to an event loop.

; Frame counters are decremented each frame.
; Once they decrement to  0 they enable the related activity.

; In the case of key press this counter value is set whenever a key is
; pressed to force a delay between key presses to limit the speed of
; the frog movement.
KeyscanFrames   .byte $00 ; = KEYSCAN_FRAMES

; In the case of animation frames the value is set from the ANIMATION_FRAMES
; table based on the number of frogs that crossed the river (difficulty level)
AnimateFrames   .byte $00 ; = ANIMATION_FRAMES,X.

; Identify the current screen.  This is what drives which timer/event loop
; features are in effect.  Value is enumerated from SCREEN_LIST table.
CurrentScreen   .byte $00 ; = identity of current screen.

; This is a 0, 1, toggle to remember the last state of
; something. For example, a blinking thing on screen.
ToggleState     .byte 0   ; = 0, 1, flipper to drive a blinking thing.

; Another event value.  Use for counting things for each pass of a screen/event.
EventCounter    .byte 0

; Another event value.  Use for multiple sequential actions in an
; Event/Screen, because I got too lazy to chain a new event into
; sequences.
EventStage      .byte 0

; Game Score and High Score.
MyScore .by $0 $0 $0 $0 $0 $0 $0 $0
HiScore .by $0 $0 $0 $0 $0 $0 $0 $0

; In the event X and/or Y can't be saved on stack, protect them here....
SAVEX = $FE
SAVEY = $FF


; Programmer's unintelligently chosen higher address on Atari
; to account for DOS, etc.
	ORG $5000

	; Label and Credit
	.by "** Thanks to the Word (John 1:1), Creator of heaven, and earth, and "
	.by "semiconductor chemistry and physics which makes all this fun possible. ** "
	.by "Dales" ATASCII_HEART "ft PET FROGGER by John C. Dale, November 1983. ** "
	.by "Atari port by Ken Jennings, December 2018. Version 01. "
	.by "IOCB Printing removed. Everything is direct writes to screen RAM. **"
	.by "Code reworked into timer/event loop organization. **"


; ==========================================================================
; Main Code Parts
	icl "Frogger01ScreenGfx.asm"   ; Physically drawing on the screen

	icl "Frogger01TimerAndIO.asm"  ; Timer, ticktock, countdowns, key I/O.

	icl "Frogger01Events.asm"      ; Run the current event/screen
	icl "Frogger01EventSetups.asm" ; Set Entry criteria for the event/screen

	icl "Frogger01GameSupport"     ; Score and Frog management, Press Any Key

	icl "Frogger01Game.asm"        ; GAMESTART and Game event loop in this file

; --------------------------------------------------------------------------


; ; ==========================================================================
; ; NEW GAME SETUP - See SETUP GAME SCREEN
; ; --------------------------------------------------------------------------
; NewGameSetup
; ;	lda #0
; ;	sta FrogsCrossed       ; Zero the number of successful crossings.

; ;	lda #<[SCREENMEM+$320] ; Low Byte, Frog position.
; ;	sta FrogLocation
; ;	lda #>[SCREENMEM+$320] ; Hi Byte, Frog position.
; ;	sta FrogLocation + 1

; ;	ldy #$13               ; Y = 19 (dec)

; ;	lda #INTERNAL_INVSPACE ; On Atari use inverse space for beach.
; ;	sta LastCharacter      ; Preset the character under the frog.

; ;	lda #$12               ; 18 (dec), number of screen rows of playfield.
; ;	sta FrogRow
; ;	lda #$30               ; 48 (dec), delay counter.
; ;	sta DelayNumber

; ;	jsr ClearGameScores    ; Zero the score.  And high score if not set.

	; rts


; ==========================================================================
; GAME OVER screen.
; Wait for a keypress.
; --------------------------------------------------------------------------
;INSTR ; Per PET Memory Map - Set integer value for SYS/GOTO ?
;	jsr ClearScreen

; Print the lives and score labels in the top two lines of the screen.
;	ldy #PRINT_SCORE_TXT
;	jsr PrintToScreen

; Display the number of frogs that crossed the river.
;	jsr PrintFrogsAndLives

;	ldy #PRINT_GAMEOVER
;	jsr PrintToScreen

;INSTR1
;	jsr WaitKey           ; Atari polling the keyboard.

;	rts





; ; Frog is dead.
; YerADeadFrog
; YRDD
	; lda #INTERNAL_ASTER  ; Atari ASCII $2A/42 (dec) Splattered Frog.
	; sta (FrogLocation),y ; Road kill the frog.
; ;	jsr DELAY1           ; Various pauses....
; ;	jsr DELAY1           ; Should do this with  jiffy counters. future TO DO.
	; jsr FILLSC           ; Fill screen with inverse blanks.

; ; Print the dead frog prompt.
; ;	ldy #PRINT_YRDDTX
	; jsr PrintToScreen



; Decide   G A M E   O V E R-ish

; DecideGameOver
; GAMEOV
	; jsr PRITSC           ; update display.
	; jsr DELAY1
	; dec NumberOfLives    ; subtract a life.
	; lda NumberOfLives
	; cmp #0               ; 0 lives left means
	; beq GOV              ; definitely game over.
	; lda #$FF
	; sta FlaggedHiScore   ; flag the high score
	; jmp START1

; VerilyISayGameOver
; GOV
	; lda #$FF
	; sta CH    ; Atari.  Make sure key is cleared.
;	jmp GOVER ; G A M E   O V E R


; FrogWins
	; inc FrogsCrossed     ; Add to frogs successfully crossed the rivers.
	; jsr FILLSC           ; Update the score display

; FrogWins1 ; Print the frog wins text.
; ;	ldy #PRINT_FROGTXT
	; jsr PrintToScreen

; FrogWins2  ; More score maintenance.   and delays.
	; jsr SCORE
; ;	jsr PRITSC
; ;	jsr DELAY1
	; jmp NEXTFR




; FILLSC  ; Setup pointer to screen. then fill screen
	; lda #<[SCREENMEM+$50]  ; point to screen memory +80 bytes (2 lines from top)
	; sta ScreenPointer
	; lda #>[SCREENMEM+$50]
	; sta ScreenPointer+1

; ; This was inside FILL, but only needs to be done once before the loop
	; ldy #0
; FILL ; Fill screen with the "beach" characters
	; lda #INTERNAL_INVSPACE ; Atari beach character is inverse space.
	; sta (ScreenPointer),y
	; lda ScreenPointer      ; Increment
	; clc                    ; the
	; adc #1                 ; pointer
	; sta ScreenPointer      ; to
	; lda ScreenPointer+1    ; screen
	; adc #0                 ; memory.
	; sta ScreenPointer+1    ; You know, inc lowbyte, bne FILL works instead of adc.
	; cmp #>[SCREENMEM+$400] ; Did high byte reach $8400 (screen memory + 1K)?
	; bne FILL               ; Nope, continue filling.

; ; Setup for score update.
	; ldx #4
	; lda #5

	; stx NumberOfChars      ; Index into "00000000" to add the score.
	; sta ScoreToAdd         ; Add 5 which represents "500" to the score.  Don't need 10s or 1s values, since they are 0.

	; jsr PRINT2             ; Display frogs count
	; ldy #0
	; rts


; ; ==========================================================================
; ; Update starting frog position.
; ; --------------------------------------------------------------------------
; NEXTFR
	; lda DelayNumber        ; Subtract 3 from delay number...
	; sec
	; sbc #3
	; sta DelayNumber

; START1 ; Manage frog's starting postion.
	; lda #<[SCREENMEM+$320] ; Set Frog Location pointer to $8320
	; sta FrogLocation
	; lda #>[SCREENMEM+$320]
	; sta FrogLocation + 1

	; jsr PRINTSC
	; jsr MOVESC

	; lda #INTERNAL_INVSPACE ; Atari: Beach character
	; sta LastCharacter      ; Prep space under frog

	; lda #INTERNAL_O        ; Atari: using "O" as the frog shape.

	; ldy #$13               ; Y = 19 (dec) the middle of screen
	; sta (FrogLocation),y   ; Erase Frog starting position.
	; lda #$12               ; A = 18 (dec)
	; sta FrogRow       ; Save as number of rows to jump

	; jmp KEY                ; GOTO Key input



; ; ==========================================================================
; ; Game Over - Prompt to go again.
; ; --------------------------------------------------------------------------
; GOVER
	; ldy #0

; GOVER1                 ; Print the go again message.
; ;	ldy #PRINT_OVER
	; jsr PrintToScreen

; GOVER2
	; jsr WaitKey        ; For Atari, wait for a key press.  returned in A
	; cmp #KEY_Y         ; keyboard code for Y
	; bne GOVER3         ; Not "Y".

	; jsr HISC           ; Manage high score
	; lda #$FF           ; Re-init a few things. . . .
	; sta FlaggedHiScore ;
	; lda #0
	; sta FrogsCrossed
	; lda #3
	; sta NumberOfLives
	; jmp START          ; Back to start.

; GOVER3
	; jsr INSTR          ; Display instructions.
	; jsr HISC           ; Manage high score
	; lda #$FF
	; sta FlaggedHiScore ; Re-init a few things. . . .
	; lda #3
	; sta NumberOfLives
	; jmp START          ; Back to start.






; ==========================================================================
; When a custom character set is used, it would go here:
; --------------------------------------------------------------------------

;	ORG $7800 ; 1K from $7800 to $7BFF
;CHARACTERSET


; ==========================================================================
; Custom Character Set Planning . . . **Minimum setup.
;
;  1) **Frog
;  2) **Boat Front Right
;  3) **Boat Back Right
;  4) **Boat Front Left
;  5) **Boat Back Left
;  6) **Boat Seat
;  7) **Splattered Frog.
;  8)   Waves 1
;  9)   Waves 2
; 10)   Waves 3
; 11) **Beach 1
; 12)   Beach 2
; 13)   Beach 3
;
; --------------------------------------------------------------------------


; ==========================================================================
; Force the Atari to impersonate the PET 4032 by setting the 40-column
; text mode memory to the same fixed address.  This minimizes the
; amount of code changes for screen memory.
;
; But, first we need a 25-line ANTIC Mode 2 text screen which means a
; custom display list.
;
; The Atari OS text printing is not being used, therefore the Atari screen
; editor's 24-line limitation is not an issue.
; --------------------------------------------------------------------------

	ORG $7FD8  ; $xxD8 to xxFF - more than enough space for Display List

DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_8, DL_BLANK_4 ; 20 blank scan lines.
	mDL_LMS DL_TEXT_2,SCREENMEM              ; Mode 2 text and Load Memory Scan for text/graphics
	.rept 24
		.byte DL_TEXT_2                      ; 24 more lines of Mode 2 text.
	.endr
	.byte DL_JUMP_VB
	.word DISPLAYLIST


; ==========================================================================
; Make Screen memory the same location the Pet uses for screen memory.
; --------------------------------------------------------------------------
	ORG $8000

SCREENMEM


; ==========================================================================
; Inform DOS of the program's Auto-Run address...
; GAMESTART is in the "Game.asm' file.
; --------------------------------------------------------------------------
	mDiskDPoke DOS_RUN_ADDR, GAMESTART


	END

