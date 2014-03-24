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

- (void) setTempo:(NSInteger)tempo;

@end
