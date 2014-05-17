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
    
    int _pitch;
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
        
        _pitch = 0;
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

- (void) stopNoteForInstrument:(int)instrument
                          note:(int)midiNote {
    
    NSInteger count = _notes.count;
    
    for ( NSInteger i = count - 1; i >= 0 ; --i ) {
        NSDictionary * note = _notes[i];
        if ( note ) {
            if ( [note[@"i"] intValue] == instrument && [note[@"k"] intValue] == midiNote ) {
                [_sampler sendNoteOffToInstrument:instrument midiKey:midiNote];
                [_notes removeObjectAtIndex:i];
            }
        }        
    }
}

- (void) playNoteForInstrument:(int)instrument
                         note:(int)midiNote
                     velocity:(int)velocity
                     duration:(int)numberOfTicks {
    
    if ( numberOfTicks <= 0 ) {
        return;
    }
    
    if ( instrument != 1 ) { // Not a drum
        midiNote += _pitch;
    }
    
    [_notes addObject:@{@"i":@(instrument), @"k":@(midiNote), @"d":@(numberOfTicks)}];
    [_sampler sendNoteOnToInstrument:instrument midiKey:midiNote velocity:velocity];
}

- (void) playChord:(NSArray*)chord {
    
    CGFloat delay = 0.001f;
    
    for ( int i = 0; i < chord.count; ++i ) {
        [self performSelector:@selector(playNote:) withObject:@{@"i":chord[i][@"i"], @"k":chord[i][@"k"], @"v":chord[i][@"v"], @"d":chord[i][@"d"]} afterDelay:i*delay];
    }
}

- (void) playNote:(NSDictionary*)note {
    [self playNoteForInstrument:[note[@"i"] intValue] note:[note[@"k"] intValue] velocity:[note[@"v"] intValue] duration:[note[@"d"] intValue]];
}

- (void) setPitch:(int)pitch {
//    [_waitingNotes removeAllObjects];
    
    NSInteger count = _notes.count;
    for ( NSInteger i = count - 1; i >= 0 ; --i ) {
        NSDictionary * note = _notes[i];
        [_sampler sendNoteOffToInstrument:[note[@"i"] intValue] midiKey:[note[@"k"] intValue]];
        [_notes removeObjectAtIndex:i];
        --i;
    }
    
    _pitch = pitch;
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
            if ( note ) {
                [_waitingNotes replaceObjectAtIndex:i withObject:@{@"i":note[@"i"], @"k":note[@"k"], @"v":note[@"v"], @"o":@(ticksBeforeStart), @"d":note[@"d"]}];
            }
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
