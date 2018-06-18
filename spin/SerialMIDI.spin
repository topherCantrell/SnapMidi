CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000

  ' Audio Out pins  
  Left            = 10  ' 4 for demo board 
  Right           = -1  ' -1 For mono

OBJ
    synth   : "pm_synth_20"
    PST     : "Parallax Serial Terminal"
    eeprom  : "Propeller EEprom"
    PS2     : "PS2Controller"

var                                 
  word channelMask
  byte guitarStrum
  word guitarNote
        
PUB Main | com,chan,chanBits, key,vel,v,nd
    
  ' For debuggig: Give the user time to switch from the Propeller Tool to theSerial Termial
  ' PauseMSec(2000)

  guitarStrum := 0    ' Not strumming
  guitarNote := 65535 ' Not a note playing
  startPS2

  ' This player can listen to several midi channels at once. The list of active
  ' channels is kept in the last two bytes of EEPROM to survive power cycles.
  '
  ' Every player listens to a MIDI system-exclusive command to set the list of
  ' midi-channels. Either power up one unit at a time or send the serial command
  ' to just the target unit.

  ' Read the list of active MIDI channels from EEPROM
  eeprom.ToRam(@channelMask, @channelMask+1, $7FFE)
  if channelMask==0      ' Zero (uprogrammed) means ...
    channelMask := $FFFF ' ... ALL channels 
    
  ' Start listening for serial MIDI
  PST.StartRxTx (31, 30, 0, 57600)
  synth.start(Left,Right,2)
  
  ' Audible that we are running  
  signOnTone
  'foreverChord  
  
  ' Remember: we have to eat the serial bytes even if they are not for us

  com := $10 ' Impossible from the stream. This is the "search for first command" case.

  repeat
    if PST.RxCount>0
      handleSerialMIDI
    handleGuitar    

PUB handleSerialMIDI  | com,chan,chanBits, key,vel,v,nd  
        
    v := PST.CharIn         ' Next byte from the stream
    if v>$7F                ' This is a new command                            
      com := v >> 4         '   Mark the new command (upper nibble)
      chan := v & $0F       '   Lower nibble is channel
      chanBits := 1<< chan  '   Make bit mask 
      nd := PST.CharIn      '   Get the first data byte
    else                    ' This is a continuation of the last command
      nd := v               '   This is the first data byte of the continuation
            
    case com    
      $8 : ' $8x KK VV -> NoteOff: KEY VELOCITY
        ' key is in nd
        vel := PST.CharIn                                              
        if (chanBits&channelMask)<>0 
          synth.noteOff(nd,chan)
          
      $9 : ' $9x KK VV -> NoteOn: KEY VELOCITY
        ' key is in nd
        vel := PST.CharIn            
        if (chanBits&channelMask)<>0              
          if vel==0 ' MIDI allows vel=0 to mean note off
            synth.noteOff(nd,chan)
          else
            synth.noteOn(nd,chan,vel)
                       
      $A : ' $Ax KK TT -> AfterTouch: KEY TOUCH
        ' key is in nd
        vel := PST.CharIn
        
      $B : ' $Bx CC VV -> Controller: NUM VALUE (only handling the "volume" controller)
        ' num is in nd
        vel := PST.CharIn
        if nd== 7 ' $Bx 07 VV -> Volume: VALUE (0-127)
          if (chanBits&channelMask)<>0  
            synth.volContr(vel,chan) ' Controller takes 0..255, incoming 0..127
            
      $C : ' $Cx PP -> Patch: PATCH
        ' patch is in nd
        if (chanBits&channelMask)<>0  
          synth.prgChange(nd,chan)
          
      $D : ' $Dx PP -> Pressure: PRES
        ' pres is in nd (nothing more to read)
        
      $E : ' $Ex BB BB -> PitchBlend: BLEND BLENDs
        ' blend is in nd
        vel := PST.CharIn

      ' These are "System Exclusive Events". We should NOT get Meta Events (FF)
      $F : ' $F0 7D 00 ... F7 Set channel-parameters where "..." is the list of channels to include one byte each (0 - 15)
        ' id is in nd
        if nd==$7D   ' 7D is "development" ... us
          nd := PST.CharIn ' Command: 0 for channel, 1 for firmware
          if nd<>0
            downloadFirmware ' Reboots the unit. Does not return.
          channelMask := 0
          repeat
            nd := PST.CharIn ' next byte from the stream
            if nd==$F7       ' read to ...
              quit           ' ... F7
           channelMask := channelMask | (1<<(nd&$0F)) ' Should only be 16 bits
          if channelMask==0        ' All 0's mean ...
            channelMask := $FFFF   ' ... everything
          eeprom.FromRam(@channelMask, @channelMask+1, $7FFE) ' Store the new params in EEPROM
      
        else
         ' Consume (ignore) any other Fx command
         repeat while (nd<>$F7)
           key := PST.CharIn
           
      $10 :
      ' This is the beginning case when we are waiting for a command byte    

PUB signOnTone
  synth.noteOn(69,0,64) ' MIDI note 69 (A440) on channel 0 velocity 127
  PauseMSec(10)  
  synth.allOff

PUB uploadStartedTone
  synth.noteOn(82,0,64)
  PauseMSec(10)  
  synth.allOff

PUB uploadBad
  synth.noteOn(40,0,80)
  PauseMSec(1000)

PUB uploadGood
  synth.noteOn(80,0,80)
  synth.noteOn(82,0,80)
  PauseMSec(1000)

PUB foreverChord
  ' Audible that we are running  
  synth.noteOn(69,0,64) ' MIDI note 69 (A440) on channel 0 velocity 127
  synth.noteOn(71,0,64) ' MIDI note 69 (A440) on channel 0 velocity 127
  synth.noteOn(73,0,64) ' MIDI note 69 (A440) on channel 0 velocity 127
  repeat       

PUB downloadFirmware | ch, p, t
  ' F0 7D 01  cm cl ...
  '   cccc is the checksum

  uploadStartedTone ' Note that we are taking the data
  
  ch := (PST.CharIn<<8) | PST.CharIn    ' Checksum

  p := $4000               ' Starting here
  t := 0                   ' Start checksum
  repeat while p<>$8000    ' The entire download
    byte[p] := PST.CharIn  '   Next byte
    t := t + byte[p]       '   Checksum it
    t := t & $FFFF         '   Two byte checksum
    p := p + 1             '   Bump pointer
    
  if ch<>t                 ' Bad checksum. Do nothing.
    uploadBad
    reboot

  ' Write the block to serial ram
  eeprom.FromRam($4000, $7FFF, $0000)

  uploadGood
  reboot
                                                                                                           
PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)

PUB startPS2 | i, j, k, h
      
  ' A clock rate of 250KHz works for all the controllers I own including two
  ' different wireless GuitarHero controllers.
  
  PS2.start(24,250_000,100)  ' DAT is pin 24, use 250KHz data clock, poll at 100Hz 
        
  ' This is how to setup the command buffer byte by byte, start a command,
  ' and wait for the command to complete. This is the "long" way. The "short"
  ' way is use for remaining commands.

  ' Execute a standard "get values" command
  PS2.setLength(9)    
  PS2.setCommandByte( $1,0)  
  PS2.setCommandByte($42,1)  
  PS2.setCommandByte( $0,2)
  PS2.setCommandByte( $0,3)
  PS2.setCommandByte( $0,4)
  PS2.setCommandByte( $0,5)
  PS2.setCommandByte( $0,6)
  PS2.setCommandByte( $0,7)
  PS2.setCommandByte( $0,8)
  PS2.setControl(2)               ' Send command
  repeat while PS2.getControl<>0  ' Wait for response    

  ' The "short" way to talk to the driver is to use byte-arrays defined
  ' in the DAT section.  

  ' Put the controller in "escape" mode for configuration
  PS2.setCommandBytes(@escapeMode)
  PS2.executeAndWait

  ' Put the controller in analog mode
  PS2.setCommandBytes(@analogMode)
  PS2.executeAndWait

  ' Exit the excape (configuration) mode
  PS2.setCommandBytes(@exitEscape)
  PS2.executeAndWait
    
  ' Setup the command to be repeated in polling
  PS2.setCommandBytes(@pollCommand)

  ' Start the polling
  PS2.startPolling

CON
'     3          4
' XdXu_SXXs  OBRY_XXGT
'  o p t  e  rlee   ri
'  w   a  l  audl   el
'  n   r     ne l   et
'      t     g  o   n
'
HERO_DOWN   = %0100_0000__0000_0000
HERO_UP     = %0001_0000__0000_0000
HERO_START  = %0000_1000__0000_0000
HERO_SELECT = %0000_0001__0000_0000
'
HERO_ORANGE = %0000_0000__1000_0000
HERO_BLUE   = %0000_0000__0100_0000
HERO_RED    = %0000_0000__0010_0000
HERO_YELLOW = %0000_0000__0001_0000
HERO_GREEN  = %0000_0000__0000_0010
HERO_TILT   = %0000_0000__0000_0001
'
HERO_STRUM  = %0101_0000__0000_0000

PUB handleGuitar
  printValues

PUB printValues | i, nn
  i := PS2.getResponseByte(3)<<8
  i := i | PS2.getResponseByte(4)

  nn := 0
  if (i & HERO_TILT) == 0
    nn := nn + 32
  if (i & HERO_GREEN) == 0
    nn := nn + 16
  if (i & HERO_RED) == 0
    nn := nn + 8
  if (i & HERO_YELLOW) == 0
    nn := nn + 4
  if (i & HERO_BLUE) == 0
    nn := nn + 2
  if (i & HERO_ORANGE) == 0
    nn := nn + 1

  nn:=nn+60 ' Start at C in octave 5

  if ((i & HERO_DOWN)<>0) and ((i & HERO_UP)<>0)
    guitarStrum := 0

  if ((i & HERO_DOWN)==0) and (guitarStrum==0)
    guitarStrum := 1
    if (guitarNote<>65535)
      'PST.str(string("Note off: "))
      'PST.hex(guitarNote,2)      
      'PST.char(13)
      PST.char($80)        ' Note Off
      PST.char(guitarNote) ' Playing note
      PST.char(0)          ' Velocity
      guitarNote := 65535
    'PST.str(string("Note on: "))    
    'PST.hex(nn,2)
    'PST.char(13)
    guitarNote := nn
    PST.char($90)
    PST.char(guitarNote)
    PST.char(64)    

  if ((i & HERO_UP)==0) and (guitarStrum==0)
    guitarStrum := 1
    if guitarNote<>65535
      'PST.str(string("Note off: "))
      'PST.hex(guitarNote,2)      
      'PST.char(13)
      PST.char($80)
      PST.char(guitarNote)
      PST.char(0)
      guitarNote := 65535
 

DAT

' Command used to poll for values in the "main" loop
pollCommand     byte   9,   $1,$42,$0,$0,$0,$0,$0,$0,$0

' Command to put the controller in escape (configuration) mode
escapeMode      byte   5,   $1,$43,$0,$1,$0

' Command to put the controller in analog mode (must be in escape mode)
analogMode      byte   9,   $1,$44,$0,$1,$3,$0,$0,$0,$0

' Command to exit the escape mode
exitEscape      byte   9,   $1,$43,$0,$0,$5A,$5A,$5A,$5A,$5A