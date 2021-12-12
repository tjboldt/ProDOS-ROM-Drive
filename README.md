# NOTE!
This branch is untested and just here as a work in progress. Do NOT use. Use main branch instead.

# ProDOS ROM-Drive
This is a peripheral card for the Apple ][ series computers that acts as a read-only solid state disk drive (SSD) all in EPROM. Although it won't run DOS, it is fully ProDOS compatible and will appear as a read-only hard drive even when booting from another drive. It holds 1024 KB of disk data with the 256 byte firmware stored in block 0001 where the SOS boot loader normally resides. The drive boots ProDOS and into BASIC in under 1.5 seconds. 

![Image of Board](/Hardware/ProDOS%20ROM-Drive%203.0%20Front.jpg)

## History

My first Apple computer was an Apple //e that my brother bought in early 1984. Countless hours were spent playing games which developed my interest in building games. This also led to the creation of various utilities to help organize disks or just to see what could be done while programming.

As time passed, I obtained other machines far more powerful and eventually my once loved Apple IIe got used less and less. I did still pull it out of storage every few months to play some classic games or see what I could accomplish with greater programming skills. The problem was connecting up disk drives, looking for disks and hoping that the disks still worked. To make life simpler, I decided I needed to come up with some way to permanently store the files inside the computer without needing to plug in anything but the power and video connectors. This is where the idea for a solid-state drive began.

In the summer of 1998 I did some research in my own Apple II library for information on building peripheral cards. I drew up some designs in September 1998 and started building a prototype on a solderless breadboard with the wires jumpered over from a dead parallel card which I had cut the traces on. The rough idea at the time was to have two EPROMs. One would hold the 256 bytes of code in the $Cs00 - $CsFF space (where s is the slot number) and the second EPROM would get accessed through the 16 byte port space for the slot. To access more than 16 bytes, I would have a couple latch chips where you could program in the address of the disk EPROM and then read it one byte at a time through the ports. Originally I was going to make my own modified version of DOS 3.3 but before I got too far, David Wilson from Australia convinced me that it was much easier to build it for ProDOS since it supported many types of drives natively.

By November 1998 I had a prototype on the solderless breadboard that could read data from the EPROM but it had no driver code, didn't boot and was very unreliable. In December I managed to have the two EPROM based system running but it would fail to boot about 80% of the time with various read errors. Shortening the length of wires, cleaning up the layout and a new design helped but it was still unreliable. I finally gave up on the second design but as it turns out, it could have been fixed quite easily.

By mid-May of 1999 I finally got around to building a third design. This time I reduced the chip count and made the firmware for the drive reside in the top two blocks of the virtual disk EPROM. It still was somewhat unreliable in slot one but it was progressively worse as it was placed into higher slot numbers. By slot seven the card was completely unuseable. I then discovered that adding a 104 ceramic capacitor to each chip made the problem disappear. It was suddenly fully reliable.

To build actual circuit boards, I tried making some by hand with marker, etching solution and copper on fibreglass boards but this proved to be far too difficult. I then learned the wonders of gerber files which can be created with a variety of PCB layout software. The files were emailed to a company in Alberta, Canada and three days later in July of 1999 I received a batch of 10 blank boards. These boards did not have the familiar green board look to them, nor were they pre-cut. I had to cut and file them to fit an Apple II slot by hand. Back then it was prohitively expensive for a young hobbiest to make less than 20 or 30 boards with the full solder-masking process due to the set-up fees.

In 2019, I decided to revisit the original design as I was disappointed that the original didn't have a solder mask and was rather large for what it was. I got the board much smaller but in the process of translating my two decade old hand written notes, I made a mistake on one control line. To actually call this project finished, I had to make another revision. I also noticed the revised board was slightly larger than a credit card so I worked for a couple weeks to optimize the lines and squeeze the two-layer board down to 3.375" x 2.125". The board here is that final revision 2.5 (note that references to first, second and third design are all the solderless breadboard prototypes leading up to the 1.0 circuit board printed in 1999, 2.0 was never made, 2.1 is the board with the error patched with a jumper wire and 2.2 through 2.4 were never made).

In 2021, the first and only issue was opened on the project requesting that the firmware be relocatable. I let that issue sit for a few months and then Ralle Palaveev supplied some relocatable firmware as a patch. I quickly realized that this could be placed into the second block on the drive normally reserved for SOS bootloader for the Apple ///, essentially allowing the full EPROM to be used for the drive. I disassembed Ralle's patch, merged it into the existing source
code and made a few updates to save a few bytes and add clarity.

## Notes

The firmware code needs to be assembled 7 times with different parameters specifying which slot to assemble for. It is probably easier to work from the EPROM image as it is already a 1 MB disk image with the firmware in the top four ProDOS blocks.

I usually use Ciderpress to copy files onto the drive image and then burn the file to a 27C801 EPROM with a GQ-4x4 USB Programmer.

If you're planning on designing you own card, I highly recommend reading "Interfacing & Digital Experiments with your Apple" by Charles J. Engelisher and Apple's "Apple II Reference Manual" as well as "ProDOS Technical Reference Manual" if you want to build a drive. You also need an EPROM programmer, some chips and a prototyping board. My designs used simple logic gates to decode addresses but if you want to reduce chip count, you'll also need a PAL/GAL logic programmer (which some EPROM programmers can do).

##
Official website is [apple2.ca](http://apple2.ca/).
