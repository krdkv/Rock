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

@end
