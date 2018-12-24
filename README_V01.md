# Atari PET FROGGER Version 01

 PET FROGGER game for Commodore PET 4032 ported to the Atari 8-bit computers

Video of the game play on YouTube: https://youtu.be/z5lkdjZt3bE    Yes, still no sound in the game.
  
Title Screen:

[![Title Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/V01_Title.png "Title Screen")](#features1)

Game Screen:

[![Game Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/V01_Game.png "Game Screen")](#features2)

You're Dead!

[![You Died!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/V01_Dead.png "Dead Frog!")](#features3)

Saved a Frog!

[![Frog Saved!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/V01_Saved.png "Saved a Frog!")](#features4)

Game Over:

[![Game Over](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/V01_Over.png "Game Over")](#features5)

---

**Porting/Enhancing PET FROGGER for Atari**

[Frogger01.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger01.asm "Frogger01.asm") Main assembly source.

[Frogger01Game.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger01Game.asm "Frogger01Game.asm") Game start, and main event loop.

[Frogger01GameSupport.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger01GameSupport.asm "Frogger01GameSupport.asm") Common routines, score management.

[Frogger01EventSetups.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger01EventSetups.asm "Frogger01EventSetups.asm") Setup entry requirements for each event. 

[Frogger01Events.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger01Events.asm "Frogger01Events.asm") A routine for each screen/event. 

[Frogger01ScreenGfx.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger01ScreenGfx.asm "Frogger01ScreenGfx.asm") Routines for managing the various displays used by the game. 

[Frogger01TimerAndIO.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger01TimerAndIO.asm "Frogger01TimerAndIO.asm") Managing Timers, flip-flop/tick-tock, count downs, keyboard I/O.

[Frogger01.xex](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger01.asm "Frogger01.xex") Atari executable program.

The assembly code for the Atari depends on my MADS include library here: https://github.com/kenjennings/Atari-Mads-Includes.  

---

PET FROGGER for Commodore PET 4032

(c) November 1983 by John C. Dale, aka Dalesoft

[Version 00](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V00.md "Version 00") Ported (parodied) to Atari 8-bit computers November 2018 by Ken Jennings (if this were 1983, aka FTR Enterprises)

Version 01, December 2018 notable changes:

- All text printing to the screen is removed.  Displayed items are written directly into screen memory.  This greatly speeds up creating the game display.

- Reorganized and modularized the code for easier maintenance and enhancements.
 
- The game structure is remade into an event-like loop driven by monitoring video frame changes.

- The original game used a CPU loop for delays to scale the game speed down to realistic levels.  Driving the game events from the vertical blank timing eliminated the CPU loop, and makes everything move more smoothly and consistently. 

- The reorganization made it easy to add new, "graphics" displays for dead frog, saved frog, and game over as well as animated transitions between the screens.  

- Boat movement is now handled for each row from the top to the bottom of the screen.  This should prevent updates occurring while the data is being displayed and eliminate visible tearing.

- Other than the timer control routine monitoring for vertical blank changes there is nothing very Atari-specific going on.  Therefore, this code could be ported back to the Pet 4032 provided character and keyboard code values are turned back into the values for the Pet.

- Have I mentioned there still is no sound?

---

[Back to Home](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README.md "Home") 
