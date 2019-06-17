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
; Version 03, June 2019
; ==========================================================================

EVENT_TARGET_TABLE
	.word EventGameInit-1           ; 0  = EVENT_INIT
	.word EventScreenStart-1        ; 1  = EVENT_START
	.word EventTitleScreen-1        ; 2  = EVENT_TITLE
	.word EventTransitionToGame-1   ; 3  = EVENT_TRANS_GAME
	.word EventGameScreen-1         ; 4  = EVENT_GAME    
	.word EventTransitionToWin-1    ; 5  = EVENT_TRANS_WIN 
	.word EventWinScreen-1          ; 6  = EVENT_WIN      
	.word EventTransitionToDead-1   ; 7  = EVENT_TRANS_DEAD  
	.word EventDeadScreen-1         ; 8  = EVENT_DEAD      
;	.word EventDeadFade-1           ; 9  = EVENT_FADE
	.word EventTransitionGameOver-1 ; 9  = EVENT_TRANS_OVER 
	.word EventGameOverScreen-1     ; 10 = EVENT_OVER      
	.word EventTransitionToTitle-1  ; 11 = EVENT_TRANS_TITLE


; ==========================================================================
; The Game Entry Point where AtariDOS calls for startup.
; 
; And the perpetual loop calling the game's event dispatch routine.
; The code needs this routine as a starting place, so that the 
; routines called from the subroutine table have a place to return
; to.  Otherwise the RTS from those routines would be at the 
; top level and exit the game.
; --------------------------------------------------------------------------

GameStart

	jsr GameLoop 

	jmp GameStart ; Do While More Electricity


; ==========================================================================
; GAME LOOP
;
; The main event dispatch loop for the game... said Capt Obvious.
; Very vaguely like an event loop or state loop across the progressive
; game states which are (loosely) based on the current mode of
; the display.
;
; Each event sets CurrentEvent to change to another event target.
; --------------------------------------------------------------------------

GameLoop
	jsr libScreenWaitFrame     ; Wait for end of frame, start of new frame.

; Due to the frame sync above, at this point the code
; is running at/near the top of the screen refresh.

	lda CurrentEvent           ; Get the current event
	asl                        ; Times 2 for size of address
	tax                        ; Use as index

	lda EVENT_TARGET_TABLE+1,x ; Get routine high byte
	pha                        ; Push to stack
	lda EVENT_TARGET_TABLE,x   ; Get routine low byte 
	pha                        ; Push to stack

	rts                        ; Forces alling the address pushed on the stack.

	; When the called routine ends with rts, it will return to the place 
	; that called this routine which is up in GameStart.

; ==========================================================================
; END OF GAME EVENT LOOP
; --------------------------------------------------------------------------

