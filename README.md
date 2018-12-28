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

[![V01 Composite](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/V01_Composite.png)](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V01.md)

Reorganized, rewritten, and refactored to implement modular code.  The game structure is remade into an event-like loop driven by monitoring video frame changes.  Yes, there still is no sound.

The reorganization made it easier to add new, "graphics" displays for dead frog, saved frog, and game over as well as animated transitions between the screens.  Driving off the vertical blank for timing eliminated the CPU loop used for delays.

Other than the timer control routine monitoring for vertical blank changes there is nothing very Atari-specific going on here, and this could be ported back to the Pet 4032 provided character and keyboard code values are turned back into the values for the Pet.

---

Version 02 PET FROGGER -- WORK IN PROGRESS

PROTOTYPE COLORIZATION (same game as V01, but with colors from DLI.  Actually easy to do. The screen memory handling will be more trouble.):

[![V02 Composite](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/V02_ProtoComposite.png)](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V02.md)

The plan for Version 02 is to continue to maintain the game in the same text mode (ANTIC mode 2, OS Text Mode 0), but to Atari-cize everything about the screen and game operation.  Ideas under contemplation....

- Add at least simple sound effects.

- Change to joystick control.   Buh-bye keyboard.

- Formalize timer updates, and other important frame-oriented decisions and updates into a deferred Vertical Blank Interrrupt.

- Custom character set to make the Frog look like a frog, and the boats look like boats, possible other graphics.

- Use Display List LMS updates to move the boats rather than reloading screen memory.  (Debating whether to go full bore and fine scroll the boats too.)

- Add color.  Use a DLI for each text line to set a different base color for every line.  The colors would be syncronized to the screen content.

---

More to come.
