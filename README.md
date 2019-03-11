# Atari-Pet-Frogger

OldSkoolCoder presented a video on YouTube and source code on GitHub for a Frogger-like game written for the PET 4032 in 1983.

The PET assembly source is here:  https://github.com/OldSkoolCoder/PET-Frogger

The OldSkoolCoder YouTube channel is here:  https://www.youtube.com/channel/UCtWfJHX6gZSOizZDbwmOrdg/videos

OldSkoolCoder's PET FROGGER video is here:  https://www.youtube.com/watch?v=xPiCUcdOry4

This repository is for the Pet Frogger game ported to the Atari 8-bit computers.  Further revisions may implement Atari-esque styled enhancements to the game as I have time and interest.

---

The assembly code for the Atari depends on my MADS include library here: https://github.com/kenjennings/Atari-Mads-Includes.  

The MADS 6502 assembler is here: http://http://mads.atari8.info

I generally build in eclipse from the WUDSN ide.  WUDSN can be found here: https://www.wudsn.com/index.php

---

[Version 00 PET FROGGER](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger00/README_V00.md "Version 00 Atari PET FROGGER") 

[![V00 Composite](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger00/V00_Composite.png)](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger00/README_V00.md)

As much of the original PET 4032 assembly code is used as possible.  In most places only the barest minimum of changes are made to deal with the differences on the Atari.  Yes, there is no sound.

---

[Version 01 PET FROGGER](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger01/README_V01.md "Version 01 Atari PET FROGGER") 

[![V01 Composite](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger01/V01_Composite.png)](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger01/README_V01.md)

Reorganized, rewritten, and refactored to implement modular code.  The game structure is remade into an event-like loop driven by monitoring video frame changes.

The reorganization made it easier to add new, "graphics" displays for dead frog, saved frog, and game over as well as animated transitions between the screens.  Driving off the vertical blank for timing eliminated the CPU loop used for delays.

Other than the timer control routine monitoring for vertical blank changes there is nothing very Atari-specific going on here, and this could be ported back to the Pet 4032 provided character and keyboard code values are turned back into the values for the Pet.

Yes, there still is no sound.

---

[Version 02 PET FROGGER](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/README_V02.md "Version 02 Atari PET FROGGER") 

[![V02 Composite](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger02/V02_Composite.png)](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/README_V02.md)

Version 02 continues to maintain the same game play in the same format as prior version.  The screen display is still the plain text mode (ANTIC mode 2, OS Text Mode 0) and frog movement is the size of a character.  Everything else about the game working and operation has been Atari-fied.

Short version: The game now uses joystick input instead of the keyboard, animated color is applied to the custom screens, and a redefined character set provides a frog and boats that look more like a frog and boats.  

By the way, there is now sound and "music" (minimally).

---

**Version 03 PET FROGGER -- WORK^H^H^H^H CONTEMPLATION IN PROGRESS**

[Version 03 PET FROGGER](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/README_V03.md "Version 03 Atari PET FROGGER") 

**More to come? Or Not?**

**??????????????????**

---
