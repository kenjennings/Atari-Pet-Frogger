# Atari PET FROGGER Version 03

PET FROGGER game for Commodore PET 4032 ported to the Atari 8-bit computers

Video of the game play on YouTube: https://youtu.be/UtNz5EE3xno 

**PET FROGGER for Commodore PET 4032**

(c) November 1983 by John C. Dale, aka Dalesoft

[Version 00](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V00.md "Version 00") Ported (or parodied) to Atari 8-bit computers November 2018 by Ken Jennings (if this were 1983, aka FTR Enterprises)

[Version 01](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V01.md "Version 01") Updated for Atari 8-bit computers December 2018 by Ken Jennings 

[Version 02](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V02.md "Version 02") Further enhanced for Atari 8-bit computers February 2019 by Ken Jennings 

Version 03, August 2019 continues to maintain the same game play in the same format as prior versions.  However, graphics have been greatly improved while still striving to retain similar screen geometry with the original game. The Frog is now upgraded to a Player/Missile overlay object.  

---

**What kind of game is Pet Frogger?**

The original author describes it as Frogger-like.  Frogger was a new game in arcades when he wrote the Pet Frogger game.  The arcade Frogger provides a myriad of enemies and environmental hazards.  Consequently, objects in arcade Frogger are much slower moving and the Frog can be controlled in all four directions.

Comparing the two, Pet Frogger is far more simple than Frogger: The Frog moves only forward, left and right.  There is never a place to move the frog in the down direction. The lethal hazards are the rivers, fore and aft boat positions, and sitting in a boat when the Frog's position would move off screen.  The beaches between rivers are indefinitely safe, and the seats in the boats are safe (again, unless the frog leaves the screen while on a boat.)  The difficulty lies in the progressive speed increases of the boats to the point where it becomes a twitch game faster than typical human reflexes.  

This has some similarity to another game, Freeway, from Activision.  Freeway is the original Crossy-Road where the goal is to get chickens to the other side of the road in a limited amount of time while avoiding horizontally moving traffic.  This game is visually more similar to Pet Frogger than the arcade Frogger game.  In Freeway there is nothing strictly lethal.  Traffic can move fast, but hitting an object merely slows the chickens' progress by momentarily knocking the chicken backwards after which it can continue.  

Pet Frogger/Freeway can be compared to the earliest arcade games (the electro-mechanical types, and some early video games).  Many of these games' objective is to accomplish a simple physical skill as many times as possible within a fixed amount of time.  All Pet Frogger demands is jumping forward to a safe landing place.  Though, Pet Frogger has no time pressure which reduces the stress level of executing the frog's boat-boarding skill at high speed. 

---

Title Screen:

[![Title Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_Title.png "Title Screen")](#features1)

Press OPTION to choose Level:

[![Level Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_LevelUp_700.png "Game Screen")](#features2)

Press SELECT to choose Lives:

[![Lives Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_SetLives_700.png "Game Screen")](#features2)

Game Screen:

[![Game Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_Game_700.png "Game Screen")](#features2)

You're Dead!

[![You Died!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_DeadFrog_700.png "Dead Frog!")](#features3)

Saved a Frog!

[![Frog Saved!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_SavedFrog_700.png "Saved a Frog!")](#features4)

Game Over:

[![Game Over](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_GameOver_700.png "Game Over")](#features5)

---

**Porting/Enhancing PET FROGGER for Atari**

[Frogger03.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03.asm "Frogger03.asm") Main assembly source and Page Zero variables.

[Frogger03Game.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03Game.asm "Frogger03Game.asm") Game start, and main event loop.

[Frogger03GameSupport.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03GameSupport.asm "Frogger03GameSupport.asm") Common routines, score management.

[Frogger03EventSetups.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03EventSetups.asm "Frogger03EventSetups.asm") Setup entry requirements for each event. 

[Frogger03Events.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03Events.asm "Frogger03Events.asm") A routine for each screen/event. 

[Frogger03TimerAndIO.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03TimerAndIO.asm "Frogger03TimerAndIO.asm") Managing timers, Joystick controller input, vertical blank interrupts, display list interrupt

[Frogger03ScreenGfx.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03ScreenGfx.asm "Frogger03ScreenGfx.asm") Routines for managing the various displays used by the game. 

[Frogger03ScreenMemory.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03ScreenMemory.asm "Frogger03ScreenMemory.asm") Data used for on screen graphics.

[Frogger03CharSet.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03CharSet.asm "Frogger03CharSet.asm") Redefined custom character set.

[Frogger03DisplayLists.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03DisplayLists.asm "Frogger03DisplayLists.asm") ANTIC Display Lists for the custom screens.

[Frogger03Audio.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03Audio.asm "Frogger03Audio.asm") Sound effects and music.

[Frogger03.xex](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03/Frogger03.xex "Frogger03.xex") Atari executable program.

---

The assembly code for the Atari depends on my MADS include library here: https://github.com/kenjennings/Atari-Mads-Includes.  

The MADS 6502 assembler is here: http://http://mads.atari8.info

I generally build in eclipse from the WUDSN ide.  WUDSN can be found here: https://www.wudsn.com/index.php 

---

**Version 03, August 2019 notable changes**


**Summary: Major Display Rework**

The focus here is to maintain the same play mechanics as close as possible to the original Pet Frogger game, but with as much visual enhancement as possible.  This requires some very careful choices.  Making the player's frog, and the screen graphics more detailed and appealing requires making objects bigger in some ways.  The problem with bigger is that small changes multiply into large impacts when they occur on 18 horizontal rows on the screen.  Fortunately, the original game had three text lines on screen that were unused.  This provides most of the needed free space for enhancing the lines, but a few more were still needed.  Therefore the display is slightly taller than the usual 200 scan line/25 text line screen.

There is one notable behavior change -- A frog on a boat does not die immediately on touching the left or right side of the display.  The frog's motion is limited to the visible display, but the boat will continue to move off the screen.  Only when the frog loses contact with the safe zone on the boat will the frog's death occur.  This provides the player a few moments of grace to get off the boat to a possible safe area. 


**Player/Missile Graphics**

The frog in V02 is a single text character which occupies space four color clocks wide, and eight scan lines tall.  The new frog for V03 is Player/Missile graphics.  Not just a Player - three overlapping players for multi-color.  The frog is nine color clocks wide, and 11 scan lines tall.  Since normal text lines are 8 scan lines tall, there are blank lines added between the lines on the playfield to spread out the text lines and make them taller to accommodate the frog.  However, the Frog is still taller than a text line and overlaps the top and bottom scan lines lines of the text lines above and below.  The Frog positioning is exactly specific.  At any place on the playfield a one scan line difference in placement results in improper collision detection for the Player due to the overlap.

The Frog is slightly animated.  The pupils in the eyes move to face the direction the frog moves.  After the player stops providing input a timer returns the eyes to the center position.  Though minimal, the eyeball and its automated movement is mildly humorous and provides a greater sense of interaction with the player.  When the frog dies there is an alternate image for the frog showing the frog splattered.  The splattered frog is made of two Players for the multi-color (red-ish), liquid, splash pattern.

Player/Missile graphics simplify moving the frog and the method of determining the frog's life and death.  Horizontal movement is the same for every line, only limited by left and right borders.  Beach lines are free and no checking for death occurs.  Life and death on the boats is determined simply checking whether or not the frog is touching the horizontal lines drawn on the boats.  This is done by collision checking between the frog and the playfield color for the lines.  This is marvelously trivial on the Atari, because collision detection bits are provided to identify specific playfield colors overlapping Players/Missiles.

Since the supporting code makes placing the frog Player on screen trivial, the frog image is re-used on the Title display and flown around the screen in pseudo-random patterns.  The flight path is provided using a table of sine wave values.  The sine wave data is read at different rates (different count of frames between updates) for X position and Y position resulting is a warped, curvy flight path for the flying frog.

And since the Frog flight path animation was already easily established, this is re-used to animate the flying tombstone on the Game Over display.  The tombstone is a fairly large object made of several Players and Missiles, 15 color clocks across, and 23 scan lines tall.  It displays "RIP" text and a shadowed side for perspective.

On the surface it seems like these animated objects above are the only use of Player/Missile graphics.  However, Player/Missile graphics also appear in some non-obvious ways.  Player/Missile graphics create the Game display's black borders on the left and right sides.  Due to the character/color gymnastics done for the game's playfield, the color used for the background is not always consistent with the rest of the horizontal line. The left and right borders made from Players hide the background color transitions making a cleaner visual presentation.

On the Title and Game displays Player/Missile graphics provide the four text labels for scores (SCORE and HI), frogs remaining (FROGS), and frogs saved (SAVED).  As these use different color registers from the playfield, they can be colored and flashed separately from other objects on the same line.  The Player/Missile pixels are the same size as pixels in ANTIC Text Mode 4 (one color clock wide and one scan line tall), thus the "text" appears to be Text Mode 4.


**Custom Character Set**

The V03 game, like V02, uses the one custom character set for all displays.  Unlike V02, the V03 character set provides characters for display in ANTIC Text modes 2 (2 color) and 4 (5 color).

The A-Z/a-z/0-9, and basic punctuation remain for the text directions on the Title display, the scrolling credits on all displays, and the scores on the Title and Game displays.  All these lines display using ANTIC Text mode 2.

The V02 game is based on ANTIC Text mode 2 for all lines of the display.  Version V03 switches the Text Mode lines that simulate giant, pixel graphics with Map Mode 9 graphics lines that provide the same sized pixels with more color control using less memory.

The characters in V02 providing colored Score and Lives labels do so via NTSC artifacts.  However, the artifacts don't work right on PAL and many modern digital/LED monitors.  These characters are now displayed in V03 using Player/Missile graphics discussed earlier.

The V02 Frog and Splattered Frog characters are not used, since V03 replaces these with Player/Missile graphics objects.

The Game screen is where most of the new activity occurs.  The game playfield is primarily 5-color, Antic Text Mode 4 lines.  The character set provides several multi-color characters for drawing the safe beach/land, and the water/waves, and boats moving left and right.  Part of the movement is simply the result of scrolling the lines -- the waves "move" by fine scrolling with the boats.  Additional animation is performed by changing character images depicting moving water at the bow and behind the engines of the boats. This animation does not occur by changing the characters of the boats, but by re-writing the bitmap in the character set for each character, so changing the image of one character in the redefined character set then changes it for all 24 occurrences of the character visible on the display.


**Playfield Graphics Handling.**

The V02 game has a one-size-fits all display list for all screens where everything uses the 8 scan-line ANTIC Text Mode 2.  V03 uses more customized display lists for the Title screen, the Game screen, and then one Display List shared by the three splash screens for Saved Frog, Dead Frog, and Game Over. 

All screens are presented with the custom Display Lists and screen memory assembled directly where they will be used.  Therefore, there is very little screen redrawing or display setup.  Switching between display screens is nearly instantaneous, which is accomplished by merely updating the system's Display List pointer.  In fact, screen switching is so fast that transitions are necessary (splash screens and transition animations) to allow the user time to recover from pressing the trigger so that the same button press is not accepted as input on the following screen.

The Title and Game displays are specific custom Display Lists.  The giant Title text is Map Mode 9 pixels allowing complete palette control over the background and the pixels.  The animation in the "PET FROGGER" title is done by a simple exclusive OR of a random value masked with the static image of the title.  This piece of screen memory is one of the limited areas that experience redrawing and updates.

The Title graphics lines are also used to provide visible feedback to the user when pressing *OPTION* or *SELECT* to change the number of Frog lives and the starting difficulty of the game.  The new value is displayed as giant text scrolling onto the screen.  After a few seconds without function key input the text scrolls down off the screen and the animation plays to return the PET FROGGER title to the screen.

The three splash screens (Saved Frog, Dead Frog, Game Over) share a common Display list.  The giant text here is also made of Map Mode 9 graphics lines like on the Title screen.  The graphics here are not changed by redrawing that part of the display, but by simply updating the LMS instruction to point to the screen memory holding the desired image.  Most of the "animation" on the splash screens is just table-driven color changes by Display List Interrupts.  In V02 the "empty" lines are ANTIC Text mode 2, but V03 uses regular blank line instructions the same height as Map Mode 9 which is half the height of the Text Mode 2 lines providing the V03 splash screens twice as many color changes for animation.

On the Game screen the Boats move by fine scrolling and coarse scrolling via LMS updates in the Display List -- no redrawing of the boats occurs at all.  The Atari's hardware-assisted scrolling is such low overhead that all the scrolling work is done during the vertical blank. (In fact, I was so lazy in an earlier iteration that the Boats' fine scrolling ran during every vertical blank even when the Game screen was not displayed.)  

The Game display needs extra time for Display Lists Interrupts in places and there is a need for cosmetic matching between adjacent lines while supplying that space, so there are some blank lines and Map Mode C lines inserted strategically in the Game Display List.

Since the frog is now Player/Missile graphics and there is no frog moving through screen memory, there no longer needs to be separate screen memory for every row of boats.  There is just one line of screen memory for boats moving left and one line of screen memory for boats moving right.  This reduces memory by 800 bytes (10 lines * 80), close to 10% of the final size of Version 02.  All the lines in the given direction refer to the same screen memory, but have different colors and scroll values, so that they all appear to be different screen objects.

All the Display Lists jump to one of two places in another common Display List to end the display.  The Game display jumps to the point showing the final fine scrolling credits at the bottom of the screen.  All other displays jump to a prior point showing the text line prompting the user for input which is followed by the fine scrolling credits line.  Having one set of Display List instructions simplifies the code needed to support the prompt line and the fine scrolling credits.


**Display List Interrupts**

V02 uses essentially the same DLI to change background color and text luminance for each ANTIC Text Mode 2 line on the screen.  V03 uses a substantial amount of custom Display List Interrupts doing much more work.

Display List Interrupts are largely table-driven.  Though there are several kinds of custom behaviors the DLIs still tend to read data from tables based on the occurrence of the DLI on that display.  The DLIs end by pre-loading page 0 locations with the values needed for the next Display List Interrupt.  This helps improve the timing of the following DLI. (3 cycles for LDA PageZero v 4 cycles for LDA TABLE,y is sometimes enough to make a difference).

On the Title screen the title text is successive lines of Map Mode 9 graphics which is only a 2 color mode.  Each line is colored by a DLI providing new colors for the background and the pixels resulting in a dozen colors for the title.  The DLIs for the Instruction areas provide different blocks of color for the background, and varies the text brightness in gradient patterns.  The background colors for pixel and text areas extend straight through the horizontal overscan area.

Where Player/Missiles are used multiple times on a screen their horizontal positions have to be set and then changed again later to position them where re-used on the display.  The Title and Game displays re-use Players/Missiles multiple times.  The text for the Score labels is the first occurrence, the text for the Frogs and Saved labels is the second, and then the animated Frog image is the third which is used as decoration on the Title display, and as the player's avatar on the Game display.  The register updates for Player/Missile colors and positions are mixed with setting the colors for playfield graphics at those points of the display.  

Additionally, an animated Player/Missile image also appears on the Game Over display, so this display must position Players/Missiles for the moving element, but not present the text labels at the top of the screen.  It would make sense and be easier to clear the Player/Missile bitmap for the objects that should not be displayed.  However, the idiot doing the programming did this the hard way.  One of the DLIs is responsible for purposely removing the unwanted Player/Missiles elements from the display by setting 0 horizontal positions for the objects. 

The Game screen requires a few custom routines to properly change colors for each line of boats and beaches.  Horizontal scrolling changes the DMA timing on the line which affects the time available for the DLI.  In some early iterations the visible changes by DLIs would move up and down to different lines.  The fix required adding blank lines and Mode C lines that accomplished several purposes:
- Proper timing to start the DLIs.
- Additional time for setting all the color registers.
- Extra lines needed to support the height of the Frog image. 


**Vertical Blank Interrupts**

Most of everything that happens on screen is counted, timed, and set by the Vertical Blank interrupt.  The Atari's indirection abilities allow several things to be managed in the game just by writing a couple bytes to hardware registers.  This relieves significant overhead for animating the display.  It reduces overhead so much that the majority of the game and display updates are executed during the vertical blank.  The mainline code determines what kind of displays changes should occur, posts those updates for the Vertical Blank, and then spends most of its time in a do-nothing loop waiting for the next frame to start.  The Vertical Blank typically has more code work to do than the main line code.

The credits line is continuously fine-scrolled no matter what is happening on the rest of the screen.  Looks most slick.  Someone may mistake me for a professional.

Boat scrolling and Player/Missile positioning/redraws occur during the vertical blank. 

The sound effects system, the lamest sequencer ever conceived, also runs during the Vertical Blank.


**Other lame sound effects.**

A few more things in V03 have audio effects attached to them.  A puttering sound is added to simulate boat motors.

The speed for Ode To Joy is doubled.  It was taking so long to play at normal speed that it started to seem like the funeral dirge.

The actual funeral dirge for the dead frog is abbreviated to relieve the long-playing tedium.  Most people don't recognize the song's initial bars and found them odd sounding, so I eliminated them.


**Joystick control.** 

Joystick control is the same as V02, but the poorly-conceived, idiotic, repetitive, bit-bashing code to eliminate invalid input combinations has been replaced with a lookup table which converts raw joystick input directly into the cooked, final values in as few steps as possible.  Derp.  (Forehead Slap.)

---

**To Be Continued... V04 ?**

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

---

[Back to Home](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README.md "Home") 
