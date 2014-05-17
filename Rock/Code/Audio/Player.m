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
#import "TrackStructure.h"

@interface Player() {
    Pulse * _pulse;
    NoteBuffer * _buffer;
    TrackStructure * _trackStructure;
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
        
        _trackStructure = [[TrackStructure alloc] init];
        
        _overheadVolume = 0;
        
    }
    return self;
}

- (void) start {
    [_pulse start];
}

- (void) stop {
    [_pulse stop];
}

- (BOOL) isPlaying {
    return _pulse && [_pulse isPlaying];
}

- (void) setIntensity:(CGFloat)intensity
       andColorsArray:(NSArray*)colorsArray {
    
    [_pulse stop];
    
    [_trackStructure generateWithIntensity:intensity colors:colorsArray];
    [self fillBuffer];
}

- (void) fillBuffer {
    
    int currentBarOffset = 0;
    
    for ( NSDictionary * bassLoop in _trackStructure.bassLoops ) {
        
        NSInteger numberOfBars = [bassLoop[@"numberOfBars"] intValue];
        
        NSArray * notes = [bassLoop[@"notes"] componentsSeparatedByString:@" "];
        
        for ( NSString * note in notes ) {
            
            if (note.length == 0 ) {
                continue;
            }
            
            NSArray * noteParams = [note componentsSeparatedByString:@","];
            
            int key = [noteParams[0] intValue];
            int offset = [noteParams[1] intValue];
            int duration = [noteParams[2] intValue];
            int velocity = [noteParams[3] intValue];
            
            offset += currentBarOffset;                        
            
            int diff = [_trackStructure keyForTick:offset] - E1;
            
            key += diff;
            
            [_buffer addNoteForInstrument:kBass note:key velocity:(velocity + _overheadVolume) offset:offset duration:duration];
        }
        
        currentBarOffset += numberOfBars * 32;
    }
    
    currentBarOffset = 0;
    
    for ( NSDictionary * drumLoop in _trackStructure.drumLoops ) {
        
        NSInteger numberOfBars = [drumLoop[@"numberOfBars"] intValue];
        
        NSArray * notes = [drumLoop[@"notes"] componentsSeparatedByString:@" "];
        
        for ( NSString * note in notes ) {
            
            if (note.length == 0 ) {
                continue;
            }
            
            NSArray * noteParams = [note componentsSeparatedByString:@","];
            
            int key = [noteParams[0] intValue];
            int offset = [noteParams[1] intValue];
            int velocity = [noteParams[3] intValue];
            
            offset += currentBarOffset;
            
            [_buffer addNoteForInstrument:kDrums note:key-12 velocity:(velocity + _overheadVolume) offset:offset duration:100];
        }
        
        currentBarOffset += numberOfBars * 32;
    }
    
    
}

- (void) setEffectColorForInstrument:(int)instrument
                               color:(UIColor*)color {
    
    
    
    
    
}

- (void) tickWithNumber:(int)tick {
    [_buffer onTick:tick];
}

- (void) setTempo:(int)tempo {
    [_pulse setTempo:tempo];
}

static int soloNotes[7][7];

- (void) soloNoteOn:(int)x :(int)y {
    
    int key = [_trackStructure keyForX:x y:y offset:_pulse.globalTick];
    soloNotes[x][y] = key;
    
    [_buffer addNoteForInstrument:kGuitar note:key velocity:100+arc4random()%50+self.overheadVolume offset:0 duration:200];
}

- (void) soloNoteOff:(int)x :(int)y {
    [_buffer stopNoteForInstrument:kGuitar note:soloNotes[x][y]];
}

- (void) playSoloWithTilt:(CGFloat)tilt {
    
}

- (void)setPitch:(int)pitch {
    [_buffer setPitch:pitch];
}

@end
