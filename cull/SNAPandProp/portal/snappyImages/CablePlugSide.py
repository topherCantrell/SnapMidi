from synapse.platforms import *
from synapse.switchboard import *

pinState = False

@setHook(HOOK_STARTUP)
def startupEvent():
    
    initUart(0, 19200) 
    flowControl(0, False)
    stdinMode(1, False)
    crossConnect(DS_UART0, DS_TRANSPARENT)        
    ucastSerial('\x00\x63\x33')
    
    #crossConnect(DS_UART0, DS_STDIO)
    
    setPinDir(GPIO_1,False)
    monitorPin(GPIO_1,True)

@setHook(HOOK_GPIN)
def pinChg(pinNum,isSet):
    rpc('\x00\x00\x01','logEvent',"Got Milk "+str(pinNum)+" "+str(isSet))
    rpc('\x00\x63\x33','writePin',1,isSet)
     
@setHook(HOOK_STDIN)
def onInput(data):
    rpc('\x00\x00\x01','logEvent',data)

'''        
def setTestPin(state):
    writePin(GPIO_18,state) 
    
def printString(mes):
    print mes
    
@setHook(HOOK_10MS)
def timer10msEvent(currentMs):
    global pinState
    v = readPin(1)
    if v!= pinState:
        pinState = v
        mes = "Transistioned to "+str(pinState)
        rpc('\x00\x00\x01','logEvent',mes)

   
def doEvery5Second():
    mcastRpc(1,4,'rpcFunctionA',1)

@setHook(HOOK_100MS)
def timer100msEvent(currentMs):
    global secondCounter

    secondCounter += 1
    if secondCounter >= 50:
        doEvery5Second()
        secondCounter = 0  
'''