//
//  Player.h
//  Rock
//
//  Created by Nick on 23/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pulse.h"

@interface Player : NSObject<PulseDelegate>

- (void) start;

- (void) stop;

- (BOOL) isPlaying;

- (void) setTempo:(int)tempo;

- (void) soloNoteOn:(int)x :(int)y;

- (void) soloNoteOff:(int)x :(int)y;

- (void) playSoloWithTilt:(CGFloat)tilt;

- (void)setPitch:(int)pitch;

- (void) tickWithNumber:(int)tick;

- (void) setIntensity:(CGFloat)intensity
       andColorsArray:(NSArray*)colorsArray;

- (void) setEffectColorForInstrument:(int)instrument
                               color:(UIColor*)color;

@property (nonatomic, assign) int overheadVolume;

@end
