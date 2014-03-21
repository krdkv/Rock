//
//  AudioSampler.h
//  Rock
//
//  Created by Nick on 21/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioSampler : NSObject

- (void) setupOnComplete:(void(^)(void))onComplete;

- (void) sendNoteOnToInstrument:(int)instrument
                        midiKey:(int)midiKey
                       velocity:(int)velocity;

- (void) sendNoteOffToInstrument:(int)instrument
                         midiKey:(int)midiKey;

@end
