# Atari PET FROGGER Version 03

PET FROGGER game for Commodore PET 4032 ported to the Atari 8-bit computers

Video of the game play on YouTube: A URL for YouTube goes here

**PET FROGGER for Commodore PET 4032**

(c) November 1983 by John C. Dale, aka Dalesoft

[Version 00](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V00.md "Version 00") Ported (or parodied) to Atari 8-bit computers November 2018 by Ken Jennings (if this were 1983, aka FTR Enterprises)

[Version 01](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V01.md "Version 01") Updated for Atari 8-bit computers December 2018 by Ken Jennings 

[Version 02](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V02.md "Version 02") Further enhanced for Atari 8-bit computers February 2019 by Ken Jennings 

Version 03, August 2019 continues to maintain the same game play in the same format as prior versions.  However, graphics have been greatly improved while still striving to retain similar screen geometry with the original game. The Frog is now upgraded to a Player/Missile overlay object.  

---

**What kind of game is Pet Frogger?**

The original author describes it as Frogger-like.  (Frogger was a new game in arcades when he wrote the Pet Frogger game.)  The arcade Frogger provides a myriad of enemies and environmental hazards.  Consequently, objects in arcade Frogger are much slower moving and the Frog can be controlled in all four directions.

Comparing the two, Pet Frogger is far more simple than Frogger: The Frog moves only forward, left and right.  There is never a place to move the frog in the down direction. The lethal hazards are the rivers, fore and aft boat positions, and sitting in a boat when the Frog's position would move off screen.  The beaches between rivers are indefinitely safe, and the seats in the boats are safe (again, unless the frog leaves the screen while on a boat.)  The difficulty lies in the progressive speed increases of the boats to the point where it becomes a twitch game faster than typical human reflexes.  

This has some similarity to another game, Freeway, from Activision.  Freeway is the original Crossy-Road where the goal is to get chickens to the other side of the road in a limited amount of time while avoiding horizontally moving traffic.  In this case there is nothing strictly lethal.  Traffic can move fast, but hitting an object merely slows the chickens' progress by momentarily knocking the chicken backwards after which it can continue.  Freeway is visually more similar to Pet Frogger than the arcade Frogger game.

Pet Frogger/Freeway are similar to the earliest arcade games (the electro-mechanical types, and some early video games).  Many of these games' objective is to accomplish a simple physical skill as many times as possible within a fixed amount of time.  All Pet Frogger demands is jumping forward to a safe landing place.  Though, Pet Frogger has no time pressure which reduces the stress level of executing the frog's boat-boarding skill at high speed. 

---

Title Screen:

[![Title Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_Title.png "Title Screen")](#features1)

Game Screen:

[![Game Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_Game.png "Game Screen")](#features2)

Dying Frog!

[![Dying Frog!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_Dying.png "Dying Frog!")](#features3)

You're Dead!

[![You Died!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_Dead.png "Dead Frog!")](#features3)

Saved a Frog!

[![Frog Saved!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_Saved.png "Saved a Frog!")](#features4)

Game Over:

[![Game Over](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger03/V03_GameOver.png "Game Over")](#features5)

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

**Version 03, July 2019 notable changes **

**Summary: Major display reworking**

The focus here is to maintain the same play mechanics as close as possible to the original Pet Frogger game, but with as much visual enhancement as possible.  This requires some very careful choices.  Making the player's frog, and the screen graphics more detailed and appealing requires making objects bigger in some ways.  The problem with bigger is that small changes multiply into large impacts when they occur on 18 horizontal rows on the screen.  Fortunately, the original game had three text lines on screen that were unused.  This provides most of the needed free space for enhancing the lines, but a few more were still needed.  Therefore the display is slightly taller than the expected 200 scan line/25 text line screen.

There is one notable behavior change -- A frog on a boat does not die immediately on touching the left or right side of the display.  The frog's motion is limited to the visible display, but the boat will continue to move off the screen.  Only when the frog loses contact with the safe zone on the boat will the frog's death occur.  This provides the player a few moments of grace to get off the boat to a possible safe area. 

**Player/Missile Graphics**

The frog in V02 is a single text character which occupies space four color clocks wide, and eight scan lines tall.  The new frog for V03 is Player/Missile graphics.  Not just a Player - three overlapping players for multi-color.  The frog is nine color clocks wide, and 11 scan lines tall.  Since normal text lines are 8 scan lines tall, there are blank lines added between lines on the playfield to spread out the text lines and make them taller to accommodate the frog.  However, the Frog is still taller than a text line and overlaps the top and bottom scan lines lines of the text lines above and below.  The Frog positioning is exactly specific.  At any place on the playfield a one scan line difference in placement results in improper collision detection for the Player due to the overlap.

The Frog is (slightly) animated.  The pupils in the eyes move to face the direction the frog moves.  After the player stops providing input a timer returns the eyes to the center position.  Though minimal, the eyeball and its automated movement is mildly humorous and provides a greater sense of interaction with the player.  When the frog dies there is an alternate image for the frog showing the frog splattered.  The splattered frog is made of two Players for the multi-color (red-ish), liquid, splash pattern.

Player/Missile graphics simplify the frog movement and the method of determining the life and death of the frog.  Horizontal movement is the same for every line, only limited by left and right borders.  Beach lines are free and no checking for death occurs.  Life and death on the boat lines is determined by simply checking whether or not the frog is touching the horizontal lines drawn on the boats.  This is done by collision checking between the frog and the playfield color for the lines.  This is marvelously trivial on the Atari, because collision detection bits are provided to identify specific playfield colors overlapping Players/Missiles.

Since the supporting code makes frog Player placement on the screen trivial, the frog image is re-used on the Title display and flown around the screen in random patterns.  The flight path is provided using a table of sine wave values.  The sine wave data is read at different rates (different count of frames between updates) for X position and Y position resulting is a warped, curvy flight path for the flying frog.

And since the Frog flight path animation was already easily established, this is re-used to animate the flying tombstone on the Game Over display.  The tombstone is a fairly large object made of several Players and Missiles, 15 color clocks across, and 23 scan lines tall.  It displays "RIP" text and a shadowed side for perspective.

On the surface it seems like these animated objects above are the only use of Player/Missile graphics.  However, Player/Missile graphics also appear in some non-obvious ways.  Player/Missile graphics create the Game display's black borders on the left and right sides.  Due to the character/color gymnastics done for the game's playfield, the color used for the background is not always consistent with the rest of the horizontal line. These borders hide the background color transitions making a cleaner visual presentation.

On the Title and Game displays Player/Missile graphics provide the four text labels for scores (SCORE and HI), frogs remaining (FROGS), and frogs saved (SAVED).  As these use different color registers from the playfield, they can be colored, flashed, and strobed separately from other objects on the same line.  The Player/Missile pixels are the same size as pixels in ANTIC Text Mode 4 (one color clock wide and one scan line tall), thus the "text" appears to look just like a presentation of Text Mode 4.

**Custom character set**

The V03 game, like V02, uses the same, single, custom character set for all displays. This provides characters for display in ANTIC Text modes 2 (2 color) and 4 (5 color).

The A-Z/a-z/0-9, and basic punctuation for the Instruction text on the Title display, the scrolling credits on all displays, and the scores on the Title and Game displays.

The Atari graphics control characters that were used in V02 as the pixels to create the giant text appearing on the Title screen and the various splash screens are no longer used for this purpose.  This is replaced in V03 with Map Mode 9 graphics that provide the same sized pixels with more color control using less memory.

The characters providing colors in V02 via NTSC artifacts for Score and Frog lives labels are no longer used.  The artifacts don't work right on PAL and many modern digital/LED monitors.  These characters are now displayed in V03 using Player/Missile graphics discussed earlier.

The V02 Frog and Splattered Frog characters are replaced in V03 with Player/Missile graphics objects.

The Game screen is where most of the new activity occurs.  The game playfield is primarily 5-color, Text Mode 4 lines.  The character set provides several multi-color characters for drawing the safe beach/land, and the water/waves, and boats moving left and right.  Part of the movement is simply the result of scrolling the lines (waves "move" by fine scrolling with the boats.)  Additional animation is performed by changing character images depicting moving water at the bow and behind the engines of the boats. This animation does not occur by changing the characters of the boats, but by re-writing the bitmap in the character set for each character, so changing the image of one character in the redefined character set then changes it for all 24 occurrences of the character visible on the display.

**Playfield Graphics Handling.**

All screens are presented as custom Display Lists with the Display Lists and screen memory assembled directly where they will be used.  Therefore, there is very little screen redrawing.  Switching between display screens is nearly instantaneous, which is accomplished by merely updating the system's Display List pointer.  In fact, screen switching is so fast that transitions are added (splash screens and intentional delays) to allow the user time to recover from pressing the trigger so that the same button press is not accepted as input on the following screen.

The Title and Game displays are specific custom Display Lists.  The giant Title text is Map Mode 9 pixels allowing complete palette control over the background and the pixels.  The Title animation is done by a simple exclusive OR of a random value masked with the static image of the title.  This piece of screen memory is one of the limited areas that experience redrawing in screen memory.

The Title graphics lines are also used to provide visible feedback to the user when pressing *OPTION* or *SELECT* to change the number of Frog lives and the starting difficulty of the game.  The new value is displayed as giant text scrolling onto the screen.  After a few seconds the animation to return the Title occurs.

The three splash screens (Saved Frog, Dead Frog, Game Over) share a common Display list.  The giant text is made of Map Mode 9 lines.  The graphics are not changed by redrawing that part of the display, but by simply updating the LMS instruction to point to the related screen memory.  Most of the "animation" on the splash screens are done with color changes by Display List Interrupts.  In V02 the "empty" lines were text modes, but V03 uses regular blank line instructions half the height of the text lines allowing twice as many color changes for animation.

On the Game screen Boats move by fine scrolling and coarse scrolling via LMS updates in the Display List -- No redrawing of the boats occurs at all.  Fine scrolling and the necessary coarse scrolling is such low overhead on the Atari that all the scrolling work is done during the vertical blank.  The Game display needs extra time for Display lists in places and there is a need for cosmetic matching between lines while supplying that space, so there are some blank lines and Map Mode C lines inserted strategically in the Game Display List. 

Since the frog is now Player/Missile graphics and there is no frog moving through screen memory, there no longer needs to be separate screen memory for every row of boats.  There is now just one line of screen memory for boats moving left and one line of screen memory for boats moving right.  This reduces memory by 800 bytes (10 lines * 80), close to 10% of the final size of Version 02.  All the lines in the given direction refer to the same screen memory, but have different colors, and scroll values, so that they all appear to be different screen objects.

All five Display Lists jump to one of two places in one common Display List to end the display.  The Game display jumps to the point showing the final fine scrolling credits at the bottom of the screen.  All other displays jump to a prior point showing the text line prompting the user for input which is followed by the fine scrolling credits line.  Having one set of Display List instructions simplifies the code needed to support the prompt line and the fine scrolling credits.

**Display List Interrupts**

V02 uses essentially the same DLI to change background color and text luminance for each ANTIC Text Mode 2 line on the screen.  V03 uses a substantial amount of custom Display List Interrupts doing much more work.

Display List Interrupts are largely table-driven.  Though there are several kinds of custom behaviors the DLIs still tend to read data from tables based on the occurrence of the DLI on that display.  Additionally, where playfield colors are involved the Display List Interrupts end by pre-loading page 0 locations with the values needed for the next Display List Interrupt. (3 cycles for LDA PageZero v 4 cycles for LDA TABLE,y is enough to make a difference).

On the Title screen the title text is successive lines of Map Mode 9 graphics which is only a 2 color mode.  Each line is colored by a DLI providing new colors for the background and the pixels resulting in a dozen colors for the title.  The DLIs for the Instruction areas provide differnt blocks of color for the background, and varies the text brightness in gradient patterns.  The background colors for pixel and text areas extend straight through the horizontal overscan area.

Where Player/Missiles are used their horizontal positions have to be set and then changed again to position them where re-used on the display.  The Title and Game displays re-use Players/Missiles multiple times.  The text for the Score labels is the first occurrence, the text for the Frogs and Saved labels is the second, and then the animated Frog image is the third which is used as decoration on the Title display, and as the player's avatar on the Game display.  The register updates for these are mixed with setting the colors for playfield graphics at those points of the display.  

Additionally, an animated Player/Missile image also appears on the Game Over display, so this display must position Players/Missiles for the character, but not position them for the text labels at the top of the screen.  Since, Player/Missile graphics do not have shadow registers the text at the top of the display must be purposely removed by a DLI that sets 0 positions for the objects.  

The Game screen requires a few custom routines to properly change colors for each line of boats and beaches.  Horizontal scrolling changes the DMA timing on line which affects the time available for the DLI, so some visible changes by DLIs would move up and down to different lines. This required adding blank lines and Mode C lines that accomplish several purposes:
- Proper timing to start the DLIs.
- Additional time for setting all the color registers.
- Extra lines needed to support the height of the frog. 





**Vertical Blank Interrupts**

The Atari's indirection abilities allow several things to be managed in the game just by writing a couple bytes to hardware registers.  This relieves the overhead for animating the display.  It reduces overhead so much that the majority of the game and display updates are executed during the vertical blank.


The credits  Fine scrolling the credits scrolling line.  It operates continuously during the vertical blank.  Looks most slick.  Someone may mistake me for a professional.


**Other lame sound effects.**

A few more things have audio effects attached to them.  A puttering sound added to simulate boat motors.

Doubled the speed for Ode To Joy.  It was taking too long to play at normal speed and starting to sound like a funeral dirge.

The actual funeral dirge for the dead frog is abbreviated to relieve some tedium.  Also, most people don't recognize the song's initial bars and found them odd sounding, so that was another reason I eliminated them.

**Joystick control.** 

Joystick control is the same as V02, but the idiotic, repetitive, bit-bashing code to eliminate invalid input combinations has been replaced with a lookup table to convert raw joystick input into the cooked, final joystick input.  Derp. 

**To Be Continued... V04??**

Any other game mechanics and actual play action to change?

- Allow backwards jumps?

- Add timer to limit a frog's turn, or limit the entire game ?

- Add another hazard/enemy object?

- Change Death into a push back to the previous row.

---

[Back to Home](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README.md "Home") 
