CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000
  
  Left            = 10  ' Audio Out pins
  Right           = 11

OBJ
    synth   : "pm_synth_20"
    PST     : "Parallax Serial Terminal"
  
PUB Main    | c, num, key,chan, vel

  ' Give the user time to switch from the Propeller Tool to the
  ' Serial Termial
  ' PauseMSec(2000)

  PST.StartRxTx (31, 30, 0, 57600)
  synth.start(Left,Right,2)

  synth.noteOn(69,0,128) ' MIDI note 69 (A440) on channel 0 velocity 64
  PauseMSec(10)
  synth.allOff

  repeat
    c := PST.CharIn
    case c
      "N" :
            key := PST.CharIn
            chan := PST.CharIn
            vel := PST.CharIn
            synth.noteOn(key,chan,vel)

      "F" :
            key := PST.CharIn
            chan := PST.CharIn
            synth.noteOff(key,chan)

      "P" :
            num := PST.CharIn
            chan := PST.CharIn
            synth.prgChange(num,chan)

      "V" :
            num := PST.CharIn
            chan := PST.CharIn
            synth.volContr(num,chan)

      "A" :
            num := PST.CharIn
            chan := PST.CharIn
            synth.panContr(num,chan)

      "X" :
            synth.allOff
      "T" :
            synth.noteOn(69,0,128)
      
                            
PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)
