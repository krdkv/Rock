//
//  ViewController.m
//  Rock
//
//  Created by Nick on 20/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "DebugViewController.h"
#import "AudioSampler.h"
#import "AudioSettings.h"
#import "DrumComposer.h"

@interface DebugViewController () {
    Pulse * _pulse;
    AudioSampler * _sampler;
    NSArray * _notes;
    
    int _intervalType;
    int _weakStrong;
    int _offset;
    CGFloat _intensity;
}

@end

@implementation DebugViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sampler = [[AudioSampler alloc] init];
    [_sampler setupOnComplete:nil];
        
    _pulse = [[Pulse alloc] init];
    
    [_pulse setDelegate:self];
    [_pulse start];
    
    
}

- (void) tickWithNumber:(int)tick {
    
    if ( tick == 0 ) {
        DrumComposer * composer = [[DrumComposer alloc] initWithNumberOfBars:1];
        
        int numberOfDrums = 6;
        
        for ( int i = 0; i < numberOfDrums; ++i ) {
            
            int drum = [kDrumKeys[arc4random()%kDrumKeys.count] intValue];
            
            [composer addDrumWithMidiKeys:@[@(drum)] withMainInterval:[@[@4, @6, @8][arc4random()%3] intValue] playStrongNotes:arc4random()%3 leftOffset:0 rightOffset:-1 intensity:0.1f + (arc4random()%10 * 0.1f) dust:0.f dustOffset:0];
        }
        _notes = [composer notes];
    }
    
    for ( NSDictionary * note in _notes ) {
        if ( [note[@"o"] intValue] == tick ) {
            [_sampler sendNoteOnToInstrument:1 midiKey:[note[@"k"] intValue] velocity:[note[@"v"] intValue]];
        }
    }
}

@end
