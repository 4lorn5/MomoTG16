# Wonder Momo Patch - how it works
(description by Dave Shadoff)


On the technical side of the patch, there were three things which needed to be accomplished:
1) Extend the ROM to accommodate a larger script
2) Relocate the text from the original locations into the new locations, including references
3) Correct a titlescreen behaviour which shows on various emulators

## Extend the ROM

First, we start with a headerless ROM, since PC Engine games don't benefit from having a header at all.

In order to extend the ROM, the file simply needs to be extended... but this needs to be done keeping a
few rules in mind.  It should be added in at least 8KB chunks; however, several devices are particular
about loading only specific sizes.  In the end, it's best to extend it to a standard size.  So, either
extend the 256KB ROM to 384KB or 512KB... but 384KB is known as a 'split' ROM and the data is mapped
in special ways... it's best to just expand it to 512KB, even though most of the space is left empty.

## Relocate the Text

First, the text needed to be located in the ROM - but that had already been done.  Based on the size of
the text and the new replacement text, the decision was made to relocate to ROM locations in bank $20,
which starts at address 0x40000.  The messages were spaced out by 0x200 bytes, to allow for substantial
new replacement messages.

### Tools Used

1) I used PCEAS to patch new code into the ROM; it can include the original ROM as a binary input
and apply changes on top of that, creating a new binary output file.

2) I also wrote a data copy utility called "filepatch" in 'C', which I have used in various projects.
I included here as it is used by the 'movescript' script.

3) I run all my code on linux, but everything should be portable if you need it to be.

Syntax of the filepatch utility:
filepatch [outfile] [dest] [srcfile] [source] [len]
where
[outfile] = filename of output file
[dest]    = destination location (offset from start of file) of binary data to copy
[srcfile] = filename of source file
[source]  = source location (offset from start of file) of binary data to copy
[len]     = number of bytes to copy

### Movescript

The movescript script simply copies each of the text strings from their original locations in the ROM
to the new target location in a target file.  Note that I use separate files - in case something I do
corrupts the output file, I can always regenerate from scratch.

### Assembler Code

There are more comments within the .asm file, but while running the code in the Mednafen debugger, I found
a few interesting things:

1) Each of the strings was stored in BANK #0 - this is important, because BANK #0 is generally kept pinned
in memory at locations $E000 through $FFFF, including the interrupt vectors.  So the pointers to the text would
be expected to refer to a memory location in that range - this made it easier to search for the pointers.

2) The pointer reference was interesting - while the code called the display function, the return address was
taken from the stack, and the pointer was loaded from there.  In other words, the sequence was something like:
```
CALL PRINT
.dw TEXT1
CALL SOMETHING_ELSE
```

3) Knowing this, I re-purposed the areas where the text previously resided, and jumped to there from the original
locations, since the call would be more convoluted now (I needed to 'page in' the new location of the data).  The code
for this looked like:
```
TMA #2	  ; save this value for later
PHA
LDA #$20  ; as mentioned, data is now in BANK #$20
TAM #2    ; we'll page in the data into the $4000-$5FFF area
JSR PRINT ; same as original
.dw new_loc
PLA       ; restore the original value 
TAM #2
JMP BACK_TO_ORIG
```
You'll see an iteration of this for each message.

## Correct Titlescreen Behaviour

There is a tricky complexity in the timing pattern of CPU-to-VRAM access which was never fully understood
by software emulators; this is because the details of software emulators went as far as they could with only
software tests to determine timing and other behaviours (which was quite far).  However, with logic state
analyzers and so on, one could determine an additional layer of nuance related to timing... this was discovered
by the author of the MiSTer_TG16 FPGA core (srg320) in 2020, but not yet re-implemented back into software
emulators.

Wonder Momo reveals this accidentally. The game implements interrupts on two video display controller situations:
VBLANK (end of screen), and RCR (reaching a specific line, mid-display).  The IRQ handler in Wonder Momo doesn't
differentiate between these two situations; it just makes an assumption about which is happeneing at a given moment.

As it happens, Wonder Momo assumes that after the initialization (which includes loading data into video memory),
that the very next VDC interrupt will signify VBLANK.  However, due to the timing variance in software emulators
compared to real hardware, the timing is slightly different, and the first interrupt is actually the RCR.  For this
reason, the display is shown differently than expected - Momo is adjusting the y-offset of the display at the wrong
moment due to the interrupt mixup.

### How this is solved:

In the original game, the expectation was that the first VDC interrupt would be VBLANK.  So I took a copy of
the IRQ handler and made it differentiate between VBLANK and any other situation - but only if it found a
specific value in the key memory location.  This check adds a few cycles to the IRQ handler for the RCR case
(which is more time-sensitive), and adds a little bit more to the VBLANK case - but this game doesn't seem
to be too sensitive to timing of these situations.  Since the interrupt handler now occupied more space, I
again used some space previously occupied by the original text which wasn't needed anymore.

(There is more detailed information in the .asm file)

I hope this information is helpful to people.
