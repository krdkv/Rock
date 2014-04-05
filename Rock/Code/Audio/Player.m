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
        
        for ( int i = 0; i < 100; ++i ) {
            NSString * firstBar = [drumBar componentsSeparatedByString:@"|"][0];
            NSArray * notes = [firstBar componentsSeparatedByString:@"-"];
            for ( NSString * note in notes ) {
                if ( note.length == 0 ) {
                    continue;
                }
                NSArray * components = [note componentsSeparatedByString:@","];
                int key = [components[0] intValue];
                int offset = [components[1] intValue];
                [_buffer addNoteForInstrument:1 note:key-12 velocity:70+arc4random()%30 offset:offset + i * 32 duration:100];
            }
            
            firstBar = [drumBar componentsSeparatedByString:@"|"][1];
            notes = [firstBar componentsSeparatedByString:@"-"];
            for ( NSString * note in notes ) {
                if ( note.length == 0 ) {
                    continue;
                }
                NSArray * components = [note componentsSeparatedByString:@","];
                int key = [components[0] intValue];
                int offset = [components[1] intValue];
                [_buffer addNoteForInstrument:1 note:key-12 velocity:70+arc4random()%30 offset:offset + i * 64 duration:100];
            }
        }
    }
    return self;
}

- (void) start {
    [_pulse start];
}

static NSString * drumBar = @"36,0,4-42,4,4-36,8,4-38,8,4-42,12,4-36,16,4-42,20,4-36,24,4-38,24,4-42,28,4-|36,32,4-42,36,4-36,40,4-38,40,4-42,44,4-36,48,2-38,50,2-36,52,5-";

static int barIndex = 0;

- (void) tickWithNumber:(int)tick {
    
    if ( tick == kNumberOfTicksPerBar - 1 ) {
        barIndex = barIndex == 0 ? 1 : 0;
    }
    
//    if ( tick % 8 == 4 ) {
//        [_buffer addNoteForInstrument:0 note:28+arc4random()%36 velocity:70+arc4random()%50 offset:0 duration:8+arc4random()%24];
//    }
    
    [_buffer onTick:tick];
}

- (void) setTempo:(int)tempo {
    [_pulse setTempo:tempo];
}

@end
