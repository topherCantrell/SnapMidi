from synapse.switchboard import *

@setHook(HOOK_STARTUP)
def _onBoot():    
    initUart(0, 57600) 
    flowControl(0, False)    
    ucastSerial('\x05\x82\x22')
    uniConnect(DS_TRANSPARENT, DS_UART0)
    
    # Testing on this side 
    #stdinMode(1, False)
    #crossConnect(DS_UART0, DS_STDIO)
    
@setHook(HOOK_STDIN)
def _getInput(data):
    rpc('\x00\x00\x01', 'logEvent', 'To stuff '+data)
    