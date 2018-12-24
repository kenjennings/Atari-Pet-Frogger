# Atari-Pet-Frogger

OldSkoolCoder presented a video on YouTube and source code on GitHub for a Frogger-like game written for the PET 4032 in 1983.

The PET assembly source is here:  https://github.com/OldSkoolCoder/PET-Frogger

The OldSkoolCoder YouTube channel is here:  https://www.youtube.com/channel/UCtWfJHX6gZSOizZDbwmOrdg/videos

OldSkoolCoder's PET FROGGER video is here:  https://www.youtube.com/watch?v=xPiCUcdOry4

This repository is for the Pet Frogger game ported to the Atari 8-bit computers.  Further revisions may implement Atari-esque styled enhancements to the game as I have time and interest.

---

The assembly code for the Atari depends on my MADS include library here: https://github.com/kenjennings/Atari-Mads-Includes.  

---

[Version 00 PET FROGGER](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V00.md "Version 00 Atari PET FROGGER") 

[![V00 Title](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/V00_Title.png)](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V00.md)

As much of the original PET 4032 assembly code is used as possible.  In most places only the barest minimum of changes are made to deal with the differences on the Atari.  Yes, there is no sound.

---

[Version 01 PET FROGGER](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V01.md "Version 01 Atari PET FROGGER") 

[![V01 Title](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/V01_Title.png)](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V01.md)

Reorganized, rewritten, and refactored to implement modular code.  The game structure is remade into an event-like loop driven by monitoring video frame changes.  Yes, there still is no sound.

The reorganization made it easier to add new, "graphics" displays for dead frog, saved frog, and game over as well as animated transitions between the screens.  Driving off the vertical blank for timing eliminated the CPU loop used for delays.

Other than the timer control routine monitoring for vertical blank changes there is nothing very Atari-specific going on here, and this could be ported back to the Pet 4032 provided character and keyboard code values are turned back into the values for the Pet.

---

More to come.