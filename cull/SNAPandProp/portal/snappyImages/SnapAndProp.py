from synapse.switchboard import *
from synapse.platforms import *

@setHook(HOOK_STARTUP)
def _onBoot():
    
    setPinDir(GPIO_5, True)
    writePin(GPIO_5,True) # Release the propeller's reset
    
    initUart(0, 19200) # Propeller talks at this rate
    flowControl(0, False)  
    stdinMode(1, False)
      
    crossConnect(DS_UART0, DS_TRANSPARENT)
    ucastSerial('\x00\x00\xFF')
    
    #crossConnect(DS_STDIO, DS_TRANSPARENT)
    
@setHook(HOOK_STDIN)
def onInput(data):
    rpc('\x00\x00\x01','logEvent',data)
    
    
    
        
