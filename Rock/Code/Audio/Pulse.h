//
//  Pulse.h
//  Rock
//
//  Created by Nick on 21/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PulseDelegate

- (void) tickWithNumber:(NSInteger)tick;

@end


@interface Pulse : NSObject

@property (nonatomic, strong) id<PulseDelegate> delegate;

- (void) start;

- (void) setTempo:(int)tempo;

@end
