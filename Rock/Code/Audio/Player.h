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

- (void) setTempo:(int)tempo;

- (void) playSolo:(CGPoint)point;

- (void)setPitch:(int)pitch;

- (void) tickWithNumber:(int)tick;

//

- (void) stop;

- (void) setIntensity:(CGFloat)intensity
       andColorsArray:(NSArray*)colorsArray;

- (void) setEffectColorForInstrument:(int)instrument
                               color:(UIColor*)color;

- (void) playSoloWithTilt:(CGFloat)tilt;

@end
