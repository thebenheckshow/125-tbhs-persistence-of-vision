
CON

_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000


DATA = 0
CLOCK = 1
LATCH = 2


VAR

  long LEDstack[50]

  long testData

  long display_memory[64]
  long parameterX


PUB Main | g

  spinTest2

  parameterX := @display_memory
  coginit(7, @Loader, @parameterX)

  g := 1
  
  repeat
 
    'testData := %10000000_11111111_00000000_00000001

    display_memory[0] := %10000000_11111111_00000000_00000001 
    display_memory[1] := %10000000_11111111_00000000_00000001 
    
    g <-= 1
    
    waitcnt((clkfreq / 5) + cnt)



  'coginit(7, driveLED, @LEDstack) 

  g := 1
  
  repeat
 
    'testData := %10000000_11111111_00000000_00000001

    testData := g

    g <-= 1
    
    waitcnt((clkfreq / 5) + cnt)




PUB spinTest

  repeat
  
    testData := %10101010_10101010_10101010_10101010

    driveLED
    
    testData := %10000001_10000001_10000001_10000001

    driveLED

    outa[Latch] := 1
    outa[Latch] := 0

    waitcnt(80_000_000 + cnt)

    testData := %10000001_10000001_10000001_10000001

    driveLED

    testData := %10101010_10101010_10101010_10101010    

    driveLED

    outa[Latch] := 1
    outa[Latch] := 0

    waitcnt(80_000_000 + cnt)



PUB spinTest2

  repeat
  
    driveSingle(%10000000)

    waitcnt(80_000_000 + cnt)

    repeat 700
    
      driveSingle(%11111111)
      driveSingle(0) 
      driveSingle(0)   




PUB driveLED | temp

  dira[DATA] := 1
  dira[CLOCK] := 1    
  dira[LATCH] := 1   


  temp := testData  
  
  repeat 8
  
    outa[Data] := temp
    
    outa[CLock] := 1  
    outa[Clock] := 0

    temp ->= 1



PUB driveSingle(theData) | temp

  dira[DATA] := 1
  dira[CLOCK] := 1    
  dira[LATCH] := 1   
   
  repeat 8
  
    outa[Data] := theData
    
    outa[CLock] := 1  
    outa[Clock] := 0

    theData >>= 1

  outa[Latch] := 1
  outa[Latch] := 0


DAT     org                                             'New version that uses all internal COG RAM

Loader
        rdlong memstart, par                            'Get location of the beginning of screen memory



        mov cdataML, #1
        mov cclockML, #3
        mov clatchML, #5  
        
        mov zilch, #0                                   'Set this to a Zero
        
        or dira, cdataML                                'Set all ouput pins to OUT direction (=1)
        or dira, cclockML
        or dira, clatchML

DoFrame
        mov pointer, memstart                           'Set pointer to start of frames          
        mov row, #16                                    'Reset row counter

DoRow
        mov column, #2                                  'Number of longs per row

DoColumns
        mov toDoPixels, #32                             'Number of pixels to do                
        rdlong datatemp, pointer                        'Load Datatemp with the current byte of screen data
        
DoByteLoop
        mov colormask, datatemp                         'Make a copy of Datatemp
        and colormask, #1 wc                            'AND it with the LSB

        muxc outa, cdataML                              'Assert serial output bit
        muxz outa, cclockML                             'Pulse dot clock
        muxnz outa, cclockML

        shr datatemp, #1                                'Shift Datatemp to the right
        
        djnz toDoPixels, #DoByteLoop                    'Repeat until we've done all 32 bits
        
        add pointer, #4                                 'Increment memory pointer
        djnz column, #DoColumns                         'Keep going until out of columns
 
RowEnd

        cmp zilch, #0 wz                                'Latch the data onto the registers
        muxz outa, clatchML
        muxnz outa, clatchML

        djnz row, #DoRow                                'Repeat until we've done all 32 rows

FrameEnd

        jmp #DoFrame                                    'Draw Color 2 frame again


'Set pin #'s                 Prop Pin #         DMD SIGNAL:   DMD PIN #:        Remember to also tie the DMD and Propeller's ground signals together!

enableML      res       1                            'DMD Enable   (pin 1)    
rdataML       res       1                           'Row Data     (pin 3)  
rclockML      res       1                           'Row Clock    (pin 5) 
clatchML      res       1                          'Column Latch (pin 7)  
cclockML      res       1                           'Dot Clock   (pin 9)  
cdataML       res       1                           'Serial Data (pin 11)                  

'Variables

rate          long      20_000

WaitCount     res       1    
row           res       1                       'Which row we are on (0-31)
column        res       1                       'Which column we are on (0-7)
datatemp      res       1                       'Used for temp data storage and bitwise operations
memstart      res       1                       'Start of screen memory
pointer       res       1                       'Current location in screen memory
pwmcount      res       1                       'Which cycle of PWM we are on
colormask     res       1                       'Used to chop up Datatemp into grayscale levels
doublecount   res       1                       'Counter to run "Frame 3" of the PWM twice to make it more distinct
toDoPixels    res       1                       'Counts how many bits need to be shifted out of current long data position

zilch         res       1                       'The number 0. All of my salesmen are ZEROS!!!