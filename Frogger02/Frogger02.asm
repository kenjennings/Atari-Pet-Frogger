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
; Version 02.  December 2018
; The design principle continues to maintain the original presentation 
; of a full screen of basic text.  (In Atari terms, this is ANTIC mode 2, 
; or OS mode 0).  Everything else in the game is subject to Atari-fication.
; * Color.  Every line of the text mode has a DLI to set background color
;   and the foreground text luminance.  The color is also used as an 
;   animation tool on the screens for dead frog, game over, and saving 
;   a frog.
; * Joystick controller input.  Game controller input is a standard for
;   Atari games.  Say goodbye to the keyboard.  
; * Sound.  Add at least simple sound effects for water/boats moving, 
;   frog jumping, frog dying, rescuing a frog, joystick input.
; * Custom character set to make the frog look like a frog, and boats 
;   look like plus other graphics enhancements.
; * Formalize game timing by implementing deferred vertical blank 
;   interrupt to maintain the game activity and timings.
; * Screen memory is no longer declared at the same location as on the 
;   Pet computer, and due to display lists is no longer contiguous RAM.
; * Display List LMS updates present the information on screen. 
;   Displayed items can be presented by updating a few display list 
;   LMS pointers rather than bulk movement of data through screen memory.
;   This is also used to move the boats around the screen by coarse 
;   scrolling through the LMS.  This permits the screen memory to be
;   non-contiguous, and data can then be aligned in memory pages allowing
;   code to update either high byte or low byte of addresses.  Since the 
;   frog is a character on screen it must move through screen memory 
;   and so the game still requires six groups of beaches and boats 
;   separately declared in memory.
;
; --------------------------------------------------------------------------


; ==========================================================================
; Random blabbering across the versions of Pet Frogger concerning
; differences between Atari and Pet, and the code considerations:
;
; Version 00 commentary. . . . . . . . . . . . . . . . . . . . . . . . 
; It appears text printing on the Pet treats the screen like a typewriter.
; "Right" cursor movement the Pet uses to move through the full line 
; width will cause the cursor to wrap around to the next line.  "Down" also
; moves to the next line.  I don't know for certain, but for printing 
; purposes the program code makes it seem like character printing on the 
; Pet does not support direct positioning of the cursor other than "Home".

; Printing for the Atari version is implemented similarly by sending single
; characters to the screen editor, E: device, channel 0.  The Atari's
; full screen editor does things differently.   Moving off the right edge
; of the screen returns the cursor to the left edge of the screen on the
; same line.  (Remember, full screen editor).  Therefore the Atari needs
; an extra "Down" cursor inserted where code expects the cursor on the
; Pet to be on the following line.  It also appears that replacing the 
; "Right" cursor movements with a blank space should accomplish the same 
; thing on the Atari, but for the sake of minimal changes Version 00 of the 
; port retains the Pet's idea of cursor movement.

; Also, depending on how the text is printed the Atari editor can relate
; several adjacent physical lines as one logical line. Great for editing
; text lines longer than 40 characters, not so good when printing wraps the
; cursor from one line to the next.  Printing a character through the end of
; the screen line (aka the right margin) extends the current line as a
; logical line into the next screen line which pushes the content in the 
; subsequent lines below further down the screen.

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
; displays 24 lines of text!?!  Gasp!  Not true.  The Atari can do up to
; 30 lines of text (240 scan lines).  Only the OS printing routines are 
; limited to 24 lines of text.  The game's 25 line screen is accomplished 
; on the Atari with a custom display list that also designates screen 
; memory starting at $8000 which is the same location used by the Pet.
;
; --------------------------------------------------------------------------
;
; Version 01 commentary. . . . . . . . . . . . . . . . . . . . . . . . 
; "Printing" via standard OS I/O has been completely replaced by direct
; writes to screen memory.  This greatly speeds up the game screen 
; and title screen presentation.
;
; Having entirely rewritten the game logic, the new modular nature 
; made it easy to add new screens and to manage animated transitions 
; between screens.  There are new screens with huge text built of 
; graphic control characters for when a frog dies, a frog is saved, 
; and when the game is over.
;
; The high score is maintained in real-time with the player's score.
; 
; The only thing that is really Atari-specific is monitoring the vertical
; blank.  Not sure how/if this could be done on the Pet.  The rest of the 
; code is still pretty generic 6502 with screen memory at the Pet's
; standard location, $8000.  It should be easily portable back to the 
; Pet by changing the character and key codes.
; 
; Monitoring the vertical blank allows for more varied control of timing. 
; The boat speeds are easily managed with a loop that relates the number 
; of frogs saved to a frame count for delays.  Note that the code does 
; not re-implement the CPU loop by waiting on frame updates.  Instead, it 
; maintains counters during each frame and when counters reach 0 then the 
; event (aka moving boats or accepting new input) is permitted.  This 
; is effectively (cooperative) multitasking vaguely like an event loop.
;
; --------------------------------------------------------------------------
;
; Version 02 commentary. . . . . . . . . . . . . . . . . . . . . . . . 
; Adding color was essentially trivial.  A table-driven Display List 
; Interrupt routine sets a new background color and text luminance value 
; for each of the 25 text lines. A Vertical Blank interrupt enforces the 
; DLI state to start at 0 for every frame.  A rough prototype showing 
; colorized displays was added to Version 01 code in just a few hours.
;
; Now that there is a VBI running various other timing controls can be 
; formally, put into the VBI rather than using looping code that detects 
; the start of a TV frame.
;
; Further use of the color indirection will eliminate the need to maintain
; and write normal text and inverse text in screen memory to make blinking 
; text.  The game can simply update the colors for that line of text to 
; make it appear to blink.
;
; Given the Atari's significant graphics indirection capabilities there is 
; no need to draw a screen to present it.  The data to supply the graphics 
; is already in memory.  Properly arranging the data will allow the Atari 
; to display the data directly as screen data.  This eliminates the need 
; to have separate data and screen memory, and also eliminates the need 
; for the supporting code to copy the data to the screen.
;
; Aaaand, the Atari has more than one way to do this.  First, we could 
; update the LMS addresses in the Display List to point to each line of 
; data for screen memory.  Changing the screen (or just the screen 
; contents) is reduced to writing a two-byte pointer for each line in the 
; Display List instead of writing 40 bytes for each line to screen memory. 
; And where there are blank lines or otherwise duplicate data the LMS can 
; point to the same screen data for each line. 
;
; The other way to do this is to have a separate Display List for each 
; screen.  This reduces changing the screen to writing one address for 
; the entire screen.  
;
; We're mixing these two methods.  Each screen will have its own Display 
; List with color tables.  Change the display list pointer and the entire 
; screen changes.  The game screen will also use updates to the the LMS 
; for each moving boat line to coarse scroll the boat data without moving 
; the boats in screen memory.
;
; Since the frog must move in screen memory, there still must be separate 
; data for each line of boats and beaches.  In a future version when the 
; frog is a Player/Missile object independent from screen data then it 
; will be possible to reduce the boats to one line for left and one for 
; right and re-use the data for each set of lines.
;
; --------------------------------------------------------------------------

; ==========================================================================
; Ideas for Atari-specific version improvements, Version 01 and beyond!:
; * Remove all printing.  Replace with direct screen writes.  This will
;   be much faster. (IMPLEMENTED, V01)
; * Timing delay loops are imprecise.  Use the OS jiffy clock (frame
;   counter) to maintain timing, and while we're here make timing tables
;   for NTSC and PAL. (IMPLEMENTED, V01)  (V02 formalized this to a real
;   Vertical Blank Interrupt service routine.)
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
	ORG $82

; Data read by the Display List Interrupts to change the colors for each line.

COLPF2_TABLE ; Text background color. ; Default Green
	.rept 25
		.byte COLOR_GREEN 
	.endr

		
COLPF1_TABLE ; Text color (luminance) ; default all to $0A/10 (dec)
	.rept 25
		.byte $0A  
	.endr

ThisDLI         .byte $00   ; = counts the instance of the DLI for indexing into the color tables. 

MovesCars       .word $00   ; = Moves Cars

FrogLocation    .word $0000 ; = Pointer to start of Frog's current row in screen memory.
FrogColumn      .byte $00   ; = Frog X coord (logical to screen)
FrogRealColumn1 .byte $00   ; = Frog physical offset into current row
FrogRealColumn2 .byte $00   ; = Frog physical offset into current row (second at +40 for scrolling)

FrogRow         .byte $00   ; = Frog Y row position (in the beach/boat playfield not counting score lines)
LastCharacter   .byte 0     ; = Last Character Under Frog

FrogSafety      .byte 0     ; = 0 When Frog OK.  !0 == Yer Dead.
DelayNumber     .byte 0     ; = Delay No. (Hi = Slow, Low = Fast)

FrogsCrossed    .byte 0     ; = Number Of Frogs crossed
ScoreToAdd      .byte 0     ; = Number To Be Added to Score

NumberOfChars   .byte 0     ; = Number Of Characters Across
FlaggedHiScore  .byte 0     ; = Flag For Hi Score.  0 = no high score.  $FF = High score.
NumberOfLives   .byte 0     ; = Is Number Of Lives

LastKeyPressed  .byte 0     ; = Remember last key pressed
ScreenPointer   .word $0000 ; = Pointer to location in screen memory.
TextPointer     .word $0000 ; = Pointer to text message to write.
TextLength      .word $0000 ; = Length of text message to write.

; Timers and event control.
; Frame counters are decremented each frame.
; Once they decrement to  0 they enable the related activity.

; After processing input (from the joystick) this is the number of frames
; to count before new input is accepted.  This prevents moving the frog at 
; 60 fps and compensates for any jitter/uneven toggling of the joystick 
; bits by flaky controllers.
InputScanFrames   .byte $00 ; = INPUTSCAN_FRAMES
InputStick        .byte $00 ; = STICK0 cooked to turn on direction bits.
; And then it is safe to use STRIG0 directly for the joystick button.

; In the case of animation frames the value is set from the ANIMATION_FRAMES
; table based on the number of frogs that crossed the river (difficulty level)
AnimateFrames   .byte $00 ; = ANIMATION_FRAMES,X.

; Animation counter for scrolling the credit line. when it reaches 0, then scroll.
ScrollCounter   .byte 8
; Current low byte of the LMS value for scrolling the credit line.
ScrollCredit    .byte <SCROLLING_CREDIT 
; Pointer to the current display LMS for the credits.
CurrentCreditLMS .word SCROLL_CREDIT_LMS0

; Identify the current screen.  This is what drives which timer/event loop
; features are in effect.  Value is enumerated from SCREEN_LIST table.
CurrentScreen   .byte $00 ; = identity of current screen.

; A display number written here by main code directs the VBI to update the 
; screen pointers and the pointers to the color tables. Updated by VBI to 
; $FF when update is completed. 
VBICurrentDL    .byte $FF ; = Direct VBI to change screens. 

; The actual display in use. Updated by VBI from the input provided by 
; VBICurrentDL to let main code  know the the current physical display.
CurrentDL        .byte $FF
CurrentDLPointer .word $0000 ; the address of the Display list.  a copy of the OS pointer.

; Pointer to the current color table sources in use.
COLPF2Pointer   .word $0000
COLPF1Pointer   .word $0000

; Pointer to an LMS instructions in the game screen.
PlayfieldLMSPointer .word $0000

; Scrolling offsets for LMS in the playfield.
; All scroll data occupies page data from  0 to 79. 
; Left scroll moves from LMS offset 0 to 39 
; Right scroll moves from LMS offset 39 to 0
CurrentRightOffset .byte $00
CurrentLeftOffset  .byte $00

; This is a 0, 1, toggle to remember the last state of
; something. For example, a blinking thing on screen.
ToggleState     .byte 0   ; = 0, 1, flipper to drive a blinking thing.

; Another event value.  Use for counting things for each pass of a screen/event.
EventCounter    .byte 0
EventCounter2   .byte 0 ; Used for other counting, such as long event counting.


; Game Score and High Score.
; This stays here and is copied to screen memory, because the math could
; temporarily generate a non-numeric character when there is carry, and I 
; don't want that (possibly) visible on the screen however short it may be.

MyScore .sb "00000000" 
HiScore .sb "00000000" 

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
	.by "Atari port by Ken Jennings, January 2019. Version 02. "
	.by "Added color with DLIs, joystick interface **"
	.by "Event loop properly managed by VBI **"


; ==========================================================================
; Include the Main Code Parts
; --------------------------------------------------------------------------

	icl "Frogger02Game.asm"         ; GAMESTART and Game event loop in this file
	icl "Frogger02GameSupport.asm"  ; Score and Frog management, Press Any Key

	icl "Frogger02EventSetups.asm"  ; Set Entry criteria for the event/screen
	icl "Frogger02Events.asm"       ; Run the current event/screen

	icl "Frogger02TimerAndIO.asm"   ; Timer, tick tock, countdowns, key I/O, VBI, DLI 

	icl "Frogger02ScreenGfx.asm"    ; Physically drawing on the screen

; ==========================================================================
; Graphics assets.  
; To make sure these won't accidentally cross an ANTIC hardware limit 
; these need to be aligned per ANTIC specs.
; --------------------------------------------------------------------------

	icl "Frogger02CharSet.asm"      ; Aligns to 1K and defines CHARACTER_SET

	icl "Frogger02DisplayLists.asm" ; Aligns for display lists.

	icl "Frogger02ScreenMemory.asm" ; Aligns for screen memory

; --------------------------------------------------------------------------


; ==========================================================================
; Inform DOS of the program's Auto-Run address...
; GAMESTART is in the "Game.asm' file.
; --------------------------------------------------------------------------
	mDiskDPoke DOS_RUN_ADDR, GAMESTART


	END

