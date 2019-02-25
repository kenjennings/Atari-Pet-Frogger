# Atari PET FROGGER Version 02

PET FROGGER game for Commodore PET 4032 ported to the Atari 8-bit computers

Video of the game play on YouTube: https://youtu.be/9MDZP2bl5KY
  
Title Screen:

[![Title Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger02/V02_Title.png "Title Screen")](#features1)

Game Screen:

[![Game Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger02/V02_Game.png "Game Screen")](#features2)

Dying Frog!

[![Dying Frog!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger02/V02_Dying.png "Dying Frog!")](#features3)

You're Dead!

[![You Died!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger02/V02_Dead.png "Dead Frog!")](#features3)

Saved a Frog!

[![Frog Saved!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger02/V02_Saved.png "Saved a Frog!")](#features4)

Game Over:

[![Game Over](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger02/V02_GameOver.png "Game Over")](#features5)

---

**Porting/Enhancing PET FROGGER for Atari**

[Frogger02.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02.asm "Frogger02.asm") Main assembly source and Page Zero variables.

[Frogger02Game.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02Game.asm "Frogger02Game.asm") Game start, and main event loop.

[Frogger02GameSupport.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02GameSupport.asm "Frogger02GameSupport.asm") Common routines, score management.

[Frogger02EventSetups.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02EventSetups.asm "Frogger02EventSetups.asm") Setup entry requirements for each event. 

[Frogger02Events.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02Events.asm "Frogger02Events.asm") A routine for each screen/event. 

[Frogger02ScreenGfx.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02ScreenGfx.asm "Frogger02ScreenGfx.asm") Routines for managing the various displays used by the game. 

[Frogger02ScreenMemory.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02ScreenMemory.asm "Frogger02ScreenMemory.asm") Data used for on screen graphics.

[Frogger02CharSet.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02CharSet.asm "Frogger02CharSet.asm") Redefined custom character set.

[Frogger02DisplayLists.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02DisplayLists.asm "Frogger02DisplayLists.asm") ANTIC Display Lists for the custom screens.

[Frogger02Audio.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02Audio.asm "Frogger02Audio.asm") Sound effects and music.

[Frogger02TimerAndIO.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02TimerAndIO.asm "Frogger02TimerAndIO.asm") Managing timers, Joystick controller input, vertical blank interrupts, display list interrupt

[Frogger02.xex](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger02/Frogger02.asm "Frogger02.xex") Atari executable program.

---

The assembly code for the Atari depends on my MADS include library here: https://github.com/kenjennings/Atari-Mads-Includes.  

The MADS 6502 assembler is here: http://http://mads.atari8.info

I generally build in eclipse from the WUDSN ide.  WUDSN can be found here: https://www.wudsn.com/index.php  

---

**PET FROGGER for Commodore PET 4032**

(c) November 1983 by John C. Dale, aka Dalesoft

[Version 00](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger00/README_V00.md "Version 00") Ported (or parodied) to Atari 8-bit computers November 2018 by Ken Jennings (if this were 1983, aka FTR Enterprises)

[Version 01](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger01/README_V01.md "Version 01") Updated for Atari 8-bit computers December 2018 by Ken Jennings 

Version 02, February 2019 continues to maintain the same game play in the same format as prior versions.  The screen display is still based on the plain text mode (ANTIC mode 2, OS Text Mode 0).  The Frog is a character and moves in steps the size of a character.  Everything else about the game internals and operation has been Atari-fied.

---

**Version 02, February 2019 notable changes:**

**Lame sound effects added.**

Sound sequences and volume envelopes are shaped by vertical blank interrupt, so longer running sounds (i.e. music) appears multi-tasking in parallel with everything else going on. Sound effects are timed to the animation that occurs on the Title screen.  When the Frog moves in any direction there is a bump sound.  The game plays randomly changing water sloshing effects. Upon a frog's inevitable demise Chopin's Funeral March plays. Should the player manage to guide a frog to the safety of the opposite shore then Beethoven's Ode To joy plays.

**Input is changed to joystick control.** 

Buh-bye keyboard. The joystick values are cooked to make the code's analysis easier later on.  It reverses the bit values making 1 instead of 0 indicate the direction is pressed.  Diagonal movement is blocked and substituted with forward direction.  Down movement is discarded.  Since the joystick needs only 4 bits for directions, it unifies the controller input by adding the trigger bit to the joystick bits (the fifth bit).

**Custom character set to make things look like things.**

The custom character set provides a frog-like Frog. Another character is the splattered Frog.   There are specific characters for the boat parts: fore, aft, and the seats, in left and right versions.  The water contains waves that are built in two parts, left and right.   The beaches are mostly blank spaces, but now there are several kinds of random rocks distributed which are also safe places to jump.

The text characters A-Z, a-z and 0-9 are all redefined in a square style.  Most lowercase letters look like shorter versions of uppercase.  There are specific text labels for Lives, Score, Hi score, and Saved frogs which are in the same style as the alpha characters, but they rely on the ANTIC Mode 2 text's high-resolution pixel color artifacts to make them appear green instead of white. 

**Atari-fied Playfield Graphics handling.**

All screens are presented as custom Display Lists with the Display Lists and screen memory assembled directly where they will be used.  Therefore, there is no screen redrawing.  Switching between display screens is nearly instantaneous, which is accomplished by merely updating the system's Display List pointer.  In fact, screen switching is so fast that transitions are added to allow the user time to recover from pressing the trigger so that the same button press is not accepted as input on the following screen.

Boats move by coarse-scrolling done via LMS updates in the Display List -- No redrawing of the boats occurs at all.  The Title screen animation is also done with LMS updates instead of redrawing.  The Title screen also now includes the last game score and the high score.  The LMS magic vastly reduces any manipulation at all in screen memeory.  The only thing left is moving the frog through the playfield screen memory, displaying the Scores, Lives, and Saved frogs statistics.

All screens actually share the same Display List instructions for the bottom of the screen which provides the prompt to Press a Button, and the continuously scrolling credits line.  Therefore, there is only one set of code to manage these things for all the displays.

**Display List Interrupts for color**

A Display list Interrupt is used on every line of the scfeen to provide each line with its own base color and text luminance.  The top 23 lines belong to the game, and the bottom two lines belong to the Vertical Blank Interupt  for the Prompt to Press A Button, and the continuously scrolling credits text.  The Dead Frog, Game Over, and Saved Frog screens include full screen animations which are simply updates to the Display List Interupt color tables.

**Vertical Blank Interrupt**

An Immediate VBI controls switching between different Display Lists.  The main code updates a value indicating which screen to switch to, then the VBI applies the associated update to the Operating System's Display List pointer (SDLST), and the screen is switched at the top of the frame.  Virtually instant.   In fact, the change is so fast that originally there were control problems between the Dead Frog screen and the Game Over screen.  The Game Over screen is able to accept input immediately, so the user did not have time to release the button press to leave the Dead Frog screen.  This would be inadvertently read by the input to leave the Game Over screen.  I should have put in some code to debounce the button, but instead added a bit of a pause, and fade and animation of the colors to give the user time to react.

There is also a Deferred Vertical Blank Interrupt handling several tasks. It updates timers controlling the game speed.  It manages the display and animation of the Press A Button Prompt.  A couple bytes negotiated between the main code and the VBI exchange information about the state of the prompt and whether or not it should be visible.   

The Deferred VBI also manages the continuously scrolling credits at the bottom of the screen.  This is only an update of an LMS instruction in the Display List.  And since all the text fits inside one page, the update is only incrementing the low byte of the LMS address, and resetting it as needed.  The text scrolls no matter what else is occuring in the game, so it pushes the illusion that the game is multitasking more than it really is.

Finally, the Deferred VBI manages the sound system -- a very, idiotically-simple, sound sequence player.  Given a pointer to a sound event for each POKEY voice, the sequencer executes the directions of the event which could be to play a sound as a specific volume, or wait a number of frames using the current setting, or to stop playing sound.  This provides Attack/Decay/Sustain/Release control for sounds, changing the sound distortions on each frame, and playing (simple) music.  Since this is done by the VBI, it appears the sound is multi-tasking, and other screen transitions can occur while sound is playing (for instance, the Funeral March and Ode To Joy may still be playing while screen animations continue to transition back to the main game screen.

---

[Back to Home](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README.md "Home")


