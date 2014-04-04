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
    NSMutableArray * _waitingNotes;
}

@end

@implementation NoteBuffer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _notes = [[NSMutableArray alloc] init];
        _waitingNotes = [[NSMutableArray alloc] init];
        
        _sampler = [[AudioSampler alloc] init];
        [_sampler setupOnComplete:nil];
    }
    return self;
}

- (void) addNoteForInstrument:(int)instrument
                         note:(int)midiNote
                     velocity:(int)velocity
                       offset:(int)ticksBeforeStart
                     duration:(int)numberOfTicks {
    
    if ( numberOfTicks <= 0 || ticksBeforeStart  < 0 ) {
        return;
    }
    
    if ( ticksBeforeStart == 0 ) {
        [self playNoteForInstrument:instrument note:midiNote velocity:velocity duration:numberOfTicks];
    } else {
        [_waitingNotes addObject:@{@"i":@(instrument), @"k":@(midiNote), @"v":@(velocity), @"o":@(ticksBeforeStart), @"d":@(numberOfTicks)}];
    }
}

- (void) playNoteForInstrument:(int)instrument
                         note:(int)midiNote
                     velocity:(int)velocity
                     duration:(int)numberOfTicks {
    
    if ( numberOfTicks <= 0 ) {
        return;
    }
    
    [_notes addObject:@{@"i":@(instrument), @"k":@(midiNote), @"d":@(numberOfTicks)}];
    [_sampler sendNoteOnToInstrument:instrument midiKey:midiNote velocity:velocity];
}



- (void) onTick:(int)tickNumber {
    
    NSInteger count = _waitingNotes.count;
    for ( NSInteger i = count - 1; i >= 0; --i ) {

        NSDictionary * note = _waitingNotes[i];
        NSInteger ticksBeforeStart = [note[@"o"] intValue] - 1;
        if ( ticksBeforeStart == 0 ) {
            [self playNoteForInstrument:[note[@"i"] intValue]
                                   note:[note[@"k"] intValue]
                               velocity:[note[@"v"] intValue]
                               duration:[note[@"d"] intValue]];
            [_waitingNotes removeObjectAtIndex:i];
        } else {
            [_waitingNotes replaceObjectAtIndex:i withObject:@{@"i":note[@"i"], @"k":note[@"k"], @"v":note[@"v"], @"o":@(ticksBeforeStart), @"d":note[@"d"]}];
        }
    }
    
    count = _notes.count;
    
    for ( NSInteger i = count - 1; i >= 0 ; --i ) {
        NSDictionary * note = _notes[i];
        NSInteger duration = [note[@"d"] intValue] - 1;
        if ( duration == 0 ) {
            [_sampler sendNoteOffToInstrument:[note[@"i"] intValue] midiKey:[note[@"k"] intValue]];
            [_notes removeObjectAtIndex:i];
            --i;
        } else {
            [_notes replaceObjectAtIndex:i withObject:@{@"i":note[@"i"], @"k":note[@"k"], @"d":@(duration)}];
        }
    }
}

@end
