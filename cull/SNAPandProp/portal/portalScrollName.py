from collections import defaultdict
from threading import Timer

characters = defaultdict(lambda: 0x0)
characters['a'] = 0x77
characters['b'] = 0x7c
characters['c'] = 0x39
characters['d'] = 0x5e
characters['e'] = 0x79
characters['f'] = 0x71
characters['g'] = 0x3d
characters['h'] = 0x76
characters['i'] = 0x06
characters['j'] = 0x1e
characters['k'] = 0x7210
characters['l'] = 0x38
characters['m'] = 0x3327
characters['n'] = 0x37
characters['o'] = 0x5c
characters['p'] = 0x73
characters['q'] = 0x67
characters['r'] = 0x50
characters['s'] = 0x6d
characters['t'] = 0x78
characters['u'] = 0x3e
characters['v'] = 0x1c
characters['w'] = 0x3c1e
characters['y'] = 0x6e
characters['z'] = 0x5b
characters['-'] = 0x4040

scrollString = "megan-"
counter = 0

def scroll():
    global counter
    positionInScrollString = counter%len(scrollString)
    currentCharacter = scrollString[positionInScrollString]
    multicastRpc(1, 2, 'SetSegments', characters[currentCharacter])
    counter += 1
    
    # Only let this scroll the name 5 times, Portal doesn't stop multi-threaded stuff when the program is changed
    if counter < 5*len(scrollString):
        global t
        t = Timer(1.0, scroll)
        t.start()

scroll()

