# Wonder Momo Translation Process 
(description by 4lorn5)

![Test Image 1](https://i.ibb.co/4R8J57v/6298screenshot1.png)

Romhacking has evolved in many ways over the last decades, with enthusiasts increasingly providing the retro gaming community with excellent fan made translations and tools that allow fellow players to join the community and create, modify, or upgrade videogame content in many ways. From simple, readymade Shift-JIS tables to extensive ROM editing suites, it has perhaps never been easier to give back something to the community.

This, however, doesn't mean that there is a tool for every single videogame ever made. On the contrary, a good portion of ROM editing programs is born from dedicated, laborious studying of a game's original code, something that might take years to fully annotate and compile. Additionally, the more powerful tools are generally reserved for the more appreciated and/or studied games: witness the amount of fan made editing tools available for series such as Castlevania, Mario, Sonic, or Pokémon while many other titles or series' intricacies are still left untapped.

As expected, Namco's Wonder Momo falls into the latter category, without any attempt made to translate it nor any kind of documentation providing insight into its code. Momo is simply one among thousands of games in this situation. Or was, thanks to our translation efforts.

Dave Shadoff has already compiled the more relevant information on the more technical side of the patch used to translate the PC Engine/Turbografx-16 game Wonder Momo. The following is information pertaining to other aspects of the fan translation effort, primarily script lookup, extraction, and other procedures.

Following from Shadoff's work, it was necessary to accomplish these additional tasks:

•Find the Japanese text in the ROM

•Understand text control codes

•Insert a new font and reinsert the script

•Localize and change the title screen logo

•Find a good way to playtest changes

## Find the Japanese text in the ROM 

In the 8 and 16-bit eras, Konami games almost always used the LZ77 compression algorithm or similar variations; some games even used two variations of the same algorithm. Suffice to say, these are specialized compression methods, and every studio may use existing methods (LZ77, RNC, JP80, etc.) or their own in-house approach. As such, every game is different from the next; unless dealing with a specific studio, which might apply recurring programming principles in their games, it's always best to approach a game from the basics. 

Fortunately, Wonder Momo is a lot more candid in how it stores information, but still had its fair share of obstacles.

Many games will store their text related code in an orderly fashion from left to right (except Mega Man 7; thanks, Capcom), although even when in possession of the corresponding values, this is not a guarantee that a dialogue string will be immediately found because even the smallest code implementation will never be quite the same.

Below we can see one of Wonder Momo's level intermissions or cutscenes, right at the end of level 1:

![Test Image 2](https://i.ibb.co/vL4FYCV/JAP1.png)

Let's look at the first line, each character separated for better visibility:

ひ ろ い は ら っ ぱ で そ よ か ぜ に ふ か れ て い る と

Now, let's focus on how the basic hiragana characters and dakuten (diacritics) are presented to the player. As an example, the second instance of a character followed by a diacritic is て (Te) and ゛. Why is this important to look at? Some games will lay out characters in a linear fashion; taking the example above, and assuming that both characters are not being rendered in a single 8x8 tile (which can happen, but is uncommon due to lack of space), this means て and ゛ will each occupy their own 8x8 tile. 

For a programmer, the advantage of this is simple: this way, both basic hiragana and diacritics can be used independently without requiring extra tiles. Romance languages can do the same, although specifics vary (ie., depending on font size, acute and grave accents may be placed on the same tile as a letter using them; this specificity of a language is something that fan translators have to contend with, as they're easy enough to place on lowercase letters, but considerably trickier for uppercase).

As mentioned above, code implementation will never be quite the same between games, so it was necessary to figure out not only the values for each character, but their order. Was it written from left to right? Were the diacritics placed right after the letter that used them? This last question might seem strange but not all games do it. Wonder Momo doesn't have any quirky formatting; meanwhile, a game like Takeda Shingen, also for the PC Engine, places diacritics before the letter that uses them; Rabio Lepus Special, another game on NEC's platform, takes Momo's approach but places diacritics on the line above the one that uses them.

To find out the specific character values, there are some tools available. Emulators with debugging features, in particular VRAM or Background viewers, can display everything currently taking up screen space, including tile values. Mednafen has a robust PC Engine debugger, although the image viewer was the function used to procure these values. Example usage:

1) Drag the ROM over to the Mednafen executable to start the game;
2) Play the game until the cutscene appears;
3) Activate Mednafen's debugger through the shortcut Alt + D, then activate the image viewer through the shortcut Alt + 2. Mednafen has dedicated tabs for Background (BG0, BG1) and Sprites (SPR0, SPR1), which can be accessed by pressing left or right. Up (and Page Up) and Down (and Page Down) buttons are used to navigate a tab.

![Test Image 3](https://i.ibb.co/1QX9jHR/1.png)

It should be noted that cutscenes will pause the action and the game will only progress when pressing the action button, but the ending cutscene is continuous; around 7 screens are displayed with only a couple of seconds of wait time. For those moments in particular, it's possible to pause the emulator through the debugger by having it on, and pressing the S button; to resume the game, still with the debugger active, is done by pressing R.

![Test Image 4](https://i.ibb.co/gRGvK7q/2.png)

So, what does the image viewer shows us? In the BG0 tab, pressing Down or Page Down will show graphics currently loaded into memory, including graphics not currently used (but which are part of the same memory page). Searching further down, we're presented with this:

![Test Image 5](https://i.ibb.co/7294BHW/3.png)

Hovering the mouse button over any 8x8 tile will display its value on the lower part of the screen; the "Tile" information is the relevant one. At this point, it's possible to start working on a table: a file that declares a character and the corresponding byte value. 40 = あ, 41 = い, 6E = ゛, etc. With this, we now know the values of each character, including those of the dakuten. So, we now also know that this:

ひ  ろ  い は  ら  っ  は  ゜  て  ゛  そ  よ  か せ  ゛  に  ふ か  れ  て い  る  と

correspond to these byte values:

``` 
5A 6A 41 59 66 95 59 6F 52 6E 4E 65 45 4D 6E 55 5B 45 69 52 41 68 53 
```

Note the individual diacritic values. As such, while the game presents characters such as ぱ and ぜ as single characters, the code loads these elements separately (は and ゜, せ and ゛, etc.). With a table file now built, it's time to start searching for where the text is stored in the ROM. For that, the HxD hexadecimal editor was used. It's out of the scope of this document to explain the general uses and commands of a hexadecimal editor, as there are too many in existence. Suffice to say, the approach is the same regardless of the choice of program. With the ROM loaded in one such editor, let's search for the string in hex form:

![Test Image 6](https://i.ibb.co/vdm5kpV/4.png)   ![Test Image 7](https://i.ibb.co/ZgfvPb8/5.png)

Success. The first line is between offsets 629 and 63F. Before we do anything else, however, let's look at the surrounding code.

Right before the first line, there are some values: 05 0B 07. Now, looking at the end of the selection, we see something similar: FE 05 0C 07. If we follow the next bit of code, we'll end up with a similar string: FE 05 0D 07. And following up from that, you'll also note a value of FF before more code is displayed. After some testing, the purpose of these values is revealed:

```
05  0B  07
XX  YY  TP
```

TP is the tilemap pointer, the value that tells the game in what area it should look to for the correct tiles. Any other value will of course retain the position, but present other tiles. 

XX is the horizontal position at which the line will be placed on the screen. The very first line begins with a 05; a 04 would move all the text in that line one 8x8 tile back.

YY is the vertical placement of the line. These values range from 00 to 0F. Look at the cutscene image above, look at the distance between each line, and then look at the middle values in the 3-byte string: 0B, 0C and 0D. By default, the game uses double spacing for its text, which limits just how much can be printed on screen at a time - a little nightmare for Western languages. This can be countered, but more on that later.

The remaining values, FE and FF, indicate Line Breaks and End Paragraph, respectively.

## Tile Editing 

We now have a table file. But the tile characters are still in Japanese, which means it's time to edit the ROM's graphics.

As briefly broached in the opening paragraphs, the romhacking community's years of experience in the subject matter has resulted in many tools for romhackers and translators alike. This also includes graphic editing tools. Some are specific, made to fully address a single game or series' graphical specificities, such as unique compression; others are more general purpose, and will parse through the most common bitplane storing methods. In the second category, [YY-CHR](https://www.romhacking.net/utilities/958/) and [TileMolester](https://www.romhacking.net/utilities/1583/), the latter having been used for Wonder Momo's translation, are recommended.

Graphic editing tools like these allow users to browse a ROM in search of graphics stored in many ways, but they also come with a caveat: they show everything inside a ROM, including code. This means that editing the wrong part of the ROM can corrupt it. Thankfully, it's not that hard. With that warning out of the way, let's open TileMolester, and load Wonder Momo. You'll be greeted with this:

![Test Image 8](https://i.ibb.co/rwngNSD/6.png)

TileMolester, and indeed most such tools, will try to "guess" the bitplane storing method (a "codec", in TileMolester's definitions) used by a game, and will load it with that definition. To change codecs, users can choose from several by going to View > Codec; alternatively, Tab will move to the next codec on the list, and Shift+Tab will load the previous codec on the list. Depending on the game, sometimes it's necessary to switch to a different codec, or even between codecs if more than one graphic storing method is in place.

Like Mednafen, searching through the ROM can be done by using Up (and Page Up) and Down (and Page Down) buttons. To shift bits, Left and Right are used. To jump to a particular place in the ROM, simply use Navigate > Go To..., then insert the offset.

At 256KB, Wonder Momo isn't a particularly large file, but we still need to locate graphics. So, begin by pressing Page Down to skip down through the ROM until you find clearly visible graphics:

![Test Image 9](https://i.ibb.co/12W4SKk/99.png)

The first set of clearly visible graphics, the graphics used for the font, resides at offset CC00. You can keep track of what offset you're currently viewing by looking at the bottom left part of TileMolester. The program will always refer to the first line at the top of the currently displayed ROM for the purposes of showing what offset users are at. To get an idea of the space each tile occupies, go to View > Tile Grid.

![Test Image 10](https://i.ibb.co/Nrx24M1/7.png)

This way, it's now possible to see how characters and symbols are making use of their 8x8 space.

TileMolester and other such programs have preset palettes, which is why the colors on display don't correspond to the colors of the actual game. Depending on the complexity of the graphical data, and number of colors, it might be necessary to adjust them. It's possible to switch between preset palettes by clicking on the large arrows at the bottom of the screen, nestled between the current palette; other methods, such as importing palettes or using palette information from the game itself (provided one knows where that info is on the ROM), are also possible. Users can also edit a color by double-clicking on a color, then choosing the correct color values between swatches, HSV, HSL, RGB and CMYK. Of these, only RGB is important for Wonder Momo. But chances are no preset palette will ever match in game colors.

There are two approaches when it comes to preparing an workflow for easy editing of these tiles.

1) One is to edit each color individually, which requires a color accurate screenshot of the game, specifically of the area you want to edit. Taking the screenshot of the first cutscene as an example, open it with your favorite graphics editing program (such as Paint.NET, Photoshop, etc.), then use a color dropper to get RGB info from it; in particular, get the RGB values for the dark purple background and the light brown font. You'll get the following values:

```
Purle: RGB 72, 0, 72
Brown: RGB 207, 154, 124
```

Now, switch to TileMolester. Notice the colors on display for the Japanese text and background:

```
Background: Black: RGB 0, 0, 0
Font: Pale Yellow: RGB 240, 240, 128
```

Double-click these to edit their RGB values. 

![Test Image 11](https://i.ibb.co/rmzkP1K/8.png)

Confirm with OK, then Notice the change:

![Test Image 12](https://i.ibb.co/4WcfVqz/9.png)

If you do this for every color, provided you know which color is representing its in game counterpart, will let you see the tiles as they appear, reducing guesswork. Note that editing the palette entries this way does not affect the game, only how TileMolester loads colors. While it's possible to import palette tables, TileMolester is excessively picky about which formats it accepts, so it's not generally recommended. On the other hand, the program will save palette changes between uses, creating an .xml file named after the file you're editing inside the "resources" folder. 

Furthermore, you can also go to Palettes > Add to Palettes..., and from there create one or multiple palettes. What's the purpose of creating more than one palette? Because videogames use different palettes at different times. The colors you choose to see when editing these graphics will not correspond to other graphics. A light blue color may be represented as dark green on a cutscene, only to be represented with a medium purple in the next. In these cases, it's recommended to create, save, and when necessary load different palettes.

2) The second method requires some guesswork, but this is mitigated by the small amount of colors used. Go to the area you want to edit, then choose the Selection Tool. TileMolester only makes use of rectangular marquee selections; no fancy elliptical stuff here, as it would conflict with the tile-based natured of these games.

Select the area you want:

![Test Image 13](https://i.ibb.co/mvnpmNS/10.png)

Notice the white border around it. You can move selections within the program but be advised it snaps to its nearest 8x8 tile on the grid, so careful placement may take a retry or two. With the area selected, go to Edit > Copy To.... This will prompt you for a location on which to save your selection as a Portable Graphic Network (.png) file. You can choose from several formats; although .png and .pcx are accurate, paletted formats, .png is a more readable format for several graphic tools than .pcx. Once it's saved, open it with your choice of graphics editing program. Below you can see the workspace used for the logo, though it applies to any graphic. The idealized, final logo is on top; while below is the same logo, using the same colors used on the ROM.

![Test Image 30](https://i.ibb.co/jVpn2Cs/process.png)

It should be noted that to maintain accurate colors and palettes, it's important not to use "dirty tools" when editing bitmaps. Selection tools shouldn't use anti-aliasing, erasers should be set to pixel perfect modes, etc. On the other hand, it's common to see people in the community recommend "simpler" tools such as Paint.NET or Graphics Gale for their ease of use, color accuracy and bitmap friendliness. This is solid advice, but feel free to use a program you know how to handle. I use the Affinity Photo design and graphics editing suite, which is analogous to Adobe Photoshop, but always make sure the tools and definitions on my workflow are set to be as pixel-editing friendly as possible. Programs such as these provide tools like grids and guides, for instance, very useful to simulate 8x8 tile sizes.

After opening the image, edit it as you wish while maintaining color and palette accuracy. Once that's done, save or export the edited file with the .png format. Switch to TileMolester again, click anywhere outside the selection to deselect, then go to Edit > Apply Selection. Another window will open and prompt you for the file to import. Once it's placed as you want, deselect, and save the ROM.

![Test Image 14](https://i.ibb.co/QmpQRJ2/ENG1.png)

Of course, if you run the game, expect the text to be jumbled. Obviously, this happens because the instructions are the same, but the letters aren't. Simply adjust your table file with the relevant character codes, and you're set. The above image is an example of a successful font creation, insertion and code rewriting, which we'll look into now.

## A brief note on text insertion 

Experienced romhackers and translators will recommend specific tools to locate, extract and reinsert scripts. Once again, solid advice; Romhacking.net has a [selection of tools](https://www.romhacking.net/?page=utilities&category=14) well suited for this purpose. Me, I'm old and like to take it easy; while I recommended anything that automates the process with the least chance of error, I prefer to manually edit text when there isn't a whole lot of it. Wonder Momo isn't very wordy; while the delicious translation provided by our translator, filler, ended up being 2x or 3x larger, it didn't take long to reinsert the text. But obviously, this was a personal choice.

Previously, I had brought up the game uses double spacing for its text, limiting the amount of text that can be shown. After some testing, me and Dave Shadoff both came to the conclusion that the horizontal value for the text, being a coordinate for its VRAM position, could "wrap around". What this means is that it's possible to make the game display several lines of text.

How so? Remember that XX, the horizontal value, defines where text starts on a given line. Meanwhile, vertical line values, YY, range from 00 to 0F. Given that cutscenes will always show a picture frame with Momo, values from 00 to 09 are not advisable as the frame is printed over them, which leaves us with values from 0A to 0F. So, for the very first line, instead of placing it 5 units (5 8x8 tiles' worth, starting from the left), let's give it a horizontal coordinate of 85 but still retain the rest of the string. In short, let's replace 05 0B 07 at offset 626 with 85 0B 07:

![Test Image 15](https://i.ibb.co/vwkCrzL/image.png)

It draws from the same graphics pointer (07), is carries the same vertical line (0B), but begins several tiles away.

The original strings only define a short number of lines, an advantage of the Japanese language. For English, or many other languages, it may be necessary to double or triple them. So, while the original made use of these strings for 3 lines, such as:


```04 0B 07
04 0C 07
04 0D 07
```

Our script ended up requiring the following most of the time:

```
04 0B 07
84 0B 07
04 0C 07
84 0C 07
04 0E 07
84 0F 07
```

Notice how each pair references the same line and graphical pointer, but simply relocates the text.

## A brief note about the use of spaces in text 

Originally, Wonder Momo used the value 26 for empty spaces between some words (in our translation, both 26 and 84 can be used interchangeably). If you explore both the original game and our translation and search for the script, you might notice that at certain points, the game declares spaces many times in a row. Why, though? Wouldn't it be more efficient to simply end a line and move on to the next? It would - but the game has a quirk that only becomes noticeable when looking at the ending credits, which is where the large spacing declarations take place. Here are Momo's lines from the first and second ending slides in our translation:

![Test Image 16](https://i.ibb.co/M5J3sQF/1.png)

[Offset 40800]

```
No way. You were finally
able to make it here.
I really like you,
you know.
```

Which translates to...

```
04 0B 07 (Coordinates)
4D 68 84 70 5A 72 90 84 58 68 6E 84 70 5E 6B 5E 84 5F 62 67 5A 65 65 72 (Text) 
FE (Line Break)
84 0B 07 (Coordinates)
5A 5B 65 5E 84 6D 68 84 66 5A 64 5E 84 62 6D 84 61 5E 6B 5E 90 26 26 26 26 26 (Text)
FE (Line Break)
04 0C 07 (Coordinates)
48 84 6B 5E 5A 65 65 72 84 65 62 64 5E 84 72 68 6E 91 26 26 26 26 26 26 26 26 (Text)
FE (Line Break)
84 0C 07 (Coordinates)
72 68 6E 84 64 67 68 70 90 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 (Text)
FF (End Paragraph)
```

![Test Image 17](https://i.ibb.co/yfG3xLm/3.png)

[Offset 40A00]

```
Also, I'm glad.
Since you played together 
with me to the end.
```

Which translates to...

```
04 0B 07 (Coordinates)
40 65 6C 68 91 84 48 95 66 84 60 65 5A 5D 90 26 26 26 26 26 26 26 26 26 26 26 (Text) 
FE (Line Break)
84 0B 07 (Coordinates)
52 62 67 5C 5E 84 72 68 6E 84 69 65 5A 72 5E 5D 84 6D 68 60 5E 6D 61 5E 6B 26 (Text) 
FE (Line Break)
04 0C 07 (Coordinates)
70 62 6D 61 84 66 5E 84 6D 68 84 6D 61 5E 84 5E 67 5D 90 26 26 26 26 26 26 26 (Text)
FE (Line Break)
84 0C 07 (Coordinates)
26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 (Text) 
FF (End Paragraph)
```

What would happen if we used Line Breaks immediately after a line was finished?

![Test Image 18](https://i.ibb.co/bv2rGKg/2.png)

The game makes use of spacing not only in a linguistic sense, but also to "cover up" the previous slide's text. This isn't a concern on the cutscenes that play between levels, as it only shows one before continuing with the game - but is immediately noticeable on the ending slides. As such, it was necessary to prolong each line in accordance to the previous one, taking the previous slide in consideration when preparing the next one.

## A brief note on the logo localization 

Usually, when translating and localizing a game, it's good showmanship to address everything, when possible, from textual to visual elements. This also applies to a game's logo. For Wonder Momo, I had a good reference: Namco's own design for the 2014 web anime series (no comments provided on its quality). Suffice to say, the English logo is a bright, bold variation of the original; obviously, we needed to feature something like this.

Locating the PC Engine version's logo was a two-step process. With TileMolester, the logo was found at, and extracted from offset 21800:

![Test Image 19](https://i.ibb.co/QHhwwCT/11.png)

It was then thoroughly reworked through a graphics editing program, keeping colors and palette in mind, then reinserted in the ROM:

![Test Image 1](https://i.ibb.co/4R8J57v/6298screenshot1.png)

Of course, the way the tiles are arranged inside the ROM don't match the way its orderly placed on the title screen (it rarely does in any game); once again, Mednafen's visual debugger was useful, specifically the BG0 tab:

![Test Image 20](https://i.ibb.co/0YknLBd/12.png)

As before, hovering over a tile will present its value on the lower part of the screen. C0 and C1 define the two top leftmost tiles of the logo... But how to find the rest? If you look closely, those two tiles are followed by another two tiles; after those two, it resumes the pattern of the first letter. The values shown are C4 and C5. Sure enough, searching for C0 C1 C4 C5 will provide results – one single result, in fact:

![Test Image 21](https://i.ibb.co/mHP1QQm/13.png)

What if it didn't? In cases like this, there are several ways of going about this. The most common one is to use a hex editor or program that can search by patterns. I tend to use [Binary Search](https://www.romhacking.net/utilities/1452/) for cases like this; it can search ROMs for patterns where we know some values, but now all of them; simply replacing the unknown ones with ??, it will then find its way through all similar patterns in a ROM. But as luck would have it, there was a single, consistent match in the entire ROM.

Here's how it's laid out in the original:

[Offset 22B2]

```
08 01 21 
26 26 C0 C1 C4 C5 26 26 CA CB CE CF
FE 
88 01 21 
26 26 C2 C3 C6 C7 C8 C9 CC CD D0 D1 D2 D3 D4 
FE 
08 02 21
D5 26 D8 D9 DC DD E0 E1 E4 E5 E8 E9 EC ED F0 F1 
FE 
88 02 21
D6 D7 DA DB DE DF E2 E3 E6 E7 EA EB EE EF F2 F3
FE 
08 03 21 
F4 F5 26 26 26 26 F6 F7 26 26 F8 26 F9 FA FB 
FF
```

Does this look familiar? If it does, then you're paying attention. It uses the same control codes as text: FE for the next line, followed by a string of 3 bytes for coordinates, and then the tile placement code until the next line, and FF for the block's end. Even 26 is repeated as a control code for empty spaces. Our final logo design was made to fit the same space, although it had to be moved one line up. Additionally, we could not place tiles on spaces that would end up becoming reserved for FE and FF, as these conflicted with the control codes:

![Test Image 22](https://i.ibb.co/yBqzYL7/14.png)

You'll note Namco did the same, since the original logo's placement in the ROM does not make use of the last few 8x8 tiles spaces as well.

## Playtesting 

It's always a good idea to find ways to playtest and debug changes in a game as fast as possible. Sometimes, it's not easy, and yes, one may have to spend 30 minutes to get to a specific area or stage just to see if a line of text is well formatted. Other times, cheat codes or even in-built secret options in a game are extremely helpful. 

Wonder Momo isn't exactly a hard game, but can become punishing quite fast. Fortunately, it has a secret sound menu from which it is possible to view all of the cutscenes, including the ending credits. It requires pressing the Run button immediately after Momo stops flashing on the title screen. Needless to say, it's best to make a save state during this period, right before the flashing ends, for better chances of getting it right. 

![Test Image 23](https://i.ibb.co/1RkhLFc/Wonder-Momo-Japan-211004-1615.png)

Once inside the special options menu, these are the inputs required:

```
Set Skip to 00, hold I + II, then press Select : first level cutscene
Set Skip to 01, hold I + II, then press Select : second level cutscene
Set Skip to 04, hold I + II, then press Select : third level cutscene
Set Skip to 0B, hold I + II, then press Select : ending
```

It was also necessary to playtest the game from start to finish; loading cutscenes in a static way, independent of any supporting code, only gets you so far. For this purpose, the PC Engine emulator Ootake was used, along with an edited memory address (ie., cheat), inserted through CPU > Write Memory... : ```F82220:255+```. This code grants Momo infinite health. 

## Viva Non Non!

And that's it for my part. I hope this information is useful for anyone looking to know how the translation for Wonder Momo was done.


