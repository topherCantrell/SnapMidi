SNAPMidi
========

# What is the Propeller Chip?

The Propeller chip is an 8-core microprocessor made by Parallax.

http://www.parallax.com/product/p8x32a-d40

Each core has access to all 32 GPIO pins. Each core has two built in counter/timers. Each core has video generation hardware for NTSC or a computer monitor.

Each core has 2K of RAM, but the RISC processor accesses the memory as 4-byte longs. Thus there are only 512 addressable locations (code or data) in each COG. Each RISC instruction is a long. Each instruction has a SOURCE field and DESTINATION field that can be any address in the COG memory. There are no registers. All 512 locations are available as registers.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%207_49_42.png)

The Propeller has 64K of memory shared by all COGs. 32K is pure RAM. This entire RAM is automatically loaded from a serial EEPROM at startup.

The last 32K contains math tables, fonts, and the SPIN interpreter. SPIN is a Parallax-invented language that compiles into byte-codes that are stored in the shared RAM. The interpreter in a COG reads the byte-codes and executes the program. The SPIN interpreter allows you to "spin up" multiple interpreters or to run pure RISC assembly programs.
But the start-up process always begins with a SPIN interpreter loaded into the first COG and an initial SPIN program to get everything else going.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%207_50_43.png)

# Virtual Hardware and Project

Most Propeller projects involve spinning up one or more "virtual hardware" COGs and then a main-COG (usually written in the SPIN language) to implement the applications main logic.
There are many pre-built hardware libraries that come with the compiler. Users are encouraged to share their own code on the Parallax Object Exchange.

http://obex.parallax.com/

## Pyramid 2000: Circuit Cellar March 2007

I wrote an article for Circuit Cellar in March 2007. The project used an NTSC (television text) driver and a keyboard driver from the Propeller library. I wrote an SD card driver to read data sectors from an SD card. I wrote an "adventure language" interpreter that read a simple language from the data sectors. Then I translated the text adventure game Pyramid 2000 into the adventure language for play on the propeller.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%207_51_57.png)

## Custom Interpreter Development: Circuit Cellar June 1010

I wrote a custom driver COG program for 48x32 LED grid. I also wrote a custom driver to talk to the AY3910 sound chip (one of my favorites from the 80s). I used the same SD card reader code from the previous project. I wrote a "Movie Player" main program that rendered images and played sounds read from the SD card. I wrote a Java tool to help make the animations and music for the 12 Days of Christmas.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%207_53_9.png)

## All-in-One Joystick: Circuit Cellar march 2012

For this project I wrote custom COG drivers to emulate the video and input hardware of the arcade classic Space Invaders. I wrote an 8080 interpreter to play the original SI code from an SD card. I used an existing SID chip driver for the sound (the original SI game used analog sound circuitry). I spun a circuit board to replace the board inside an Atari all-in-one joystick.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%207_53_43.png)

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%207_54_24.png)

# The Snap Midi Project

For this project I spun a custom board that docked a Synapse RF engine to a propeller chip via the RF engine's UART. I call this board the "octo" board because it is octagonal.
The board allows the RF engine to reset the propeller and talk to its UART bootloader on power-up to reprogram the propeller over the air.

I used the existing UART driver in the propeller library. I used an existing synthesizer object to play MIDI notes on selectable instruments.
I used an existing playstation-2 controller cog to read inputs from a guitar-hero controller.
The custom board has the SD card hardware, but does not currently use it.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%207_56_24.png)

There are several ways to connect the propeller to the RF engine. In this project I used the UART, but the propeller has library objects for SPI and I2C. You might consider an "interrupt" line from the propeller to tell the master engine it as data to pull. You can also create your own custom interface with many GPIO pins.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%207_56_54.png)

# Programming the Propeller Over the Air

Synapse engines are good at serial-to-air-to-serial applications. They have "transparent" data modes built in. I connected my FTDI dongle to an engine and wrote code to watch the DTR line, which the propeller programmer uses to reset the chip. I modified the RF engine code on the octo board to pass this reset signal along to the attached propeller.
The free parallax IDE tool drives the serial port at 115200, which is a little fast for the RF engine to keep up with. I used the free python tool "BST", which allows the rate to be cranked down to a reliable level.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%207_58_46.png)

The propeller uses a 3-bit self-clocking protocol to program the propeller. A much faster way is to write your own code uploader into your application. In my project I used a MIDI "meta" event to carry the new firmware to the propeller.
The propeller uses a 32K serial EEPROM to load the RAM on startup. I used a 64K EEPROM, which allowed by "upload" code to fill the EEPROM as the data arrives. If the checksum is valid the the code is copied from the upper half to the lower half. This allows the code to reject uploads if packets get lost (common with the RF engine).

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_1_45.png)

# The MIDI Pipe

Originally I packed the octo board, battery, speaker, and amplifier into a PVC housing (shown below).
![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_2_25.png)

# Generic Module

I wanted to use the octo boards more generically. I changed to a tupperware container that holds all the components and a 3.5 mm audio jack for what ever powered-speaker I wanted to use. I ended up buying a couple of different kinds of generic amps from Walmart.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_3_17.png)

# Lunch and Learn Configuration

For the lunch and learn I spread 8 different modules around the room. The main module in the front of the room used a PC powered speaker system. This module also included the guitar-hero interface (see below).
The other modules used battery powered speakers. I programmed each module to listen to a different set of MIDI voices and to play the notes for that voice with different instruments.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_4_5.png)

# I used a snapconnect application to stream MIDI notes over the air to all the modules. 

I used a text-to-MIDI program to create the music for the 12 Days of Christmas. Each voice came out of a different speaker.
The snapconnect application also monitored a MIDI keyboard and sent those notes over the air. You could play the keyboard across the instruments around the room.

The guitar-hero controller also broadcast MIDI notes over the air. You could play the guitar hero guitar to speakers around the room.

# Future Use

Ultimately I want to augment the snapconnect application with a web interface and replace my PC with a Raspberry Pi. The web interface would allow you to pick MIDI files to play. It would allow you to map speakers and channels and voices.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_4_55.png)

# Code Modules

The SeriapProp.py runs on the octo board. It relays serial MIDI notes to the propeller chip through the UART. It also resets the propeller chip when requested.

The SerialMIDI.spin run on the octo board. It listens for serial MIDI commands from the network and plays them through an attached speaker. The code also allows for firmware uploads through MIDI meta events.

https://github.com/topherCantrell/snap/blob/master/SnapMidi/snappyImages/SerialProp.py

https://github.com/topherCantrell/snap/blob/master/SnapMidi/spin/SerialMIDI.spin

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_14_21.png)

The SerialToAir.py connects to a FTDI chip and sends data from the serial cable over the air to the octo board. This essentially replaces a USB cable with two snap engines. The FTDI chip pulses the DTR signal very quickly. I had to use a capacitor to stretch it out for detection.

https://github.com/topherCantrell/snap/blob/master/SnapMidi/portal/snappyImages/SerialToAir.py

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_14_50.png)

The OTALoader.py uses the python uploader module from the propeller BST tool to load propeller firmware over the air. This uses the 3-bit self-clocking protocol, and it is very slow. But it does program the engine no matter what code is running on the propeller.

https://github.com/topherCantrell/snap/blob/master/SnapMidi/snapmidi/propupload/OTALoader.py

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_15_40.png)

The MidiPropLoader.py module uploads firmware to the octo board using the MIDI meta event. This requires that the SerialMIDI.spin code is running in the propeller. Otherwise you must use the OTALoader.py above.

https://github.com/topherCantrell/snap/blob/master/SnapMidi/snapmidi/MidiPropLoader.py

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_16_3.png)

The SetMidiChannels.py snapconnect application configures the list of "listened to channels" for a target octo board.

https://github.com/topherCantrell/snap/blob/master/SnapMidi/snapmidi/SetMidiChannels.py

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_16_24.png)

The MidiPlayer.py is a snapconnect application that streams a MIDI file over the air to any and all listening octo boards.

https://github.com/topherCantrell/snap/blob/master/SnapMidi/snapmidi/MidiPlayer.py

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_16_43.png)

The MusicParser.py module reads my own custom music-description syntax and creates a MIDI file that can be streamed over the air to the octo boards.

https://github.com/topherCantrell/snap/blob/master/SnapMidi/snapmidi/MusicParser.py

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_17_8.png)

The MidiDiss.py module converts an existing MIDI file into a text representation that can be tweaked and sent back through the MusicParser to make another MIDI file. Use this process to tweak the voices and instruments in a given file.

https://github.com/topherCantrell/snap/blob/master/SnapMidi/snapmidi/MidiDiss.py

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_18_27.png)

The AKAIMapper.py module is part of the MIDI player. It maps input events from the AKAI keyboard to midi notes to be plated over the air. The current algorithm spreads the notes across all the octo boards using a modulo function on the MIDI note number.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_19_0.png)

The playstation 2 controller uses a bidirectional serial shifting protocol with several control lines. This protocol is well documented on the web. The biggest problem is getting the physical connection between the controller and the microprocessor.
I used an SD card breakout board and a female playstation controller connector to bridge the gap. The propeller bit-bangs the pins on the SD card connector to talk to the SD card. I programmed it to bit bang the playstation 2 controller logic instead.
The tricky part is mapping controller inputs to MIDI notes. I thought about using a trumpet-valve scheme since I play trumpet. In the end I picked an octave in the middle of the MIDI range and mapped the buttons as a binary number offset for the note within the octave.

![](https://github.com/topherCantrell/snap/blob/master/SnapMidi/art/image2015-3-5%208_19_57.png)
