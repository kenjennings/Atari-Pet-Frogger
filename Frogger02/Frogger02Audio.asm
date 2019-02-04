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
; Frogger AUDIO
;
; All the routines to run for sound support.
; It is truly sad.
; --------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------
;; Sound Service
;;---------------------------------------------------------------------------------------------------
;; The world's cheapest sequencer. Play one sound value from a table at each call.
;; Assuming this is done synchronized to the frame it performs a sound change every 
;; 16.6ms (approximately)
;; 
; Sound control between main process and VBI to turn on/off/play sounds.
; 0   = Set by Main to direct stop managing sound pending an update from MAIN. 
;       This does not stop the sound. 
;       It is set by the VBI to indicate the channel is idle. 
; 1   = Main sets to direct VBI to start playing a sound FX.
; 2   = VBI sets when it is playing to inform Main that it has taken direction.
; 255 = Direct VBI to silence the channel.
; So, the procedure for playing sound.
; 1) MAIN sets SOUND_CONTROL to 0.
; 2) MAIN sets SOUND_FX_LO/HI pointer to the sound effects sequence to play.
; 3) MAIN sets SOUND_CONTROL to 1 to tell VBI to start.
; 4) VBI when playing sets SOUND_CONTROL value to 2  
;
; A sound Entry is 4 bytes...
; byte 0, AUDC
; byte 1, AUDF
; byte 2, Duration, number of frames to count.
; byte 3, Some magic to be determined goes here.  
;         0 == end+stop sound.  
;         1 == continue normal playing
;       255 == end (do not stop sound).
;;--------------------------------------------------------------------------------------------------

SoundService
	ldx #3
LoopSoundServiceControl
	lda SOUND_CONTROL,x
	beq DoNextSoundChannel   ; SOUND_CONTROL == 0 means MAIN says do nothing

	cmp #255
	bne CheckMainSoundDirections
	jsr EndFXAndStopSound    ; SOUND_CONTROL == 255 Direction from main to stop sound.
	jmp DoNextSoundChannel

CheckMainSoundDirections
	cmp #1                   ; SOUND_CONTROL == 1 New direction from main?
	bne DoNormalSoundService ; No, continue normally.

; SOUND_CONTROL == 1  is new direction from Main.  Setup new request.
	lda #2
	sta SOUND_CONTROL,x      ; Tell Main we're on the clock

	lda SOUND_FX_LO,X       ;  Get Pointer to specified sound effect.
	sta SOUND_POINTER
	lda SOUND_FX_HI,X
	sta SOUND_POINTER+1

	; This is the first time in this Entry.  
	jsr EvaluateEntryControlToStop  ; test if this is the end now.
	beq DoNextSoundChannel          ; If so, then we're done.

	jsr LoadTheCurrentSoundEntry    ; If not, then load sound up the first time,
	jmp DoNextSoundChannel          ; and then we're done without evaluation duration.

DoNormalSoundService                ; SOUND_CONTROL == 2.  VBI is running normally.
	jsr EvaluateEntryControlToStop 
	; If the Entry Control set CONTROL to stop the sound, then do no more work.
	beq DoNextSoundChannel          ; SOUND_CONTROL == 0 means do nothing

	; Regular continuation.
	lda SOUND_DURATION,x            ; If sound currently running has a duration, then decrement and loop.
	beq DoTheCurrentSound           ; 0 means end of duration.  Load sound for the current entry.
	dec SOUND_DURATION,x            ; Decrement duration.
	jmp DoNextSoundChannel          ; Maybe on the next frame there will be something to do.

DoTheCurrentSound                   ; Duration is 0. Just do current parameters.
	jsr LoadTheCurrentSoundEntry

GoToNextSoundEntry                  ; Add 4 to the current pointer address to get the next entry.
	clc
	lda SOUND_FX_LO,X
	adc #4
	sta SOUND_FX_LO,X
	bcc DoNextSoundChannel
	inc SOUND_FX_HI,X

DoNextSoundChannel
	dex                            ; 3,2,1,0....
	bpl LoopSoundServiceControl

ExitSoundService
	rts


; Given X and SOUND_POINTER pointing to the entry, then set
; audio controls.
LoadTheCurrentSoundEntry
	jsr SaveXTimes2

	ldy #0                 ; Pull AUDC
	lda (SOUND_POINTER),y
	sta AUDC1,X
	iny
	lda (SOUND_POINTER),y  ; Pull AUDF
	sta AUDF1,X
	iny
	lda (SOUND_POINTER),y   ; Pull Duration
	ldx SAVEX               ; Get original X * 1 value.
	sta SOUND_DURATION,X

	rts


; Do what the Entry control says if it says to stop sound.
EvaluateEntryControlToStop
	ldy #3
	lda (SOUND_POINTER),y    ; What does entry control say?
	beq EndFXAndStopSound    ; 0 means the end.
	bmi EndFX                ; 255 means end, without stopping sound.

	lda SOUND_CONTROL,X      ; Get value so caller can evaluate.

	rts

EndFXAndStopSound
	jsr SaveXTimes2

	lda #0
	sta AUDC1,X
	sta AUDF1,X

EndFX
	ldx SAVEX             ; Get original X * 1 value.
	sta SOUND_DURATION,X  ; Make sure duration is 0.
	sta SOUND_CONTROL,X   ; And inform MAIN that this channel is unused.

	beq DoNextSoundChannel

	rts


SaveXTimes2
	stx SAVEX ; To reference AUDC and AUDF need X * 2.
	txa
	asl
	tax
	
	rts


; ======== Support for the world's most inept sound system. ========

; Pointers used by the VBI for the current sound entry.
SOUND_FX0 .word $0000
SOUND_FX1 .word $0000
SOUND_FX2 .word $0000
SOUND_FX3 .word $0000 

; Sound control between main process and VBI to turn on/off/play sounds.
; 0   = Set by Main to direct stop managing sound pending an update from MAIN. 
;       This does not stop the sound. 
;       It is set by the VBI to indicate the channel is idle. 
; 1   = Main sets to direct VBI to start playing a sound FX.
; 2   = VBI sets when it is playing to inform Main that it has taken direction.
; 255 = Direct VBI to silence the channel.
; So, the procedure for playing sound.
; 1) MAIN sets SOUND_CONTROL to 0.
; 2) MAIN sets SOUND_FX pointer to the sound effects sequence to play.
; 3) MAIN sets SOUND_CONTROL to 1 to tell VBI to start.
; 4) VBI when playing sets SOUND_CONTROL value to 2  


; Pointers to starting sound entry in a sequence.
SOUND_FX_LO_TABLE
	.byte <SOUND_OFF


SOUND_FX_HI_TABLE
	.byte >SOUND_OFF

; A sound Entry is 4 bytes...
; byte 0, AUDC
; byte 1, AUDF
; byte 2, Duration, number of frames to count.
; byte 3, Some magic to be determined goes here.  
;         0 == end+stop sound.  
;         1 == continue
;       255 == end (do not stop sound).

SOUND_OFF
	.byte 0,0,0,0


SOUND_AUDC_TABLE ;; AUDC -- Waveform, and Volume
;; index 0 is 0 sound
	.byte $00
;; index 1 is bing/buzz on drop ball.  A 2ms, D 168ms, S 0, R 168 ms
	.byte $Ad,$AC,$AB,$AA,$A9,$A8,$A7,$A6,$A5,$A3,$A2,$A0,$00
;; index $0e/14 is bounce brick.  A 2ms, D 168ms, S 0, R 168 ms
	.byte $Ad,$AC,$AB,$AA,$A9,$A8,$A7,$A6,$A5,$A3,$A2,$A0,$00
;; index $1b/27 is bounce_wall.  A 2ms, D 168ms, S 0, R 168 ms
	.byte $Ad,$AC,$AB,$AA,$A9,$A8,$A7,$A6,$A5,$A3,$A2,$A0,$00
;; index $28/40 is bounce_paddle.  A 2ms, D 168ms, S 0, R 168 ms
	.byte $Ad,$AC,$AB,$AA,$A9,$A8,$A7,$A6,$A5,$A3,$A2,$A0,$00

SOUND_AUDF_TABLE ;; AUDF -- Frequency -- a little quirky tone shaping
;; index 0 is 0 sound
	.byte $00
;; index 1 is bing/buzz on drop ball.  A 2ms, D 168ms, S 0, R 168 ms
	.byte $30,$38,$40,$48,$50,$58,$60,$68,$70,$80,$90,$a0,$00
;; index $0E/14 is bounce brick.  A 2ms, D 168ms, S 0, R 168 ms
	.byte $20,$20,$20,$20,$20,$1f,$1f,$1f,$1e,$1e,$1e,$1d,$00
;; index $1b/27 is bounce_wall.  A 2ms, D 168ms, S 0, R 168 ms
	.byte $18,$18,$18,$18,$18,$17,$17,$17,$16,$16,$16,$15,$00
;; index $28/40 is bounce_paddle.  A 2ms, D 168ms, S 0, R 168 ms
	.byte $10,$10,$10,$10,$10,$0f,$0f,$0f,$0e,$0e,$0e,$0d,$00

SOUND_DURATION_TABLE ;; Number of frames to count.


