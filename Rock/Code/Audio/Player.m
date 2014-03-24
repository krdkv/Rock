//
//  Player.m
//  Rock
//
//  Created by Nick on 23/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "Player.h"
#import "AudioSettings.h"
#import "AudioSampler.h"

@interface Player() {
    Pulse * _pulse;
    AudioSampler * _sampler;
}

@end

@implementation Player

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pulse = [[Pulse alloc] init];
        _pulse.delegate = self;
        
        
        _sampler = [[AudioSampler alloc] init];
        
        
        [_sampler setupOnComplete:nil];
    }
    return self;
}

- (void) start {
    [_pulse start];
}

static int barNumber = -1;
static int barCycle = 4;
static int startNote = 28;

- (void) tickWithNumber:(NSInteger)tick {

    if ( tick == 0 ) {
        barNumber++;
        if ( barNumber == barCycle ) {
            barNumber = 0;
            startNote = [@[@28, @33, @35][arc4random()%3] intValue];
        }
    }
    
    if ( barNumber == 0 && tick == 0 ) {
        [_sampler sendNoteOnToInstrument:0 midiKey:startNote velocity:70];
    }
    
    if ( barNumber == 0 && tick == 16 ) {
        [_sampler sendNoteOnToInstrument:0 midiKey:startNote velocity:70];
    }
    
    if ( barNumber == 1 && tick == 0 ) {
        [_sampler sendNoteOnToInstrument:0 midiKey:startNote velocity:70];
    }
    
    if ( barNumber == 1 && tick == 16 ) {
        [_sampler sendNoteOffToInstrument:0 midiKey:startNote];
    }
    
    if ( barNumber == 2 && tick == 16 ) {
        [_sampler sendNoteOnToInstrument:0 midiKey:startNote+7 velocity:80];
    }
    
    if ( barNumber == 3 && tick == 0 ) {
        [_sampler sendNoteOffToInstrument:0 midiKey:startNote+7];
    }
    
    if ( barNumber == 3 && tick == 16 ) {
        [_sampler sendNoteOnToInstrument:0 midiKey:startNote+3 velocity:80];
    }
    
    if ( barNumber == 3 && tick == 31 ) {
        [_sampler sendNoteOffToInstrument:0 midiKey:startNote+3];
    }
}

- (void) setTempo:(NSInteger)tempo {
    [_pulse setTempo:tempo];
}

@end
