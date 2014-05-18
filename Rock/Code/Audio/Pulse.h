//
//  Pulse.h
//  Rock
//
//  Created by Nick on 21/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PulseDelegate

- (void) tickWithNumber:(int)tick;

@end


@interface Pulse : NSObject

@property (nonatomic, weak) id<PulseDelegate> delegate;

- (void) start;

- (void) stop;

- (void) restart;

- (BOOL) isPlaying;

- (void) setTempo:(int)tempo;

@property (nonatomic, readonly) unsigned int globalTick;

@end
