CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000
  
  Left            = 10  ' Audio Out pins
  Right           = 11

OBJ
    synth   : "pm_synth_20"
    PST     : "Parallax Serial Terminal"
    eeprom  : "Propeller EEprom"

var                                 
  byte firstChannel
  byte channelCount 
        
PUB Main | com,chan, key,vel , lastChannel
    
  ' Give the user time to switch from the Propeller Tool to the
  ' Serial Termial
  ' PauseMSec(2000)

  ' This player can listen to several channels at once, but the
  ' channel numbers must be contiguous. When built each player
  ' is set to respond to ALL channels.

  ' Every player listes to a MIDI system-exclusive command to set
  ' these channel-parameters in EEPROM. Since everyone listens you
  ' must either power them on one at a time or target the specific
  ' player's serial stream.

  ' Read the channel specs from EEPROM
  eeprom.ToRam(@firstChannel, @firstChannel+1, $7FFE)  
  lastChannel :=  15
  if channelCount > 0
    lastChannel := firstChannel+channelCount-1                          

  ' Start listening for serial MIDI
  PST.StartRxTx (31, 30, 0, 57600)
  synth.start(Left,Right,2)
  
  ' Audible that we are running
  synth.noteOn(60,0,127)
  'synth.noteOn(64,0,127)
  'synth.noteOn(67,0,127)
  'synth.noteOn(69,0,128) ' MIDI note 69 (A440) on channel 0 velocity 128
  PauseMSec(10)
  synth.allOff

  ' $8x KK VV     Note-off      KEY   VELOCITY
  ' $9x KK VV     Note-on       KEY   VELOCITY
  ' $Ax KK TT     After-touch   KEY   TOUCH
  ' $Bx CC VV     Controller    NUM   VALUE (see breakdown)
  '   $Bx 07 VV   Volume        VALUE (0-127)
  ' $Cx PP        Patch         PATCH
  ' $Dx PP        Pressure      PRES
  ' $Ex BB BB        Pitch-blend   BLEND BLEND
  '
  ' $F0 7D ss cc F7 Set channel-parameters ss=start(0-15) cc=count(1-16)  
   
  repeat
    ' We have to eat the serial bytes even if they are not for us
    com := PST.CharIn
    chan := com & $0F   ' Lower nibble    
    com := com >> 4     ' Upper nibble
         
    ' Any Fx except F0 gets dropped
    ' Anything less than 80 gets dropped
    
    if com==$F and chan==0
      key := PST.CharIn ' The 7D (development ... us)
      if key==$7D
        firstChannel := PST.CharIn ' first
        channelCount := PST.CharIn ' last
        eeprom.FromRam(@firstChannel, @firstChannel+1, $7FFE)
        lastChannel := 15
        if channelCount > 0
          lastChannel := firstChannel+channelCount-1 
      repeat while (key<> $F7)
        key := PST.CharIn
    else       
      case com     
        $8 : ' 2 bytes    
          key := PST.CharIn
          vel := PST.CharIn
          if chan=>firstChannel and chan=<lastChannel 
            synth.noteOff(key,chan-firstChannel)
        $9 : ' 2 bytes                        
          key := PST.CharIn
          vel := PST.CharIn            
          if ((chan=>firstChannel) and (chan=<lastChannel))             
            if vel==0 ' MIDI allows vel=0 to mean note off
              synth.noteOff(key,chan-firstChannel)
            else
              synth.noteOn(key,chan-firstChannel,vel)           
        $A : ' 2 bytes
          key := PST.CharIn
          vel := PST.CharIn
        $B : ' 2 bytes
          key := PST.CharIn
          vel := PST.CharIn
          if key== 7
            if chan=>firstChannel and chan=<lastChannel 
              synth.volContr(vel*2,chan-firstChannel)
        $C : ' 1 byte
          key := PST.CharIn
          if chan=>firstChannel and chan=<lastChannel 
            synth.prgChange(key,chan-firstChannel)
        $D : ' 1 byte
          key := PST.CharIn
        $E : ' 2 bytes
          key := PST.CharIn
          vel := PST.CharIn      

PUB programEEPROM
' Must be done in a COG since entire EEPROM is being replaced
                            
PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)