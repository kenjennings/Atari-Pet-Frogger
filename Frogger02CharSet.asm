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
; Version 02, December 2018
;
; --------------------------------------------------------------------------

; ==========================================================================
; Custom Character Set Planning for V02  . . . **Minimum setup.
;
;  1) **Frog
;  2) **Right Boat Front 
;  3) **Right Boat Back 
;  4) **Left Boat Front 
;  5) **Left Boat Back 
;  6) **Boat Seat 
;  7) **Splattered Frog
;  8)   Waves 1
;  9)   Waves 2
; 10)   Waves 3
; 11) **Beach 1
; 12)   Beach 2
; 13)   Beach 3
; --------------------------------------------------------------------------

	.align $0400 ; Start at ANTIC's 1K boundary for character sets

CHARACTER_SET
