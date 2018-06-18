SNAPMidi Hardware
========

## Guitar Hero Interface

Sparkfun makes a micro-SD breakout board:

[https://www.sparkfun.com/products/9419](https://www.sparkfun.com/products/9419)

The propeller just bit-bangs the four SD card lines. The same four lines can be  bit-banged differently to talk to the 
Guitar Hero controller. The breakout card provides a plug-in physical interface for the controller. 

The playstation controller requires a pullup resistor on the input-to-micro line, which is already on the propeller board.

![](https://github.com/topherCantrell/snapmidi/blob/master/hardware/HeroToSD2.jpg)

I cut a playstation controller extension cable and soldered the wires to the breakout board as shown below. The controller 
needs four signal lines plus power and ground (6 wires). The optional signals (vibrarion-motor-power and ACK) are not used. 
But I soldered the gray and green wires to unused lines of the SD slot to give the connection extra strength.

The propeller chip is shown on the left. The SD card slot is shown on the right. The red and blue labels list the
connected playstation controller wires.

![](https://github.com/topherCantrell/snapmidi/blob/master/hardware/HeroToSD.jpg)
