//
//  Player.m
//  Rock
//
//  Created by Nick on 23/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "Player.h"
#import "AudioSettings.h"
#import "NoteBuffer.h"

@interface Player() {
    Pulse * _pulse;
    NoteBuffer * _buffer;
}

@end

@implementation Player

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pulse = [[Pulse alloc] init];
        _pulse.delegate = self;
        
        _buffer = [[NoteBuffer alloc] init];
    }
    return self;
}

- (void) start {
    [_pulse start];
}

static int barNumber = -1;
static int barCycle = 20;
static int startNote = 28;

- (void) tickWithNumber:(int)tick {
    
    [_buffer onTick:tick];
    
    if ( tick == 0 ) {
        barNumber++;
        if ( barNumber == barCycle ) {
            barNumber = 0;
            startNote = [@[@28, @33, @35][arc4random()%3] intValue];
        }
    }
    
    if ( tick % 18 == 0 ) {
        int note = [@[@24, @25, @26, @30, @31, @34, @35, @37, @39][arc4random()%9] intValue];
        int octave = arc4random()%2;
        if ( octave > 0 ) {
            note += 24 * octave;
        }
        [_buffer addNoteForInstrument:1 note:note velocity:60+arc4random()%100 offset:0 duration:100];
    }
    

//    if ( barNumber == 0 && tick == 0 ) {
//        [_buffer addNoteForInstrument:0 note:startNote velocity:70 + arc4random()%20 offset:0 duration:32];
//        [_buffer addNoteForInstrument:0 note:startNote velocity:70+arc4random()%20 offset:16 duration:32];
//    }
//    
//    if ( barNumber == 1 && tick == 0  ) {
//        [_buffer addNoteForInstrument:0 note:startNote velocity:70+arc4random()%20 offset:0 duration:16];
//    }
//    
//    if ( barNumber == 2 && tick == 0 ) {
//        [_buffer addNoteForInstrument:0 note:startNote+7 velocity:70+arc4random()%20 offset:16 duration:16];
//    }
//    
//    if ( barNumber == 3 && tick == 0 ) {
//        [_buffer addNoteForInstrument:0 note:startNote+3 velocity:70+arc4random()%20 offset:16 duration:14];
//    }
}

- (void) setTempo:(int)tempo {
    [_pulse setTempo:tempo];
}

@end
