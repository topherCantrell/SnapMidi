import pygame.midi
from snapconnect import snap

pygame.init()
pygame.midi.init() 

comm = snap.Snap()
comm.open_serial(snap.SERIAL_TYPE_SNAPSTICK100, 0)

inp = pygame.midi.Input(1)

bells = [
         
         #'\x04\x6D\xC2', # Pipe1  OK
         #'\x04\x6D\xBA', # Pipe2  OK
         #'\x03\xAC\x26', # Pipe3  Sticky switch
         '\x03\xC4\x2D', # Pipe4  Sticky switch
         '\x00\x63\x33', # Pipe5  OK
         #'\x04\x00\x4A', # Pipe6  OK
         #'\x00\x81\x77', # Pipe7
         #'\x04\xC7\x42', # Pipe8
             
        ]
 
while True:
    comm.poll()
    if inp.poll():
        events = inp.read(1000)        
        for event in events:      
            print event[0]        
            r = ""
            for x in range(0,len(event[0])):
                r = r + chr(event[0][x])
            addr = bells[event[0][1]%len(bells)]
            comm.data_mode(addr,r)
            
            