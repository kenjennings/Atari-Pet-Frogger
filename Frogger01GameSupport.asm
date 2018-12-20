; ==========================================================================
; GAME SUPPORT
;
; Miscellaneous:
; Press ANY Key.
; Score management.
; Frog Management.
; Game Level Speed management.
;
; --------------------------------------------------------------------------

; ==========================================================================
; RUN PROMPT FOR ANY KEY
; Maintain blinking timer.
; Update/blink text on line 23.
; Return 0/BEQ when the any key is not pressed.
; Return !0/BNE when the any key is pressed.
;
; On Exit:
; A  contains key press.
; CPU flags are comparison of key value to $FF which means no key press.
; --------------------------------------------------------------------------
RunPromptForAnyKey
	lda AnimateFrames        ; Did animation counter reach 0 ?
	bne CheckAnyKey          ; no, then is a key pressed?

	jsr ToggleFlipFlop       ; Yes! Let's toggle the flashing prompt
	bne PromptInverse        ; If this is 1 then display inverse prompt

	ldy #PRINT_INST_TXT4     ; Display normal prompt
	ldx #23
	jsr PrintToScreen
	jmp ResetPromptBlinking

PromptInverse
	ldy #PRINT_INST_TXT4_INV ; Display inverse prompt
	ldx #23
	jsr PrintToScreen

ResetPromptBlinking
	lda #60                  ; Blinking speed.
	jsr ResetTimers

CheckAnyKey
	jsr CheckKey             ; Get a key if timer permits.
	cmp #$FF                 ; Key is pressed?

	rts


; ==========================================================================
; Clear the score digits to zeros.
; That is, internal screen code for "0"
; If a high score is flagged, then do not clear high score.
; --------------------------------------------------------------------------
ClearGameScores
	ldx #$07           ; 8 digits. 7 to 0

CLEAR
	lda #INTERNAL_0    ; Atari internal code for "0"
	sta MyScore,x      ; Put zero/"0" in score buffer.

	ldy FlaggedHiScore ; Has a high score been flagged? ($FF)
	bmi CLNEXT         ; If so, then skip this and go to the next digit.

	sta HiScore,x      ; Also put zero/"0" in the high score.

CLNEXT
	dex                ; decrement index to score digits.
	bpl CLEAR          ; went from 0 to $FF? no, loop for next digit.

; Hmmmm.  Did modularization eliminate the following ?
;	tay                ; Now Y also is zero/"0".
	lda #3             ; Reset number of
	sta NumberOfLives  ; lives to 3.
;	tya                ; A  is zero/"0" again.
	ldy #$13           ; Y = 19 (dec) (again)

	rts


; ==========================================================================
; ADD 500 TO SCORE
;
; Add 500 to score.  (duh.)
;
; Uses A, X
; --------------------------------------------------------------------------
Add500ToScore
	lda #5            ; Represents "500" Since we don't need to add to the tens and ones columns.
	sta ScoreToAdd    ; Save to add 1
	ldx #5            ; Offset from start of "00000*00" to do the adding.
	stx NumberOfChars ; Position offset in score.
	jsr AddToScore    ; Deal with score update.

	inc FrogsCrossed  ; Add to frogs successfully crossed the rivers.

	rts


; ==========================================================================
; ADD 10 TO SCORE
;
; Add 10 to score.  (duh.)
;
; Uses A, X
; --------------------------------------------------------------------------
Add10ToScore
	lda #1            ; Represents "10" Since we don't need to add to the ones column.
	sta ScoreToAdd    ; Save to add 1
	ldx #6            ; Offset from start of "000000*0" to do the adding.
	stx NumberOfChars ; Position offset in score.
	jsr AddToScore    ; Deal with score update.

	rts


; ==========================================================================
; ADD TO SCORE
;
; Add value in ScoreToAdd to the score at index position
; NumberOfChars in the score digits.
;
; A, Y, X registers  are preserved.
; --------------------------------------------------------------------------
AddToScore
	mRegSaveAYX          ; Save A, X, and Y.

	ldx NumberOfChars    ; index into "00000000" to add score.
	lda ScoreToAdd       ; value to add to the score
	clc
	adc MyScore,x
	sta MyScore,x

EvaluateCarry            ; (re)evaluate if carry occurred for the current position.
	lda MyScore,x
	cmp #[INTERNAL_0+10] ; Did math carry past the "9"?
	bcc ExitAddToScore   ; if it does not carry , then go to exit.

; The score carried past "9", so it must be adjusted and
; the next/greater position is added.
	lda #INTERNAL_0      ; Atari internal code for "0".
	sta MyScore,x        ; Reset current position to "0"
	dex                  ; Go to previous position in score
	inc MyScore,x        ; Add 1 to the next digit.
	bne EvaluateCarry    ; This cannot go from $FF to 0, so it must be not zero.

ExitAddToScore           ; All done.
	jsr HighScoreOrNot     ; If My score is high score, then copy to high score.

	mRegRestoreAYX       ; Restore Y, X, and A

	rts


; ==========================================================================
; HIGH SCORE OR NOT
;
; Figure out if My Score is the High Score.
; If so, then copy My Score to High Score.
;
; A  and  X  used.
; --------------------------------------------------------------------------
HighScoreOrNot
	ldx #0

CompareScoreToHighScore
	lda MyScore,x               ; Get my score.
	cmp HiScore,x               ; Compare to high score.
	beq ContinueCheckingScores  ; Equals?  then so far it is not high score
	bcs CopyNewHighScore        ; Greater than.  Would be new high score.

ContinueCheckingScores
	inx
	cpx #7                      ; Are all 7 digits tested?
	bne CompareScoreToHighScore ; No, then go do next digit.
	rts                         ; Yes.  Done.

CopyNewHighScore                ; It is a high score.
	lda MyScore,x               ; Copy my score to high score
	sta HiScore,x
	inx
	cpx #7                      ; Copy until the remaining 7 digits are done.
	bne CopyNewHighScore

	rts


; ==========================================================================
; FROG MOVE UP
;
; Add 10 to the score, move screen memory pointer up one line, and
; finally decrement row counter.
; (packed into a callable routine to shorten the caller's code.)
;
; On return BEQ means the frog has reached safety.
; Thus BNE means continue game.
;
; Uses A
; --------------------------------------------------------------------------
FrogMoveUp
	jsr Add10ToScore

	lda FrogLocation     ; subtract $28/40 (dec) from
	sec                  ; the address pointing to
	sbc #$28             ; the frog.
	sta FrogLocation
	bcs DecrementRows    ; If carry is still set, skip high byte decrement.
	dec FrogLocation+1   ; Smartly done instead of lda/sbc/sta.

DecrementRows            ; decrement number of rows.
	dec FrogRow

	rts


; ==========================================================================
; AUTO MOVE FROG
; Process automagical movement on the frog in the moving boat lines
;
; Data to drive AutoMoveFrog routine.
; Byte value indicates direction of row movement.
; 0   = Beach line, no movement.
; 1   = first boat/river row, move right
; 255 = second boat/river row, move left.
; --------------------------------------------------------------------------
AutoMoveFrog
	ldx FrogRow             ; Get the current row number.
	lda MOVING_ROW_STATES,x ; Get the movement flag for the row.
	beq ExitAutoMoveFrog    ; Is it 0?  Nothing to do.  Bail.
	bmi AutoFrogRight       ; is it $ff?  then automatic right move.

	dey                     ; It is 1, so move Frog left one character
	bpl ExitAutoMoveFrog    ; Is it 0 or greater? Then nothing to do. Bail.

	inc FrogSafety          ; Yup.  Ran out of river.  Yer Dead!
	rts

AutoFrogRight
	iny                     ; Move Frog right one character
	cpy #$28                ; Did it reach the right side ?    $28/40 (dec)
	bne ExitAutoMoveFrog    ; No.  Bail..
	inc FrogSafety          ; Yup.  Ran out of river.   Yer Dead!

ExitAutoMoveFrog
	rts


MOVING_ROW_STATES
	.rept 6                 ; 6 occurrences of
		.BYTE 0, 1, $FF     ; Beach (0), Left (1), Right (FF) directions.
	.endr


; ==========================================================================
; A little code size optimization.
; Add 120 (dec) to the current MovesCars pointer.
; This moves the pointer to the next river/boat line 3 lines lower,
; so the current shift logic can be repeated.
; --------------------------------------------------------------------------
MoveCarsPlus120
	clc
	lda MovesCars           ; Add $78/120 (dec) to the start of line pointer
	adc #$78                ; to set new position 3 lines lower.
	sta MovesCars
	bcc ExitMoveCarsPlus120 ; No carry?  Then exit.
	inc MovesCars + 1       ; Smartly done instead of lda/adc #0/sta.

ExitMoveCarsPlus120
	rts


; ==========================================================================
; SET BOAT SPEED
; Set the animation timer for the game screen based on the
; number of frogs that have been saved.
;
; NOTE ANIMATION_FRAMES is in the TimerStuff.asm file.
; A  and  X  will be saved.
; --------------------------------------------------------------------------
SetBoatSpeed

	mRegSaveAX

	ldx FrogsCrossed          ; How many frogs crossed?
	cpx #12                   ; Limit this index from 0 to 11.
	bcc GetSpeedByWayOfFrogs  ; Anything bigger than that
	ldx #11                   ; must be truncated to the limit.

GetSpeedByWayOfFrogs
	lda ANIMATION_FRAMES,x    ; Set timer for animation based on frogs.
	jsr ResetTimers

	mRegRestoreAX

	rts

