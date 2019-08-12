; ==========================================================================
; Pet Frogger
; (c) November 1983 by John C. Dale, aka Dalesoft
; for the Commodore Pet 4032
; ==========================================================================
; Ported (parodied) to Atari 8-bit computers
; by Ken Jennings (if this were 1983, aka FTR Enterprises)
; ==========================================================================
; Version 00, November 2018
; Version 01, December 2018
; Version 02, February 2019
; Version 03, July 2019
; ==========================================================================

; ==========================================================================
; SCREEN GRAPHICS
; ==========================================================================
; This should contain everything that pertains to changes in visible screen 
; components.  
; Managing the score/status lines.
; Managing scrolling boats/display lists.
; Maintaining the Player/missile objects, and moving the objects around. 
; Updating color table contents for each of the displays.

; The original Pet version mixed printing to the screen with direct
; writes to screen memory.  The printing required adjustments, because
; the Atari full screen editor works differently from the Pet terminal.

; Most of the ASCII/PETASCII/ATASCII is now removed.  No more "printing"
; to the screen.  Everything is directly written to the screen memory.
; All the data to write to the screen is declared, then the addresses to
; the data is listed in a table. Rather than several different screen
; printing routines there is now one display routine that accepts an index
; into the table driving the data movement to screen memory.  Since the
; data also has a declared length the end of text sentinel byte is no
; longer needed.
; --------------------------------------------------------------------------

; Display layouts and associated text blocks:

; Original V00 Title Screen and Instructions:
;    +----------------------------------------+
; 1  |              PET FROGGER               | INSTXT_1
; 2  |              --- -------               | INSTXT_1
; 3  |     (c) November 1983 by DalesOft      | INSTXT_1
; 4  |                                        |
; 5  |All you have to do is to get as many of | INSTXT_2
; 6  |the frogs across the river without      | INSTXT_2
; 7  |drowning them. You have to leap onto a  | INSTXT_2
; 8  |boat like this :- <QQQ] and land on the | INSTXT_2
; 9  |seats ('Q'). You get 10 points for every| INSTXT_2
; 10 |jump forward and 500 points every time  | INSTXT_2
; 11 |you get a frog across the river.        | INSTXT_2
; 12 |                                        |
; 13 |                                        |
; 14 |                                        |
; 15 |The controls are :-                     | INSTXT_3
; 16 |                 S = Up                 | INSTXT_3
; 17 |  4 = left                   6 = right  | INSTXT_3
; 18 |                                        |
; 19 |                                        |
; 20 |     Hit any key to start the game.     | INSTXT_4
; 21 |                                        |
; 22 |                                        |
; 23 |                                        |
; 24 |                                        |
; 25 |Atari V00 port by Ken Jennings, Nov 2018| PORTBYTEXT
;    +----------------------------------------+

;  Original V00 Main Game Play Screen:
;    +----------------------------------------+
; 1  |Successful Crossings =                  | SCORE_TXT
; 2  |Score = 00000000     Hi = 00000000  Lv:3| SCORE_TXT
; 3  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_1
; 4  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_1
; 5  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_1
; 6  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_2
; 7  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_2
; 8  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_2
; 9  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_3
; 10 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_3
; 11 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_3
; 12 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_4
; 13 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_4
; 14 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_4
; 15 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_5
; 16 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_5
; 17 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_5
; 18 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_6
; 29 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_6
; 20 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_6
; 21 |BBBBBBBBBBBBBBBBBBBOBBBBBBBBBBBBBBBBBBBB| TEXT2
; 22 |     (c) November 1983 by DalesOft      | TEXT2
; 23 |        Written by John C Dale          | TEXT2
; 24 |                                        |
; 25 |Atari V00 port by Ken Jennings, Nov 2018| PORTBYTEXT
;    +----------------------------------------+



; Revised V01 Title Screen and Instructions:
;    +----------------------------------------+
; 1  |              PET FROGGER               | TITLE
; 2  |              --- -------               | TITLE
; 3  |     (c) November 1983 by DalesOft      | CREDIT
; 4  |        Written by John C Dale          | CREDIT
; 5  |Atari V01 port by Ken Jennings, Dec 2018| CREDIT
; 6  |                                        |
; 7  |Help the frogs escape from Doc Hopper's | INSTXT_1
; 8  |frog legs fast food franchise! But, the | INSTXT_1
; 9  |frogs must cross piranha-infested rivers| INSTXT_1
; 10 |to reach freedom. You have three chances| INSTXT_1
; 11 |to prove your frog management skills by | INSTXT_1
; 12 |directing frogs to jump on boats in the | INSTXT_1
; 13 |rivers like this:  <QQQQ]  Land only on | INSTXT_1
; 14 |the seats in the boats ('Q').           | INSTXT_1
; 15 |                                        |
; 16 |Scoring:                                | INSTXT_2
; 17 |    10 points for each jump forward.    | INSTXT_2
; 18 |   500 points for each rescued frog.    | INSTXT_2
; 19 |                                        |
; 20 |Game controls:                          | INSTXT_3
; 21 |                 S = Up                 | INSTXT_3
; 22 |      left = 4           6 = right      | INSTXT_3
; 23 |                                        |
; 24 |     Hit any key to start the game.     | INSTXT_4
; 25 |                                        |
;    +----------------------------------------+

; Transition Title screen to Game Screen.
; Animate Credit lines down from Line 3 to Line 23.

; Revised V01 Main Game Play Screen:
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; 3  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_1
; 4  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_1
; 5  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_1
; 6  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_2
; 7  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_2
; 8  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_2
; 9  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_3
; 10 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_3
; 11 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_3
; 12 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_4
; 13 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_4
; 14 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_4
; 15 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_5
; 16 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_5
; 17 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_5
; 18 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_6
; 19 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_6
; 20 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_6
; 21 |BBBBBBBBBBBBBBBBBBBOBBBBBBBBBBBBBBBBBBBB| TEXT2
; 22 |                                        |
; 23 |     (c) November 1983 by DalesOft      | CREDIT
; 24 |        Written by John C Dale          | CREDIT
; 25 |Atari V01 port by Ken Jennings, Dec 2018| CREDIT
;    +----------------------------------------+



; Revised V02 Title Screen and Instructions:
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |                                        |
; 3  |              PET FROGGER               | TITLE
; 4  |              PET FROGGER               | TITLE
; 5  |              PET FROGGER               | TITLE
; 6  |              --- -------               | TITLE
; 7  |                                        |
; 8  |Help the frogs escape from Doc Hopper's | INSTXT_1
; 9  |frog legs fast food franchise! But, the | INSTXT_1
; 10 |frogs must cross piranha-infested rivers| INSTXT_1
; 11 |to reach freedom. You have three chances| INSTXT_1
; 12 |to prove your frog management skills by | INSTXT_1
; 13 |directing frogs to jump on boats in the | INSTXT_1
; 14 |rivers like this:  <QQQQ]  Land only on | INSTXT_1
; 15 |the seats in the boats ('Q').           | INSTXT_1
; 16 |                                        |
; 17 |Scoring:                                | INSTXT_2
; 18 |    10 points for each jump forward.    | INSTXT_2
; 19 |   500 points for each rescued frog.    | INSTXT_2
; 20 |                                        |
; 21 |Use joystick control to jump forward,   | INSTXT_3
; 22 |left, and right.                        | INSTXT_3
; 23 |                                        |
; 24 |   Press joystick button to continue.   | ANYBUTTON_MEM
; 25 |(c) November 1983 by DalesOft  Written b| SCROLLING CREDIT
;    +----------------------------------------+

; Revised V02 Main Game Play Screen:
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; 3  |                                        |
; 4  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_1
; 5  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_1
; 6  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_1
; 7  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_2
; 8  | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_2
; 9  |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_2
; 10 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_3
; 11 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_3
; 12 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_3
; 13 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_4
; 14 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_4
; 15 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_4
; 16 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_5
; 17 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_5
; 18 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_5
; 19 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_6
; 20 | [QQQQ>        [QQQQ>       [QQQQ>      | TEXT1_6
; 21 |      <QQQQ]        <QQQQ]    <QQQQ]    | TEXT1_6
; 22 |BBBBBBBBBBBBBBBBBBBOBBBBBBBBBBBBBBBBBBBB| TEXT2
; 23 |                                        |
; 24 |                                        |
; 25 |(c) November 1983 by DalesOft  Written b| SCROLLING CREDIT
;    +----------------------------------------+



; Revised V03 Title Screen and Instructions:
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0       00000000000000000000:Saved| SCORE_TXT
; 3  |              PET FROGGER               | TITLE
; 4  |              PET FROGGER               | TITLE
; 5  |              PET FROGGER               | TITLE
; 6  |              --- -------               | TITLE
; 7  |                                        |
; 8  |Help the frogs escape evil Doc Hopper's | INSTXT_1
; 9  |Frog Legs Fast Food Franchise! But, the | INSTXT_1
; 10 |frogs must cross piranha-infested rivers| INSTXT_1
; 11 |to reach freedom. You have three chances| INSTXT_1
; 12 |to prove your frog management skills by | INSTXT_1
; 13 |directing frogs to jump on boats in the | INSTXT_1
; 14 |rivers. Land in the middle of the boats.| INSTXT_1
; 15 |Do not fall off or jump in the river.   | INSTXT_1
; 16 |                                        |
; 17 |Scoring:                                | INSTXT_2
; 18 |    10 points for each jump forward.    | INSTXT_2
; 19 |   500 points for each saved frog.      | INSTXT_2
; 20 |                                        |
; 21 |Use the joystick control to jump        | INSTXT_3
; 22 |forward, left, and right.               | INSTXT_3
; 23 |                                        |
; 24 | Press the joystick button to continue. | ANYBUTTON_MEM
; 25 |(c) November 1983 by DalesOft  Written b| SCROLLING CREDIT
;    +----------------------------------------+

; Revised V03 Main Game Play Screen:
; FYI: Old boats.
; 8  | [QQQQ1        [QQQQ1       [QQQQ1      | TEXT1_2
; 9  |      <QQQQ0        <QQQQ0    <QQQQ0    | TEXT1_2
; New boats are larger to provide more safe surface for the larger 
; frog and to provide some additional graphics enhancement for 
; the boats.  Illustration below shows the entire memory needed 
; for scrolling.  Since boats on each row are identical, and 
; they are spaced equally, then scrolling only need move the 
; distance between two boats (16 chars), and then reset
; to the starting position. 
;    +----------------------------------------+
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0       00000000000000000000:Saved| SCORE_TXT
; 3  |                                        | 
; 4  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_1
; 5  |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        | ; Boats Right
; 6  |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        | ; Boats Left
; 7  |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_2
; 8  |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        |
; 9  |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 10 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_3
; 11 |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        |
; 12 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 13 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_4
; 14 |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        |
; 15 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 16 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_5
; 17 |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        |
; 18 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 19 |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB| TEXT1_6
; 20 |[[QQQQQ>        [[QQQQQ>        [[QQQQQ>        [[QQQQQ>        |
; 21 |<QQQQQ]]        <QQQQQ]]        <QQQQQ]]        <QQQQQ]]        |
; 22 |BBBBBBBBBBBBBBBBBBBOBBBBBBBBBBBBBBBBBBBB| TEXT2
; 23 |                                        |
; 24 |                                        |
; 25 |(c) November 1983 by DalesOft  Written b| SCROLLING CREDIT
;    +----------------------------------------+


STATUS_LUMA = 6 ; Base luminance for the status text.


; ==========================================================================
; D I S P L A Y S   A N D   P L A Y F I E L D 
; ==========================================================================


; ==========================================================================
; FLASH TITLE LABELS
; ==========================================================================
; Based on timer set high luminance colors for different screen labels.
; The VBI will reduce the brightness back to normal over time.
;
; AnimateFrames4 == timer to set the next label color
; EventCounter2  == number of label to change, 0, 1, 2, 3, 0, 1, 2, 3...
; --------------------------------------------------------------------------

FlashTitleLabels

	lda AnimateFrames4       ; Did the timer expire?
	bne EndFlashTitleLabels  ; No, nothing else to do.

	lda #30                  ; Reset the timer.
	sta AnimateFrames4          

	inc EventCounter2        ; Iterate the EventCounter 0, 1, 2, 3, 0, 1, 2....
	lda EventCounter2
	and #$03
	sta EventCounter2
	bne DoFlashHi            ; On 1, 2, 3 go to next nest.

	lda #COLOR_BLUE2+$0F     ; 0 is flash Score label.
	sta COLPM0_TABLE
	sta COLPM1_TABLE
	bne EndFlashTitleLabels

DoFlashHi                    ; 1 is flash the hi score label
	cmp #1
	bne DoFlashSaved 
	lda #COLOR_PINK+$0F      ; Flash Hi score label.
	sta COLPM2_TABLE
	bne EndFlashTitleLabels
	
DoFlashSaved                 ; 2 is flash the Saved frogs label
	cmp #2
	bne DoFlashLives
	lda #COLOR_GREEN+$0F
	sta COLPM2_TABLE+1
	sta COLPM3_TABLE+1
	bne EndFlashTitleLabels

DoFlashLives
	lda #COLOR_PURPLE+$0F    ; 3 is flash Frog lives label.
	sta COLPM0_TABLE+1
	sta COLPM1_TABLE+1

EndFlashTitleLabels
	rts


; ==========================================================================
; TITLE RENDER                                                        A
; ==========================================================================
; Copy the title image to the screen memory. 
; Accumulator determines behavior.
;
; Since screen memory has been restructured to perform horizontal scrolling,
; the coping and loading the displayed title is more complicated.
; 
; The defined/declared Title graphics are a block of 60 bytes. 
; The screen memory representation is a block of 120 bytes.  10 bytes on
; the left (default visible) and 10 bytes on the right (scroll-in buffer)
; 
;
; A == 0  Clear the Title.
; A == 1  Copy Title as is.
; A == -1 Use random value, mask with Title Image.
; ==========================================================================
; TITLE_START=TITLE_MEM1-1 ; Cheating. To show all color clocks from 
;                          ; TITLE_MEM1 the LMS is at * -1, and HSCROLL 0
; TITLE_END   = TITLE_START+10
;
; Values for manipulating screen memory.
; TITLE_LEFT  = TITLE_MEM1
; TITLE_RIGHT = TITLE_MEM1+10
;
; Start Scroll position = TITLE_START (Increment), HSCROL 0  (Decrement)
; End   Scroll position = TITLE_START + 9,         HSCROL 0
; --------------------------------------------------------------------------

TitleRender

	ldx #9                   ; 10 iterations/bytes instead of 60.

	cmp #0                   ; Is is to clear?
	beq bTR_LoopClearTitle   ; Yes.  Go clear.
	bmi bTR_LoopRandomTitle  ; No.  Next choice is the random rezz in.

bTR_loopCopyTitle
	lda TITLE_GFX,x          ; Read from Title Image
	sta TITLE_LEFT,x         ; Copy to screen memory.
	lda TITLE_GFX+10,x       ; And so on.
	sta TITLE_LEFT+20,x
	lda TITLE_GFX+20,x
	sta TITLE_LEFT+40,x
	lda TITLE_GFX+30,x
	sta TITLE_LEFT+60,x
	lda TITLE_GFX+40,x
	sta TITLE_LEFT+80,x
	lda TITLE_GFX+50,x
	sta TITLE_LEFT+100,x
	dex
	bpl bTR_loopCopyTitle

	rts

bTR_LoopClearTitle
	sta TITLE_LEFT,x
	sta TITLE_LEFT+20,x
	sta TITLE_LEFT+40,x
	sta TITLE_LEFT+60,x
	sta TITLE_LEFT+80,x
	sta TITLE_LEFT+100,x
	dex
	bpl bTR_LoopClearTitle

	rts

bTR_LoopRandomTitle
	lda RANDOM
	and TITLE_GFX,x
	sta TITLE_LEFT,x
	lda RANDOM
	and TITLE_GFX+10,x
	sta TITLE_LEFT+20,x
	lda RANDOM
	and TITLE_GFX+20,x
	sta TITLE_LEFT+40,x
	lda RANDOM
	and TITLE_GFX+30,x
	sta TITLE_LEFT+60,x
	lda RANDOM
	and TITLE_GFX+40,x
	sta TITLE_LEFT+80,x
	lda RANDOM
	and TITLE_GFX+50,x
	sta TITLE_LEFT+100,x
	dex
	bpl bTR_LoopRandomTitle

	rts


; ==========================================================================
; COPY SCORE TO SCREEN
; ==========================================================================
; Copy the score from memory to screen positions.
; --------------------------------------------------------------------------
; 1  |Score:00000000               00000000:Hi| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; --------------------------------------------------------------------------
; Game Score and High Score.
; This stays here and is copied to screen memory, because the math could
; temporarily generate a non-numeric character when there is carry, and I
; don't want that (possibly) visible on the screen however short it may be.
; Also, we have run out of adequate page 0 space, so these need to be 
; declared here, or wherever, doesn't matter... unless someone decides 
; to put this in a ROM card and then this is a problem.  In that case 
; there are a lot of things that have to change about screen memory and 
; other lists. 
; --------------------------------------------------------------------------

MyScore .sb "00000000"
HiScore .sb "00000000"

CopyScoreToScreen

	ldx #7
DoUpdateScreenScore
	lda MyScore,x       ; Read from Score buffer
	sta SCREEN_MYSCORE,x
	lda HiScore,x       ; Read from Hi Score buffer
	sta SCREEN_HISCORE,x
	dex                 ; Loop 8 bytes - 7 to 0.
	bpl DoUpdateScreenScore

	rts


; ==========================================================================
; CLEAR SAVED FROGS
; ==========================================================================
; Remove the number of saved frogs from the screen.
;
; 1  |0000000:Score                 Hi:0000000| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; --------------------------------------------------------------------------

ClearSavedFrogs

	lda #INTERNAL_SPACE ; Blank space. which also happens to be 0.

	ldx #20
RemoveFroggies
	sta SCREEN_SAVED-1,x      ; Write to screen 
	dex                       ; Erase county-counter frog character
	bne RemoveFroggies        ; then go back and remove the next frog counter.

	sta FrogsCrossed          ; reset count to 0.  (Remember A == space == 0 ?)
	clc                       ; Plus...
	adc NewLevelStart         ; the currently selected starting level.
	cmp #MAX_FROG_SPEED+1     ; Number of difficulty levels. 0 to 10 OK.  11 not so much
	bcc bCSF_SkipLimitCrossed 
	lda #MAX_FROG_SPEED       ; Or Reset to max level.

bCSF_SkipLimitCrossed
	sta FrogsCrossedIndex    ; sets the base index into difficulty arrays
	jsr MultiplyFrogsCrossed ; Multiply by 18, make index base, set difficulty address pointers.

	lda #COLOR_GREEN+$F      ; Glow the Saved label.  VBI will decrement it.
	sta COLPM2_TABLE+1       ; S a - - d
	sta COLPM3_TABLE+1       ; - - v e d

	rts


; ==========================================================================
; PRINT FROGS AND LIVES
; ==========================================================================
; Display the number of frogs that crossed the river and lives.
; There are two different character patterns that represent a frog 
; head used to indicate number of saved frogs. del/$7e and tab/$7f.
; These are alternated in the line, to make the 8-bit wide image 
; patterns discernible.  (The same image repeated looks a mess.)
; ==========================================================================
; 1  |0000000:Score                 Hi:0000000| SCORE_TXT
; 2  |Frogs:0    Frogs Saved:OOOOOOOOOOOOOOOOO| SCORE_TXT
; --------------------------------------------------------------------------
; New:
; 1  |Score:0000000                 0000000:Hi| SCORE_TXT
; 2  |Frogs:ooo     OOOOOOOOOOOOOOOOOOOO:Saved| SCORE_TXT
; --------------------------------------------------------------------------

PrintFrogsAndLives

	ldx FrogsCrossed    ; Number of times successfully crossed the rivers.
	beq WriteLives      ; then nothing to display. Skip to do lives.

	ldy #20             ; Start printing right to left from end of field.

	cpx #21             ; Limit saved frogs to the remaining width of screen
	bcc SavedFroggies

	ldx #20

SavedFroggies           ; Write an alternating pattern of Frog1, Frog2 characters.
	lda #I_FROG1        ; On Atari we're using tab/$7f as a frog shape.
	sta SCREEN_SAVED-1,y  ; Write to screen. 
	dey
	dex                 ; Decrement number of frogs.
	beq WriteLives      ; Reached 0, stop adding frogs.
	lda #I_FROG2        ; On Atari we're using del/$7e as a frog shape.
	sta SCREEN_SAVED-1,y  ; Write to screen. 
	dey
	dex                 ; Decrement number of frogs.
	bne SavedFroggies   ; then go back and display the next frog counter.

WriteLives
	ldy #0
	sty SCREEN_LIVES    ; Hackitty hack.  The code below does not remove 
	sty SCREEN_LIVES+1  ; missing/dead frogs.  oops.
	sty SCREEN_LIVES+2  ; 
	
	ldx NumberOfLives   ; Get number of lives.
	beq EndPrintFrogsAndLives

LoopWriteLives
	lda #I_FROG1        ; On Atari we're using tab/$7f as a frog shape.
	sta SCREEN_LIVES,y  ; Write to screen. 
	iny
	dex                 ; Decrement number of frogs.
	beq EndPrintFrogsAndLives ; Reached 0, stop adding frogs.
	lda #I_FROG2        ; On Atari we're using del/$7e as a frog shape.
	sta SCREEN_LIVES,y  ; Write to screen. 
	iny
	dex                 ; Decrement number of frogs.
	bne LoopWriteLives  ; then go back and display the next number of frogs.

EndPrintFrogsAndLives
	rts


; ==========================================================================
; CHANGE SCREEN                                                     A (Y)
; ==========================================================================
; Set a new display.
;
; 1. The Press Any Key Prompt is always disabled on the start of any screen.
; 2. Tell the VBI the screen ID.
; 3. Wait for the VBI to change the current display and update the
; 4. other pointers to the color tables.
; 5. Copy the color tables to the current lookups.
;
; A  is the DISPLAY_* value (defined elsewhere) for the desired display.
; Y  is used to turn off the Press A Button Prompt, and loop through 
;    the color tables.
; --------------------------------------------------------------------------

ChangeScreen

	sta VBICurrentDL                  ; Tell VBI to change to new display mode.

	jsr HideButtonPrompt              ; Always tell the VBI to stop the prompt. (This preserves A)

	; While waiting for the VBI to do its part, lets do something useful.
	; Display Win, Display Dead and Display Game Over are the same display lists.  
	; The only difference is the LMS to point to the big text.
	; So, reassign that here.

	pha                               ; Save Display number for later.
	tay
	lda DISPLAYLIST_GFXLMS_TABLE,y    ; Get the new address.
	sta GFX_LMS                       ; Save in the Win/Dead/Over display list.

	; ALSO, the Game screen needs the mask borders on the left and right sides
	; of the screen.   Determine if we need to do it or not do it and then
	; draw or erase the borders accordingly.

bCSCheckScreenBorders
	lda DISPLAY_NEEDS_BORDERS_TABLE,y ; Does this display need the P/M graphics borders? 
	beq bCSNoBorders                  ; If it is 0 it is not needed.  Erase it this.
	jsr DrawGameBorder                ; Game screen needs left and right sides masked.
	jmp bCSContinueUpdate

bCSNoBorders
	jsr EraseGameBorder

	; Back to checking on what the VBI has accomplished...
bCSContinueUpdate
	pla                               ; Get the display number back.

LoopChangeScreenWaitForVBI            ; Wait for VBI to signal the values changed.
	cmp VBICurrentDL                  ; Is the DISPLAY value the same?
	beq LoopChangeScreenWaitForVBI    ; Yes. Keep looping.

	; The VBI has changed the display and loaded page zero pointers.
	tay
	jsr CopyBaseColors    ; Now update the DLI color tables.

	jsr CopyPMGBase       ; And update the base player/missile data.

	rts


; ==========================================================================
; C O L O R   T A B L E S
; ==========================================================================

; ==========================================================================
; ZERO CURRENT COLORS                                                 A  Y
; ==========================================================================
; Force all the colors in the current tables to black.
; Used to insure black screen BEFORE  fading up the Game screen.
; Note that we do not want to zero colors for the status lines 
; on the Game screen.
; --------------------------------------------------------------------------

ZeroCurrentColors

	ldy #21  

LoopZeroColors
	lda #0
	jsr NukeAllColorsFromOrbitToBeSure ; Sets all colors.  Decrements Y.

	lda CurrentDL
	cmp #DISPLAY_GAME
	bne bZCC_CheckZero
	cpy #2
	beq ExitZeroCurrentColors
	bne LoopZeroColors

bZCC_CheckZero
	cpy #$FF
	beq ExitZeroCurrentColors
	bne LoopZeroColors

ExitZeroCurrentColors
	jsr HideButtonPrompt

	rts


; ==========================================================================
; FLIP OFF EVERYTHING (MATCHING)                                   A  Y  X
; ==========================================================================
; Turn off a bit in the value keeping track of multiple bits 
; indicating which values match or do not match.
;
; Exit with 0 flag.
;
; Uses Page 0 value: EverythingMatches
;
; A  is the mask to apply to the tracking bits.
; --------------------------------------------------------------------------

FlipOffEverything

	and EverythingMatches
	sta EverythingMatches    ; Save the finished flag.  
	lda #0                   ; So the caller can BEQ
	rts


; ==========================================================================
; DEAD FROG RAIN                                                A  Y  X
; ==========================================================================
; Dark to light color scroller, moving down the screen.  
; Apply to only the background lines above and below the text.
;
; Uses EventCounter as the current base color.
; 
; Stopping this is under the caller's control (button pressed, then 
; move on to a different animation stage.)
; --------------------------------------------------------------------------

DeadFrogRain

	dec EventCounter            ; Increment base color 
	dec EventCounter            ; Twice.  (need to use even numbers.)
	lda EventCounter            ; Get value 
	and #$0F                    ; Keep this truncated to grey (black) $0 to $F
	sta EventCounter            ; Save it for next time.

	ldy #2 ; Top 20 lines of screen...
DeadLoopTopOverGrey
	jsr DeadFrogGreyScroll      ; Increments and color stuffing.
	cpy #21                     ; Reached the 19th line?
	bne DeadLoopTopOverGrey     ; No, continue looping.

	ldy #29 ; Bottom 20 lines of screen (above prompt and credits.)
DeadLoopBottomOverGrey
	jsr DeadFrogGreyScroll      ; Increments and color stuffing.
	cpy #48                     ; Reached the 23rd line?
	bne DeadLoopBottomOverGrey  ; No, continue looping.
;	beq EndDeadScreen
	
	rts


; ==========================================================================
; BLACK SPLASH BACKGROUND                                           A  Y  
; ==========================================================================
; For the Splash screens, set the background above the big splash text 
; and below the text to black.  No gradual fading.
;
; On switching to the game screen from a splash screen there is 
; sometimes flashing of the score line.  This was because splash 
; screens were not using COLPF1, but the values were still present 
; from the game and were visible for a moment when the display changes
; back to the game.  So, for the sake of mental cleanliness the program 
; nukes the entire set of colors from orbit. Its the only way to be sure.
;
; Only on the game over screen also do lines 21 to 26 for the text.
; --------------------------------------------------------------------------

BlackSplashBackground

	lda #COLOR_BLACK

	ldy #21 ; Top 20 lines of screen...
SplashLoopTopToBlack                   ; Filling the top
	jsr NukeAllColorsFromOrbitToBeSure ; Also decrements Y
	bne SplashLoopTopToBlack           ; Continue looping.  Ends at 0.

	ldx CurrentDL                      ; Only the Game Over display clears the middle.
	cpx #DISPLAY_OVER                  ; Is it game over?
	bne ContinueSplashBottomToBlack    ; Nope.  Skip to the bottom

	ldy #27 ; Middle six lines of the text background. 
SplashLoopMidToBlack
	sta COLBK_TABLE,y ; only background, because we need to fade text later.
	dey
	cpy #21                            ; Filling the middle
	bne SplashLoopMidToBlack           ; No, continue looping.

ContinueSplashBottomToBlack
	ldy #47 ; Bottom 20 lines of screen (above prompt and credits.
SplashLoopBottomToBlack
	jsr NukeAllColorsFromOrbitToBeSure ; Also decrements Y

	cpy #27                            ; Reached the last line?
	bne SplashLoopBottomToBlack        ; No, continue looping.

	rts


; ==========================================================================
; NUKE ALL COLORS FROM ORBIT TO BE SURE                               A  Y  
; ==========================================================================
; Support function for setting colors.
; Write the same value to a specific entry in all color tables.
; Typically, this will be black.
; Then decrement the Y index.
;
; A = the color value to use.
; Y = the index into the color tables.
; --------------------------------------------------------------------------

NukeAllColorsFromOrbitToBeSure

	sta COLBK_TABLE,y           ; Zero Background
	sta COLPF0_TABLE,y          ; Zero pixel (or text)
	sta COLPF1_TABLE,y          ; Zero text
	sta COLPF2_TABLE,y          ; Zero something else

	pha
	ldx CurrentDL
	cpx #DISPLAY_OVER
	bne DoNotUseWhite
	lda #COLOR_BLACK+$0e

DoNotUseWhite
	sta COLPF3_TABLE,y          ; Zero this too
	pla

	dey

	rts


; ==========================================================================
; FADE SPLASH TEXT BACKGROUND                                      A  X
; ==========================================================================
; For the Splash screens, fade the background of the text to black. 
; If the current line's luminance matches the reference value, then 
; decrement it.
; At the end, decrement the reference value. 
; When the reference value is 0, then set all to black. 
; Gradual fade on each pass.
;
; Uses EventCounter for the reference luminance.  must start at $0E
;
; Returns flags based on Event counter.  BMI means fade finished.
; --------------------------------------------------------------------------

FadeSplashTextBackground

	ldx #22                         ; Text lines 22 to 27 ...
bFSTB_LoopTextBackFade
	lda COLBK_TABLE,x               ; Get the color
	and #$0F                        ; Mask out color. Keep only the luminance.
	cmp EventCounter                ; Compare to target luminance
	bne bFSTB_LoopTextBackInc       ; not the same, so skip it.
	dec COLBK_TABLE,x               ; The same.  Decrement luminance
	dec COLBK_TABLE,x               ; Decrement luminance again.

bFSTB_LoopTextBackInc
	inx                             ; Go to the next line
	cpx #28                         ; There yet?
	bne bFSTB_LoopTextBackFade      ; No, continue looping.

	dec EventCounter                ; Reduce target luminance,
	dec EventCounter                ; and again.
	bpl EndFadeSplashTextBackground ; 0 is legit.  Only finish here on negative something.

	; Now that luminance for all is 0, force all to black.
	lda #COLOR_BLACK
	ldx #22                         ; Text lines 22 to 27 ...
bFSTB_LoopTextBackToBlack
	sta COLBK_TABLE,x               ; Zero/black it.
	inx
	cpx #28  
	bne bFSTB_LoopTextBackToBlack   ; do while more rows to black out.

	lda #$FF                        ; Let the caller know - Really, really done.

EndFadeSplashTextBackground

	rts


; ==========================================================================
; FADE SPLASH TEXT                                                  A  X
; ==========================================================================
; For the Splash screens, fade the text to black. 
; The same basic operations as FadeSplashTextBackground above, but this is
; for COLPF0 instead of COLBK.
; If the current line's luminance matches the reference value, then 
; decrement it.
; At the end, decrement the reference value. 
; when the reference value is 0, then set all to black. 
; Gradual fade on each pass.
;
; Uses EventCounter for the reference luminance.  must start at $0E
;
; Returns flags based on Event counter.  BMI means fade finished.
; --------------------------------------------------------------------------

FadeSplashText

	ldx #22                         ; Text lines 22 to 27 ...
bFST_LoopTextFade
	lda COLPF0_TABLE,x              ; Get the color
	and #$0F                        ; Mask out color.  Keep the luminance.
	cmp EventCounter                ; Compare to target luminance
	bne bFST_LoopTextInc            ; Not the same, so skip it.
	dec COLPF0_TABLE,x              ; The same luma, so decrement it.
	dec COLPF0_TABLE,x              ; Decrement again.

bFST_LoopTextInc
	inx                             ; Go to the next line.
	cpx #28                         ; Reached the end?
	bne bFST_LoopTextFade           ; No, continue looping.

	dec EventCounter                ; Reduce target luminance,
	dec EventCounter                ; and again.
	bpl EndFadeSplashText

	; Now that luminance are 0, then force all to black.
	lda #COLOR_BLACK
	ldx #22                         ; Text lines 22 to 27 ...
bFST_LoopTextToBlack
	sta COLPF0_TABLE,x              ; Zero/black it.
	inx
	cpx #28  
	bne bFST_LoopTextToBlack        ; Do while more rows to black out.

	lda #$FF                        ; Let the caller know - Really, really done.

EndFadeSplashText
	rts


; ==========================================================================
; COMMON SPLASH FADE 123                                           
; ==========================================================================
; One set of code to run Stage 1, 2, 3, screen fade results.
; 1) Black background for scrolling colors in one pass.
; 2) Fade background colors behind text until it reaches 0.
; 3) Fade text colors to black.
;
; Expectations:
;;; EventCounter is initialized to $E0 before calling this.
; EventStage is initialized to 1 to start the first stage.
; The caller is expected to have a use for EventStage = 4 
; (i.e to stop calling this part.) 
;
; The Game Over screen bypasses stage 2 as it finishes blacking its 
; background during Stage 1.
; --------------------------------------------------------------------------

CommonSplashFade

	lda EventStage

SplashStageOne                    ; Stage 1 is set background black.             
	cmp #1
	bne SplashStageTwo

	jsr BlackSplashBackground     ; Set non-text background to black.

	lda #$0e
	sta EventCounter              ; Luminance matching for fade
	inc EventStage                ; Set Stage = 2

	ldx CurrentDL                 ; The Game Over Display already cleared the entire background
	cpx #DISPLAY_OVER             ; Is it Game Over? (and stage 2 is not needed?)
	bne EndCommonSplashFade       ; No. End with Stage 2 as current stage
	inc EventStage                ; Set Stage = 3

	bne EndCommonSplashFade


SplashStageTwo                    ; Stage 2 is fading the text background
	cmp #2
	bne SplashStageThree          ; Not Stage 2.

	jsr FadeSplashTextBackground  ; Like it says, Fade Splash Text Background
	bpl EndCommonSplashFade       ; Not negative return means we're done for this pass.

	lda #$0e                      ; Negative return.
	sta EventCounter              ; Luminance matching for fade
	inc EventStage                ; Set Stage = 3

	bne EndCommonSplashFade


SplashStageThree                  ; Stage 3 is fading the text 
	cmp #3
	bne EndCommonSplashFade       ; Not stage 3.  So why did the caller call this?

	jsr FadeSplashText            ; Like it says, Fade Splash Text 
	bpl EndCommonSplashFade       ; Not negative return means we're done for this pass.

	inc EventStage                ; Negative return.  Set Stage = 4


EndCommonSplashFade
	lda EventStage                ; Make sure A = EventStage on exit.

	rts


; ==========================================================================
; INCREMENT GAME COLOR                                            A  Y  X
; ==========================================================================
; Merge the current luminance to the target color.
; Increment the current luminance.
;
; Inputs:
; A = target color
; Y = current color.
;
; Uses Page 0 locations: TempSaveColor, TempTargetColor
;
; Output:
; A = New current color.
; --------------------------------------------------------------------------

; Such sloppiness....  gah!
IncrementGameColor      ; Y = current color.   A = target color

	sta TempTargetColor
	and #$F0            ; Extract target color part (to be joined to current luminance)
	sta TempSaveColor   ; Keep color
	tya                 ; A = Current color from Y.
	and #$0F            ; Extract current luminance.
	ora TempSaveColor   ; Join current luminance to target color for new current base color.
	cmp TempTargetColor ; Is the new save color already the same as the target?
	beq SkipIncCurrent  ; Do not change the value. 
	tay                 ; Current color back to Y for increments
	iny
	iny
	tya                 ; A = new current color.
	
SkipIncCurrent
	rts


; ==========================================================================
; INCREMENT TABLE COLORS                                          A  Y  X
; ==========================================================================
; Increment color table luminance values until they reach target values.
; Exit with 0 flag when all values are matching.
;
; I'm sure there's a smarter way to drive this off a list of data
; and make this smaller code.
;
; Uses Page 0 value: EverythingMatches
;
; X  is the index into the tables. 
; --------------------------------------------------------------------------

IncrementTableColors

	lda #%00011111       ; Flags indicate nothing matches yet.
	sta EverythingMatches

bDoTestCOLBK
	lda COLBK_TABLE,x        ; Get the current color. 
	cmp GAME_BACK_COLORS,x   ; Is it the same as the Target color?
	bne bDoIncCOLBK          ; No.  Go inc the luminance.
	lda #%00001111           ; Yes, turn off $10 .
	jsr FlipOffEverything    
	beq bDoTestCOLPF0        ; Do the next color.

bDoIncCOLBK
	tay                      ; Y = current color
	lda GAME_BACK_COLORS,x   ; A = target color
	jsr IncrementGameColor   ; Merge and increment color.
	sta COLBK_TABLE,x        ; Save the result.

bDoTestCOLPF0
	lda COLPF0_TABLE,x       ; Get the current color. 
	cmp GAME_COLPF0_COLORS,x ; Is it the same as the Target color?
	bne bDoIncCOLPF0         ; No.  Go inc the luminance.
	lda #%00010111           ; Yes, turn off $08 .
	jsr FlipOffEverything    
	beq bDoTestCOLPF1        ; Do the next color.

bDoIncCOLPF0
	tay                      ; Y = current color
	lda GAME_COLPF0_COLORS,x ; A = target color
	jsr IncrementGameColor   ; Merge and increment color.
	sta COLPF0_TABLE,x       ; Save the result.

bDoTestCOLPF1
	lda COLPF1_TABLE,x       ; Get the current color. 
	cmp GAME_COLPF1_COLORS,x ; Is it the same as the Target color?
	bne bDoIncCOLPF1         ; No.  Go inc the luminance.
	lda #%00011011           ; Yes, turn off $04.
	jsr FlipOffEverything    
	beq bDoTestCOLPF2        ; Do the next color.

bDoIncCOLPF1
	tay                      ; Y = current color
	lda GAME_COLPF1_COLORS,x ; A = target color
	jsr IncrementGameColor   ; Merge and increment color.
	sta COLPF1_TABLE,x       ; Save the result.

bDoTestCOLPF2
	lda COLPF2_TABLE,x       ; Get the current color. 
	cmp GAME_COLPF2_COLORS,x ; Is it the same as the Target color?
	bne bDoIncCOLPF2         ; No.  Go inc the luminance.
	lda #%00011101           ; Yes, turn off $02.
	jsr FlipOffEverything    
	beq bDoTestCOLPF3  ; Done With Everything.

bDoIncCOLPF2
	tay                      ; Y = current color
	lda GAME_COLPF2_COLORS,x ; A = target color
	jsr IncrementGameColor   ; Merge and increment color.
	sta COLPF2_TABLE,x       ; Save the result.

bDoTestCOLPF3
	lda COLPF3_TABLE,x       ; Get the current color. 
	cmp GAME_COLPF3_COLORS,x ; Is it the same as the Target color?
	bne bDoIncCOLPF3         ; No.  Go inc the luminance.
	lda #%00011110           ; Yes, turn off $01.
	jsr FlipOffEverything    
	beq bDoneWithEverything  ; Done With Everything.

bDoIncCOLPF3
	tay                      ; Y = current color
	lda GAME_COLPF3_COLORS,x ; A = target color
	jsr IncrementGameColor   ; Merge and increment color.
	sta COLPF3_TABLE,x       ; Save the result.

bDoneWithEverything
	lda EverythingMatches    ; If all flags are turned off the caller knows this row is done.

	rts


; ==========================================================================
; COPY BASE COLORS                                                    A Y
; ==========================================================================
; Copy the base colors for the current display.
;
; Base colors means the background, COLPF0 for pixels for Mode 9 graphics, 
; and COLPF1 for text on Mode 2 text lines.
;
; Game screen uses all color registers and its setup is custom, so here
; the colors are simply left black for the game screen.
;
; Y  =  is the DISPLAY_* value (defined elsewhere) for the desired display.
; --------------------------------------------------------------------------

COPY_BASE_SIZE_TABLE ; Starting point at end of table to copy. (Game screen is 0, for custom)
	.by 25 0 47 47 47


CopyBaseColors

	cpy #MAX_DISPLAYS         ; 5.
	bcs EndCopyBaseColors     ; 5 or more is invalid display number. Exit.

	cpy #DISPLAY_GAME         ; Is it the Game screen?
	bne bCBC_SkipGameScreen   ; Nope, do the usual (below).
	jmp ZeroCurrentColors     ; Jmp instead of Jsr will return to the original caller

bCBC_SkipGameScreen
	lda COLOR_BACK_LO_TABLE,y ; Get Pointer to background colors
	sta MainPointer1
	lda COLOR_BACK_HI_TABLE,y
	sta MainPointer1+1
	
	lda COLOR_TEXT_LO_TABLE,y ; Get Pointer to "text"/foreground colors.
	sta MainPointer2
	lda COLOR_TEXT_HI_TABLE,y
	sta MainPointer2+1

	lda COPY_BASE_SIZE_TABLE,y ; How many times to loop? 
	tay                        ; Looping this many times...
 
bCBC_LoopCopyColors
	lda (MainPointer1),y       ; TITLE_BACK_COLORS,x
	sta COLBK_TABLE,y

	lda (MainPointer2),y       ; TITLE_TEXT_COLORS,x
	sta COLPF1_TABLE,y         ; Title screen has "text" using ANTIC Mode 2
	sta COLPF0_TABLE,y         ; All displays use COLPF0 for pixel graphics colors.

	dey
	bne bCBC_LoopCopyColors   ; Do while more colors. (Note 0 entry is actually not needed, so not used.)

EndCopyBaseColors
	rts                  


; ==========================================================================
; DEAD FROG GREY SCROLL
; ==========================================================================
; Redundant code section used for two separate loops in the Dead Frog event.
;
; --------------------------------------------------------------------------

DeadFrogGreyScroll

	sta COLBK_TABLE,y          ; Set line on screen
	tax                         ; X = A
	inx                         ; X = X + 1
	inx                         ; X = X + 1
	txa                         ; A = X
	and #$0F                    ; Keep this truncated to grey (black) $0 to $F
	iny                         ; Next line on screen.

	rts


; ==========================================================================
; GAME OVER RED SINE
; ==========================================================================
; Game Over background color scroll.
;
; --------------------------------------------------------------------------

GameOverRedSine

	ldx EventCounter         ; Get starting color index.
	inx                      ; Next index. 
	cpx #20                  ; Did index reach the repeat?
	bne SkipZeroOverCycle    ; Nope.
	ldx #0                   ; Yes, restart at 0.
SkipZeroOverCycle
	stx EventCounter         ; And save for next time.

	ldy #2 ; All the background lines on the screen
LoopTopOverSine
	jsr OverRedScroll        ; Increments and color stuffing.
	cpx #20
	bne SkipZeroOverCycle2
	ldx #0
SkipZeroOverCycle2
	cpy #48 ;                ; Reached the last line?
	bne LoopTopOverSine      ; No, continue looping.

	rts


; ==========================================================================
; OVER RED SCROLL
; ==========================================================================
; Redundant code section used for two separate loops in the Dead Frog event.
;
; --------------------------------------------------------------------------

OverRedScroll

	lda DEAD_COLOR_SINE_TABLE,x ; Get another color
	sta COLBK_TABLE,y           ; Set line on screen
	inx                         ; Next color entry
	iny                         ; Next line on screen.

	rts

DEAD_COLOR_SINE_TABLE ; 20 entries.
	.byte COLOR_RED_ORANGE+6, COLOR_RED_ORANGE+8, COLOR_RED_ORANGE+10,COLOR_RED_ORANGE+12
	.byte COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+14,COLOR_RED_ORANGE+12
	.byte COLOR_RED_ORANGE+10,COLOR_RED_ORANGE+8, COLOR_RED_ORANGE+6, COLOR_RED_ORANGE+4
	.byte COLOR_RED_ORANGE+2, COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+0
	.byte COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+0, COLOR_RED_ORANGE+2, COLOR_RED_ORANGE+4


; ==========================================================================
; WIN COLOR SCROLL UP                                                   A
; ==========================================================================
; Support function.
; Redundant code section used for two separate places in the Win event.
; Subtract 4 from the current color.
; Reset to 238 if the limit 14 (== 18-4) is reached.
;
; A  is the current color.   
; --------------------------------------------------------------------------

WinColorScrollUp

	sec
	sbc #4                      ; Subtract 4
 	cmp #14                     ; Did it pass the limit (minimum 18, minus 4 == 14)
	bne ExitWinColorScrollUp    ; No. We're done here.
	lda #238                    ; Yes.  Reset back to start.

ExitWinColorScrollUp
	rts


; ==========================================================================
; WIN COLOR SCROLL DOWN                                                 A
; ==========================================================================
; Support function.
; Redundant code section used for two separate places in the Win event.
; Add 4 to the current color.
; Reset to 18 if the limit 242 (== 238 + 4) is reached.
;
; A  is the current color.   
; --------------------------------------------------------------------------

WinColorScrollDown

	clc
	adc #4                      ; Add 4
 	cmp #242                    ; Did it pass the limit (max 238, plus 4 == 242)
	bne ExitWinColorScrollDown  ; No. We're done here.
	lda #18                     ; Yes.  Reset back to start.

ExitWinColorScrollDown
	rts


; ==========================================================================
; WIN RANINBOW
; ==========================================================================
; Scroll Rainbow colors on screen while waiting for a button press.
; Scroll up at top. light to dark.  
; Scroll down at bottom.  Dark to light.
; Do not use $0x or $Fx  (Min 16, max 238)
; 
; Setup for next transition in EventCounter.
; --------------------------------------------------------------------------

WinRainbow

; ======================== T O P ========================  
; Color scrolling skips the black/grey/white values.  
; The scrolling uses values 238 to 18 step -4
	lda EventCounter        ; Get starting value from last frame
	jsr WinColorScrollUp    ; Subtract 4 and reset to start if needed.
	sta EventCounter        ; Save it for next time.

	ldy #2 ; Color the Top 20 lines of screen...
LoopTopWinScroll
	sta COLBK_TABLE,y       ; Set color for line on screen
	jsr WinColorScrollUp    ; Subtract 4 and reset to start if needed.

	iny                     ; Next line on screen.
	cpy #20                 ; Reached the 19th (20th table entry) line?
	bne LoopTopWinScroll    ; No, continue looping.

	pha                     ; Save current color to use as start value later.

; ======================== M I D D L E ========================  
; Background/COLBK in the text section is static in the color tables.
; Manipulate current color to make it the "inverse" color for the Text.
	eor #$F0                ; Invert color bits for the middle SAVED text.
	and #$F0                ; Truncate luminance bits.
	ora #$02                ; Start at +2.

	ldy #27                 ; Start at bottom of text going backwards.
bews_LoopTextColors
	sta COLPF0_TABLE,Y      ; Use as manipulated color for 
	clc                     ; the six lines of giant label "text."
	adc #2                  ; brightness:  2, 4, 6, 8, A, C
	dey
	cpy #21
	bne bews_LoopTextColors

; ======================== B O T T O M ========================  
	pla                         ; Get the color back for scrolling the bottom. 

; Color scrolling skips the black/grey/white values.  
; The scrolling uses values 18 to 238 step +4
	ldy #29                 ; Bottom 20 lines of screen (above prompt and credits.)
LoopBottomWinScroll         ; Scroll colors in opposite direction
	jsr WinColorScrollDown  ; Add 4, and reset to start if needed.
	sta COLBK_TABLE,y       ; Set color for line on screen
	iny                     ; Next line on screen.
	cpy #48                 ; Reached the end, 20th line after text? 
	bne LoopBottomWinScroll ; No, continue looping.

EndWinRainbow

	rts


; ==========================================================================
; SLICE COLOR AND LUMA                                              A  Y
; ==========================================================================
; Supporting the support function. Decrement Title text colors.
;
; Separate luminance from color. 
; If luminance is already 0, then return color as 0.
; Decrement the luminance.
; Recombine with original color.
; 
; A = color value to adjust
; --------------------------------------------------------------------------

SliceColorAndLuma

	sta SavePF                ; Save the incoming value
	and #$F0                  ; Mask out the luminance.
	sta SavePFC               ; Save just the color part.

	lda SavePF                ; Get the original value again.
	and #$0F                  ; Now check keep the luminance.
	beq ExitSliceColorAndLuma ; If it is 0, we can exit with A as color/lum 0.

	tay                       ; Y = A = Luminance
	dey                       ; Dec
	beq Reassemble_PF         ; If 0, then we're done.
	dey                       ; Dec twice to speed the transition.

Reassemble_PF
	tya                       ; A = Y = Luminance
	ora SavePFC               ; join the color.

ExitSliceColorAndLuma
	rts


; ==========================================================================
; FADE COLPF TO BLACK
; ==========================================================================
; Support function. Decrement Title text colors.
; 
; Cut out of the EventTransitionToGame, it makes that shorter and more 
; readable, and allows the start to branch to the end/exit point.
;
; BEQ state is exit immediate exit. (Text value has reached 0)
; --------------------------------------------------------------------------
; === STAGE 1 ===
; ; Fade out text lines  from bottom to top.
; Fade out COLPF0 and COLPF1 at the same time.
; When luminance reaches 0, set color to 0. 
; Return flags the OR value of the COLPF0 and COLPF1.
; --------------------------------------------------------------------------

FadeColPfToBlack

	ldx EventCounter2         ; Row counter decrementing.

	lda COLPF1_TABLE,x
	beq TryCOLPF0             ; It is already 0, so skip this.
	jsr SliceColorAndLuma
	sta COLPF1_TABLE,x

TryCOLPF0
	lda COLPF0_TABLE,x
	beq ExitFadeColPfToBlack  ; It is already 0, so skip this.
	jsr SliceColorAndLuma
	sta COLPF0_TABLE,x

ExitFadeColPfToBlack          ; Insure we're leaving with 0 for both colors 0.  Or !0 otherwise.
	lda COLPF0_TABLE,x        ; Get current color 0
	ora COLPF1_TABLE,x        ; ORA the value of color 0

	rts


; ==========================================================================
; GREY EACH COLOR TABLE
; ==========================================================================
; Support function. Turn color table entries to grey. 
; 
; Replace all the color components of the current row with the 
; chosen color. 
;
; Grey doesn't necessarily mean grey. It would be whatever the chosen 
; base color is which is passed in the A register. 
;
; Uses TempWipeColor in page 0.
; X = current Row
; A = color to use.
; --------------------------------------------------------------------------

GreyEachColorTable

	sta TempWipeColor

	lda COLPF0_TABLE+3,x
	and #$0F
	ora TempWipeColor
	sta COLPF0_TABLE+3,x

	lda COLPF1_TABLE+3,x
	and #$0F
	ora TempWipeColor
	sta COLPF1_TABLE+3,x

	lda COLPF2_TABLE+3,x
	and #$0F
	ora TempWipeColor
	sta COLPF2_TABLE+3,x

	lda COLPF3_TABLE+3,x
	and #$0F
	ora TempWipeColor
	sta COLPF3_TABLE+3,x

	lda COLBK_TABLE+3,x
	and #$0F
	ora TempWipeColor
	sta COLBK_TABLE+3,x

	rts


;==============================================================================
; RANDOMIZE TITLE COLORS 
;==============================================================================
; Support function. Set a random gradient for the title pixels.
; -----------------------------------------------------------------------------

RandomizeTitleColors

	lda RANDOM               ; Get a random value
	eor COLPF0_TABLE+2       ; Flip bits through the previous color.
	and #$F0                 ; Keep color component
	ora #$04                 ; Start at 4, so we get 4, 6, 8, 10, 12, 14.
	tax                      ; X = A  ; for the increments below.

	ldy #5
bRTC_RecolorText             ; Fill the six bytes of color entries.
	sta COLPF0_TABLE+2,y
	inx                      ; ++X ; color + luminance
	inx                      ; ++X ; color + luminance
	txa                      ; A = X in order to save
	dey                      ; --X ; previous color entry.
	bpl bRTC_RecolorText     ; do 0 entry, too. stop at -1.

	rts


;==============================================================================
; RESET TITLE COLORS 
;==============================================================================
; Support function. Set the original colors for the title pixels.
; -----------------------------------------------------------------------------

ResetTitleColors

	ldx #5
bRTC_RecolorTitle            ; Fix the six bytes of Title color entries.
	lda TITLE_PIXEL_COLORS,x
	sta COLPF0_TABLE+2,x
	dex                      ; --X ; previous color entry.
	bpl bRTC_RecolorTitle    ; do 0 entry, too. stop at -1.

	rts


;==============================================================================
; C H A R A C T E R   A N I M A T I O N
;==============================================================================

;==============================================================================
;										DoBoatCharacterAnimation  A  X
;==============================================================================
; Based on the current frame value and the component value, copy 
; the 8 bytes from the animation table to the character image.
;
; ManageBoatAnimations takes care of determining if it is time to animate, 
; and the current component, and the frame counter.
; This function just uses the current values and copies the indicated 
; character image.
;
; When BoatyMcBoatCounter is 0, then animate based on BoatyComponent
; 0 = Right Boat Front
; 1 = Right Boat Back
; 2 = Left Boat Front
; 3 = Left Boat Back
;BoatyFrame         .byte 0  ; counts 0 to 7.
;BoatyMcBoatCounter .byte 2  ; decrement.  On 0 animate a component.
;BoatyComponent     .byte 0  ; 0, 1, 2, 3 one of the four boat parts.
; 
; The Boat Front is two characters.   One of the characters changes
; only on frame 2 and frame 6, so there is extra exception logic to 
; copy those frames when they occur.
;
; You know, a marginally smart person would have made this code smaller 
; by using  another list of values based on component number to provide the 
; base pointers to the arrays of addresses for the source and target
; character maps.
;
; X = frame counter
; -----------------------------------------------------------------------------

DoBoatCharacterAnimation
; Zero is Right Front Boat.

	lda BoatyComponent               ; Get the component to animate
	bne TestBoaty1                   ; Non-zero means try 1, 2, 3

	lda RIGHT_BOAT_WATER_LOW,x       ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda RIGHT_BOAT_WATER_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_RFW*8] ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_RFW*8]
	sta VBIPointer2+1
	jsr BoatCsetCopy8                ; Copy the 8 bytes to the character set via the pointers set up.

; Zero, Part 2 for Right Front Boat.

	cpx #2                           ; Frame 2 and 6 have new images at front of boat.
	beq bCopyRightFrontBoat          ; Yes, this is 2. Copy new image
	cpx #6                           ; If not, then is it 6?
	bne ExitBoatCharacterAnimation   ; Not 6, so done with the frame animation.

bCopyRightFrontBoat
	lda RIGHT_BOAT_FRONT_LOW,x       ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda RIGHT_BOAT_FRONT_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_RF*8]  ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_RF*8]
	sta VBIPointer2+1
	jmp BoatCopy8                    ;  Go do the 8 byte copy to the character set via the pointers.

; One is Right Back Boat.

TestBoaty1
	cmp #1
	bne TestBoaty2                   ; Not 1.  So, not the Right back boat.

	lda RIGHT_BOAT_WAKE_LOW,x        ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda RIGHT_BOAT_WAKE_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_RBW*8] ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_RBW*8]
	sta VBIPointer2+1
	jmp BoatCopy8                    ;  Go do the 8 byte copy to the character set via the pointers.

; Two is Left Front Boat.

TestBoaty2
	cmp #2
	bne TestBoaty3

	lda LEFT_BOAT_WATER_LOW,x        ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda LEFT_BOAT_WATER_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_LFW*8] ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_LFW*8]
	sta VBIPointer2+1
	jsr BoatCsetCopy8                ; Copy the 8 bytes to the character set via the pointers set up.

; Two, Part 2 for Left Front Boat.

	cpx #2                           ; Frame 2 and 6 have new images at front of boat.
	beq bCopyLeftFrontBoat           ; Yes, this is 2. Copy new image
	cpx #6                           ; If not, then is it 6?
	bne ExitBoatCharacterAnimation   ; Not 6, so done with the frame animation.

bCopyLeftFrontBoat
	lda LEFT_BOAT_FRONT_LOW,x        ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda LEFT_BOAT_FRONT_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_LF*8]  ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_LF*8]
	sta VBIPointer2+1
	jmp BoatCopy8                    ;  Go do the 8 byte copy to the character set via the pointers.

; Three is Left Back Boat.

TestBoaty3
	lda LEFT_BOAT_WAKE_LOW,x        ; Get pointer for the data for this frame 
	sta VBIPointer1
	lda LEFT_BOAT_WAKE_HIGH,x
	sta VBIPointer1+1

	lda #<[CHARACTER_SET+I_BOAT_LBW*8] ; Get pointer to destination character.
	sta VBIPointer2
	lda #>[CHARACTER_SET+I_BOAT_LBW*8]
	sta VBIPointer2+1

; Done with frame setup.  Now copy the frame.

BoatCopy8
	jsr BoatCsetCopy8            ;  Copy the 8 bytes to the character set via the pointers set up.

ExitBoatCharacterAnimation
	rts


;==============================================================================
;										BoatCsetCopy8  A  Y
;==============================================================================
; DoBoatCharacterAnimation set up zero page VBIPointer1 and VBIPointer2.
; Copy 8 bytes from pointer1 to pointer 2.
; Without the cpy/bne loop overhead *  8 bytes.
; Y = byte index.
; -----------------------------------------------------------------------------

BoatCsetCopy8

	ldy #0

	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y
	iny
	lda (VBIPointer1),y
	sta (VBIPointer2),y

	rts


;==============================================================================
; F I N E   S C R O L L I N G
;==============================================================================

; ==========================================================================
; FINE SCROLL THE CREDIT LINE
; ==========================================================================
; Perpetually Scrolling Credits
; 
; The credits appear at the bottom line of the screen and continue 
; scrolling forever.
; 
; Yeah, not entirely the most efficient fine scroll.
; ANTIC supports fine horizontal scrolling 16 color clocks or 4 text
; characters at a time.  But, the actual credit text length is variable
; every time I change the string, so it is more simple code to fine scroll
; only one character at a time before a coarse scroll.  Still, the way the 
; Atari coarse scrolls makes this a mind-bogglingly, low-overhead activity
; compared to any other 8-bit.  Only update one pointer instead of rewriting 
; the screen data to coarse scroll.
; --------------------------------------------------------------------------

FineScrollTheCreditLine          ; scroll the text identifying the perpetrators

	dec CreditHSCROL             ; Subtract one color clock from the left (aka fine scroll).
	bne ExitScrollTheCredits     ; It is not yet 0.  Nothing else to do here.

ResetCreditScroll                ; Fine Scroll reached 0, so coarse scroll the text.
	inc SCROLL_CREDIT_LMS        ; Move text left one character position.
	lda SCROLL_CREDIT_LMS
	cmp #<END_OF_CREDITS         ; Did coarse scroll position reach the end of the text?
	bne RestartCreditHSCROL      ; No.  We are done with coarse scroll, now reset fine scroll. 

	lda #<SCROLLING_CREDIT       ; Yes, restart coarse scroll to the beginning position.
	sta SCROLL_CREDIT_LMS

RestartCreditHSCROL              ; Reset the 
	lda #4                       ; horizontal fine 
	sta CreditHSCROL             ; scrolling.

ExitScrollTheCredits
	rts


;==============================================================================
; F I N E   S C R O L L I N G   B O A T S
;==============================================================================

; Offsets from first LMS low byte in Display List to 
; the subsequent LMS low byte of each boat line. (VBI)
; For the Right Boats this is the offset from PF_LMS1.
; For the Left Boats this is the offset from PF_LMS2.
BOAT_LMS_OFFSET 
	.by 0 0 0 0 17 17 0 34 34 0 51 51 0 68 68 0 85 85 

; Index into DLI's HSCROL table for each boat row. 
BOAT_HS_TABLE
	.by 0 4 5 0 7 8 0 10 11 0 13 14 0 16 17 0 19 20

; ==========================================================================
; RIGHT BOAT FINE SCROLLING
; ==========================================================================
; 
; Start Scroll position = LMS + 12 (decrement), HSCROL 0  (Increment)
; End   Scroll position = LMS + 0,              HSCROL 15
;
; X and Y are current row to analyze.
; --------------------------------------------------------------------------

RightBoatFineScrolling

	; Easier to push the frog first before the actual fine scrolling.
	cpy FrogRow             ; Are we on the frog's row?
	bne DoFineScrollRight   ; No.  Continue with boat scroll.
	clc
	lda FrogNewPMX
	adc (BoatMovePointer),y ; Increment the position same as HSCROL distance.
	sta FrogNewPMX

DoFineScrollRight
	ldx BOAT_HS_TABLE,y     ; X = Get the index into HSCROL table.
	lda HSCROL_TABLE,x      ; Get value of HSCROL.
	clc
	adc (BoatMovePointer),y ; Increment the HSCROL.
	cmp #16                 ; Shift past scroll limit?
	bcs DoCoarseScrollRight ; Yes.  Need to coarse scroll.
	sta HSCROL_TABLE,x      ; No. Save the updated HSCROL.
	rts                     ; Done.  No coarse scroll this time.

	; HSCROL wrapped over 15.  Time to coarse scroll by subtracting 4 from LMS.
DoCoarseScrollRight
;	sec  ; Got here via bcs
	sbc #16                 ; Fix the new HSCROL
	sta HSCROL_TABLE,x      ; Save the updated HSCROL.
	ldx BOAT_LMS_OFFSET,y   ; X = Get the index to the LMS in the Display List for this line.
	lda PF_LMS1,x           ; Get the actual LMS low byte.
	sec
	sbc #4                  ; Subtract 4 from LMS in display list.
	bpl SaveNewRightLMS     ; If still positive (0), then good to update LMS
	lda #12                 ; LMS went negative. Reset to start position.
SaveNewRightLMS
	sta PF_LMS1,x           ; Update LMS pointer.

EndOfRightBoat
	rts


; ==========================================================================
; LEFT BOAT FINE SCROLLING
; ==========================================================================
; 
; Start Scroll position = LMS + 0 (increment), HSCROL 15  (Decrement)
; End   Scroll position = LMS + 12,            HSCROL 0
;
; X and Y are current row to analyze/scroll.
; --------------------------------------------------------------------------

LeftBoatFineScrolling

	; Easier to push the frog first before the actual fine scrolling.
	cpy FrogRow             ; Are we on the frog's row?
	bne DoFineScrollLeft    ; No.  Continue with boat scroll.
	sec
	lda FrogNewPMX
	sbc (BoatMovePointer),y ; Decrement the position same as HSCROL distance.
	sta FrogNewPMX

DoFineScrollLeft
	ldx BOAT_HS_TABLE,y     ; X = Get the index into HSCROL table.
	lda HSCROL_TABLE,x      ; Get value of HSCROL.
	sec
	sbc (BoatMovePointer),y ; Decrement the HSCROL
	bmi DoCoarseScrollLeft  ; It went negative, must reset and coarse scroll
	sta HSCROL_TABLE,x      ; It's OK. Save the updated HSCROL.
	rts                     ; Done.  No coarse scroll this time.

	; HSCROL wrapped below 0.  Time to coarse scroll by Adding 4 to LMS.
DoCoarseScrollLeft
	adc #16                 ; Re-wrap over 0 into the positive.
	sta HSCROL_TABLE,x      ; Save the updated HSCROL.
	ldx BOAT_LMS_OFFSET,y   ; X = Get the index to the LMS in the Display List for this line.
	lda PF_LMS2,x           ; Get the actual LMS low byte.
	clc
	adc #4                  ; Add 4 to LMS in display list.
	cmp #13                 ; Is it greater than max (12)? 
	bcc SaveNewLeftLMS      ; No.  Good to update LMS.
	lda #0                  ; LMS greater than 12. Reset to start position.
SaveNewLeftLMS
	sta PF_LMS2,x           ; Update LMS pointer.

EndOfLeftBoat
	rts


;==============================================================================
; F I N E   S C R O L L I N G   T I T L E
;==============================================================================

; ==========================================================================
; TITLE_START=TITLE_MEM1-1 ; Cheating. To show all color clocks from 
;                          ; TITLE_MEM1 the LMS is at * -1, and HSCROLL 0
; TITLE_END   = TITLE_START+10
;
; Values for manipulating screen memory.
; TITLE_LEFT  = TITLE_MEM1
; TITLE_RIGHT = TITLE_MEM1+10
;
; Start Scroll position = TITLE_START (Increment), HSCROL 0  (Decrement)
; End   Scroll position = TITLE_START + 9,         HSCROL 0
; --------------------------------------------------------------------------

; Offsets from first LMS low byte in Display List to 
; the subsequent LMS low byte of each title line. (VBI use)
; Offset from TT_LMS0.

TITLE_LMS_OFFSET 
	.by 0 3 6 9 12 15 

TITLE_LMS_ORIGIN
	.by <TITLE_START <[TITLE_START+20] <[TITLE_START+40] <[TITLE_START+60] <[TITLE_START+80] <[TITLE_START+100]


; ==========================================================================
; TITLE LEFT SCROLL
; ==========================================================================
; Left scroll from origin (LMS-1/0) to Right target (9/0)
; --------------------------------------------------------------------------

TitleLeftScroll

	lda TT_LMS0            ; Get current LMS
	cmp #<[TITLE_START+9]  ; Did it reach the end?
	beq bTLF_Exit          ; Yes.  Nothing to do.

	dec TitleHSCROL        ; Decrement HSCROL.  
	bpl bTLF_Exit          ; Positive. No roll over. Do not coarse scroll.

	lda #15                ; Coarse scrolling to next byte
	sta TitleHSCROL        ; Reset HSCROL for next screen byte.

	inc TT_LMS0            ; Coarse scroll display to next byte...
	inc TT_LMS1
	inc TT_LMS2
	inc TT_LMS3
	inc TT_LMS4
	inc TT_LMS5

bTLF_Exit
	rts


; ==========================================================================
; TITLE SHIFT DOWN
; ==========================================================================
; Shift down the content of the Left buffer to incrementally and visibly 
; clear the Left buffer before the scroll from the right.   ALSO shift down
; the color table entries for the Title to follow the text pixels.
; --------------------------------------------------------------------------

TitleShiftDown

	jsr TitleWaitForScanLine88 ; Be sure the beam passed the title. 

	ldx #9

bTSD_Loop
	lda TITLE_LEFT+80,x  ; Copy Pixel Row 5 
	sta TITLE_LEFT+100,x ; down to Row 6

	lda TITLE_LEFT+60,x  ; Copy Pixel Row 4
	sta TITLE_LEFT+80,x  ; down to Row 5

	lda TITLE_LEFT+40,x  ; Copy Pixel Row 3
	sta TITLE_LEFT+60,x  ; down to Row 4

	lda TITLE_LEFT+20,x  ; Copy Pixel Row 2
	sta TITLE_LEFT+40,x  ; down to Row 3

	lda TITLE_LEFT,x     ; Copy Pixel Row 1
	sta TITLE_LEFT+20,x  ; down to Row 2

	lda #0               ; Erase
	sta TITLE_LEFT,x     ; Row 1

	dex
	bpl bTSD_Loop        ; Loop including 0


	ldx #4               ; Now move the pixel colors to match.

bTSD_ColorLoop
	lda COLPF0_TABLE+2,x ; shift colors in table 2 to 6
	sta COLPF0_TABLE+3,x ; down to table 3 to 7

	dex
	bpl bTSD_Loop        ; Loop including 0

	rts


; ==========================================================================
; Screen codes for printing the numbers for the Option/Select Hacks.
; ==========================================================================
; Combine something from the "LIST" and stuff it into the "NUMBER" 
; location, then print the string to pixels.
; --------------------------------------------------------------------------

LEVEL_TEXT   .sb " LEVEL "
LEVEL_NUMBER .sb "   "       ; Actual number goes here.

LIVES_LIST                        ; Reference 1 to 7 as --X, so 0 to 8
LEVEL_LIST1  .sb "12345678911111" ; 0 to 13 == 1 to 14
LEVEL_LIST2  .sb "         01234" ; 

LIVES_TEXT   .sb " "
LIVES_NUMBER .sb "  LIVES  " ; Actual number goes there


; ==========================================================================
; TITLE PREP LEVEL
; ==========================================================================
; Convert the user-selected NewLevelStart to "text" built of pixels
; that will be scrolled into the Title area.
; --------------------------------------------------------------------------

TitlePrepLevel

	ldx NewLevelStart ; 0 to 13  is 1 to 14
	lda LEVEL_LIST1,x
	sta LEVEL_NUMBER
	lda LEVEL_LIST2,x
	sta LEVEL_NUMBER+1

	lda #<LEVEL_TEXT
	ldx #>LEVEL_TEXT

	jmp TitleFinishPrep


; ==========================================================================
; TITLE PREP LIVES
; ==========================================================================
; Convert the user-selected NewNumberOfLives to "text" built of pixels
; that will be scrolled into the Title area.
; hackitty hack hack hack
; --------------------------------------------------------------------------

TitlePrepLives

	ldx NewNumberOfLives ; 1 to 7 
	dex
	bne bTPL_UsePlural ; 1 LIFE, 2 LIVES, right?
	; Singular
	lda #I_F
	sta LIVES_NUMBER+4
	lda #I_SPACE
	sta LIVES_NUMBER+6
	beq bTPL_SkipPlural

bTPL_UsePlural
	lda #I_V
	sta LIVES_NUMBER+4
	lda #I_S
	sta LIVES_NUMBER+6

bTPL_SkipPlural
	lda LEVEL_LIST1,x
	sta LIVES_NUMBER

	lda #<LIVES_TEXT
	ldx #>LIVES_TEXT

	jmp TitleFinishPrep


; ==========================================================================
; TITLE FINISH PREP
; ==========================================================================
; Common code.  Fill in pointer, set length.  Print the pixels.
; A+X == Address of screen codes to print.
; --------------------------------------------------------------------------

TitleFinishPrep

	sta MainPointer1
	stx MainPointer1+1

	ldx #0
	ldy #10

	jsr TitlePrintString

	rts


; ==========================================================================
; TITLE PRINT STRING                                MainPointer1  A  X  Y
; ==========================================================================
; Iterate through a string of internal screen code characters.
;
; Uses MainPointer1 for string pointer.
; Uses SAVEY to remember the string length.
; Uses A to pass each character to the printing routine.
;
; X = position in screen's Right text buffer.  0 to 9.
; Y = length
; 
; Registers saved prior to work.
; --------------------------------------------------------------------------

TitlePrintString

	cpy #0                ; If length is 0, then
	beq bTPS_Exit         ; Nothing to do here.  (yes, overkill.  could check X too for greater than 9.  derp.))

	sty SAVEY             ; Remember length for later.

	ldy #0                ; Start working length at 0 (index into input).
bTPS_Loop
	lda (MainPointer1),y ; Get internal code character from input
	jsr TitlePrintChar    ; Print it.  This routine preserves all registers.
	inx                   ; Next character position in output screen buffer
	iny                   ; Next position in the input string
	cpy SAVEY             ; Did it reach length?
	bne bTPS_Loop         ; Not yet.  Do next character.

bTPS_Exit
	rts


; ==========================================================================
; TITLE PRINT CHAR                                             A  X
; ==========================================================================
; Write bytes 1 to 6 (skipping 0 and 8) of the character from an internal 
; character code into the right side Title buffer at a designated position.
; The position is byte aligned.  No fancy bit twiddling to do pixel-
; accurate placement. 
;
; Uses MaintPointer2 for character pointer.
; Uses SAVEA temporarily.
;
; A = Internal Character Code
; X = position in screen Right text buffer.  0 to 9.
; 
; Registers saved prior to work.
; --------------------------------------------------------------------------

TitlePrintChar

	sta SAVEA ; save A for routine.

	mRegSave  ; Preserve all regs on stack so routine does not affect caller.

	lda #0
	sta MainPointer2
	sta MainPointer2+1

	lda SAVEA

	; MainPointer2 = A * 8
	asl
	rol MainPointer2+1
	asl
	rol MainPointer2+1
	asl
	rol MainPointer2+1
	sta MainPointer2

	; MainPointer2+1  += $e0 ; Or maybe use the redefined set?
	clc
	lda #$E0
	adc MainPointer2+1
	sta MainPointer2+1

	; Copy middle 6 bytes from character set to screen memory.
	ldy #1
	lda (MainPointer2),y
	sta TITLE_RIGHT,x
	iny
	lda (MainPointer2),y
	sta TITLE_RIGHT+20,x
	iny
	lda (MainPointer2),y
	sta TITLE_RIGHT+40,x
	iny
	lda (MainPointer2),y
	sta TITLE_RIGHT+60,x
	iny
	lda (MainPointer2),y
	sta TITLE_RIGHT+80,x
	iny
	lda (MainPointer2),y
	sta TITLE_RIGHT+100,x

bTPC_Exit
	mRegRestore

	rts


; ==========================================================================
; TITLE SET ORIGIN                                            
; ==========================================================================
; For the Title display, wait for the scan line to be below the title 
; before changing the LMS values to avoid weirdness on display.
; Set All Display List LMS to the Left Side buffer. Reset Title HSCROL.
; This is called before scrolling from right to left. 
; --------------------------------------------------------------------------

TitleSetOrigin

	jsr TitleWaitForScanLine88 ; Be sure the beam passed the title. 

	ldx #5

bTSO_loop
	ldy TITLE_LMS_OFFSET,x ; Get LMS offset

	lda TITLE_LMS_ORIGIN,x ; Get low byte for this line of the scrolling buffer

	sta TT_LMS0,y          ; Update LMS with low byte to TITLE. 

	dex                    ; next line
	bpl bTSO_loop          ; Reached the end?

	ldx #0
	stx TitleHSCROL        ; Zero the fine scroll while we're here

	rts


; ==========================================================================
; TITLE CLEAR RIGHT GRAPHICS                                             
; ==========================================================================
; Clear the right side of the scrolling buffer.  
; Done in preparation of populating and prior to scrolling left.
; --------------------------------------------------------------------------

TitleClearRightGraphics

	lda #0
	ldx #9

bTCRG_Loop
	sta TITLE_RIGHT,x
	sta TITLE_RIGHT+20,x
	sta TITLE_RIGHT+40,x
	sta TITLE_RIGHT+60,x
	sta TITLE_RIGHT+80,x
	sta TITLE_RIGHT+100,x

	dex
	bpl bTCRG_Loop

	rts


; ==========================================================================
; TITLE COPY RIGHT TO LEFT GRAPHICS                                             
; ==========================================================================
; Copy data on the right side of the buffer to the left side, so 
; the scrolling can be reset to the origin. 
; --------------------------------------------------------------------------

TitleCopyRightToLeftGraphics

	ldx #9

bTCRTLG_Loop
	lda TITLE_RIGHT,x
	sta TITLE_LEFT,x
	lda TITLE_RIGHT+20,x
	sta TITLE_LEFT+20,x
	lda TITLE_RIGHT+40,x
	sta TITLE_LEFT+40,x
	lda TITLE_RIGHT+60,x
	sta TITLE_LEFT+60,x
	lda TITLE_RIGHT+80,x
	sta TITLE_LEFT+80,x
	lda TITLE_RIGHT+100,x
	sta TITLE_LEFT+100,x

	dex
	bpl bTCRTLG_Loop

	rts


; ==========================================================================
; TITLE WAIT FOR SCAN LINE 88                                             
; ==========================================================================
; Wait to start changes to the Title graphics until after the electron beam
; passes the title block.  This should prevent visible tearing or glitches 
; while updating LMS or actual pixel values. 
; --------------------------------------------------------------------------

TitleWaitForScanLine88

	lda VCOUNT                 ; Current electron bean scan line
	cmp #44                    ; scan line 88 / 2 should be ok.
	bcc TitleWaitForScanLine88 ; Loop until scan line after the Title.

	rts


;==============================================================================
; P R E S S   J O Y S T I C K   B U T T O N   P R O M P T
;==============================================================================

; ==========================================================================
; HIDE BUTTON PROMPT                                                   A
; ==========================================================================
; Tell the VBI to shut off the prompt.
;
; Uses A.   Preserves original value, so caller is not affected.
; --------------------------------------------------------------------------

HideButtonPrompt

	pha                     ; Save whatever is here.

	lda #0                  ; 0 == off
	sta EnablePressAButton  ; Tell VBI this is off.

	pla                     ; Get A back.

	rts                     ; bye.  Are there enough comments here?


;==============================================================================
; TOGGLE PRESS A BUTTON STATE 
;==============================================================================
; Flip the fade up/fade down state.

TogglePressAButtonState

	lda PressAButtonState    ; Get button state
	eor #$FF                 ; Invert the value
	sta PressAButtonState    ; Save new value.

	rts


;==============================================================================
; TOGGLE BUTTON PROMPT
;==============================================================================
; Fade the prompt colors up and down. 
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
	bne PromptFadeUp            ; >0 == up.

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


;==============================================================================
; RUN PROMPT FOR BUTTON
;==============================================================================
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


;==============================================================================
; P L A Y E R / M I S S I L E   G R A P H I C S
;==============================================================================
; Game-specific Shapes:
; SHAPE_OFF   = 0
; SHAPE_FROG  = 1
; SHAPE_SPLAT = 2
; SHAPE_TOMB  = 3

; ==========================================================================
; SET SPLATTERED ON SCREEN
; ==========================================================================
; Show the splattered frog image on the screen...
;
; This does not bother changing the FrogUpdate for the VBI, since 
; this activity should only occur when frog animation is already 
; underway.
; --------------------------------------------------------------------------

SetSplatteredOnScreen

	lda #SHAPE_SPLAT
	sta FrogNewShape

	rts


; ==========================================================================
; SET FROG ON SCREEN
; ==========================================================================
; Show the frog image on the screen...
;
; Set default eyeball shape.  
; Enable updates for the VBI.
; Write the Frog character into screen memory.
; --------------------------------------------------------------------------

SetFrogOnScreen

	lda #SHAPE_FROG
	sta FrogNewShape ; Set new shape
	lda #1
	sta FrogEyeball  ; Set default eyeball shape (1 is default/centered)

	sta FrogUpdate   ; and finally enable VBI to do P/M redraw. (>0 is ON)

	rts


; ==========================================================================
; REMOVE FROG ON SCREEN
; ==========================================================================
; Remove the frog from the screen...
;
; VBI will update other values, and the shape ID.
; --------------------------------------------------------------------------

RemoveFrogOnScreen

	lda #$FF           ; (<0 is shutdown)
	sta FrogUpdate     ; Signal VBI to erase and do not redraw. 

	rts


;==============================================================================
;												PmgInit  A  X  Y
;==============================================================================
; One-time setup tasks to do Player/Missile graphics.
; -----------------------------------------------------------------------------

libPmgInit

	jsr libPmgAllZero  ; get all Players/Missiles off screen, etc.
	
	; clear all bitmap images
	jsr libPmgClearBitmaps

	; Load text labels into P/M memory
	jsr LoadPMGTextLines

	; Tell ANTIC where P/M memory is located for DMA to GTIA
	lda #>PMADR
	sta PMBASE

	; Enable GTIA to accept DMA to the GRAFxx registers.
	lda #ENABLE_PLAYERS|ENABLE_MISSILES
	sta GRACTL

	; Set all the ANTIC screen controls and DMA options.
	lda #ENABLE_DL_DMA|PM_1LINE_RESOLUTION|ENABLE_PM_DMA|PLAYFIELD_WIDTH_NORMAL
	sta SDMCTL

	; Ordinarily, GPRIOR would be set here.
	; However, GTIA GPRIOR varies by Display.
	; The VBI will manage the values based on the current Display List.

	ldx #SHAPE_FROG ; Frog Shape
	jsr libPmgSetColors

	rts 


;==============================================================================
;											SetPmgHPOSZero  A  X
;==============================================================================
; Zero the hardware HPOS registers.
;
; Useful for DLI which needs to remove Players from the screen.
; With no other changes (i.e. the size,) this is sufficient to remove 
; visibility for all Player/Missile overlay objects 
; -----------------------------------------------------------------------------

libSetPmgHPOSZero

	lda #$00                ; 0 position

	sta HPOSP0
	sta HPOSP1
	sta HPOSP2
	sta HPOSP3
	sta HPOSM0
	sta HPOSM1
	sta HPOSM2
	sta HPOSM3

	rts


;==============================================================================
;											PmgAllZero  A  X
;==============================================================================
; Simple hardware reset of all Player/Missile registers.
; Typically used only at program startup to zero everything
; and prevent any screen glitchiness on startup.
;
; Reset all Players and Missiles horizontal positions to 0, so
; that none are visible no matter the size or bitmap contents.
; Zero all colors.
; Also reset sizes to zero.
; -----------------------------------------------------------------------------

libPmgAllZero

	lda #$00                ; 0 position
	ldx #$03                ; four objects, 3 to 0

bLoopZeroPMPosition
	sta HPOSP0,x            ; Player positions 3, 2, 1, 0
	sta SIZEP0,x            ; Player width 3, 2, 1, 0
	sta HPOSM0,x            ; Missiles 3, 2, 1, 0 just to be sure.
	sta PCOLOR0,x           ; And black the colors.
	dex
	bpl bLoopZeroPMPosition

	sta SIZEM

	lda #[GTIA_MODE_DEFAULT|%0001]
	sta GPRIOR

	rts


;==============================================================================
;											PmgClearBitmaps  A  X
;==============================================================================
; Zero the bitmaps for all players and missiles
; 
; Try to make this called only once at game initialization.
; All other P/M  use should be otrderly and clean up after itself.
; Residual P/M pixels are verboten.
; -----------------------------------------------------------------------------

libPmgClearBitmaps

	lda #$00
	tax      ; count 0 to 255.

bCBloop
	sta MISSILEADR,x ; Missiles
	sta PLAYERADR0,x  ; Player 0
	sta PLAYERADR1,x  ; Player 1
	sta PLAYERADR2,x  ; Player 2
	sta PLAYERADR3,x  ; Player 3
	inx
	bne bCBloop       ; Count 1 to 255, then 0 breaks out of loop

	rts


;==============================================================================
;											PmgSetColors  A  X
;==============================================================================
; Load the P0-P3 colors based on shape identity.
; 
; X == SHAPE Identify  0 (off), 1, 2, 3...
; -----------------------------------------------------------------------------

libPmgSetColors

	txa   ; Object number
	asl   ; Times 2
	asl   ; Times 4
	tax   ; Back into index for referencing from table.

	lda BASE_PMCOLORS_TABLE,x    ; Get color associated to object                 
	sta COLPM0_TABLE+2           ; Stuff in the Player color registers.

	lda BASE_PMCOLORS_TABLE+1,x
	sta COLPM1_TABLE+2

	lda BASE_PMCOLORS_TABLE+2,x
	sta COLPM2_TABLE+2

	lda BASE_PMCOLORS_TABLE+3,x
	sta COLPM3_TABLE+2

	rts


; ==========================================================================
; LOAD PMG TEXT LINES                                                 A  X  
; ==========================================================================
; Load the Text labels for the the scores, lives, and saved frogs into 
; the Player/Missile memory.
; --------------------------------------------------------------------------

PMGLABEL_OFFSET=24

LoadPmgTextLines

	ldx #14

bLPTL_LoadBytes
	lda P0TEXT_TABLE,x
	sta PLAYERADR0+PMGLABEL_OFFSET,x
	lda P1TEXT_TABLE,x
	sta PLAYERADR1+PMGLABEL_OFFSET,x
	lda P2TEXT_TABLE,x
	sta PLAYERADR2+PMGLABEL_OFFSET,x
	lda P3TEXT_TABLE,x
	sta PLAYERADR3+PMGLABEL_OFFSET,x
	lda MTEXT_TABLE,x
	sta MISSILEADR+PMGLABEL_OFFSET,x

	dex
	bpl bLPTL_LoadBytes

	rts


;==============================================================================
;											SetPmgAllZero  A  X
;==============================================================================
; Zero the table entries for the animated object on screen.
;
; -----------------------------------------------------------------------------

SetPmgAllZero

	lda #$00            ; 0 position

	sta COLPM0_TABLE+2
	sta COLPM1_TABLE+2
	sta COLPM2_TABLE+2
	sta COLPM3_TABLE+2
	sta SIZEP0_TABLE+2
	sta SIZEP0_TABLE+2
	sta SIZEP0_TABLE+2
	sta SIZEP0_TABLE+2
	sta SIZEM_TABLE+2   ; and Missile size 3, 2, 1, 0
	sta HPOSP0_TABLE+2
	sta HPOSP1_TABLE+2
	sta HPOSP2_TABLE+2
	sta HPOSP3_TABLE+2
	sta HPOSM0_TABLE+2
	sta HPOSM1_TABLE+2
	sta HPOSM2_TABLE+2
	sta HPOSM3_TABLE+2

	lda #[GTIA_MODE_DEFAULT|%0001]
	sta PRIOR_TABLE+2

	rts


;==============================================================================
;														CopyPmgBase  A  Y
;==============================================================================
; Bulk copy the base values for the current display to the working table.
;
; -----------------------------------------------------------------------------

CopyPmgBase

	ldy #53

bCPB_loop
	lda (BasePmgAddr),y
	sta PLAYER_MISSILE_BASE_SPECS,y
	dey
	bpl bCPB_loop

	rts


; ==========================================================================
; WOBBLE DE WOBBLE                                                 A  X  
; ==========================================================================
; Frog (etc) Gymnastics.
; On the title screen the frog moves in a sine path from  +88 to +160.
; This value is centered at 128, the middle of the screen.
; The data from the sine generator is 0 to $80  (0 to 80).
; The center of the screen should be 128,128. 
; So, the value to add to center the sine motion on the screen is:
; 128 - (80 / 2) ==  88. 
; Minus 4 for the width/height of the Frog == 84
; Add that to current values to position the frog.
; The rate of updates between X and Y values differs, so the 
; frog does not travel in a circle, but a distorted arc.
; The frog Y center position is offset slightly differently from 
; the X Center.
; This same code is used for the Tomb/gravestone on the GameOver screen.
;
; Uses AnimateFrame2 and AnimateFrames3
; --------------------------------------------------------------------------

WOBBLE_SINE_TABLE
	.by $28 $2c $30 $34 $37 $3b $3e $41 
	.by $44 $47 $49 $4b $4d $4e $4f $50 
	.by $50 $50 $4f $4e $4d $4b $49 $47 
	.by $44 $41 $3e $3b $37 $34 $30 $2c 
	.by $28 $24 $20 $1c $19 $15 $12 $0f 
	.by $0c $09 $07 $05 $03 $02 $01 $00 
	.by $00 $00 $01 $02 $03 $05 $07 $09 
	.by $0c $0f $12 $15 $19 $1c $20 $24 

WobbleDeWobble

	lda AnimateFrames3        ; Get the countdown timer for X movement.
	bne CheckOnAnimateY      ; Not 0.  No X movement.  Go try Y movement.

	lda #WOBBLEX_SPEED       ; Reset the X movement timer.
	sta AnimateFrames3        

	jsr WobbleDeWobbleX_Now  ; Do the actual X wobble work.

CheckOnAnimateY
	lda AnimateFrames2       ; Get the countdown timer for Y movement.
	bne EndWobbleDeWobble    ; Not 0.  No Y movement.  Depart.

	lda #WOBBLEY_SPEED       ; Reset the Y movement timer.
	sta AnimateFrames2

	jsr WobbleDeWobbleY_Now  ; Do the actual X wobble work.

EndWobbleDeWobble
	rts

; Working parts of the Wobble, callable by others.

WobbleDeWobbleX_Now          ; jsr here to force wobble coordinates

	inc WobbleX              ; Increment Index for X offset
	lda WobbleX              ; Get new X index
	and #$3F                 ; Limit to 0 to 63.
	; Remarkably, the Base-2-ness of the size plus the AND above make it unecessary to update WobbleX.
	tax                      ; X = Index for X movement
	lda WOBBLE_SINE_TABLE,x  ; Get current path value for Horizontal placement.
	clc
	adc WobOffsetX           ; Add to offset for placement.
	sta FrogNewPMX           ; Tell VBI where to draw the object.

	rts

; Working parts of the Wobble, callable by others.

WobbleDeWobbleY_Now          ; jsr here to force wobble coordinates

	inc WobbleY              ; Increment Index for Y offset.
	lda WobbleY              ; Get new Y index
	and #$3F                 ; Limit to 0 to 63.
	; Remarkably, the Base-2-ness of the size plus the AND above make it unnecessary to update WobbleY.
	tax                      ; X = Index for Y movement
	lda WOBBLE_SINE_TABLE,x  ; Get current path value for Vertical placement.
	clc
	adc WobOffsetY           ; Add to offset for placement.
	sta FrogNewPMY           ; Tell VBI where to draw the object.

	rts


;==============================================================================
;											CheckRidetheBoat    A 
;==============================================================================
; Collision processing the prior frame results is utterly trivial.
;
; The caller should make this check for collisions only when the  
; Frog is in a Boat row.
;
; Here's how life and death works:
; As long as a frog part (Player 0 or 1) is touching the colored, horizontal 
; lines (COLPF2) on the boat, then the frog lives.
;
; This is easy, because the Atari identifies exactly what playfield 
; color is involved in the collision.  
; On other systems we're lucky to get a bit that says a sprite collided 
; with a pixel. Then we would have to do a series of coordinate bounding 
; box checks to see if the frog is in a safe position on a boat.
; 
; In the event of a rare border condition where the frog lost the collision  
; attachment on the past frame AND the player has directed the frog move to 
; the next row in the coming frame, then grace is applied to ignore the 
; collision results and keep the frog alive.  
;
; Output: 
; FrogSafety = 0  ; Life
; FrogSafety = 1  ; Death
; -----------------------------------------------------------------------------

CheckRideTheBoat

	lda FrogSafety               ; Is the frog already dead ?
	bne ExitCheckRideTheBoat     ; Yes.   No need to check.

	lda P0PF                     ; Get Player 0 collision with playfield
	ora P1PF                     ; OR with Player 1 collision with playfield
	and #COLPMF2_BIT             ; Keep only the collision with COLPF2 (lines on the boats)
	bne ExitCheckRideTheBoat     ; 1 == touching the lines. Therefore Frog is safe.

	; Oops.  The frog is off a boat. 
	; Frog must die. Unless, the frog must live. :-) 
	; If the Frog is moving to the next row on the next frame, then 
	; disregard the collision failure to permit the frog to live.

	lda FrogRow                  ; Get the current Row number.
	cmp FrogNewRow               ; Is the new Row the same?  
	bne ExitCheckRideTheBoat     ; No.  Life!

	inc FrogSafety               ; Yes.  Die, Frog, Die!

	; The rest of the VBI motion processing will happily drag the frog  
	; corpse along with the moving boats/water.
	; It is MAIN's job to change the image to the splattered frog.

ExitCheckRideTheBoat
	rts


;==============================================================================
;											EraseShape  A  X  Y
;==============================================================================
; Erase current Shape at current position.
; -----------------------------------------------------------------------------

EraseShape

	lda FrogShape       ; Current shape?
	beq ExitEraseShape  ; 0 is off. Nothing to Erase.

	; Note that if there is animation here is where the frame change 
	; would be evaluated to be followed by the position check if the 
	; frame does not change.

	ldy FrogUpdate     ; If -1, then update/erase is mandatory.
	bmi bes_Test1

	cmp FrogNewShape   ; Is it different from the old shape?
	bne bes_Test1      ; Yes.  Erase is mandatory.

	ldy FrogNewPMY     ; Get new position.
	cpy FrogPMY        ; Is it the same as the old position?
	beq ExitEraseShape ; Yes.  Nothing to erase here.

bes_Test1
	cmp #SHAPE_FROG
	bne bes_Test2
	jsr EraseFrog
	jmp ExitEraseShape

bes_Test2
	cmp #SHAPE_SPLAT
	bne bes_Test3
	jsr EraseSplat
	jmp ExitEraseShape

bes_Test3
	cmp #SHAPE_TOMB
	bne ExitEraseShape
	jsr EraseTomb

; Do not change FrogShape to FrogNewShape.   
; Drawing a new shape will transition New to Current.
ExitEraseShape
	lda FrogShape  ; return with value for caller.

	rts


;==============================================================================
;											EraseGameBorder  A  X  Y
;==============================================================================
; Erase Shape in Missile memory.
; -----------------------------------------------------------------------------

BORDER_OFFSET=41

EraseGameBorder

	lda #$00
	sta HPOSP3_TABLE+2
	sta HPOSM3_TABLE+2

	ldx #178

begb_LoopFillBorder
	lda #$00
	sta PLAYERADR3+BORDER_OFFSET,x
	
	lda MISSILEADR+BORDER_OFFSET,x
	and #%00111111
	sta MISSILEADR+BORDER_OFFSET,x

	dex
	bne begb_LoopFillBorder

	rts


;==============================================================================
;											EraseTomb  A  X  Y
;==============================================================================
; Erase Tomb at current position.
; -----------------------------------------------------------------------------

EraseTomb

	lda #0
	ldx FrogPMY      ; Old  Y
	ldy #22

bLoopET_Erase
	sta PLAYERADR0,x ; main  1
	sta PLAYERADR1,x ; main  2
	sta PLAYERADR2,x ; 
	sta PLAYERADR3,x ; 
	sta MISSILEADR,x ; 
	inx
	dey
	bpl bLoopET_Erase

	rts


;==============================================================================
;											EraseSplat  A  X  Y
;==============================================================================
; Erase Splat at current position.
; -----------------------------------------------------------------------------

EraseSplat

	lda #0
	ldx FrogPMY        ; Old frog Y
	ldy #10
	
bLoopES_Erase
	sta PLAYERADR0,x   ; splat 1
	sta PLAYERADR1,x   ; splat 2
	inx
	dey
	bpl bLoopES_Erase

	rts


;==============================================================================
;											EraseFrog  A  X  Y
;==============================================================================
; Erase Frog at current position.
; -----------------------------------------------------------------------------

EraseFrog

	lda #0
	ldx FrogPMY       ; Old frog Y
	ldy #10
	
bLoopEF_Erase
	sta PLAYERADR0,x  ; main frog 1
	sta PLAYERADR1,x  ; main frog 2, mouth, pupil
	sta PLAYERADR2,x  ; eyeball
	inx
	dey
	bpl bLoopEF_Erase

	rts


;==============================================================================
;											DrawShape  A  X  Y
;==============================================================================
; Draw current Shape at current position.
; -----------------------------------------------------------------------------

DrawShape

	lda FrogNewShape
	beq ExitDrawShape  ; 0 is off.

	ldy FrogUpdate        ; Is update mandatory?
	bmi ExitDrawShape     ; Update is forced off.
	beq bds_CheckInMotion ; Update is neutral.
	bpl bds_Test1         ; FrogUpdate >0 means redraw is required.
	
	; Note that if there is animation here is where the frame change 
	; would be evaluated to be followed by the position check if the 
	; frame does not change.

bds_CheckInMotion
	cmp FrogShape          ; Is it different from the old shape?
	bne bds_Test1          ; Yes.  Redraw is mandatory.

	ldy FrogNewPMY         ; Get new position.
	cpy FrogPMY            ; Is it the same as the old position?
	beq ExitDrawShape      ; Yes.  Nothing to draw here.

bds_Test1
	cmp #SHAPE_FROG
	bne bds_Test2
	jsr DrawFrog
	jmp ExitDrawShape

bds_Test2
	cmp #SHAPE_SPLAT
	bne bds_Test3
	jsr DrawSplat
	jmp ExitDrawShape

bds_Test3
	cmp #SHAPE_TOMB
	bne ExitDrawShape
	jsr DrawTomb

ExitDrawShape
	lda FrogNewShape ; return value to caller.

	rts


;==============================================================================
;											DrawGameBorder  A  X  Y
;==============================================================================
; Show the black border that masks the left and right sides of the background.
;
; Draw Shape in Player/Missile memory.
; Set color of border to Black.
; Set position of Player/Missile.
; Set size of Player and Missile.
; -----------------------------------------------------------------------------

DrawGameBorder

	ldx #178
bdgb_LoopFillBorder
	lda #$C0
	sta PLAYERADR3+BORDER_OFFSET,x

	lda MISSILEADR+BORDER_OFFSET,x
	ora #$C0 ; or %11000000
	sta MISSILEADR+BORDER_OFFSET,x

	dex
	bne bdgb_LoopFillBorder

	rts


;==============================================================================
;											DrawTomb   A  X  Y
;==============================================================================
; Draw Tomb at new position.
; -----------------------------------------------------------------------------

DrawTomb

	ldx FrogNewPMY            ; New frog Y
	ldy #22
	
bLoopDT_DrawTomb
	lda PLAYER0_GRAVE_DATA,y
	sta PLAYERADR0+22,x

	lda PLAYER1_GRAVE_DATA,y
	sta PLAYERADR1+22,x

	lda PLAYER2_GRAVE_DATA,y
	sta PLAYERADR2+22,x

	lda PLAYER3_GRAVE_DATA,y
	sta PLAYERADR3+22,x

	lda PLAYER5_GRAVE_DATA,y
	sta MISSILEADR+22,x

	dex
	dey
	bpl bLoopDT_DrawTomb

	rts


;==============================================================================
;											DrawSplat   A  X  Y
;==============================================================================
; Draw SplatteredFrog at new position.
; -----------------------------------------------------------------------------

DrawSplat

	ldx FrogNewPMY
	ldy #10
	
bLoopDS_DrawSplatFrog
	lda PLAYER0_SPLATTER_DATA,y
	sta PLAYERADR0+10,x

	lda PLAYER1_SPLATTER_DATA,y
	sta PLAYERADR1+10,x

	dex
	dey
	bpl bLoopDS_DrawSplatFrog

	rts


;==============================================================================
;											DrawFrog  A  X  Y
;==============================================================================
; Draw Frog at new position.
; -----------------------------------------------------------------------------

DrawFrog

	ldx FrogNewPMY            ; New frog Y
	ldy #10

bLoopDF_DrawFrog
	lda PLAYER0_FROG_DATA,y
	sta PLAYERADR0+10,x

	lda PLAYER1_FROG_DATA,y
	sta PLAYERADR1+10,x

	dex
	dey
	bpl bLoopDF_DrawFrog

	; Player 2 is the eyeball whites
	ldx FrogNewPMY             ; Reload new frog Y
	lda #$EE
	sta PLAYERADR2+2,x
	sta PLAYERADR2+3,x
	sta PLAYERADR2+4,x

	; Player 1 also contains the animated pupil.
	lda FrogEyeball            ; What shape is the eye pupil?
	asl
	asl
	tay

	lda PLAYER1_EYE_DATA,y
	sta PLAYERADR1+2,x
	iny
	lda PLAYER1_EYE_DATA,y
	sta PLAYERADR1+3,x
	iny
	lda PLAYER1_EYE_DATA,y
	sta PLAYERADR1+4,x

	rts


;==============================================================================
;											PositionShape  A  X  Y
;==============================================================================
; Set HPOS coords of the shape parts. 
; -----------------------------------------------------------------------------

PositionShape

	ldy FrogNewShape       ; Get new shape
	cpy FrogShape          ; Is it different from the old shape?
	bne bps_Test0          ; Yes.   Reposition is mandatory.

	ldy FrogNewPMX         ; Get new position.
	cpy FrogPMX            ; Is it the same as the old position?
	beq ExitPositionShape  ; Yes.  Nothing to draw here.

bps_Test0
	cmp #SHAPE_OFF
	bne bps_Test1
	jmp ExitPositionShape

bps_Test1
	cmp #SHAPE_FROG
	bne bps_Test2
	jsr PositionFrog
	jmp ExitPositionShape

bps_Test2
	cmp #SHAPE_SPLAT
	bne bps_Test3
	jsr PositionSplat
	jmp ExitPositionShape

bps_Test3
	cmp #SHAPE_TOMB
	bne ExitPositionShape
	jsr PositionTomb

ExitPositionShape
	lda FrogNewShape ; return value to caller.
	rts


;==============================================================================
;											PositionTomb  A  X  Y
;==============================================================================
; Move X position.
; Set sizes of parts.
; -----------------------------------------------------------------------------

PositionTomb

	ldx FrogNewPMX            ; New frog X...

	; Do horizontal repositioning.
	; Change frog HPOS.  Each part is not at 0 origin, so there are offsets...

	stx HPOSP0_TABLE+2 ; + 0 is shadow on left
	inx
	inx
	stx HPOSM0_TABLE+2 ; + 2 is p5 left part of tombstone
	inx
	inx
	stx HPOSP3_TABLE+2 ; + 4 is part of RIP
	inx
	stx HPOSP2_TABLE+2 ; + 5 is rest of the RIP
	inx
	inx
	stx HPOSP1_TABLE+2 ; + 7 right side of tombstone

	rts


;==============================================================================
;											PositionSplat  A  X  Y
;==============================================================================
; Move X position.
; Set sizes of parts.
; -----------------------------------------------------------------------------

PositionSplat

	ldx FrogNewPMX            ; New frog X...

	; Do horizontal repositioning.
	; Change frog HPOS.  Each part is not at 0 origin, so there are offsets...

	stx HPOSP0_TABLE+2 ; + 0 is splat parts 1
	inx
	stx HPOSP1_TABLE+2 ; + 1 is splat parts 2

	rts


;==============================================================================
;											PositionFrog  A  X  Y
;==============================================================================
; Move X position.
; Set sizes of parts.
; -----------------------------------------------------------------------------

PositionFrog

	ldx FrogNewPMX            ; New frog X...

	; Do horizontal repositioning.
	; Change frog HPOS.  Each part is not at 0 origin, so there are offsets...

	stx HPOSP0_TABLE+2 ; + 0 is frog parts 1
	inx
	stx HPOSP1_TABLE+2 ; + 1 is frog parts 2
	stx HPOSP2_TABLE+2 ; + 1 is frog eye iris


	rts


;==============================================================================
; UPDATE SHAPE SPECS                                           A  X  Y
;==============================================================================
; Set all Current values to the New values.
; 
; On Exit X is the new shape. Useful if someone wants to call the color update.
; -----------------------------------------------------------------------------

UpdateShapeSpecs

	lda FrogNewPMX       ; New Y coord.
	sta FrogPMX

	lda FrogNewPMY       ; New X coord.
	sta FrogPMY 

	lda FrogNewRow       ; Also new Frog Row.
	sta FrogRow

	ldx FrogNewShape    ; And the shape.
	stx FrogShape

	rts


;==============================================================================
;											UpdateShape  A  X  Y
;==============================================================================
; Complete redisplay of the object/shape.  
; Erase old object/shape position if needed.
; Load new object/shape into PM Memory at the new position.
; Update current position == new position.
; Y positioning different from X positioning, since it must reload memory.
; Update current shape = new shape.
; Frog Update controls parts to do (because Main trying to erase the 
; shape is arguing with the VBI)
; FrogUpdate 0 = no changes.  
;            1 = Any reason to change position... 
;           -1 = erase, stop, and no further updates. 
; -----------------------------------------------------------------------------

UpdateShape

	lda FrogUpdate       ; 
	beq ExitUpdateShape  ; 0 == no movement.  skip all.

	jsr EraseShape       ; Remove old shape at the old vertical Y position.
	lda FrogUpdate        
	bpl b_usRedrawShape  ; >0 = continue   

	lda #SHAPE_OFF       ; <0 = stop, so stop doing things after the erase.
	sta FrogUpdate       ; Erased above, therefore stop everything further.
	sta FrogNewShape     ; SHAPE_OFF is 0.  Make all shapes off.
	sta FrogShape
	beq ExitUpdateShape

b_usRedrawShape
	jsr DrawShape        ; Draw NEW shape at new vertical Y position.
	jsr PositionShape    ; Move shape to new horizontal X position. (and set sizes).

ExitUpdateShape
	jsr UpdateShapeSpecs ; Commit the new shape and the new X and Y coords.
	                     ;  UpdateShapeSpecs returns the new shape number in X.
	jsr libPmgSetColors  ; Set colors for this object.  Depends on X = Shape number.

	rts


;==============================================================================
; PROCESS NEW SHAPE POSITION                                         
;==============================================================================
; Forcibly clip the new frog positions to the game's playfield area limits.
; Call the main routine to redraw the object.
; -----------------------------------------------------------------------------

ProcessNewShapePosition

	lda FrogNewPMX      ; Is the new X different
	cmp #MIN_FROGX      ; Is PM X smaller than the minimum?
	bcs CheckHPOSMax    ; No.  

	lda #MIN_FROGX      ; Yes.  Reset X
	sta FrogNewPMX      ; to the minimum.
	bne UpdateTheFrog   ; render it.

CheckHPOSMax
	cmp #MAX_FROGX+1    ; Is PM X bigger than the maximum?
	bcc UpdateTheFrog   ; No.

	lda #MAX_FROGX      ; Yes.  Reset X
	sta FrogNewPMX      ; to the maximum.

UpdateTheFrog
	jsr UpdateShape     ; then FrogPMX == FrogNewPMX. FrogPMY == FrogNewPMY. FrogRow=FrogNewRow.

	rts

