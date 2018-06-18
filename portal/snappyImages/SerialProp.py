from synapse.switchboard import * 

CONTROL_ADDR="\x00\x00\x01"

channelMask = 65535
description = 'SNAPNotes'

@setHook(HOOK_STARTUP)
def _onBoot():
    global channelMask, description
    initUart(0, 57600)            # UART0 at 57600
    flowControl(0, False)         # Character mode, no echo
    writePin(5,True)              # Release the propeller's reset
    ucastSerial(CONTROL_ADDR)     # Output goes back to controller
    
    crossConnect(DS_UART0, DS_TRANSPARENT)    
    
    description = loadNvParam(128)
    channelMask = loadNvParam(129)
    if description == None:
        description = 'SNAPNotes'
    if channelMask == None:
        channelMask = 65535
    
def resetPropeller():
    # Pulse pin 5 (reset) low for 1MS
    pulsePin(5,1,False)
    
def setControllerAddress(addr):
    global CONTROL_ADDR
    CONTROL_ADDR = addr
    ucastSerial(CONTROL_ADDR)
    
def getUnitDescription():
    global description
    return description

def getUnitChannels():
    global channelMask
    return channelMask

def setUnitDescription(desc):
    global description
    description = desc
    saveNvParam(128,description)
    
def setUnitChannels(chans):
    global channelMask
    channelMask = chans
    saveNvParam(129,channelMask)