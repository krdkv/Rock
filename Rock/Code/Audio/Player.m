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
    
    NSArray * _availableForSolo;
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
        
        
        NSArray * loopsArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Loops" ofType:@"plist"]];
        NSArray * shiftsArray = @[@5, @3, @(-4), @(-2), @5];
        
        _availableForSolo = @[@40, @42, @43, @45, @47, @48, @50];
        
        for ( int BIG = 0; BIG < 20; ++BIG ) {
            
            NSString * bassBar, *drumsBar;
            
            int shiftIndex = BIG % (shiftsArray.count);
            int shift = 0;
            
            for ( ;; ) {
                int index = arc4random()%loopsArray.count;
                NSDictionary * loop = loopsArray[index];
                if ( [loop[@"instrument"] isEqualToString:@"b"] ) {
                    continue;
                }
                drumsBar = loop[@"notes"];
                break;
            }
            
            for ( ;; ) {
                int index = arc4random()%loopsArray.count;
                NSDictionary * loop = loopsArray[index];
                if ( [loop[@"instrument"] isEqualToString:@"d"] ) {
                    continue;
                }
                bassBar = loop[@"notes"];
                break;
            }
            
            NSArray * notes = [bassBar componentsSeparatedByString:@" "];
            for ( int j = 0; j < notes.count; ++j ) {
                if ([notes[j] length] == 0 ) {
                    continue;
                }
                NSArray * components = [notes[j] componentsSeparatedByString:@","];
                int key = [components[0] intValue];
                int offset = [components[1] intValue];
                int duration = [components[2] intValue];
                if ( down ) {
                    velocity--;
                } else {
                    velocity++;
                }
                if ( velocity == 80 ) {
                    down = YES;
                } if ( velocity == 50 ) {
                    down = NO;
                }
                
                [_buffer addNoteForInstrument:0 note:(key+shift-12) velocity:140 offset:offset + BIG * (4*32) duration:duration];
            }
            
            notes = [drumsBar componentsSeparatedByString:@" "];
            for ( int j = 0; j < notes.count; ++j ) {
                if ([notes[j] length] == 0 ) {
                    continue;
                }
                NSArray * components = [notes[j] componentsSeparatedByString:@","];
                int key = [components[0] intValue];
                int offset = [components[1] intValue];
                int duration = [components[2] intValue];
                [_buffer addNoteForInstrument:1 note:key-12 velocity:120 offset:offset + BIG * (4*32) duration:100];
            }
        }
        
        

        
//        bars = [guitarBar componentsSeparatedByString:@"|"];
//        for ( int i = 0; i < bars.count; ++i ) {
//            NSArray * notes = [bars[i] componentsSeparatedByString:@"-"];
//            for ( int j = 0; j < notes.count; ++j ) {
//                if ([notes[j] length] == 0 ) {
//                    continue;
//                }
//                NSArray * components = [notes[j] componentsSeparatedByString:@","];
//                int key = [components[0] intValue];
//                int offset = [components[1] intValue];
//                int duration = [components[2] intValue];
//                int offsetDelta = 0;
//                [_buffer addNoteForInstrument:2 note:key velocity:velocity offset:(i * 32 + offset + offsetDelta) duration:(duration - offsetDelta)];
//            }
//        }
    }
    return self;
}

static int velocity = 80;
static BOOL down = false;

- (void) start {
    [_pulse start];
}

- (void) tickWithNumber:(int)tick {
    [_buffer onTick:tick];
}

- (void) setTempo:(int)tempo {
    [_pulse setTempo:tempo];
}

static int lastKey = -1;

- (void) playSolo:(CGPoint)point {
    
    [_buffer setPitch:1 + arc4random()%5];
    
    return;
    int index = point.x / (320.f / _availableForSolo.count);
    int newKey = [_availableForSolo[index] intValue];
    
    if ( newKey == lastKey ) {
        return;
    }
    
    if ( lastKey != -1 ) {
        [_buffer stopNoteForInstrument:2 note:lastKey];
    }

    lastKey = newKey;
    [_buffer addNoteForInstrument:2 note:newKey velocity:50 offset:0 duration:16];
}

- (void)setPitch:(int)pitch {
    [_buffer setPitch:pitch];
}

@end
