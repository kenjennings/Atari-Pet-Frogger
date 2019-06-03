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
; Frogger AUDIO
;
; All the routines to run "The world's cheapest sequencer." 
; It is truly sad.
;
; Game sound allocation:
; Channel 0 - title slide, light saber
; Channel 1 - light saber
; Channel 2 - Frog movement bump.
; Channel 3 - Ambient water noise, music.
; --------------------------------------------------------------------------

SOUND_OFF   = 0
SOUND_TINK  = 1
SOUND_SLIDE = 2
SOUND_HUM_A = 3
SOUND_HUM_B = 4
SOUND_DIRGE = 5
SOUND_THUMP = 6
SOUND_JOY   = 7
SOUND_WATER = 8

SOUND_MAX   = 8

; ======== The world's most inept sound system. ========
;
; The world's cheapest sequencer. Play one sound value from a table at each 
; call. Assuming this is done synchronized to the frame it performs a sound 
; change every 16.6ms (approximately)  (at 60fps)
; 
; Sound control between main process and VBI to turn on/off/play sounds.
; 0   = Set by Main to direct stop managing sound pending an update from 
;       MAIN. This does not stop the POKEY's currently playing sound. 
;       It is set by the VBI to indicate the channel is idle/unmanaged. 
; 1   = Main sets to direct VBI to start playing a new sound FX.
; 2   = VBI sets when it is playing to inform Main that it has taken 
;       direction and is now busy.
; 255 = Direct VBI to silence the channel.
;
; So, the procedure for playing sound.
; 1) MAIN sets the channel's SOUND_CONTROL to 0.
; 2) MAIN sets the channel's SOUND_FX_LO/HI pointer to the sound effects 
;    sequence to play.
; 3) MAIN sets the channel's SOUND_CONTROL to 1 to tell VBI to start.
; 4) VBI when playing sets the channel's SOUND_CONTROL value to 2, then 
;    to 0 when done.


	.align 4

; A sound Entry is 4 bytes...
; byte 0, AUDC (distortion/volume) value
; byte 1, AUDF (frequency) value
; byte 2, Duration, number of frames to count. 0 counts as 1 frame.
; byte 3, 0 == End of sequence. Stop playing sound. (Set AUDF and AUDC to 0)
;         1 == Continue normal playing.
;       255 == End of sequence. Do not stop playing sound.
;       Eventually some other magic to be determined goes here.

SOUND_ENTRY_OFF
	.byte 0,0,0,0


SOUND_ENTRY_TINK ; Press A Button.
	.byte $A6,120,2,1
	.byte $A5,120,1,1
	.byte $A4,120,1,1
	.byte $A3,120,0,1
	.byte $A2,120,0,1
	.byte $A1,120,0,1

	.byte $A0,0,0,0

	; Maybe if I thought about it for a while I could do a 
	; ramp/counting feature in the sound entry control byte 
	; in less than 100-ish bytes of code which is abpout how 
	; much space this table occupies. 
SOUND_ENTRY_SLIDE ; Title logo lines slide right to left
	.byte $02,50,1,1 ; 1 == 2 frames per wait.
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
	.byte $0d,27,1,1
	.byte $0d,26,1,1
	.byte $0d,25,1,1
	.byte $0e,24,1,1
	.byte $0e,23,1,1
	.byte $0e,22,1,1
	.byte $0e,21,1,1
	.byte $0e,20,1,1
	.byte $0e,19,1,1
	.byte $0e,18,1,1
	.byte $0e,17,1,1
	.byte $0e,16,1,1
	.byte $0e,15,1,1
	.byte $0e,14,1,1
	.byte $0e,13,1,1

	.byte $00,$00,0,0

	
SOUND_ENTRY_HUMMER_A ; one-half of Atari light saber
	.byte $A9,$FF,30,1
	.byte $A8,$FF,7,1
	.byte $A7,$FF,7,1
	.byte $A6,$FF,7,1
	.byte $A5,$FF,7,1
	.byte $A3,$FF,7,1
	.byte $A1,$FF,7,1
	.byte $A0,0,0,0

SOUND_ENTRY_HUMMER_B ; one-half of Atari light saber
	.byte $A8,$FE,30,1
	.byte $A8,$FE,7,1
	.byte $A7,$FE,7,1
	.byte $A6,$FE,7,1
	.byte $A5,$FE,7,1
	.byte $A3,$FE,7,1
	.byte $A1,$FE,7,1
	.byte $A0,0,0,0


SOUND_ENTRY_DIRGE ; Chopin's Funeral for a frog (or gunslinger in Outlaw) 
	.byte $A4,182,0,1 ; F, 1/4, 16 steps
	.byte $A6,182,13,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/8 ., 12 steps
	.byte $A6,182,9,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/16,  4 steps
	.byte $A6,182,0,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/2, 32 steps
	.byte $A6,182,29,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 

	.byte $A4,182,0,1 ; F, 1/4, 16 steps
	.byte $A6,182,13,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/8 ., 12 steps
	.byte $A6,182,9,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/16,  4 steps
	.byte $A6,182,0,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/2, 32 steps
	.byte $A6,182,29,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 

	.byte $A4,182,0,1 ; F, 1/4, 16 steps
	.byte $A6,182,13,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/8 ., 12 steps
	.byte $A6,182,9,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/16,  4 steps
	.byte $A6,182,0,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/4, 16 steps
	.byte $A6,182,13,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,144,0,1 ; A, 1/8 ., 12 steps
	.byte $A6,144,9,1 
	.byte $A4,144,0,1 
	.byte $A2,144,0,1 
	.byte $A4,162,0,1 ; G, 1/16,  4 steps
	.byte $A6,162,0,1 
	.byte $A4,162,0,1 
	.byte $A2,162,0,1 

	.byte $A4,162,0,1 ; G, 1/8 ., 12 steps
	.byte $A6,162,9,1 
	.byte $A4,162,0,1 
	.byte $A2,162,0,1 
	.byte $A4,182,0,1 ; F, 1/16,  4 steps
	.byte $A6,182,0,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/8 ., 12 steps
	.byte $A6,182,9,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/16,  4 steps
	.byte $A6,182,0,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 
	.byte $A4,182,0,1 ; F, 1/2,  32 steps
	.byte $A6,182,29,1 
	.byte $A4,182,0,1 
	.byte $A2,182,0,1 

	.byte $A0,$00,0,0


SOUND_ENTRY_THUMP ; When a frog moves
	.byte $A2,240,0,1 
	.byte $A5,240,0,1 
	.byte $A8,240,2,1 
	.byte $A4,240,0,1 
	.byte $A1,240,0,1 
	.byte $A0,$00,0,0


SOUND_ENTRY_ODE2JOY ; Beethoven's Ode To Joy when a frog is saved 
	.byte $Aa,121,0,1 ; C, 1/4, 10 steps
	.byte $A8,121,6,1 
	.byte $A5,121,0,1 
	.byte $A3,121,0,1 
	.byte $A1,121,0,1 
	.byte $Aa,121,0,1 ; C, 1/4, 10 steps
	.byte $A8,121,6,1 
	.byte $A5,121,0,1 
	.byte $A3,121,0,1 
	.byte $A1,121,0,1 
	.byte $Aa,108,0,1 ; D, 1/4, 10 steps
	.byte $A8,108,6,1 
	.byte $A5,108,0,1 
	.byte $A3,108,0,1 
	.byte $A2,108,0,1 
	.byte $Aa,96,0,1 ; E, 1/4, 10 steps
	.byte $A8,96,6,1 
	.byte $A5,96,0,1 
	.byte $A3,96,0,1 
	.byte $A1,96,0,1 

	.byte $Aa,96,0,1 ; E, 1/4, 10 steps
	.byte $A8,96,6,1 
	.byte $A5,96,0,1 
	.byte $A3,96,0,1 
	.byte $A1,96,0,1 
	.byte $Aa,108,0,1 ; D, 1/4, 10 steps
	.byte $A8,108,6,1 
	.byte $A5,108,0,1 
	.byte $A3,108,0,1 
	.byte $A1,108,0,1 
	.byte $Aa,121,0,1 ; C, 1/4, 10 steps
	.byte $A8,121,6,1 
	.byte $A5,121,0,1 
	.byte $A3,121,0,1 
	.byte $A1,121,0,1 
	.byte $Aa,128,0,1 ; B, 1/4, 10 steps
	.byte $A8,128,6,1 
	.byte $A5,128,0,1 
	.byte $A3,128,0,1 
	.byte $A1,128,0,1 

	.byte $Aa,144,0,1 ; A, 1/4, 10 steps
	.byte $A8,144,6,1 
	.byte $A5,144,0,1 
	.byte $A3,144,0,1 
	.byte $A1,144,0,1 
	.byte $Aa,144,0,1 ; A, 1/4, 10 steps
	.byte $A8,144,6,1 
	.byte $A5,144,0,1 
	.byte $A3,144,0,1 
	.byte $A1,144,0,1 
	.byte $Aa,128,0,1 ; B, 1/4, 10 steps
	.byte $A8,128,6,1 
	.byte $A5,128,0,1 
	.byte $A3,128,0,1 
	.byte $A1,128,0,1 
	.byte $Aa,121,0,1 ; C, 1/4, 10 steps
	.byte $A8,121,6,1 
	.byte $A5,121,0,1 
	.byte $A3,121,0,1 
	.byte $A1,121,0,1 

	.byte $Aa,121,0,1 ; C, 1/4 ., 15 steps
	.byte $A8,121,11,1 
	.byte $A5,121,0,1 
	.byte $A3,121,0,1 
	.byte $A1,121,0,1 
	.byte $Aa,128,0,1 ; B, 1/8, 5 steps
	.byte $A8,128,0,1 
	.byte $A5,128,0,1 
	.byte $A3,128,0,1 
	.byte $A1,128,0,1 
	.byte $Aa,128,0,1 ; B, 1/4, 20 steps
	.byte $A8,128,16,1 
	.byte $A5,128,0,1 
	.byte $A3,128,0,1 
	.byte $A1,128,0,1 

	.byte $A0,$00,0,0


SOUND_ENTRY_WATER ; Water sloshing noises
	.byte $82,1,75,1 ; several full seconds 
	.byte $83,2,75,1 ; of different sounds 
	.byte $81,3,75,1 ; at different volumes.
	.byte $84,4,75,1
	.byte $82,5,75,1
	.byte $81,2,75,255 ; End.  Do not stop sound.


; Pointers to starting sound entry in a sequence.
SOUND_FX_LO_TABLE
	.byte <SOUND_ENTRY_OFF
	.byte <SOUND_ENTRY_TINK
	.byte <SOUND_ENTRY_SLIDE
	.byte <SOUND_ENTRY_HUMMER_A
	.byte <SOUND_ENTRY_HUMMER_B
	.byte <SOUND_ENTRY_DIRGE
	.byte <SOUND_ENTRY_THUMP
	.byte <SOUND_ENTRY_ODE2JOY
	.byte <SOUND_ENTRY_WATER

SOUND_FX_HI_TABLE
	.byte >SOUND_ENTRY_OFF
	.byte >SOUND_ENTRY_TINK
	.byte >SOUND_ENTRY_SLIDE
	.byte >SOUND_ENTRY_HUMMER_A
	.byte >SOUND_ENTRY_HUMMER_B
	.byte >SOUND_ENTRY_DIRGE
	.byte >SOUND_ENTRY_THUMP
	.byte >SOUND_ENTRY_ODE2JOY
	.byte >SOUND_ENTRY_WATER



; ==========================================================================
; ToPlayFXScrollOrNot                                             A  X  Y
; -------------------------------------------------------------------------- 
; Decide to start playing the slide sound or not.
; 
; The duration of the slide on screen should be the same(ish) as the 
; length of the sound playing.  Therefore the sound should run out at the
; same time the slide finishes (more or less)    
; 
; Uses all the registers. 
; X = sound channel to assign.
; Y = sound number to use. (values declared at beginning of Audio.asm.) 
; --------------------------------------------------------------------------
ToPlayFXScrollOrNot
	lda SOUND_CONTROL3      ; Is channel 3 busy?
	bne ExitToPlayFXScroll  ; Yes.  Don't do anything.

	ldx #3                  ; Setup channel 3 to play slide sound.
	ldy #SOUND_SLIDE
	jsr SetSound 

ExitToPlayFXScroll
	rts


; ==========================================================================
; ToReplayFXWaterOrNot                                             A  X  Y
; -------------------------------------------------------------------------- 
; To Replay water effects or not
; 
; Main routine to play the Water sounds during the game. 
; This checks the channel 3 control to see if it is idle.  
; If the channel is idle then the water effects sound sequence is restarted.
;
; Water is a series of long duration white noise/hissing sounds. 
; 
; Uses all the registers. 
; X = sound channel to assign.
; Y = sound number to use. (values declared at beginning of Audio.asm.) 
; --------------------------------------------------------------------------
ToReplayFXWaterOrNot
	lda SOUND_CONTROL3      ; Is channel 3 busy?
	bne ExitPlayWaterFX     ; Yes.  Don't do anything.

PlayWaterFX
	ldx #3                  ; Setup channel 3 to play water noises
	ldy #SOUND_WATER
	jsr SetSound

ExitPlayWaterFX
	rts


; ==========================================================================
; PlayThump                                                      *  *  *
; -------------------------------------------------------------------------- 
; Play Thump for jumping frog
;
; Main routine to play the frog movement sound. 
; This needs to be introduced where the main code is dependent on 
; the CPU flags for determining outcomes. Therefore, to prevent disrupting 
; the logic flow due to flag changes this routine is wrapped in the macros 
; to preserve/protect all registers to insure calling this routine has no 
; discernible effect on the Main code.
; 
; Uses A, X, Y, but preserves all registers on entry/exit.
; --------------------------------------------------------------------------
PlayThump
	mRegSave                   ; Macro: save CPU flags, and A, X, Y

	ldx #2                     ; Setup channel 2 to play frog bump.
	ldy #SOUND_THUMP
	jsr SetSound 

	mRegRestore                ; Macro: Restore Y, X, A, and CPU flags

	rts


; ==========================================================================
; StopAllSound                                                      A  X 
; -------------------------------------------------------------------------- 
; Stop All Sound
;
; Main routine to stop all playing for all channels.
;
; Set the control for each channel to 255 to stop everything now.
; 
; Uses A, X
; X = sound channel to assign.
; --------------------------------------------------------------------------
StopAllSound
	ldx #3               ; Channel 3, 2, 1, 0
	lda #255             ; Tell VBI to silence channel.

LoopStopSound
	sta SOUND_CONTROL,x  ; Set channel control to silence.
	dex
	bpl LoopStopSound    ; Channel 3, 2, 1, 0

	rts


; ==========================================================================
; SetSound                                                        A  X  Y
; -------------------------------------------------------------------------- 
; Set Sound
;
; Main routine to set sound playing for a channel.
;
; The procedure for playing sound.
; 1) MAIN sets the channel's SOUND_CONTROL to 0.
; 2) MAIN sets the channel's SOUND_FX_LO/HI pointer to the sound effects 
;    sequence to play.
; 3) MAIN sets the channel's SOUND_CONTROL to 1 to tell VBI to start.
; 4) VBI when playing sets the channel's SOUND_CONTROL value to 2, then 
;    to 0 when done.
;
; Uses A, X, Y
; X = sound channel to assign. (0 to 3, not 1 to 4)
; Y = sound number to use. (values declared at beginning of Audio.asm.) 
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
; SoundService                                                    A  X  Y
; --------------------------------------------------------------------------
; Sound service called by Deferred Vertical Blank Interrupt.
;
; The world's cheapest sequencer. Play one sound value from a table at each 
; call. Assuming this is done synchronized to the frame it performs a sound 
; change every 16.6ms (approximately)
; 
; Sound control between main process and VBI to turn on/off/play sounds.
; 0   = Set by Main to direct stop managing sound pending an update from 
;       MAIN. This does not stop the POKEY's currently playing sound. 
;       It is set by the VBI to indicate the channel is idle/unmanaged. 
; 1   = Main sets to direct VBI to start playing a new sound FX.
; 2   = VBI sets when it is playing to inform Main that it has taken 
;       direction and is now busy.
; 255 = Direct VBI to silence the channel.
;
; So, the procedure for playing sound.
; 1) MAIN sets the channel's SOUND_CONTROL to 0.
; 2) MAIN sets the channel's SOUND_FX_LO/HI pointer to the sound effects 
;    sequence to play.
; 3) MAIN sets the channel's SOUND_CONTROL to 1 to tell VBI to start.
; 4) VBI when playing sets the channel's SOUND_CONTROL value to 2, then 
;    to 0 when done.
;
; A sound Entry is 4 bytes...
; byte 0, AUDC (distortion/volume) value
; byte 1, AUDF (frequency) value
; byte 2, Duration, number of frames to count. 0 counts as 1 frame.
; byte 3, 0 == End of sequence. Stop playing sound. (Set AUDF and AUDC to 0)
;         1 == Continue normal playing.
;       255 == End of sequence. Do not stop playing sound.
;       Eventually some other magic to be determined goes here.
; --------------------------------------------------------------------------

SoundService
	ldx #3
LoopSoundServiceControl
	lda SOUND_CONTROL,x
	beq DoNextSoundChannel       ; SOUND_CONTROL == 0 means do nothing

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
	lda SOUND_DURATION,x            ; If sound currently running has a duration, then decrement and loop.
	beq ContinueNextSound           ; 0 means end of duration.  Load sound for the currently queued entry.
	dec SOUND_DURATION,x            ; Otherwise, Decrement duration.
	jmp DoNextSoundChannel          ; Maybe on the next frame there will be something to do.

ContinueNextSound
	jsr LoadSoundPointerFromX       ; Get the pointer to the current entry.
	jsr EvaluateEntryControlToStop 
	; If the Entry Control set CONTROL to stop the sound, then do no more work.
	beq DoNextSoundChannel          ; SOUND_CONTROL == 0 means do nothing

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
	lda SOUND_FX_LO,X       ; Get Pointer to specified sound effect.
	sta SOUND_POINTER
	lda SOUND_FX_HI,X
	sta SOUND_POINTER+1

	rts


; Given X and SOUND_POINTER pointing to the entry, then set
; audio controls.
LoadTheCurrentSoundEntry
	jsr SaveXTimes2          ;  X = X * 2  (but save original value)

	ldy #0                   ; Pull AUDC
	lda (SOUND_POINTER),y
	sta AUDC1,X
	iny
	lda (SOUND_POINTER),y    ; Pull AUDF
	sta AUDF1,X
	iny
	lda (SOUND_POINTER),y    ; Pull Duration
	ldx SAVEX                ; Get original X * 1 value.
	sta SOUND_DURATION,X

	rts


; Does the Entry control says to stop sound? 
EvaluateEntryControlToStop
	ldy #3
	lda (SOUND_POINTER),y    ; What does entry control say?
	beq EndFXAndStopSound    ; 0 means the end.
	bmi EndFX                ; 255 means end, without stopping sound.

	lda (SOUND_POINTER),y    ; What does entry control say? (return to caller)

	rts


; Entry control says the sound is over, and stop the sound...
EndFXAndStopSound
	jsr SaveXTimes2          ;  X = X * 2  (but save original value)

	lda #0                   
	sta AUDC1,X              ; Stop POKEY playing.
	sta AUDF1,X
	ldx SAVEX                ; Get original X * 1 value.

; Entry control says the sound is over. (but don't actually stop POKEY).
EndFX
	lda #0
	sta SOUND_DURATION,X     ; Make duration 0.
	sta SOUND_CONTROL,X      ; And inform MAIN and VBI this channel is unused.

	rts

; In order to index the reference to AUDC and AUDF we need the channel 
; number in X temporarily multiplied by 2.
SaveXTimes2
	stx SAVEX                ; Save the current X
	txa                      ; A = X
	asl                      ; A = A << 1  ; (or A = A *2)
	tax                      ; X = A  (0, 1, 2, 3 is now 0, 2, 4, 6).

	rts
