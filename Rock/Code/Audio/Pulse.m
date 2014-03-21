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
    ++ _currentTick;
    if ( _currentTick == kNumberOfTicksPerBar ) {
        _currentTick = 0;
    }
}

- (void) setTempo:(int)tempo {
    
    if ( tempo == 0 ) {
        return;
    }
    
}

- (void) startTimer {
    CGFloat timeInterval = kTimerCoefficient / _tempo;
    _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

@end
