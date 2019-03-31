from synapse.switchboard import *

PORTAL_ADDR="\x00\x00\x01"

@setHook(HOOK_STARTUP)
def _onBoot():
    initUart(0, 57600)
    flowControl(0, False)
    stdinMode(1, False)   # Char mode, no echo 
    crossConnect(DS_UART0, DS_STDIO)
        
@setHook(HOOK_STDIN)
def _getInput(data):
    rpc(PORTAL_ADDR , "logEvent", data)    
    
def sendByte(b):        
    print (chr)(b&255),