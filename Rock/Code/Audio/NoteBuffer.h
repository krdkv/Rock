//
//  NoteBuffer.h
//  Rock
//
//  Created by Nick on 26/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteBuffer : NSObject

- (void) onTick:(int)tickNumber;

- (void) addNoteForInstrument:(int)instrument
                         note:(int)midiNote
                     velocity:(int)velocity
                       offset:(int)tickerBeforeStart
                     duration:(int)numberOfTicks;

- (void) stopNoteForInstrument:(int)instrument
                          note:(int)midiNote;

- (void) setPitch:(int)pitch;

- (void) effectChangedForInstrument:(int)instrument
                              value:(CGFloat)value;

@end
