# Atari-Pet-Frogger

OldSkoolCoder presented a video on YouTube and source code on GitHub for a Frogger-like game written for the PET 4032 in 1983.

The PET 4032 assembly source is here:  https://github.com/OldSkoolCoder/PET-Frogger

The OldSkoolCoder YouTube channel is here:  https://www.youtube.com/channel/UCtWfJHX6gZSOizZDbwmOrdg/videos

OldSkoolCoder's PET FROGGER video is here:  https://www.youtube.com/watch?v=xPiCUcdOry4

This repository is for the Pet Frogger game ported to the Atari 8-bit computers.  The initial version is a direct port with as few changes possible to make the game function on the Atari the same as the Pet.  The focus of successive revisions is to maintain the play mechanics as close as possible to the original game while introducing optimizations and graphics enhancements to the game.

---

The assembly code for the Atari depends on my MADS include library here: https://github.com/kenjennings/Atari-Mads-Includes.  

The MADS 6502 assembler is here: http://http://mads.atari8.info

I generally build in eclipse from the WUDSN ide.  WUDSN can be found here: https://www.wudsn.com/index.php

---

[DISCUSSION OF PORTING GAMES FROM OTHER COMPUTERS TO ATARI](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_Porting.md "Discussing How To Port Games From Other Computers To Atari") 

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

Version 02 continues to maintain the same game play in the same screen geometry as prior version.  The screen display is still the plain text mode (ANTIC mode 2, OS Text Mode 0) and frog movement is the size of a character.  The visual perspective of the boats has been changed from the top view of boats in V00 and V01 now to a side view.

More of the game's internal operations and display parts have been Atari-fied.  Short version: There is now sound and music (minimally), the game uses joystick input instead of the keyboard, animated color is applied to the custom screens, and a redefined character set provides a frog and boats that look more like a frog and boats.

---

[Version 03 PET FROGGER](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/README_V03.md "Version 03 Atari PET FROGGER") 

[![V03 Composite](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_Composite_700.png)](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/README_V03.md)
 
Version 03 maintains the same game play and overall screen geometry as the prior version.  The same number of lines of boats appear on the display.  Within this limit the graphics are significantly enhanced.  

The game graphics are updated to multi-color text (ANTIC mode 4, 5 colors) and the boats are built of redefined characters with animated water parts.  Also, the boats fine-scroll for movement.

Player/Missile graphics make the Frog and various other display enhancements on the screens.

OPTION and SELECT can be used on the Title screen to change the difficulty level (1 to 7) , and the number of starting Frog lives. (1 to 5)

---

**More to come in V04?**

V03 intentionally limits the game play to stay as close as possible to the parameters of the original Pet 4032 version while amping up the graphics.  The limited game play mechanics makes the game, well, limited.  Though pretty to look at, the game is borderline boring.
 
The V03 playtesters suggested a variety of changes to the game's graphics and the game behaviors which would add variety and change the strategy. 

Possible Enhancements for V04:
- Display
  - Sinking boats, missing boats.
  - Other non-boat obstacles/hazards. (Log jams, alligators)
  - Other object/hazard independent of horizontal moving rows (swooping birds).
  - Bigger objects, bigger frog, more animation details.
- Gameplay
  - Add a level timer to motivate the player to move faster and make mistakes. 
  - Allow backward jumps, since more hazards require more flexible player movement.
  - Reduced maximum speed, since more hazards require more opportunity for player reaction. 
  - Change death into a push back to prior row position.

The visual changes described above will require wholesale re-engineering of how screen memory works.  The reason is that V03 uses tricks to create the illusion of boats moving across the screen.  The moving boats capitalize on the hardware-assisted scrolling in the Atari.  First, since all the boats are the same and evenly spaced on each line,  there is only one line of boats going left and one line going right.  The display list points to the same lines of screen memory for every left-moving row, and then for every right-moving row.  Also, there is only enough screen memory allocated to a line of boats support scrolling from one boat position to the next before the scrolling resets to the origin position.  Since the boats are identical this makes it appear the boats move continuously across the screen.

Individual objects that display differently from others on the same line and from line to line require at least enough screen memory to describe every line on the screen individually.  The same line of data can't be shared on multiple lines.  This will be a big change to how the game screen works.

Objects must be bigger to provide more detail.  This will impact the screen geometry.  Some lines of the display must go, so others can be bigger.  For example, if the boats increase to 12 scan lines tall then one line of boats is lost for every two displayed, so the 12 lines of boats on screen would be reduced to 8.  Safe beach lines would also need to be resized, and some eliminated as a result.  16 scan lines per each line of boat or beach graphics would halve the number of lines on the screen.

---
