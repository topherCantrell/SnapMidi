from synapse.switchboard import * 

pinValue = False

@setHook(HOOK_STARTUP)
def _onBoot():    
    global pinValue
    setPinDir(0, False)
    setPinPullup(0, True)
        
    initUart(0, 57600)
    flowControl(0, False)
    mcastSerial(1,2)
    
    crossConnect(DS_UART0, DS_TRANSPARENT)    

@setHook(HOOK_1MS)
def _oneMSTick():
    global pinValue
    v = readPin(0)
    if v!=pinValue:
        pinValue = v
        if pinValue == False:
            mcastRpc(1,1,'resetPropeller',True)            