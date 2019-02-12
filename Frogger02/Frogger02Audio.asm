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
;
; --------------------------------------------------------------------------


; ==========================================================================
; Frogger AUDIO
;
; All the routines to run for sound support.
; It is truly sad.
; --------------------------------------------------------------------------

SOUND_OFF   = 0
SOUND_TINK  = 1
SOUND_SLIDE = 2
SOUND_HUM_A = 3
SOUND_HUM_B = 4

SOUND_MAX = 4

; ======== The world's most inept sound system. ========
;
; The world's cheapest sequencer. Play one sound value from a table at each 
; call. Assuming this is done synchronized to the frame it performs a sound 
; change every 16.6ms (approximately)  (at 60fps)
; 
; Sound control between main process and VBI to turn on/off/play sounds.
; 0   = Set by Main to direct stop managing sound pending an update from 
;       MAIN. This does not stop the POKEY's currently playing sound. 
;       It is set by the VBI to indicate the channel is idle. (unmanaged) 
; 1   = Main sets to direct VBI to start playing a sound FX.
; 2   = VBI sets when it is playing to inform Main that it has taken 
;       direction and is now busy.
; 255 = Direct VBI to silence the channel.
;
; So, the procedure for playing sound.
; 1) MAIN sets SOUND_CONTROL to 0.
; 2) MAIN sets SOUND_FX_LO/HI pointer to the sound effects 
;    sequence to play.
; 3) MAIN sets SOUND_CONTROL to 1 to tell VBI to start.
; 4) VBI when playing sets SOUND_CONTROL value to 2. 


	.align 4

; A sound Entry is 4 bytes...
; byte 0, AUDC
; byte 1, AUDF
; byte 2, Duration, number of frames to count.
; byte 3, 0 == end+stop sound.  
;         1 == continue normal playing
;       255 == end (do not stop sound).
;       Eventually some other magic to be determined goes here.

SOUND_ENTRY_OFF
	.byte 0,0,0,0

SOUND_ENTRY_TINK ; Press A Button.
	.byte $AD,$20,3,1
	.byte $Ac,$20,3,1
	.byte $Ab,$20,3,1
	.byte $Aa,$20,2,1
	.byte $A8,$20,3,1
	.byte $A6,$20,2,1
	.byte $A5,$20,1,1
	.byte $A3,$20,1,1
	.byte $A2,$20,1,1
	.byte $A1,$20,0,1
	.byte $A0,$00,0,0

SOUND_ENTRY_SLIDE ; Title logo lines slide right to left
	.byte $02,50,1,1
	.byte $03,49,1,1
	.byte $03,48,1,1
	.byte $04,47,1,1
	.byte $04,46,1,1
	.byte $05,45,1,1
	.byte $05,44,1,1
	.byte $06,43,1,1
	.byte $06,42,1,1
	.byte $07,41,1,1
	.byte $07,40,1,1
	.byte $08,39,1,1
	.byte $08,38,1,1
	.byte $09,37,1,1
	.byte $09,36,1,1
	.byte $0a,35,1,1
	.byte $0a,34,1,1
	.byte $0b,33,1,1
	.byte $0b,32,1,1
	.byte $0c,31,1,1
	.byte $0c,30,1,1
	.byte $0d,29,1,1
	.byte $0d,28,1,1
	.byte $0e,27,1,1
	.byte $0e,26,1,1
	.byte $0e,25,1,1
	.byte $0e,24,1,1
	.byte $0e,23,1,1
	.byte $0d,22,1,1
	.byte $0c,21,1,1
	.byte $00,$00,0,0

SOUND_ENTRY_HUMMER_A ; one-half of Atari light saber
	.byte $A8,$FF,0,255

SOUND_ENTRY_HUMMER_B ; one-half of Atari light saber
	.byte $A8,$FE,0,255

; Pointers to starting sound entry in a sequence.
SOUND_FX_LO_TABLE
	.byte <SOUND_ENTRY_OFF
	.byte <SOUND_ENTRY_TINK
	.byte <SOUND_ENTRY_SLIDE
	.byte <SOUND_ENTRY_HUMMER_A
	.byte <SOUND_ENTRY_HUMMER_B

SOUND_FX_HI_TABLE
	.byte >SOUND_ENTRY_OFF
	.byte >SOUND_ENTRY_TINK
	.byte >SOUND_ENTRY_SLIDE
	.byte >SOUND_ENTRY_HUMMER_A
	.byte >SOUND_ENTRY_HUMMER_B

; ==========================================================================
; Stop All Sound
; -------------------------------------------------------------------------- 
; Main routine to stop all playing for all channels.
; 
; X = sound number to use.
; Y = sound channel to assign.
; --------------------------------------------------------------------------
StopAllSound
	ldy #SOUND_OFF

	ldx #3
LoopStopSound
	jsr SetSound
	dex
	bpl LoopStopSound

	rts


; ==========================================================================
; Set Sound
; -------------------------------------------------------------------------- 
; Main routine to set sound playing for a channel.
;
; Sound control between main process and VBI to turn on/off/play sounds.
; 0   = Set by Main to direct stop managing sound pending an update from 
;       MAIN. This does not stop the POKEY's currently playing sound. 
;       It is set by the VBI to indicate the channel is idle. (unmanaged) 
; 1   = Main sets to direct VBI to start playing a sound FX.
; 2   = VBI sets when it is playing to inform Main that it has taken 
;       direction and is now busy.
; 255 = Direct VBI to silence the channel.
;
; X = sound number to use.
; Y = sound channel to assign.
; --------------------------------------------------------------------------
SetSound
	lda #0
	sta SOUND_CONTROL,X     ; Tell VBI to stop working POKEY channel X

	lda SOUND_FX_LO_TABLE,Y ; Assign pointer of sound effect
	sta SOUND_FX_LO,X       ; to the channel controller.
	lda SOUND_FX_HI_TABLE,Y
	sta SOUND_FX_HI,X

	lda #1
	sta SOUND_CONTROL,X     ; Tell VBI it can start running POKEY channel X

	rts


; ==========================================================================
; Sound Service
; --------------------------------------------------------------------------
; The world's cheapest sequencer. Play one sound value from a table at each 
; call. Assuming this is done synchronized to the frame it performs a sound 
; change every 16.6ms (approximately)
; 
; Sound control between main process and VBI to turn on/off/play sounds.
; 0   = Set by Main to direct stop managing sound pending an update from 
;       MAIN. This does not stop the POKEY's currently playing sound. 
;       It is set by the VBI to indicate the channel is idle. (unmanaged) 
; 1   = Main sets to direct VBI to start playing a sound FX.
; 2   = VBI sets when it is playing to inform Main that it has taken 
;       direction and is now busy.
; 255 = Direct VBI to silence the channel.
; So, the procedure for playing sound.
; 1) MAIN sets SOUND_CONTROL to 0.
; 2) MAIN sets SOUND_FX_LO/HI pointer to the sound effects 
;    sequence to play.
; 3) MAIN sets SOUND_CONTROL to 1 to tell VBI to start.
; 4) VBI when playing sets SOUND_CONTROL value to 2.
;
; A sound Entry is 4 bytes...
; byte 0, AUDC
; byte 1, AUDF
; byte 2, Duration, number of frames to count.
; byte 3, 0 == end+stop sound.  
;         1 == continue normal playing
;       255 == end (do not stop sound).
;       Eventually some other magic to be determined goes here.
; --------------------------------------------------------------------------

SoundService
	ldx #3
LoopSoundServiceControl
	lda SOUND_CONTROL,x
	beq DoNextSoundChannel       ; SOUND_CONTROL == 0 means MAIN says do nothing

	cmp #255                     ; Is it 255 (-1)?
	bne CheckMainSoundDirections ; No, then go follow channel FX directions.
	jsr EndFXAndStopSound        ; SOUND_CONTROL == 255 Direction from main to stop sound.
	jmp DoNextSoundChannel

CheckMainSoundDirections
	cmp #1                   ; SOUND_CONTROL == 1 New direction from main?
	bne DoNormalSoundService ; No, continue normally.

; SOUND_CONTROL == 1  is new direction from Main.  Setup new request.
	lda #2
	sta SOUND_CONTROL,x      ; Tell Main we're on the clock

	jsr LoadSoundPointerFromX ; Get the pointer to the current entry.

	; This is the first time in this Entry.  
	jsr EvaluateEntryControlToStop  ; test if this is the end now.
	beq DoNextSoundChannel          ; If so, then we're done.

	jsr LoadTheCurrentSoundEntry    ; If not, then load sound up the first time,
	jmp DoNextSoundChannel          ; and then we're done without evaluation duration.

DoNormalSoundService                ; SOUND_CONTROL == 2.  VBI is running normally.
	jsr LoadSoundPointerFromX       ; Get the pointer to the current entry.
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


; Given X, load the current Entry pointer into SOUND_POINTER
LoadSoundPointerFromX
	lda SOUND_FX_LO,X       ;  Get Pointer to specified sound effect.
	sta SOUND_POINTER
	lda SOUND_FX_HI,X
	sta SOUND_POINTER+1

	rts


; Given X and SOUND_POINTER pointing to the entry, then set
; audio controls.
LoadTheCurrentSoundEntry
	jsr SaveXTimes2        ;  X = X * 2  (but save original value)

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
	jsr SaveXTimes2          ;  X = X * 2  (but save original value)

	lda #0                   
	sta AUDC1,X              ; Stop Pokey playing.
	sta AUDF1,X

EndFX
	lda #0
	ldx SAVEX               ; Get original X * 1 value.
	sta SOUND_DURATION,X    ; Make sure duration is 0.
	sta SOUND_CONTROL,X     ; And inform MAIN that this channel is unused.

;	beq DoNextSoundChannel

	rts


SaveXTimes2
	stx SAVEX ; To reference AUDC and AUDF need X * 2.
	txa
	asl
	tax

	rts
