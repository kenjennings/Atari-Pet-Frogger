; ==========================================================================
; Pet Frogger
; (c) November 1983 by John C. Dale, aka Dalesoft
;
; ==========================================================================
; Ported (parodied) to Atari 8-bit computers 
; November 2018 by Ken Jennings (if this were 1983, aka FTR Enterprises)

; Version 00.  As much of the Pet code is used as possible.  In most 
; places only the barest minimum of changes are made to deal with the
; differences on the Atari.

; ==========================================================================
; Atari System Includes (MADS assembler)
	icl "ANTIC.asm"
	icl "GTIA.asm"
	icl "POKEY.asm"
	icl "OS.asm"
	icl "DOS.asm" ; This provides the LOMEM, start, and run addresses.


; ==========================================================================
; Macros (No code/data declared)
	icl "macros.asm"
;	icl "macros_screen.asm"
;	icl "macros_input.asm"


; ==========================================================================
; SYS init N/A for Atari.   Atari load file format will do it.

; 10 SYS (1280) ; aka $0500
;	*= $0401
;	BYTE $0E, $04, $0A, $00, $9E, $20, $28,  $31, $32, $38, $30, $29, $00, $00, $00


; ==========================================================================
; Declare some Page Zero variables.
; On the Atari we'll move these a bit, since 
; the OS owns the first half of Page Zero.

; $00 - $01 = Moves Cars
; $02 - $03 = Frog Location
; $04       = Number Of Rows
; $06       = Last Character Under Frog
; $07       = Delay No. (Hi = Slow, Low = Fast)
; $08       = Number Of Frogs crossed
; $09       = Number To Be Added to Score
; $0A       = Number Of Characters Across
; $0B       = Flag For Hi Score
; $0C       = Is Number Of Lives

; MovesCars       = $00
; FrogLocation    = $02
; NumberOfRows    = $04
; LastCharacter   = $06
; DelayNumber     = $07
; FrogsCrossed    = $08
; ScoreToAdd      = $09
; NumberOfChars   = $0A
; FlaggedHiScore  = $0B
; NumberOfLives   = $0C
; LastKeyPressed  = $0D

; The Atari load file format allows loading from disk to anywhere in 
; memory, therefore indulging in this evilness to define Page Zero 
; variables and load directly into them at the same time...

	ORG $88

MovesCars       .word $00
FrogLocation    .word $00 
NumberOfRows    .word $00
LastCharacter   .byte 0
DelayNumber     .byte 0
FrogsCrossed    .byte 0
ScoreToAdd      .byte 0
NumberOfChars   .byte 0
FlaggedHiScore  .byte 0
NumberOfLives   .byte 0
LastKeyPressed  .byte 0
ScreenPointer   .word $00

; In the original code the game score and the high score are (oddly) referred 
; to by fixed addresses $4600 and $4610, respectively.  Maybe scoring was 
; added after the fact?  For the sake of my sanity I am declaring equivalent
; space and labeling it for scores.  All occurrences of addresses in code 
; are changed to show the named labels. The evil part is that I'm declaring 
; the values here in Page Zero with everything else.  This cuts three byte 
; instructions down to two byte Page Zero instructions.  Muahahahaha!

; The scores appear to be 16 bytes each. I think.  Based on the difference
; between $4600 and $4610.   So, declaring each as 16 bytes...
MyScore .by $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0
HiScore .by $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0 $0


; ==========================================================================
; Some Atari character things for convenience, or that can't be easily 
; typed in a modern text editor...
ATASCII_UP     = $1C ; Move Cursor 
ATASCII_DOWN   = $1D
ATASCII_LEFT   = $1E
ATASCII_RIGHT  = $1F

ATASCII_CLEAR  = $7D
ATASCII_EOL    = $9B

ATASCII_HEART  = $00 ; heart graphics
ATASCII_HLINE  = $12 ; horizontal line, ctrl-r (title underline) 
ATASCII_BALL   = $14 ; ball graphics, ctrl-t

ATASCII_EQUALS = $3D ; Character for '='
ATASCII_ASTER  = $2A ; Character for '*' splattered frog.
ATASCII_Y      = $59 ; Character for 'Y'
ATASCII_0      = $30 ; Character for '0'

; Atari uses different, "internal" values when writing to 
; Screen RAM.  These are the internal codes for writing 
; bytes directly to the screen:
INTERNAL_O        = $2F ; Letter 'O' is the frog.  
INTERNAL_0        = $10 ; Number '0' for scores.
INTERNAL_BALL     = $54 ; Ball graphics, ctrl-t, boat part.
INTERNAL_SPACE    = $00 ; Blank space character.
INTERNAL_INVSPACE = $80 ; Inverse Blank space, for the beach.
INTERNAL_ASTER    = $0A ; Character for '*' splattered frog.

; Keyboard codes for keyboard game controls.

KEY_S     = 62
KEY_Y     = 43
KEY_6     = 27
KEY_4     = 24


; ==========================================================================
; Inform DOS of the program's Auto-Run address...
	mDiskDPoke DOS_RUN_ADDR, GAMESTART

;	*= $0500  ; Originally on PET. 

	ORG $5000 ; Programmer's unintelligently chosen higher address on Atari for DOS, blah de blah. 

	jmp GAMESTART ; Probably not needed.  Atari DOS will automatically go to GAMESTART

	; Label and Credit 
	.by "    Dalesoft PET FROGGER by John C. Dale, November 1983. "
	.by "Atari port by Ken Jennings, November 2018. Version 00. "
	.by "As much of the PET code is used as possible.  "
	.by "In most places only the barest minimum of changes are made to "
	.by "deal with the differences on the Atari. " 
	.by "** Thanks to the Word (John 1:1), Creator of heaven and earth, and semiconductor chemistry and physics making all this fun possible. **"

; ==========================================================================
; Move the lines of boats around either left or right.
; Not sure why the initialization switches between Y and A for setting MovesCars.

MOVESC
;	ldx #$00
;	ldy #$78
;	sty MovesCars
;	ldy #$26
;	lda #$80
;	sta MovesCars + 1

	; Alternatively.  Set up for Right Shift... 
	; MovedCars is a word set to $8078...
	; which is SCREENMEM + $78 (or 120 decimal [i.e. 3 lines of text])
	lda #<[SCREENMEM+$78] ; low byte 
	sta MovesCars
	lda #>[SCREENMEM+$78] ; high byte
	sta MovesCars + 1

	ldx #$00  ; Count number of rows shifted
	ldy #$26  ; Character position, start at +38 (dec)

MOVE ; Shift text lines to the right.
	lda (MovesCars),y ; Read byte from screen (start +38)
	iny
	sta (MovesCars),y ; Store byte to screen at next position (start +39)

	; Blank the original read position. (Hummmm.Mmmmmm. May not be necessary.)
	dey               ; Back up to the original read position.
;	lda #$20          ; Was ASCII/PETSCII blank space...
	lda #$00          ; is now Atari blank space.
	sta (MovesCars),y ; Erase position at first byte read above.

	dey               ; Backup to previous position.
	cpy #$FF          ; Backed up from 0 to FF?
	bne MOVE          ; No.  Do the shift again.

	; Copy character at end of line to the start of the line.
	ldy #$27          ; Offset $27/39 (dec)
	lda (MovesCars),y ; Get character at end of line
	ldy #$00          ; Offset 0 == start of line
	sta (MovesCars),y ; Save it at start of line.

	ldy #$27          ; Set offset $27/39 (dec) again. (Why?  See ldy #$26 in CROSS section.)
	clc
	lda MovesCars     ; Add $78/120 (dec) to the start of line pointer
	adc #$78          ; to set new position 3 lines lower.
	sta MovesCars
	bcc CROSS         ; Smartly done instead of lda/adc #0/sta.
	inc MovesCars + 1 

CROSS
	inx               ; Track that a line is done.
	ldy #$26          ; Get offset $26 == 38 (dec) 
	cpx #6            ; Did we do this 6 times?
	bne MOVE          ; No.  Go do right shift on another line.

	; Setup for Left Shift...
	; MovedCars is a word to set to $80A0...
	; which is SCREENMEM + $A0 (or 160 decimal [i.e. 4 lines of text])
;	lda #$80
	lda #>[SCREENMEM+$A0] ; high byte
	sta MovesCars + 1 ; 
;	lda #$A0
	lda #<[SCREENMEM+$A0] ; low byte 
	sta MovesCars

	; Then the index values are set.
	ldy #0 ; Number of rows shifted
	ldx #0 ; Character position, start at +38 (dec)

MOVE1 ; Shift text lines to the left.
	iny
	lda (MovesCars),y ; Get byte from screen (start +1)
	dey
	sta (MovesCars),y ; Store byte at previous position (start +0)

	; Blank the original read position. (May not be necessary.)
	iny               ; Forward to the original read position.
	lda #$20          ; Was ASCII/PETSCII blank space...
	lda #$00          ; is now Atari blank space.
	sta (MovesCars),y ; Erase position at first byte read above.

;	dey               ; Back up to previous position.
;	iny               ; Move to next position.   (huh?) 
	cpy #$27          ; Reached position $27/39 (dec) (end of line)?
	bne MOVE1         ; No.  Do the shift again.

	; Copy character at start of line to the end of the line.
	ldy #0            ; Offset 0 == start of line
	lda (MovesCars),y ; Get character at start of line.
	ldy #$27          ; Offset $27/39 (dec)
	sta (MovesCars),y ; Save it at end of line.

	ldy #0            ; Set offset $0 again. (Why?  See ldy #$0 in CROSS1 section.)
	clc
	lda MovesCars     ; Add $78/120 (dec) to the start of line pointer
	adc #$78          ; to set new position 3 lines lower.
	sta MovesCars
	bcc CROSS1        ; Smartly done instead of lda/adc #0/sta.
	inc MovesCars + 1

CROSS1
	inx               ; Track that a line is done.
	ldy #0            ; Get offset $0 
	cpx #06           ; Did we do this 6 times?
	bne MOVE1         ; No.  Go do left shift on another line.

; Finish up by copying the score from memory to screen positions.
PRITSC
	ldx #0
REPLACE
	lda MyScore,x       ; Read from Score buffer
	sta SCREENMEM+$30,x ; Screen Memory + $30/48 bytes (9th character on second line)
	lda HiScore,x       ; Read from Hi Score buffer
	sta SCREENMEM+$42,x ; Screen Memory + $42/66 bytes (27th character on second line)
	inx ; 
	cpx #7 ; Loop 8 bytes - 0 to 7.
	bne REPLACE 

	rts

; ==========================================================================
; It appears text printing treats the screen sort of like a typewriter.
; "Right" seems like it is used to move through full line width to cause 
; the cursor to wrap around to the next line.  "Down" moves to the next 
; line.  I don't know, but for printing purposes the code makes it seem 
; like character printing on the PET does not support direct positioning 
; of the cursor. 

; I'm sort of torn here to support printing the same way on the Atari via 
; the screen editor, "E:"/Channel 0.  The Atari screen editor is more 
; advanced and does some things that interferes with a simple printing 
; mechanism that assumes streaming text to contiguous screen bytes.  
; Depending on how the text is printed the Atari editor can relate several 
; adjacent lines as one logical line. Great for editing text lines longer 
; than 40 characters, not so good when printing wraps the cursor from one
; line to the next.  Printing through the end of the screen line (aka the 
; right margin) extends the current line as a logical line into the next 
; screen line which pushes the content in lines below that further down 
; the screen.

; ALSO, since some code does direct manipulation of the screen memory, I 
; wonder why all the screen code didn't just do the same.  Copy from 
; source to destination is easier (or at least more consistent) than
; printing.

; Atari cursor control is a little different from PET.  The Pet's cursor 
; moves to the next line when right cursor movement occurs at the right 
; border.  On the Atari it is part of the screen editor and wraps around 
; to the same line.  Atari needs a DOWN inserted to move the cursor to 
; the next line.  (The alternative is replacing all the Pet RIGHT cursor 
; control characters with simple blank spaces).

; Changing all the text handling to use direct write is number one on 
; the short list of Version 1 optimizations.

; It looks like "BRK" is actually being treated as 0 data to end the 
; text strings.  Changing this to hange this to Atari EOL $9B in order to print 

; None of the game displays use the entire 25 lines available on the PET.
; Actually, none even use 24 lines.  The only time the game writes to 
; the entire screen is when it fills the screen with the block graphics.


TEXT_CLEARSCREEN 
	; TEXT "{clear}{down*2}"
	; BYTE $11,$11
	.by ATASCII_CLEAR ATASCII_DOWN ATASCII_DOWN
	.by ATASCII_EOL
	BRK


; It doesn't seem like there is a need to do cursor control 
; movement (right) rather than just printing spaces as it 
; seems like the purpose is to redraw the entire line, 
; so.... I think blank spaces will do.  (therefore  I can 
; be lazy and provide most of this data as text strings.)

; The original PET version uses some graphics characters that
; don't have direct equivalents on the Atari.  In a future 
; iteration custom characters would be used to make the 
; characters appear more like the original PET version. 
; (just for the sake of matching the look of the original.)
; going that route of redefined characters would then imply 
; why not make a frog that looks like a frog and a boat that 
; looks like a boat.

; Using the inverse blank space as the "beach" character.
; Using the 'O' as the frog. (No open circle graphic like the Pet's).
; Using the Atari EOL $9b to flag the end of text, because the
; character value 0 on the Atari is the heart graphic which 
; appears in the "Dalesoft" string and which would then conflict
; with the 0 byte (BRK) used as end of text on the PET version.

TEXT1 ; Default display of "Beach", for lack of any other description, and the two lines of Boats
	;BYTE $A6,$A6,$A6,$A6,$A6,$A6,$A6,$A6
	;BYTE $A6,$A6,$A6,$A6,$A6,$A6,$A6,$A6
	;BYTE $A6,$A6,$A6,$A6,$A6,$A6,$A6,$A6
	;BYTE $A6,$A6,$A6,$A6,$A6,$A6,$A6,$A6
	;BYTE $A6,$A6,$A6,$A6,$A6,$A6,$A6,$A6
	;TEXT "{cm +*40}"
	; I do not understand the data.. Code suggests $66 is the "beach" 
	.by +$80 "                                        " ; "Beach"
	;BYTE $1D,$5B,$D1,$D1,$D1,$D1,$3E,$1D
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$1D,$5B
	;BYTE $D1,$D1,$D1,$D1,$3E,$1D,$1D,$1D
	;BYTE $1D,$1D,$1D,$1D,$5B,$D1,$D1,$D1
	;BYTE $D1,$D1,$3E,$1D,$1D,$1D,$1D,$1D; Hmmm.  This data has an extra ball in the boat?
	;TEXT "{right}[QQQQ>{right*8}[QQQQ>{right*7}[QQQQ>{right*5}"; This data is 39 characters?  {right 6} at end?
	.by ATASCII_RIGHT '['           ATASCII_BALL  ATASCII_BALL  ATASCII_BALL  ATASCII_BALL  '>'           ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT '['
	.by ATASCII_BALL  ATASCII_BALL  ATASCII_BALL  ATASCII_BALL  '>'           ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT '['           ATASCII_BALL  ATASCII_BALL  ATASCII_BALL
	; Added an extra right here to make it 40 characters.
	.by ATASCII_BALL  '>'           ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$3C,$D1
	;BYTE $D1,$D1,$D1,$5D,$1D,$1D,$1D,$1D
	;BYTE $1D,$1D,$1D,$1D,$3C,$D1,$D1,$D1
	;BYTE $D1,$5D,$1D,$1D,$1D,$3C,$D1,$D1 ; This data is missing a Right cursor. ?
	;BYTE $D1,$D1,$5D,$1D,$1D,$1D,$1D,$1D
	;TEXT "{right*6}<QQQQ]{right*8}<QQQQ]{right*4}<QQQQ]{right*5}"; This data is 41 characters? {right 5} at start?
	; Adding a down here to make the data go to the next line.
	.by ATASCII_DOWN
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT '<'           ATASCII_BALL
	.by ATASCII_BALL  ATASCII_BALL  ATASCII_BALL  ']'           ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT '<'           ATASCII_BALL  ATASCII_BALL  ATASCII_BALL  
	.by ATASCII_BALL  ']'           ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT '<'           ATASCII_BALL
	.by ATASCII_BALL  ATASCII_BALL  ATASCII_BALL  ']'           ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT 
	; Adding a down here to make the data go to the next line.
	.by ATASCII_DOWN
	.by ATASCII_EOL
	brk  

TEXT2 ; this last block includes a Beach, with the "Frog" character which is the starting line. 
	;BYTE $A6,$A6,$A6,$A6,$A6,$A6,$A6,$A6
	;BYTE $A6,$A6,$A6,$A6,$A6,$A6,$A6,$A6
	;BYTE $A6,$A6,$A6,$D7,$A6,$A6,$A6,$A6
	;BYTE $A6,$A6,$A6,$A6,$A6,$A6,$A6,$A6
	;BYTE $A6,$A6,$A6,$A6,$A6,$A6,$A6,$A6
	;TEXT "{cm +*19}W{cm +*20}"
	.by +$80 "                   " ; The "beach"
	.by 'O' ; frog (Atari has no Open Circle graphic other then "O").  (Pet Frog == $D7)
	.by +$80 "                    "
	;BYTE $20,$20,$20,$20,$20,$28,$43,$29
	;BYTE $20,$4E,$4F,$56,$45,$4D,$42,$45
	;BYTE $52,$20,$31,$39,$38,$33,$20,$42
	;BYTE $59,$20,$44,$41,$4C,$45,$53,$D3
	;BYTE $46,$54,$1D,$1D,$1D,$1D,$1D,$1D
	;TEXT "{space*5}(c) november 1983 by dalesSft{right*6}"
	.by "     (C) NOVEMBER 1983 BY DALES" ATASCII_HEART "FT" ; The heart is character 0 which conflicts with BRK end of line.
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;BYTE $57,$52,$49,$54,$54,$45,$4E,$20
	;BYTE $42,$59,$20,$4A,$4F,$48,$4E,$20
	;BYTE $43,$2E,$20,$44,$41,$4C,$45,$1D
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;TEXT "{right*8}written by john c. dale{right*9}"
	; Adding a down here to make the data go to the next line.
	.by ATASCII_DOWN
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by "WRITTEN BY JOHN C. DALE"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT
	.by ATASCII_EOL
	brk

LIVETT
	;BYTE $13
	;BYTE $53,$55,$43,$43,$45,$53,$53,$46
	;BYTE $55,$4C,$20,$43,$52,$4F,$53,$53
	;BYTE $49,$4E,$47,$53,$20,$3D,$20,$1D
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;TEXT "{home}successful crossings = {right*17}"
	; Assume position 0,0 happens before this.
	.by "SUCCESSFUL CROSSINGS = "
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT
	;BYTE $53,$43,$4F,$52,$45,$20,$3D,$20
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;BYTE $1D,$1D,$1D,$1D,$1D,$48,$49,$20
	;BYTE $3D,$20,$1D,$1D,$1D,$1D,$1D,$1D
	;BYTE $1D,$1D,$1D,$1D,$4C,$56,$3A
	;TEXT "score = {right*13}hi = {right*10}lv:"
	; Adding a down here to make the data go to the next line.
	.by ATASCII_DOWN
	.by "SCORE = "
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT   
	.by "HI = "
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT 
	.by "LV:"
	.by ATASCII_EOL
	brk

	
; ==========================================================================
; Printing things to the screen.
; For Atari, all occurrences of $FFD2 now call routine "fputc"
; Most of this priting is strictly serial and prints the entire content 
; of screen line.  This means this could be easily optimized to do direct 
; copy of a block of bytes from a defined source to the destination in 
; screen memory. (future to-do)

PRINTSC ; Print the Clear Screen 
	ldx #0 ; how many times printed the block of beach/boats 
	ldy #0

LK
	lda TEXT_CLEARSCREEN,y ; read a character
;	cmp #0                 ; PET uses 0/BRK to flag end of string which is Heart on Atari
	cmp #ATASCII_EOL       ; so, use the Atari End Of Line character as end of string.
	beq PRINT              ; Exit at the end to the next print routine.
;	jsr $FFD2
	jsr fputc              ; Uses the CIO PutCH in IOCB0
	iny
	jmp LK


PRINT ; Print TEXT1 -  beaches and boats, six times.
	ldy #0

LK2
	lda TEXT1,y
;	cmp #0            ; PET uses 0/BRK to flag end of string which is Heart on Atari
	cmp #ATASCII_EOL  ; so, use the Atari End Of Line character as end of string.
	beq PRINT1
;	JSR $FFD2
	jsr fputc         ; Uses the CIO PutCH in IOCB0
	iny
	jmp LK2

PRINT1 ; Evaluate number of times beach/boats is printed
	inx 
	cpx #6     ; if we printed six times, (18 lines total) then we're done 
	bne PRINT  ; Go back and print another set of lines.


; Print TEXT2 - Credits
	ldy #0
LK3
	lda TEXT2,y
;	cmp #0                 ; PET uses 0/BRK to flag end of string which is Heart on Atari
	cmp #ATASCII_EOL       ; so, use the Atari End Of Line character as end of string.
	beq PRINT2
;	JSR $FFD2
	jsr fputc              ; Uses the CIO PutCH in IOCB0
	iny
	jmp LK3


PRINT2
	jsr PRINTPORTBYTEXT 
		; Display the number of frogs that crossed the river.
		; This is done by direct write, not printing.
		; Logic here is ummm. different. not exactly certain of it all.

	ldx FrogsCrossed ; number of times successfully crossed the rivers.
LIVES
	cpx #0           ; If FrogsCrossed is 0 , 
	beq PRINT3       ; then nothing to display. Skip to scores.
	cpx #$11         ; If FrogsCrossed is $11/17 (dec)    Hmmm...   Why??
	beq PRINT4       ; then print the frog.
	lda #1           ; Reset the 
	sta FrogsCrossed ; FrogsCrossed to 1

PRINT4
;	lda #$57            ; PET Frog - either upper case W or Open circle graphics.
	lda #INTERNAL_O     ; On Atari we're using "O" as the frog shape.
	sta SCREENMEM+$17,x ; Write to screen.
	dex                 ; Decrement number of frogs.
	cpx #0              ; If there are more frogs left
	bne LIVES           ; then go back and display the next frog counter.


PRINT3 ; Print the lives and score labels at the top of the screen.
	jsr POSITION ; Atari: POSITION 0,0 aka "Home" cursor control
	ldy #0

PRLIVE ; Print the lives and score labels in the top two lines of the screen.
	lda LIVETT,y
;	cmp #0            ; PET uses 0/BRK to flag end of string which is Heart on Atari
	cmp #ATASCII_EOL  ; so, use the Atari End Of Line character as end of string.
	beq FINLIV        ; Done printing this, now write the lives to the screen.
;	JSR $FFD2
	jsr fputc         ; Uses the CIO PutCH in IOCB0
	iny
	jmp PRLIVE

FINLIV ; Write the number of lives to screen memory
	lda NumberOfLives ; Get number of lives.
	clc               ; Add to value for  
;	adc #$30          ; PET ASCII '0'
	adc #INTERNAL_0   ; Atari internal code for '0'
	sta SCREENMEM+$4F ; Write to screen
	rts


; ==========================================================================
; Data to drive AUTOMVE routine.
; Byte value indicates direction of row movement.
; 0   = Beach line, no movement.
; 1   = first boat/river row, move right
; 255 = second boat/river row, move left.

DATA
	.BYTE 0, 1, 255
	.BYTE 0, 1, 255
	.BYTE 0, 1, 255
	.BYTE 0, 1, 255
	.BYTE 0, 1, 255
	.BYTE 0, 1, 255

	brk


; ==========================================================================
; Called once on program start.
; Use this to setup Atari display settings to imitate the   
; PET 4032's 40x25 display.

GAMESTART
	; Atari initialization stuff...
	
	; Changing the Display List is potentially tricky.  If the update is 
	; interrupted by the Vertical blank, then it could mess up the display
	; list address and crash the Atari.  So, the code must make sure the 
	; system is not near the end of the screen to make the change.
	; The jiffy counter is updated during the vertical blank.  When the 
	; main code sees the counter change then it means the vertical blank is 
	; over, the electron beam is near the top of the screen thus there is 
	; now plenty of time to set the new display list pointer.  Technically, 
	; this should be done by managing SDMCTL too, but this is overkill for a 
	; program with only one display.

	lda RTCLOK60     ; Get the jiffy clock
WaitForFrame
	cmp RTCLOK60     ; If it is unchanged, 
	beq WaitForFrame ; then go check the jiffy clock value again.

	; Safe to change Display list pointer now.
	lda #<DISPLAYLIST
	sta SDLSTL
	lda #>DISPLAYLIST
	sta SDLSTH

	; Tell the OS where screen memory starts 
	lda #<SCREENMEM ; low byte screen
	sta SAVMSC
	lda #>SCREENMEM ; hi byte screen
	sta SAVMSC+1

	lda #1
	sta CRSINH ; Turn off the displayed cursor.

	lda #0
	sta DINDEX ; Tell OS screen/cursor control is Text Mode 0
	sta LMARGN ; Set left margin to 0 (default is 2)

	lda #COLOR_GREEN ; Set screen base color dark green
	sta COLOR2       ; Background and
	sta COLOR4       ; Border
	lda #$0A
	sta COLOR1       ; Text brightness

	; End of Atari initialization stuff.

	; Continue with regular Pet Frogger initialization
	; Zero these values...
	sta FrogsCrossed
	sta FlaggedHiScore
	sta LastKeyPressed

	jsr INSTR ; print game instructions

START
	lda #0
	sta FrogsCrossed       ; Zero the number of successful crossings.
	
	lda #<[SCREENMEM+$320] ; Low Byte, Frog position.
	sta FrogLocation      
	lda #>[SCREENMEM+$320] ; Hi Byte, Frog position.
	sta FrogLocation + 1
	
	ldy #$13               ; Y = 19 (dec)
	;lda #$66               ; PET ASCII.  I think the "beach" ??  
	lda #INTERNAL_INVSPACE ; On Atari use inverse space.
	sta LastCharacter      ; Preset the character under the frog.
	
	lda #$12               ; 18 (dec), number of screen rows of playfield.
	sta NumberOfRows
	lda #$30               ; 48 (dec), delay counter.
	sta DelayNumber

;	lda #0                 ; Hey, we did this at the top
;	sta FrogsCrossed       ; of the START routine.

;	lda #$57               ; PET ASCII 'W' or open circle graphic ?
	lda #INTERNAL_O        ; On Atari we're using "O" as the frog shape.
	sta (FrogLocation),y   ; SCREENMEM + $320 + $13
	;lda FlaggedHiScore    ; Don't look at me.  It was commented out when I got here.

; Clear the score digits to zeros.
; Reminder to do for Atari.  
; If Scores are printed on screen, keep the ASCII values.
; If scores are written directly to screen memory then change to use internal
; screen code for digits. ("0" base)
	ldx #$07           ; 7 digits.
CLEAR
;	lda #$30           ; PET ASCII "0". (And Atari ASCII).
	lda #INTERNAL_0   ; Atari internal code for "0"
	sta MyScore,x      ; Put zero/"0" in score buffer.
	ldy FlaggedHiScore ; Has a high score been flagged?
	cpy #$FF           ; If so, then skip this and 
	beq CLNEXT         ; go to the next digit.

	sta HiScore,x      ; Also put zero/"0" in the high score. 
	;sta $HiScore      ; Don't look at me.  It was commented out when I got here.
	tay                ; Now Y also is zero/"0".
	lda #3             ; Reset number of 
	sta NumberOfLives  ; lives to 3.
	tya                ; A  is zero/"0" again.
	ldy #$13           ; Y = 19 (dec) (again)

CLNEXT
	dex                ; decrement index to score digits.
	cpx #255           ; did it go from 0 to $FF?  
	bne CLEAR          ; no, loop for next digit.
	;  FYI: alternatively,  dex ; bpl CLEAR  would work without using cpx.
	;sta MyScore       ; Don't look at me.  It was commented out when I got here.

	jsr PRINTSC        ; Go clear screen and print game screen
	ldy #$13           ; Y = 19 (dec) (again, again)


KEY ; Read keyboard.  (I hate keyboard input.  TO DO - Use a joystick.)
;	lda $97            ; PET Get key pressed (LSTX)
	lda CH             ; Atari get key pressed 
	cmp #$FF           ; Check for no key pressed (same for PET and Atari)
	bne KEY1           ; Not $FF, then something is pressed.


DELAY
	sta LastKeyPressed ; Save $FF, for no key pressed.
	tya                ; Whatever Y was, probably $13/19 (dec) again,
	pha                ; and push that to the stack.  must be important.
	jsr MOVESC         ; Move the boats around.

	ldx DelayNumber    ; Get the Delay counter.
DEL1
	ldy #$FF           ; Reset Y to $FF/255 (dec)

DEL
	dey                ; decrement Y counter
	bne DEL            ; if Y is not 0, then do the decrement again.
	dex                ; decrement delay counter.
	bne DEL1           ; If X is not 0, then wind up Y again and start over.

	pla                ; Pull original Y value 
	tay                ; and return to Y.
	jmp AUTMVE         ; GOTO AUTOMVE


KEY1 ; Process keypress
	pha
	lda #$FF             ; Need to clear CH on Atari
	sta CH
	pla
	cmp LastKeyPressed   ; is this key the same as the last key?
	BEQ DELAY            ; Yes.  So, probably a key repeat, so ignore it and do delay.

	tax                  ; Save that key in X, too.
	lda LastCharacter    ; Get the last character (under the frog)  
	sta (FrogLocation),y ; Erase the frog with the last character.

; Test for Left "4" key
	txa                  ; Restore the key press to A
;	cmp #52              ; PET "4"
	cmp #KEY_4           ; Atari "4", #24
	bne RIGHT            ; No.  Go test for Right.
	dey                  ; Move Y to left.
	cpy #$FF             ; Did it move off the screen?
	bne CORR             ; No.  GOTO CORR (Place frog on screen)
	iny                  ; Yes.  Correct by adding 1 to Y.

CORR
	jmp PLACE ; Place frog on screen (?)

RIGHT ; Test for Right "6" key
;	cmp #54              ; PET "6"
	cmp #KEY_6           ; Atari "6", #27
	bne UP               ; Not "6" key, so go test for Up.

	iny                  ; Move Y to right.
	cpy #$28             ; Did it move off screen? Position $28/40 (dec)
	bne CORR1            ; No.  GOTO CORR1  (Place frog on screen)
	DEY                  ; Yes.  Correct by subtracting 1 from Y.

CORR1    ; couldn't the BNE above just go to CORR in order to jump to PLACE?
	jmp PLACE
	jmp PLACE ; What???  How does this happen?


UP ; Test for Up "S" key
;	cmp #83              ; PET "S"
	cmp #KEY_S           ; Atari "S", #62
	beq UP1              ; Yes, go do UP.

; No.  key press is not a frog control key.  Replace frog where it came from.
;	lda #$57             ; Pet open circle for frog
	lda #INTERNAL_O      ; On Atari we're using "O" as the frog shape.
	sta (FrogLocation),y ; Return frog to screen
	jmp DELAY            ; Go to the delay

UP1 ; Move the frog a row up.
	lda #1               ; Represents "10" Since we don't need to add to the ones column.  
	ldx #5               ; Offset from start of "00000000" to do the adding.
; I have to correct this.
; the intend is to add 10 to the score.
; the score is 00000000
; The index position of the 1 from the start of the score is  5.
; Therefore:
; Number of chars = 5 = X
; Score to add    = 1 = A
; Original code reverses this:
;	stx ScoreToAdd       ; Save to add 1
;	sta NumberOfChars    ; Position offset in score.
; Fixed here:
	sta ScoreToAdd       ; Save to add 1
	stx NumberOfChars    ; Position offset in score.
	jsr SCORE            ; Deal with score update.

	lda FrogLocation     ; subtract $28/40 (dec) from 
	sec                  ; the address pointing to 
	sbc #$28             ; the frog.
	sta FrogLocation
	bcs CORR2
	dec FrogLocation + 1 

CORR2 ; decrement number of rows.
	sec                  ; ummm.  Does carry affect dec? did not think so.
	dec NumberOfRows
	lda NumberOfRows
	cmp #0               ; If more row are left to cross, then 
	bne PLACE            ; draw frog on screen. 
;pla
;pla
	jmp FROG             ; No more rows to cross. Update frog reward/stats.


; Get the character that will be under the frog.
PLACE
	lda (FrogLocation),y ; Get the character in the new position.
	sta LastCharacter    ; Save for later when frog moves.
	jmp CHECK


; Draw the frog on screen.
PLACE2 
;	lda #87              ; Pet frog. ASCII $57/87 (dec) 
	lda #INTERNAL_O       ; Atari internal code for "O" is frog.
	sta (FrogLocation),y ; Save to screen memory to display it.
	jmp DELAY            ; Slow down game speed.
	rts


; Will the Pet Frog land on the Beach?
CHECK
	lda LastCharacter      ; Is the character the beach?
;	cmp #102               ; Pet ASCII $66/102 (dec) - The beach 
	cmp #INTERNAL_INVSPACE ; Atari uses inverse space for beach
	bne CHECK1             ; not the beach?  Goto CHECK1
	jmp PLACE2             ; Draw the frog.


; Will the Pet Frog land in the boat?
CHECK1
;	cmp #81                ; Pet ASCII $51/81 (dec) is "Q" in the boat.
	cmp #INTERNAL_BALL     ; Atari uses ball graphics, ctrl-t
	bne CHECK2             ; No?   GOTO CHECK2 to die.
	jmp PLACE2             ; Draw the frog.


; Safe locations discarded, so wherever the Frog will land, it is Baaaaad.
CHECK2
	;jmp PLACE2

	jmp YRDD               ; Yer Dead!


; Process automagical movement on the frog in the boat.
AUTMVE
	ldx NumberOfRows   ; Get the current row number.
	lda DATA,x         ; Get the movement flag for the row.
	cmp #0             ; Is it 0?  Nothing to do.  Bail and go back to keyboard polling..  
	beq RETURN         ; (ya know, the cmp was not actually necessary.)
	cmp #$FF           ; is it $ff?  then automatic right move.
	bne AUTRIG         ; (ya know, could have done  bmi AUTRIG without the cmp).
	dey                ; Move Frog left one character
	cpy #0             ; Is it at 0? (Why not check for $FF here (or bmi)?)
	bne RETURN         ; No.  Bail and go back to keyboard polling.
	jmp YRDD           ; Yup.  Ran out of river.   Yer Dead!

AUTRIG 
	iny                ; Move Frog right one character
	cpy #$28           ; Did it reach the right side ?    $28/40 (dec)
	bne RETURN         ; No.  Bail and go back to keyboard polling.
	jmp YRDD           ; Yup.  Ran out of river.   Yer Dead!

RETURN
	jmp KEY            ; Return to keyboard polling.


; Yer dead! Text prompt.
YRDDTX
	;BYTE $13
	;BYTE $1D,$1D,$1D,$1D,$1D
	;BYTE $12
	;BYTE $59,$4F,$55,$27,$52,$45,$20,$44
	;BYTE $45,$41,$44,$21,$21,$20,$59,$4F
	;BYTE $55,$20,$57,$41,$53,$20,$53,$57
	;BYTE $41,$4D,$50,$45,$44
	;TEXT "{home}{right}{right}{right}{right}{right}{reverse on}you're dead!! you was swamped"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by +$80 "YOU'RE DEAD!! YOU WAS SWAMPED"
	.by ATASCII_EOL
	brk


; Frog is dead.
YRDD
	lda #INTERNAL_ASTER  ; Atari ASCII $2A/42 (dec) Splattered Frog.
	sta (FrogLocation),y ; Road kill the frog.
	jsr DELAY1           ; Various pauses....
	jsr DELAY1           ; Should do this with  jiffy counters. future TO DO.
	jsr DELAY1
	jsr DELAY1
	jsr FILLSC           ; Fill screen with inverse blanks.

	jsr POSITION         ; Atari: POSITION 0,0 aka "Home" cursor control

AGAIN                    ; Print the dead frog prompt.
	lda YRDDTX,y
;	cmp #0               ; PET uses 0/BRK to flag end of string which is Heart on Atari
	cmp #ATASCII_EOL     ; so, use the Atari End Of Line character as end of string.
	beq GAMEOV           ; Dead frog is game over.
;	JSR $FFD2
	jsr fputc            ; Uses the CIO PutCH in IOCB0
	iny
	jmp AGAIN            ; Do until the end of string....


; Decide   G A M E   O V E R-ish
GAMEOV
	lda #0
;	sta $9E              ; Zero a Pet interrupt  ?????
	jsr PRITSC           ; update display.
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	dec NumberOfLives    ; subtract a life.
	lda NumberOfLives
	cmp #0               ; 0 lives left means
	beq GOV              ; definitely game over.
	lda #$FF
	sta FlaggedHiScore   ; flag the high score
	jmp START1


GOV
	jmp GOVER ; G A M E   O V E R


FROGTXT
	;BYTE $13,
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D
	;BYTE $12
	;BYTE $43,$4F,$4E,$47,$52,$41,$54,$55
	;BYTE $4C,$41,$54,$49,$4F,$4E,$53,$20
	;BYTE $59,$4F,$55,$20,$4D,$41,$44,$45
	;BYTE $20,$49,$54
	;TEXT "{home}{right}{right}{right}{right}{right}{right}{reverse on}congratulations you made it"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by +$80 "CONGRATULATIONS YOU MADE IT"
	.by ATASCII_EOL
	BRK


FROG
	inc FrogsCrossed     ; Add to frogs successfully crossed the rivers.
	jsr FILLSC           ; Update the score display

	jsr POSITION         ; Atari: POSITION 0,0 aka "Home" cursor control

FROG1 ; Print the frog wins text.
	lda FROGTXT,y
;	cmp #0               ; PET uses 0/BRK to flag end of string which is Heart on Atari
	cmp #ATASCII_EOL     ; so, use the Atari End Of Line character as end of string.
	beq FROG2            ; Go do the score management
;	JSR $FFD2
	jsr fputc            ; Uses the CIO PutCH in IOCB0

	iny
	jmp FROG1


FROG2  ; More score maintenance.   and delays.
	jsr SCORE
	jsr PRITSC
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jsr DELAY1
	jmp NEXTFR


FILLSC  ; Setup pointer to screen. then fill screen
;	lda #$50
;	sta $11 ; Another hardcoded address.  Use a declared location (below).
;	lda #$80
;	sta $12

	lda #<[SCREENMEM+$50]  ; point to screen memory +80 bytes (2 lines from top)
	sta ScreenPointer
	lda #>[SCREENMEM+$50]
	sta ScreenPointer+1

; This was inside FILL, but only needs to be done once before the loop
	ldy #0
FILL ; Fill screen with the "beach" characters
;	lda #$66               ; Pet beach character.
	lda #INTERNAL_INVSPACE ; Atari beach character is inverse space.
	sta (ScreenPointer),y
	lda ScreenPointer      ; Increment  
	clc                    ; the  
	adc #1                 ; pointer 
	sta ScreenPointer      ; to  
	lda ScreenPointer+1    ; screen 
	adc #0                 ; memory.
	sta ScreenPointer+1    ; You know, inc lowbyte, bne FILL works instead of adc.
	cmp #>[SCREENMEM+$400] ; Did high byte reach $8400 (screen memory + 1K)?
	bne FILL               ; Nope, continue filling.

; Setup for score update.
	ldx #4
	lda #5
; I have to correct this.
; the intend is to add 500 to the score.
; the score is 00000000
; The index position of the 5 from the start of the score is  4.
; Therefore:
; Number of chars = 4 = X
; Score to add    = 5 = A
; Original code reverses this:
;	sta NumberOfChars      ; Number of sequential characters.
;	stx ScoreToAdd         ; Add 4 to score
; Now fix it:
	stx NumberOfChars      ; Index into "00000000" to add the score.
	sta ScoreToAdd         ; Add 5 which represents "500" to the score.  Don't need 10s or 1s values, since they are 0.

;	lda #$13               ; Pet ASCII HOME position character
;	JSR $FFD2
	jsr POSITION           ; Atari, POSITION 0,0

	jsr PRINT2             ; Display frogs count
	ldy #0
	rts


; ==========================================================================
; Update starting frog position.

NEXTFR
	lda DelayNumber        ; Subtract 3 from delay number...
	sec
	sbc #3
	sta DelayNumber

START1 ; Manage frog's starting postion.
	lda #<[SCREENMEM+$320] ; Set Frog Location pointer to $8320
	sta FrogLocation
	lda #>[SCREENMEM+$320]
	sta FrogLocation + 1

	jsr PRINTSC
	jsr MOVESC

;	lda #$66               ; Pet?  Beach?
	lda #INTERNAL_INVSPACE ; Atari: Beach character 
	sta LastCharacter      ; Prep space under frog

;	lda #$57               ; Pet: Frog character
	lda #INTERNAL_O        ; Atari: using "O" as the frog shape.

	ldy #$13               ; Y = 19 (dec) the middle of screen
	sta (FrogLocation),y   ; Erase Frog starting position.
	lda #$12               ; A = 18 (dec)
	sta NumberOfRows       ; Save as number of rows to jump
	
	jmp KEY                ; GOTO Key input


; ==========================================================================
; D E  L   A    Y          L      O       O        P
; Count down X=255 to 0 by Y=255 times.  
DELAY1
	ldx #$FF

DELA1
	ldy #$FF

DELA
	dey
	bne DELA

	dex
	bne DELA1
	rts


; ==========================================================================
; Add to score.

SCORE
	pha               ; Save A, X, and Y.
	txa
	pha
	tya
	pha

	ldx NumberOfChars ; index into "00000000" to add score.
	lda ScoreToAdd    ; value to add to the score
	clc
	adc MyScore,x
	sta MyScore,x

SCORE1                   ; Evaluate if carry occurred
	lda MyScore,x
	; Pet used $3A for the next comparison.  Since the score display is 
	; writing directly to the screen, the values are updated based 
	; on Atari ointernal character codes instead.
	cmp #[INTERNAL_0+10] ; Did math carry past the "9"?
	bcs UPDATE           ; if it carried then readjust the values.

PULL                     ; All done.
	pla                  ; Restore Y, X, and A
	tay
	pla
	tax
	pla

	rts


; ==========================================================================
; The score carried past "9", so it must be adjusted and
; the next/greater position is added.

UPDATE
	lda #INTERNAL_0 ; Atari internal code for "0".  
	sta MyScore,x   ; Reset current position to "0"
	dex             ; Go to previous position in score
	inc MyScore,x   ; Add 1 to the next digit.
	jmp SCORE1      ; (re)evaluate carry for the current position.


; ==========================================================================
; Game Over - Prompt to go again.

GOVER
	ldy #0

GOVER1                 ; Print the go again message.
	lda OVER,y
;	cmp #0             ; PET uses 0/BRK to flag end of string which is Heart on Atari
	cmp #ATASCII_EOL   ; so, use the Atari End Of Line character as end of string.
	beq GOVER2
;	JSR $FFD2
	jsr fputc          ; Uses the CIO PutCH in IOCB0
	iny
	jmp GOVER1

GOVER2
;	jsr $FFCF          ; Get a byte.  Input from keyboard.  returned in A
	cmp #ATASCII_Y     ; 89 (dec) Pet/Atari ASCII "Y"
	bne GOVER3         ; Not "Y".  
	jsr HISC           ; Manage high score
	lda #$FF           ; Re-init a few things. . . .
	sta FlaggedHiScore ; 
	lda #0
	sta FrogsCrossed
	lda #3
	sta NumberOfLives
	jmp START          ; Back to start.

GOVER3
	jsr INSTR          ; Display instructions.
	jsr HISC           ; Manage high score
	lda #$FF
	sta FlaggedHiScore ; Re-init a few things. . . .
	lda #3
	sta NumberOfLives
	jmp START          ; Back to start.


; ==========================================================================
; Figure out if My Score is the High Score

HISC
	lda #0

HISC2
	lda MyScore,x    ; Get my score
	clc
	cmp HiScore,x    ; Compare to high score
	beq NOT          ; Equals?  then sofar it is not high score
	bcs HISC1        ; Greater than.  Could be high score.

NOT
	inx              
	cpx #7           ; Are all 7 digits tested?
	bne HISC2        ; No, then go do next digit.
	rts              ; Yes.  Done.

HISC1                ; It is a high score.
	lda MyScore,x    ; Copy my score to high score
	sta HiScore,x
	inx
	cpx #7           ; if the first 7 digits are not done testing, then
	bne HISC1        ; go test next digit.
	rts


; ==========================================================================
; Prompt for playing again.

OVER
	;BYTE $93,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;BYTE $44,$4F,$20,$59,$4F,$55,$20,$57
	;BYTE $41,$4E,$54,$20,$20,$41,$4E,$4F
	;BYTE $54,$48,$45,$52,$20,$47,$4F,$20
	;BYTE $3F,$1D
	;TEXT "{clear}{right}{right}{right}{right}{right}{right}{right}do you want another go ?{right}"
	.by ATASCII_CLEAR ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by "DO YOU WANT ANOTHER GO ?" ATASCII_RIGHT
	.by ATASCII_EOL
	brk


; Print the instruction/title screen text.
; Instructions are longer than a register can index, so this
; version of printing iterates the pointer itself and not the 
; index register.

INSTR ; Per PET Memory Map - Set integer value for SYS/GOTO ?
	lda #<INSTXT
;	sta $11
 	sta ScreenPointer     ; borrow a variable already set up as screen pointer to point to instruction text
	lda #>INSTXT
;	sta $12
	sta ScreenPointer+1

	ldy #0
INSTR2
	lda (ScreenPointer),y
;	cmp #0                ; PET uses 0/BRK to flag end of string which is Heart on Atari
	cmp #ATASCII_EOL      ; so, use the Atari End Of Line character as end of string.
	beq PRINTPORTBTYTEXT  ; finish title with Atari ported by text.
;	JSR $FFD2
	jsr fputc             ; Uses the CIO PutCH in IOCB0
	clc
;	lda $11
	lda ScreenPointer     ; Increment screen pointer
	adc #1
;	sta $11
	sta ScreenPointer
;	lda $12
	lda ScreenPointer+1
	adc #0
;	sta $12
	sta ScreenPointer+1
	jmp INSTR2            ; Do again until end of string

PRINTPORTBTYTEXT 
	jsr PRINTPORTBYTEXT  ; Add Atari Ported by credit.

INSTR1
;	lda $97               ; Pet current key pressed (LSTX)
	lda CH                ; Atari current key press
	cmp #$FF              ; Pet/Atari, no key pressed
	bne CLEAR_CH
	beq INSTR1            ; so, loop again while no key pressed.

CLEAR_CH
	lda #$FF              ; Atari, clear  out the key
	sta CH

	lda #0                ; Clear high score flag.
	sta FlaggedHiScore
	rts

; ==========================================================================
; Instructions text. 
; Atari cursor is different from PET. Due to the Atari's full scrren editor
; the Atari needs a DOWN inserted to get the Atari printing to move to the 
; next line.  

INSTXT
	;BYTE $93,
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$50,$45
	;BYTE $54,$20,$46,$52,$4F,$47,$47,$45
	;BYTE $52,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;TEXT "{clear}{right*14}pet frogger{right*15}"
	.by ATASCII_CLEAR ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT 
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT 
	.by "PET FROGGER"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT 
	.by ATASCII_DOWN
	;byte $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$B8,$B8
	;BYTE $B8,$20,$B8,$B8,$B8,$B8,$B8,$B8
	;BYTE $B8,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;BYTE $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
	;TEXT "{right*14}{cm u*3} {cm u*7}{right*15}"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT  
	.by ATASCII_HLINE ATASCII_HLINE ATASCII_HLINE ' '           ATASCII_HLINE ATASCII_HLINE ATASCII_HLINE ATASCII_HLINE
	.by ATASCII_HLINE ATASCII_HLINE ATASCII_HLINE ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_DOWN
	;TEXT "{right*4}(c) november 1983 by dalesSft{right*7}{down*2}"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by "(C) NOVEMBER 1983 BY DALES" ATASCII_HEART "ft"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_DOWN
	.by ATASCII_DOWN
	;TEXT "all you have to do is to get as many of{right}"
	.by "ALL YOU HAVE TO DO IS TO GET AS MANY OF" ATASCII_RIGHT ATASCII_DOWN
	;TEXT "the frogs across the river without{right*6}"
	.by "THE FROGS ACROSS THE RIVER WITHOUT"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_DOWN
	;TEXT "drowning them. you have to leap onto a{right*2}"
	.by "DROWNING THEM. YOU HAVE TO LEAP ONTO A"  ATASCII_RIGHT ATASCII_RIGHT ATASCII_DOWN
	;TEXT "boat like this :- <QQQ] and land on the{right}"
	.BY "BOAT LIKE THIS :- <" ATASCII_BALL ATASCII_BALL ATASCII_BALL "] AND LAND ON THE" ATASCII_RIGHT ATASCII_DOWN
	;TEXT "seats ('Q'). you get 10 points for every"
	.by "SEATS ('" ATASCII_BALL "'). YOU GET 10 POINTS FOR EVERY" 
	;TEXT "jump forward and 500 points every time{right*2}"
	.by "JUMP FORWARD AND 500 POINTS EVERY TIME" ATASCII_RIGHT ATASCII_RIGHT ATASCII_DOWN
	;TEXT "you get a frog across the river{right*9}"
	.by "YOU GET A FROG ACROSS THE RIVER" ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_DOWN
	;TEXT "{down*3}the controls are:-{right*22}"
	.by ATASCII_DOWN ATASCII_DOWN ATASCII_DOWN
	.by "THE CONTROLS ARE:-"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_DOWN
	;TEXT "{right*17}s = up{right*17}"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT "S = UP"      ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_DOWN
	;TEXT "{down}{right*2}4 = left{right*18}6 = right{right*2}"
	.by ATASCII_DOWN  ATASCII_RIGHT ATASCII_RIGHT "4 = LEFT"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_RIGHT ATASCII_RIGHT "6 = RIGHT"   ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_DOWN
	;TEXT "{down*2}{reverse on}{right*6}hit  a key to start the game{right*6}"
	.by ATASCII_DOWN  ATASCII_DOWN ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by +$80 "HIT A KEY TO START THE GAME"
	.by ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT ATASCII_RIGHT
	.by ATASCII_EOL
	brk

; ==========================================================================
; Atari stuff.
; The game never uses the 25th text line, so that conveniently allows a 
; place to put the porting credit.  Cheap and dirty.  Just direct copy,
; because the OS printing can only write to the top 24 lines.
PORTBYTEXT
	.sb '  Atari port by Ken Jennings, Nov 2018  '

PRINTPORTBYTEXT
	ldy #39             ; Loop 40 bytes from +39 to +0
PORTBYLOOP
	lda PORTBYTEXT,y    ; Read from text block + Y
	sta SCREENMEM+960,y ; Write to screen's 25th line + Y
	dey                 ; next (previous) byte
	bpl PORTBYLOOP      ; If still 0 to 39, then continue loop

	rts


; ==========================================================================
; Atari stuff.   
; Necessary Central I/O values for putch to screen.
;
; If OS.asm is not included, then you need these declared:
;
;IOCB = $0340     ; Base IO Control Block, Channel 0, E: by default
;
;ICPTL = IOCB+$06 ; Put char routine (low)
;ICPTH = IOCB+$07 ; Put char routine (high)

; Borrow page 0 locations to preserve X and Y registers,
; because the PutCH will change everything.
SAVEY = $FF
SAVEX = $FE


; ==========================================================================
; Write a character to the screen.
;
; Due to foolish hackery in PutCH, provide a wrapper function to save
; register(s) for return to the caller.
;---------------------------------------------------------------------
fputc
	sty SAVEY  ; Need to save Y for printing index.  PutCH will change it.
	stx SAVEX  ; Need to save X also, since PutCH will change it.
	jsr PutCH  ; Uses the CIO PutCH in IOCB0
	ldy SAVEY  ; Restore Y.
	ldx SAVEX  ; Restore X.
	rts


; ==========================================================================
; Write a character to the screen.
; Rather than doing the whole setup for an IOCB call, cheat by using the  
; put character vector in the Channel 0 IOCB meant for BASIC. 
;
; Push the address of the E: device PutChar routine held in 
; IOCB0 onto the stack and call it. 
;
; INPUT:
; A = character to write
;
; NOTE:
; OS will modify all registers.
;---------------------------------------------------------------------
PutCH
	sta OUTPUT ; Self modifying code - save the byte below.

	lda ICPTH ; High byte for Put Char in E:/IOCB Channel 0.
	pha       ; Push to stack

	lda ICPTL ; Low byte for Put Char in E:/IOCB Channel 0.
	pha       ; Push to stack

OUTPUT = *+1
	lda #$00 ; Modified at routine entry.

	; This rts actually triggers calling the address of PutCH
	; that was pushed onto the stack above.
	; This hackery means the caller must restore Y register. 
	rts  


; ==========================================================================
; Atari does not have a "Home" character, so we need to set 
; cursor position ourselves. 
; Do POSITION 0,0.
;---------------------------------------------------------------------
POSITION
	sty SAVEY  ; Need to save Y for printing index.

	ldy #0
	sty COLCRS   ; Column, X position.
	sty COLCRS+1
	sty ROWCRS   ; Row, Y position.

	ldy SAVEY
	rts


; ==========================================================================
; When a custom character set is used, it would go here:

;	ORG $7800 ; 1K from $7800 to $7BFF
;CHARACTERSET


; ==========================================================================
; Force the Atari to impersonate the PET 4032 by setting the 40-column
; text mode memory to the same fixed address.  This minimizes the 
; amount of code changes for screen memory.
;
; But First we need a 25-line ANTIC Mode 2 text screen which means a  
; custom display list.
; 
; Since the OS only understands 24 lines it can do standard printing to those
; lines, but the 25th line requires some code shenanigans.

	ORG $7FD8  ; $xxD8 to xxFF - more than enough space for Display List
	
DISPLAYLIST
	.byte DL_BLANK_8, DL_BLANK_8, DL_BLANK_4 ; 20 blank scan lines.
	mDL_LMS DL_TEXT_2,SCREENMEM              ; Mode 2 text and Load Memory Scan for text/graphics
	.rept 24
		.byte DL_TEXT_2                      ; 24 more lines of Mode 2 text.
	.endr
	.byte DL_JUMP_VB
	.word DISPLAYLIST

	ORG $8000 ; The same location the Pet uses for screen memory.

SCREENMEM

	END

