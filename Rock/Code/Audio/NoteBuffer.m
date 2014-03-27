//
//  NoteBuffer.m
//  Rock
//
//  Created by Nick on 26/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "NoteBuffer.h"
#import "AudioSampler.h"

@interface NoteBuffer() {
    AudioSampler * _sampler;
    NSMutableArray * _notes;
}

@end

@implementation NoteBuffer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _notes = [[NSMutableArray alloc] init];
        
        _sampler = [[AudioSampler alloc] init];
        [_sampler setupOnComplete:nil];
    }
    return self;
}

- (void) addNoteForInstrument:(int)instrument
                         note:(int)midiNote
                     velocity:(int)velocity
                     duration:(int)numberOfTicks {
    
    if ( numberOfTicks <= 0 ) {
        return;
    }
    
    [_notes addObject:@{@"instrument":@(instrument), @"key":@(midiNote), @"duration":@(numberOfTicks)}];
    [_sampler sendNoteOnToInstrument:instrument midiKey:midiNote velocity:velocity];
    
}

- (void) onTick:(int)tickNumber {

    NSInteger count = _notes.count;
    
    for ( NSInteger i = count - 1; i >= 0 ; --i ) {
        NSDictionary * note = _notes[i];
        NSInteger duration = [note[@"duration"] intValue] - 1;
        if ( duration == 0 ) {
            [_sampler sendNoteOffToInstrument:[note[@"instrument"] intValue] midiKey:[note[@"key"] intValue]];
            [_notes removeObjectAtIndex:i];
            --i;
        } else if ( duration > 0 ) {
            [_notes replaceObjectAtIndex:i withObject:@{@"instrument":note[@"instrument"], @"key":note[@"key"], @"duration":@(duration)}];
        }
    }
}

@end
