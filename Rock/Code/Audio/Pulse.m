//
//  Pulse.m
//  Rock
//
//  Created by Nick on 21/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "Pulse.h"
#import "AudioSettings.h"

@interface Pulse() {
    NSTimer * _timer;
    int _tempo;
    int _currentTick;
}

@end

@implementation Pulse

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tempo = kDefaultTempo;
    }
    return self;
}

- (void) start {
    
    if ( _timer && _timer.isValid ) {
        return;
    }
    
    _currentTick = 0;
    [self startTimer];
}

- (void) tick {
    
    if ( self.delegate ) {
        [self.delegate tickWithNumber:_currentTick];
    }
    
    ++ _currentTick;
    if ( _currentTick == kNumberOfTicksPerBar ) {
        _currentTick = 0;
    }
}

- (void) setTempo:(int)tempo {
    
    if ( tempo == 0 || _tempo == tempo) {
        return;
    }
    
    if ( _timer ) {
        [_timer invalidate];
    }
    
    _tempo = tempo;
    
    [self startTimer];
}

- (void) startTimer {
    CGFloat timeInterval = kTimerCoefficient / _tempo;
    
    __block Pulse * me = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:me selector:@selector(tick) userInfo:nil repeats:YES];
        
        NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
        [runLoop run];
    });
    
    
}

@end
