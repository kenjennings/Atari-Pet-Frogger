# Atari-Pet-Frogger

OldSkoolCoder presented a video on YouTube and source code on GitHub for a Frogger-like game written for the PET 4032 in 1983.

The PET assembly source is here:  https://github.com/OldSkoolCoder/PET-Frogger

The OldSkoolCoder YouTube channel is here:  https://www.youtube.com/channel/UCtWfJHX6gZSOizZDbwmOrdg/videos

OldSkoolCoder's PET FROGGER video is here:  https://www.youtube.com/watch?v=xPiCUcdOry4

This repository is for the Pet Frogger game ported to the Atari 8-bit computers.  The initial version is a direct port with as few changes possible to make the game function on the Atari the same as the Pet.  The focus of successive revisions is to maintain the play mechanics as close as possible to the original game while introducing optimizations and graphics enhancements to the game.

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

Reorganized, rewritten, and refactored to modularize the code.  This is done to facilitate enhancements for future versions.  The game structure is remade into an event-like loop driven by monitoring video frame changes.  Yes, there still is no sound.

The reorganization made it easier to add new, "graphics" displays for dead frog, saved frog, and game over as well as animated transitions between the screens.  Driving off the vertical blank for timing eliminated the CPU loop used for delays.

Although the code is substantially modified from the original, the only thing going on that is Atari-specific is the timer control routine monitoring for vertical blank changes.  (I could not identify a way to do this on the Pet.)  Aside from this feature the entire code could be ported back to the Pet 4032.  (Character and keyboard code values would also need to be turned back into the Pet's values.)

---

[Version 02 PET FROGGER](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/README_V02.md "Version 02 Atari PET FROGGER") 

[![V02 Composite](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger02/V02_Composite.png)](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/README_V02.md)

Version 02 continues to maintain the same game play in the same format as prior version.  The screen display is still the plain text mode (ANTIC mode 2, OS Text Mode 0) and frog movement is the size of a character.  

More of the game's internal operations and display parts have been Atari-fied.  Short version: There is now sound and music (minimally), the game uses joystick input instead of the keyboard, animated color is applied to the custom screens, and a redefined character set provides a frog and boats that look more like a frog and boats.

---

[Version 03 PET FROGGER](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/README_V03.md "Version 03 Atari PET FROGGER") 

[![V03 Composite](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_Composite_700.png)](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/README_V03.md)

**Currently Work In Progress**

!!! Note, the current executable is a setup for playtesters and does not implement the difficulty arrangement expected in the final version. !!!
 
Version 03 maintains the same game play and overall screen layout as the prior version.  The same number of lines of boats appear on the display.  Within this limit the graphics are significantly enhanced.  

The game graphics are changed to multi-color text (ANTIC mode 4, 5 colors), the boats are built of redefined characters with animated water parts.  Also, the boats now fine-scroll for movement.

Player/Missile graphics are used now for the Frog, and for various other display enhancements on the screens. 

OPTION and SELECT can be used on the Title screen to change the difficulty level, and the number of Frog lives.

---

**More to come in V4? Or Not?**

**??????????????????**

The version V03 Playtesters suggest objects other than boats on the scrolling lines.   Also, boats that sink could be an interesting obstacle.

These kinds of changes would vastly affect how the boat lines are represented in memory which then cascades into a number of other major code reorganizations.   We'll see. 

**??????????????????**


---
