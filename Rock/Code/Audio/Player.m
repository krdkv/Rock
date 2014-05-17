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

#define kPopularHarmonies @{ @0.273 : @[@5, @7, @0], @0.226 : @[@7, @5, @0], @0.113: @[@10, @5, @0], @0.09 : @[@9, @5, @0], @0.079: @[@10, @8, @0], @0.0512: @[@3, @8, @0], @0.048: @[@2, @7, @0], @0.046: @[@8, @10, @0], @0.032: @[@7, @9, @0], @0.03: @[@5, @10, @0] }

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _pulse = [[Pulse alloc] init];
        _pulse.delegate = self;
        
        _buffer = [[NoteBuffer alloc] init];
        
        NSArray * loopsArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Loops" ofType:@"plist"]];
        
        _availableForSolo = @[@40, @42, @44, @45, @47, @48, @50];
        
        NSString * bassBar, *drumsBar;
        
        for ( int BIG = 0; BIG < 24; ++BIG ) {
            
            int shift = 0;
            
            NSArray * harmony = [kPopularHarmonies allValues][0];//[arc4random()%kPopularHarmonies.allValues.count];
            
            if ( ! drumsBar || arc4random()%5 == 1 ) {
                for ( ;; ) {
                    int index = arc4random()%loopsArray.count;
                    NSDictionary * loop = loopsArray[index];
                    if ( [loop[@"instrument"] isEqualToString:@"b"] ) {
                        continue;
                    }
                    drumsBar = loop[@"notes"];
                    break;
                }
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
                
                if ( offset >= 0 && offset < 16 ) {
                    offset += [harmony[0] intValue];
                } else if ( offset >= 16 && offset < 32 ) {
                    offset += [harmony[1] intValue];
                }
                
                [_buffer addNoteForInstrument:0 note:(key+shift-12) velocity:50+100+50+arc4random()%50 offset:offset + BIG * (4*32) duration:duration];
            }
            
            int drumPossibleShift = [@[@0, @48, @24][arc4random()%3] intValue];
            
            notes = [drumsBar componentsSeparatedByString:@" "];
            for ( int j = 0; j < notes.count; ++j ) {
                if ([notes[j] length] == 0 ) {
                    continue;
                }
                NSArray * components = [notes[j] componentsSeparatedByString:@","];
                int key = [components[0] intValue];
                int offset = [components[1] intValue];
                int duration = [components[2] intValue];
                [_buffer addNoteForInstrument:1 note:(key-12+drumPossibleShift) velocity:50+30+60+arc4random()%40 offset:offset + BIG * (4*32) duration:100];
            }
        }
    }
    return self;
}

static int velocity = 80;
static BOOL down = false;

- (void) start {
    [_pulse start];
}

- (void) stop {
    
}

- (void) setIntensity:(CGFloat)intensity
       andColorsArray:(NSArray*)colorsArray {
    
}

- (void) setEffectColorForInstrument:(int)instrument
                               color:(UIColor*)color {
    
}

- (void) playSoloWithTilt:(CGFloat)tilt {
    
}

- (void) tickWithNumber:(int)tick {
    [_buffer onTick:tick];
}

- (void) setTempo:(int)tempo {
    [_pulse setTempo:tempo];
}

static int lastKey = -1;

- (void) playSolo:(CGPoint)point {
    
    int index = point.x / (320.f / _availableForSolo.count);
    int newKey = 32 + arc4random()%20;//[_availableForSolo[index] intValue];
    
    if ( newKey == lastKey ) {
        return;
    }
    
    if ( lastKey != -1 ) {
//        [_buffer stopNoteForInstrument:2 note:lastKey];
    }

    lastKey = newKey;
    [_buffer addNoteForInstrument:2 note:newKey velocity:120 offset:0 duration:16];
}

- (void)setPitch:(int)pitch {
    [_buffer setPitch:pitch];
}

@end
