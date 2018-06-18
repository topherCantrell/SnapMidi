import Loader

"""Program propeller over the air

This module uses the "Serial-Air Gateway" to program the propeller chip over the air.

The "Serial-Air Gateway" simply extends the COM serial port over the air, but at a greatly
reduced baud rate. The Loader (written by Remy Blank) sends the propellers 3-bit communication
protocol to program the propeller EEPROM.

This protocol is very verbose, and the process takes a long time. The RF communication path
is unreliable. It may take several attempts to completely program the chip.

This should be a "last ditch" effort to program the propeller. Ideally, the uploaded code
will include a self-programmer function that can use a more reliable uploader 
(like OTAPropLoader.py).

"""
 
def showProgress(msg):
    print msg

if __name__ == "__main__":
    Loader.upload("COM6","d:/workspaceee/snapnotesSNAP/spin/SerialMIDI.eeprom", 
                  eeprom=True, run=True, progress=showProgress )