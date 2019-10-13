# Atari PET FROGGER Version 00

 PET FROGGER game for Commodore PET 4032 ported to the Atari 8-bit computers

Video of the game play on YouTube: https://youtu.be/Aotkgw6ZSfw   

The game has no sound as the original Pet version has no sound.

Title Screen:

[![Title Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger00/V00_Title.png "Title Screen")](#features1)

Game Screen:

[![Game Screen](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger00/V00_Game.png "Game Screen")](#features2)

You're Dead!

[![You Died!](https://github.com/kenjennings/Atari-Pet-Frogger/raw/master/Frogger00/V00_YerDead.png "You're Dead!")](#features3)

---

**Porting PET FROGGER for Atari**

[Frogger00.asm](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger00/Frogger00.asm "Frogger00.asm") Atari assembly source.

[Frogger00.xex](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/Frogger00/Frogger00.xex "Frogger00.xex") Atari executable program.

---

The assembly code for the Atari depends on my MADS include library here: https://github.com/kenjennings/Atari-Mads-Includes.  

The MADS 6502 assembler is here: http://http://mads.atari8.info

I generally build in eclipse from the WUDSN ide.  WUDSN can be found here: https://www.wudsn.com/index.php  

---

PET FROGGER for Commodore PET 4032

(c) November 1983 by John C. Dale, aka Dalesoft

Ported (parodied) to Atari 8-bit computers November 2018 by Ken Jennings (if this were 1983, aka FTR Enterprises)

As much of the PET 4032 code is used as possible. In most places only the barest minimum of changes are made to deal with the differences on the Atari.  Yes, there is no sound.

---

**Porting Games From Other Systems To Atari**

INTRO

The Atari 8-bit computers have astounding capabilities considering the chips were first manufactured for development systems in 1978 and the home computers went on sale in 1979.  The computers are the evolutionary successors to the Atari 2600, and the ancestor of the Amiga.   Some Programming concepts from the 2600 apply to the Atari 8-bits, and understanding the Ataris provides insight into the Amiga's custom hardware features. 

The 2600 requires a programming methodology that would drive most people nuts.  The machine has 128 bytes of RAM.  There is no memory for graphics.  Everything displayed on the screen has to be written into the graphics chip's registers as the screen is drawn.  The game logic is slave to tight timing cycles.  Between the programming difficulty, and the more primitive graphics capabilities, Atari 2600 games tend to be simple.  In spite of this there are mindblowing games on the 2600.  Respect is due the person who can write any kind of functional game for the 2600.

The Atari computers began design as the advanced replacement for the 2600 that would have more capabilities and be easier to program.  As soon as design started the focus shifted to making a personal computer with advanced graphics ability.  The resulting machines have graphics features many of which would not be bested until the Amiga appeared.  

Programming the Atari computers is considerably easier than the 2600.  In fact, most of the time it is downright lazy by comparison.  The graphics chips generate the playfield text and graphics and Player/Missile overlay graphics without direct CPU intervention.  The program simply arranges these things in memory and tells the graphics hardware where to find everything in memory.  An Atari computer game is free to  spend more time on complex game logic. 

The Atari systems were popular, selling several millions of units, and toward the 1982 to 1983 years they were very popular targets for software developers.  But, there was competition.  Other systems, cheaper than the Ataris, sold more and become the developer favorites.  Every computer model had games written for them that may have been ported to only a limited number of systems that did not include the Ataris, or may have not been ported to any other computer.

CHOOSING GAMES TO PORT

There are two considerations here:  What you're porting to, and what you're porting from.   

The language you choose to work in affects the scope of what you can port to the Atari.  6502 Assembly language provides total control of the machine language program and offers complete use of all the Atari's features.   If it can be done on the Atari, it will be done in Assembly.

Atari BASIC -- It is easy to understand, and allows for fast code changes, and testing, since it is an interpreted language.  I use BASIC to prototype a program, so I can get logic in order before starting in Assembly language.   However, operating in Atari BASIC limits the hardware features possible.  Some Atari graphics features require use of machine language.  If you are determined to work with BASIC, then I recommend using something other than Atari BASIC.  My favorite is OSS BASIC XL (or XE) which is compatible with Atari BASIC, considerably faster, and has built-in support for Player/Missile graphics that Atari BASIC does not have.  However, no matter what you do, BASIC is far, far slower than Assembly language. 

There are versions of BASIC, and other languages that can be compiled into machine language.  Often the results are as good as having worked directly in Assembly, though sometimes there can still be compromises when working directly with Atari hardware features.  I do not have a lot of experience with thes languages.  BASIC and Assembly cover all the bases for me.

OVERVIEW OF THE ATARI HARDWARE

Porting to the Atari means understanding how to fit another computer's features into what the Atari can do.  Some things another comuter can do may not be  easily portable to the Atari, and at other times you may choose to enhance something on the Atari beyond what the original platform can do.

- Custom character set.  The Atari's text modes can render the imagery for text characters from anywhere in memory.  The images for characters can be changed simply by pointing to different memory.

- 6 text modes.
  - 2 modes of 40 column text based on the "high resolution" pixels.  This allows monochrome text, plus a border color.  One mode is 8 scan lines tall which is the standard text display on the Atari.  The other is infrequently used and is 10 scan lines tall allowing for lower case descenders if an appropriate custom character set is supplied. 
  - 2 modes of 40 column text based on the "medium resolution" pixels. This allows up to 5 colors with 4 colors within a single character.
  - 2 modes of 20 column text based on the "medium resolution" pixels. This allows 5 colors.  Each character is a single color.

- 8 graphics modes.
  - color modes range from very low resolution at 40 pixels across the screen, to "medium resolution" at 160 pixels across the screen.  
  - "high resolution" mode is 320 pixels across the screen allowing monochrome graphics (2 shades of the same color)

- Mixing graphics modes on the screen.   The display is generated by the Graphics chip executing a "Display List" of instructions which specifies what kind of text or graphics to display on a horizontal line on the screen. 

 - Display List Interrupt. The Display List instructions can trigger a machine language routine when the display reaches that line of the display.  Typical use is to change the value of volor registers allowing more colors on screen, and changing the  Player/Missile graphics to new positions.

- Vertical Blank Interrupt. The end of the Display List at the bottom of the screen triggers a system machine language routine that can optionally transfer to a custom routine supplied by the program.
 
- Text/Graphics memory indirection.   Any part of the Atari computer's memeory map may be displayed as graphics for each line in the Display List.

- Overscan.  The Atari display can extend vertically or horizontally beyond the edges of the screen.  Vertically this is done with the Display List inteructions.  Horizontally, this is a register setting in the graphics chip.  Horizontal overscan means the chip is displaying more text chanracters or graphics pixels on the horizontal line that described earlier for normal graphics behavior.

- 128 color palette.  256 colors in some color interpretation modes.  Depending on graphics mode and color interpretation mode 2, 4, 5, 9, or 16 colors can be on screen at once without using any machine language routines to reuse colors.

- Color indirection.  In most of the display modes the normal color interpretation allows the colors on the screen to be any one of the 128 colors in the palette via a hardware register assigned to that color.  Changing the value of the color register changes all the pixels in the screen using that color register.

- Four color interpretation modes. The 14 text and graphics modes can be rendered using one of four kinds of color interpretation.  In theory, this makes 46 graphics modes possible.   However, the last three color interpretation modes work best in conjunction with certain graphics modes, so not all 46 combinations are practical.
  - Normal color interpretation. All the discussion above utilizing normal color indirection.
  - 16 shades of one base color.
  - Up to 9 colors using color indirection.
  - 16 colors all using the same brightness.

- Fine scrolling.
  - Up to 16 pixels horizontally (4 normal text characters) 
  - Up to 16 scan lines vertically.
  - Hardware assisted coarse scrolling.

- Player/Missile graphics
  - Four, 8-pixel wide "Players" with separate color registers from  the text/graphics colors.
  - Four, 2-pixel wide "Missiles" using the Player's colors.
  - Full collision detection of Player/Missiles, and Playfield text/graphics to specific colors.
  - Variable priority allowing Player/Missiles to be in front or behind playfield text/graphics.
 
 - Four channel sound with variable noise waveforms.
 
 - Two (or four on the Atari 400/800) Joystick ports providing unique/separate input from the keyboard.
 
 - Option, Select, Start buttons read separately from the keyboard and joysticks.

Whew!  That's a lot.  People have written entire books about how to use this.

THINGS YOU CAN DO IN ATARI BASIC

- Custom Character Set - It is easy to POKE data into memory to change the character images being used and then change the register value pointing to the character set images.

- Mixing any text and graphics modes on the same display. - Building a Display List does not require Assembly language.

- Overscan. - Suprisingly easy, but not often used.  Build a Display List using more scan lines for vertical scan lines.  Change the graphics chip's horizontal width register.   The change in display width does make it more difficuly to print or plot graphics as the wide display does not match the Operating System's graphics routine use.

- Hardware assisted coarse scrolling. - Well planned use of the Display List and pointers to screen memory can make coarse scrolling the display, or a limited set of lines on the display appear to move together as one solid object without tearing.

- Player/Missile graphics - Loading and positioning an image for Player/Missile graphics is easy in  BASIC.  Animating an image is a harder problem.  OSS BASIC XL has built-in commands for vertically moving Player missile graphics.  The other common method is to use Atari BASIC/BASIC XL's unique string capabilities to assign a string to Player/Missile memory and manipulate the string.

- Sound.  Very simple.  Atari BASIC includes commands to play sounds.

THE OTHER PLATFORMS

Porting the First-person shooter Counter-Strike:Global Offensive to the Atari is a noble goal which you will probably never finish with acceptable results within your lifetime.  The best pool of potential games to port comes from other retro platforms at or below the capabiltities of the Atari.  A reasonable list would be the common home computers released in the 1977 to 1983 timeframe: Pet, TRS-80, TRS color computer, Apple II, Vic-20, C64.  I'm not familiar with many non-US brands.  Based on YouTube review of games the BBC Micro should also be a potential source.

MOST of these platforms share similar limitations.  SOME are better than others.  
- No graphics beyond a text display, or limited graphics.  
- If multiple graphics modes are possible the hardware cannot easily mix text and graphics modes on screen.  Where this does occur in games it is usually done by simply drawing text on a graphics display.
- Limited color palette:  2, 8, or 16 colors.  Either no, or limited color indirection supported.
- Fine scrolling is usually not supported beyond physically redrawing the entire screen.
- Coarse scrolling requires redrawing the screen.
- No sound or limited sound.


PET

The Pet has no actual graphics capability and no color.  It does have a large text character set that with careful use can create displays that appear to be drawn graphics.  As everything is text-based any game object or moving player is based on character positions.
It has no sound, no joysticks, and as it has very limited hardware its BASIC language has little unique considerations.

APPLE II

TRS-80

TRS COLOR COMPUTER

VIC-20

COMMODORE 64

BBC MICRO

  

porting handling methods 
The first consideration is what other platforms games can be ported.  In theory, anything can be ported

BASIC PROGRAMS

ASSEMBLY PROGRAMS


---

**Porting Pet Frogger**

There are some changes to the code made to facilitate porting.  Certain changes are necessary given the differences between the Pet and Atari 8-bit computers.  Occasionally, I did optimize something if it looked like there was something obviously wrong with the way the code was doing things, but that is not very frequent.   Sometimes an optimization turns out to not be an improvement.  Therefore, I don't usually delete the original code, but instead comment it out, so I can go back to see what was origfinally coded.  Notable changes:

- References to fixed addresses inthe code are changed to meaningful labels.  This includes page 0 variables, and score values.  The original code for the Pet included a comment block identifying the 

- Kernel call $FFD2 is replaced with "fputc" subroutine for Atari.

- Excessive chattiness... the source is heavily commented.  Much of it is me talking to myself in my head and trying to figure out what the Pet code was doing.

- The Atari screen is a full screen editor, so cursor movement off the right edge of the screen is different from the Pet requiring an extra "DOWN" character to move the cursor to next lines.

- Direct write to screen memory does not use ASCII/ATASCII codes on the Atari.  Instead, internal character codes are used. 

- Direct keyboard scanning is a little different on the Atari.  The OS register for the key needs to be cleared to the no-key-pressed value ($FF) in order to recognize the next key press.   Also, the keyboard codes are different on the Atari (and they're not ASCII/ATASCII or Internal character set codes.)

---

I think I did something that broke the display of multiple frogs that successfully crossed over the rivers.  One is displayed.   But if more frogs cross, still only one is displayed.

I dialed down the game speed a bit in order to shoot the video and make sure my elderly reflexes could manage some successful runs.

---

[Back to Home](https://github.com/kenjennings/Atari-Pet-Frogger/blob/master/README.md "Home") 
