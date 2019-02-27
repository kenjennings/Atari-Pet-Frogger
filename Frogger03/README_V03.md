# Atari PET FROGGER Version 03

PET FROGGER game for Commodore PET 4032 ported to the Atari 8-bit computers

Video of the game play on YouTube: A URL for YouTube goes here
  
Title Screen:

[![Title Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/V03_Title.png "Title Screen")](#features1)

Various Screen grabs go here...

---

**Porting/Enhancing PET FROGGER for Atari**

[Frogger03.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03.asm "Frogger03.asm") Main assembly source and Page Zero variables.

Other source files go here....

[Frogger03.xex](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger03.asm "Frogger03.xex") Atari executable program.

---

The assembly code for the Atari depends on my MADS include library here: https://github.com/kenjennings/Atari-Mads-Includes.  

The MADS 6502 assembler is here: http://http://mads.atari8.info

I generally build in eclipse from the WUDSN ide.  WUDSN can be found here: https://www.wudsn.com/index.php 

---

**PET FROGGER for Commodore PET 4032**

(c) November 1983 by John C. Dale, aka Dalesoft

[Version 00](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V00.md "Version 00") Ported (or parodied) to Atari 8-bit computers November 2018 by Ken Jennings (if this were 1983, aka FTR Enterprises)

[Version 01](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V01.md "Version 01") Updated for Atari 8-bit computers December 2018 by Ken Jennings 

[Version 02](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README_V02.md "Version 02") Further enhanced for Atari 8-bit computers February 2019 by Ken Jennings 

Version 03, February 2019 ? . . . .  

---

**Version 03 PET FROGGER -- WORK^H^H^H^H CONTEMPLATION IN PROGRESS**

**More to come? Or Not?**

**??????????????????**

**The Big Issues**

The game has fundamental problems related to its character-based presentation.  First, the frog is very small.  Considering the 8x8 matrix and display/color limitation of pixels in this text mode it is very hard to render a convincing frog within this geometry.  The frog needs to be much bigger which implies multiple characters horizontally and vertically, or another method that is not limited to character geometry.

Next, two boats moving 1 character position in opposite directions results in an actual 2 position movement relative to each other.  Although the boats have four safe seats when jumping from one boat to another it is only possible to jump to two of the four possible seats.  The character-sized increments makes this jumping from boat to boat tad on the unfair side.  

Finally, the standard text mode on the Atari provides limited color.   The per-line colorization in Version 02 is most of the color capabilities inherent in the text mode.  There are ways to introduce a limited amount of additional color but with higher technical barriers to surmount.  There is more mileage to be gained simply using other text modes that provide multiple colors by design. 

Bigger frogs means bigger boats.  Smoothly moving bigger boats and bigger Frogs in increments smaller than a character means escalating the moving object implementation into a higher level of warfare.  This could mean any or all of the following:  Multiple versions of the character objects at different offset positions, using fine scrolling, and Player/Missile graphics.  (In other words, using an Atari like it was meant to be.) 

**What kind of game is Pet Frogger?  (And should it be expanded?)**

The author describes it as Frogger-like.  (Frogger was a new game in arcades when he wrote the original game of Pet Frogger.) Frogger provides a myriad of enemies and environmental hazards.  Consequently, objects in Frogger are much slower moving and the Frog can be controlled in all four directions.

Comparing the two, Pet Frogger is more simple than Frogger: The Frog moves only forward, left and right.  There is never a place to move the frog in the down direction. The lethal hazards are the rivers, fore and aft boat positions, and sitting in a boat when the Frog's position would move off screen.  The beaches between rivers are indefinitely safe, and the seats in the boats are safe (again, unless the frog leaves the screen while on a boat.)  The difficulty lies in the progressive speed increases of the boats to the point where it becomes a twitch game faster than typical human reflexes.  

But is it like Frogger?   What about Freeway, the original Crossy-Road where the goal is to get chickens to the other side of the road in a limited amount of time while avoiding horizontally moving traffic.  In this case there is nothing strictly lethal.  Traffic can move fast, but hitting an object merely slows the chickens' progress by momentarily knocking the chicken backwards after which it can continue.  This appears visually more similar to Pet Frogger than the Frogger game.

Pet Frogger is similar to some early arcade games (electro-mechanical, and early video games) where the goal is to accomplish a physical skill as many times as possible within a fixed amount of time.  Though, Pet Frogger has no time pressure which reduces the stress level of executing the frog boat-boarding skill. 


**What can be improved?  A cascade of consequences...**

Fine scrolling the boats would improve the game play not to mention the visual slickness of the game motion.  However, fine scrolling the boats would then complicate the movement/placement of the Frog.  Most of the time the Frog would not be aligned to the character positions of the boats which requires extra code to "round" the frog to the nearest character.

Changing the Frog to Player/Missile graphics brings a number of improvements.  The Frog can be displayed in frog-like colors.  Also, Player/Missile would eliminate a pound of code carefully maintaining the frog in screen memory so that the frog does not destroy the boat and water data.  Also, when the boats are fine-scrolled the frog's movement as a Player object is much easier to maintain relative to the boats.  Another benefit is that if the frog is no longer drawn into screen memory and the boat layout is the same for every pair of boat lines, then only one pair of boat rows need be declared as screen memory and the same two lines can be used for all six pairs of lines, reducing screen memory for boats from 12 lines times 80 bytes (960 bytes) to only 2 lines times 80 bytes (160 bytes).  This is still true even if the boats are scrolled to different positions for each row.

On the down side, (if this is a down side?) Player/Missile objects tend to be larger.  The frog as a character is only 4 color clocks wide by 8 scan lines tall.  It would be practically impossible to present a believable looking frog in 4 by 8 pixels.  A decent frog image should should use at least the entire Player width at 8 color clocks, and by being wider, it should be taller, too, 16 or perhaps 24 scan lines.

If the Frog is a large and most-frog-like animated Player object, then the boats also must be upscaled.  Larger boats means there is no longer enough screen real estate to support 12 lines of boats.   If each line of boats needs two text lines, that's 24 lines.  So, the game has to reduce the number of lines, or implement another method of managing the game's Playfield.  Vertical Scrolling would permit keeping the 12 lines of moving boats while not displaying them all at the same time.  (And consequently, vertical scrolling makes the playfield management more complicated.)

Finally, the basis of the display -- ANTIC Mode 2 text.  This provides the most limited color options.  There are four other text modes available from ANTIC that provide real color control, two of those are based on single scan-line, one color clock pixels.  Making the boats bigger would go along with making the frog bigger and provide an opportunity for more realistic looking boats.

**To Be Continued -- any other game mechanics and actual play action to change?**

Allow backwards jumps?  

Add timer to limit a frog's turn, or limit the entire game ?

Add another hazard/enemy object?

---

**Version 03 PET FROGGER -- Current Experimentation in progress....**

- Doubled the speed for Ode To Joy.   It was taking too long to play at normal speed.

- Fine scrolling the credits scrolling line.   Looks most slick.  Someone may mistake me for a professional.

- Use only one line of data for all the boats moving left, and one for all the boats moving right.  All lines going in the same direction display the same screen memory data.  This reduces memory by 800 bytes (10 lines * 80), close to 10% of the final size of Version 02. 


---

[Back to Home](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README.md "Home") 
