from synapse.switchboard import *

PORTAL_ADDR="\x00\x00\x01"

@setHook(HOOK_STARTUP)
def _onBoot():    
    initUart(0, 57600)
    flowControl(0, False)
    writePin(5,True) # Release the propeller's reset
    stdinMode(1, False)   # Char mode, no echo 
    crossConnect(DS_UART0, DS_STDIO)
            
@setHook(HOOK_STDIN)
def _getInput(data):
    rpc(PORTAL_ADDR , "logEvent", data)    
    
def sendByte(b):        
    print (chr)(b&255),
    
def allOff():
    sendByte(0x58) # 'X'
    
def noteOn(key,channel,velocity):
    sendByte(0x4E) # 'N'
    sendByte(key)
    sendByte(channel)
    sendByte(velocity)
    
def noteOff(key,channel):
    sendByte(0x46) # 'F'
    sendByte(key)
    sendByte(channel)
    
def programChange(num,channel):
    sendByte(0x50) #'P'
    sendByte(num)
    sendByte(channel)
    
def volumeControl(vol,channel):
    sendByte('P')
    sendByte(vol)
    sendByte(channel)
    
def panControl(pan,channel):
    sendByte('A')
    sendByte(pan)
    sendByte(channel)
    
def test():              
    noteOn(60,0,128)
    noteOn(64,1,128)
    noteOn(67,2,128)