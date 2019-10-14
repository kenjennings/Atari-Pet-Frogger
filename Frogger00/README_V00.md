# Atari PET FROGGER Version 00

 PET FROGGER game for Commodore PET 4032 ported to the Atari 8-bit computers

Video of the game play on YouTube: https://youtu.be/Aotkgw6ZSfw   

The game has no sound as the original Pet version has no sound.

Title Screen:

[![Title Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger00/V00_Title.png "Title Screen")](#features1)

Game Screen:

[![Game Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger00/V00_Game.png "Game Screen")](#features2)

You're Dead!

[![You Died!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger00/V00_YerDead.png "You're Dead!")](#features3)

---

**Porting PET FROGGER for Atari**

[Frogger00.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger00/Frogger00.asm "Frogger00.asm") Atari assembly source.

[Frogger00.xex](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger00/Frogger00.xex "Frogger00.xex") Atari executable program.

---

The assembly code for the Atari depends on my MADS include library here: https://github.com/kenjennings/Atari-Mads-Includes.  

The MADS 6502 assembler is here: http://http://mads.atari8.info

I generally build in eclipse from the WUDSN ide.  WUDSN can be found here: https://www.wudsn.com/index.php  

---

PET FROGGER for Commodore PET 4032

(c) November 1983 by John C. Dale, aka Dalesoft

Ported (parodied) to Atari 8-bit computers November 2018 by Ken Jennings (if this were 1983, aka FTR Enterprises)

As much of the PET 4032 code is used as possible.  Most changes are meant to deal with differences between the Pet and Atari.  Some changes are to enhance readability, and understand the code. 

Yes, there is no sound, because the Pet has no audio.

---

**Porting Pet Frogger**

Certain changes are necessary for porting given the differences between the Pet and Atari 8-bit computers.  Occasionally, I optimized code where it seemed something weird was going on in the source, but that was not very frequent.   Sometimes optimizations turn out to not be not such a great improvement.  Therefore, I don't usually delete the original code, but instead comment it out, so everyone can go back to see what was originally coded and how ill-conceived my changes may be.  Notable changes:

- References to fixed, numeric addresses in the code are changed to meaningful labels.  This includes page 0 variables, and score values.  The original code for the Pet included a convenient comment block identifying the list of addresses and what they do for the program. 

- Excessive chattiness... The original source is sparsely commented.  The Atari ported source is heavily commented.  Much of this is me talking to myself in my head and trying to figure out what the Pet code was doing.

- The Atari screen is a full screen editor, so cursor movement off the right edge of the screen is different from the Pet requiring an extra "DOWN" character to move the cursor to next lines.

- Kernel call $FFD2, the Commodore universal print-something-routine, has a coded replacement for the Atari, "fputc", which outputs a character to the "E:" device.

- Direct write to screen memory does not use ASCII/ATASCII codes on the Atari.  Instead, internal character codes are used. 

- Direct keyboard scanning is a different on the Atari.  The OS register for the key needs to be cleared to the no-key-pressed value ($FF) in order to recognize the next key press.   Also, the keyboard codes are different on the Atari (and they're not ASCII/ATASCII or the internal character set codes.)

---

I think I did something that broke the display of multiple frogs that successfully crossed over the rivers.  One is displayed.   But if more frogs cross, still only one is displayed.

I dialed down the game speed a bit in order to shoot the video and make sure my elderly reflexes could manage some successful runs.

---

[Back to Home](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README.md "Home") 
