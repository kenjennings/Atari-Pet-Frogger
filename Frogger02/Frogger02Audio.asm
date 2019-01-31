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
;; If the current index is zero then quit. 
;; Apply the Control and Frequency values from the tables to AUDC1 and AUDF1
;; If Control and Frequency are both 0 then the sound is over.  Zero the index.
;; If Control and Frequency are both non-zero, increment the index for the next call.
;;
;; No registers modified.
;;---------------------------------------------------------------------------------------------------

SoundService

	ldx SOUND_INDEX ;; Get current sound progress
	beq exitSoundService ;; If zero, then no sound.

	lda SOUND_AUDC_TABLE,x  ;; Load current sound into registers
	sta AUDC1
	lda SOUND_AUDF_TABLE,x
	sta AUDF1

	;; if AUDC and AUDF values are zero then zero the index
	ora SOUND_AUDC_TABLE,x  ;; if AUDC and AUDF values are not zero
	bne nextSoundIndex  ;; then incement index for next sound
	sta SOUND_INDEX     ;; otherwise, if 0 , then reset index to 0
	beq exitSoundService

nextSoundIndex
	inc SOUND_INDEX ;; increment index for next call.
	
exitSoundService
	rts





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

