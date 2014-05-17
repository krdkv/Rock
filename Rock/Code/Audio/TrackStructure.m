//
//  TrackStructure.m
//  Rock
//
//  Created by Nick on 17/05/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "TrackStructure.h"
#import "AudioSettings.h"

@interface TrackStructure() {
    NSArray * _loops;
}

@property (nonatomic, readwrite) NSArray * keys;
@property (nonatomic, readwrite) NSArray * drumLoops;
@property (nonatomic, readwrite) NSArray * bassLoops;

@end

@implementation TrackStructure

#define kPopularHarmonies @{ @0.273 : @[@5, @7, @0], @0.226 : @[@7, @5, @0], @0.113: @[@10, @5, @0], @0.09 : @[@9, @5, @0], @0.079: @[@10, @8, @0], @0.0512: @[@3, @8, @0], @0.048: @[@2, @7, @0], @0.046: @[@8, @10, @0], @0.032: @[@7, @9, @0], @0.03: @[@5, @10, @0] }

- (void) generateWithIntensity:(CGFloat)intensity
                        colors:(NSArray*)colors {
    
    _loops = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Loops" ofType:@"plist"]];
    
    _keys = @[ @{@"o": @0, @"k": @(C1)}, @{@"o": @32, @"k": @(F1)}, @{@"o": @64, @"k": @(G1)}, @{@"o": @96, @"k": @(F1)},
               @{@"o": @128, @"k": @(C1)}, @{@"o": @160, @"k": @(F1)}, @{@"o": @192, @"k": @(G1)}, @{@"o": @224, @"k": @(F1)},
               ];
    
    _bassLoops = @[ @{@"numberOfBars": @4, @"notes":@"40,0,4,101 52,4,4,101 40,8,4,101 52,12,4,101 40,16,4,101 52,20,4,101 43,24,4,101 55,28,4,101 45,32,4,101 57,36,4,101 45,40,4,101 57,44,4,101 45,48,4,101 57,52,4,101 45,56,4,101 57,60,4,101 43,64,4,101 55,68,4,101 43,72,4,101 55,76,4,101 43,80,4,101 55,84,4,101 43,88,4,101 55,92,4,101 47,96,4,101 59,100,4,101 47,104,4,101 59,108,4,101 47,112,4,101 59,116,4,101 45,120,4,101 57,124,4,101", @"name": @"major"}, @{@"numberOfBars": @4, @"notes":@"40,0,4,98 52,4,4,83 50,8,3,91 48,12,3,93 47,16,5,89 45,22,9,84 40,32,4,98 52,36,4,83 50,40,3,91 48,44,3,93 47,48,5,89 43,54,9,84 40,64,4,98 52,68,4,83 50,72,3,91 48,76,3,93 47,80,5,89 45,86,9,84 43,96,4,98 43,102,4,91 43,108,4,93 40,116,4,89 45,120,8,89", @"name": @"major"} ];
    
    _drumLoops = @[ @{@"numberOfBars": @4, @"notes":@"49,0,1,104 36,0,1,104 42,2,1,104 51,4,1,78 42,6,1,104 51,8,1,78 38,8,1,104 42,10,1,104 51,12,1,74 42,14,1,104 51,16,1,73 42,18,1,104 51,20,1,71 36,20,1,104 42,22,1,104 51,24,1,71 38,24,1,104 42,26,1,104 51,28,1,78 42,30,1,104 36,32,1,104 51,32,1,78 42,34,1,104 36,36,1,104 51,36,1,74 42,38,1,104 38,40,1,104 51,40,1,73 42,42,1,104 38,44,1,104 51,44,1,71 42,46,1,104 51,48,1,71 42,50,1,104 36,52,1,104 51,52,1,78 42,54,1,104 38,56,1,104 51,56,1,78 42,58,1,104 51,60,1,74 42,62,1,104 36,64,1,104 49,64,1,120 42,66,1,104 51,68,1,71 42,70,1,104 38,72,1,104 51,72,1,71 42,74,1,104 51,76,1,78 42,78,1,104 51,80,1,78 42,82,1,104 36,84,1,104 51,84,1,74 42,86,1,104 38,88,1,104 51,88,1,73 42,90,1,104 51,92,1,71 42,94,1,104 36,96,1,104 51,96,1,71 42,98,1,104 36,100,1,104 51,100,1,78 42,102,1,104 38,104,1,104 51,104,1,78 42,106,1,104 38,108,1,104 51,108,1,74 42,110,1,104 51,112,1,73 42,114,1,104 38,114,1,120 36,116,1,104 51,116,1,71 42,118,1,104 38,120,1,104 51,120,1,71 42,122,1,104 51,124,1,71 42,126,1,104", @"name": @"major"}, @{@"numberOfBars": @4, @"notes":@"36,0,1,120 46,0,1,120 36,2,1,120 36,4,1,120 46,4,1,82 38,8,1,120 46,8,1,120 36,12,1,120 46,12,1,87 36,16,1,120 46,16,1,120 46,20,1,83 38,24,1,120 46,24,1,120 46,28,1,87 46,32,1,120 36,32,1,120 36,34,1,120 36,36,1,120 46,36,1,85 38,40,1,120 46,40,1,120 46,44,1,87 46,48,1,120 36,52,1,120 46,52,1,83 38,56,1,120 46,56,1,120 46,60,1,84 36,64,1,120 46,64,1,120 36,66,1,120 36,68,1,120 46,68,1,80 38,72,1,120 46,72,1,120 36,76,1,120 46,76,1,79 36,80,1,120 46,80,1,120 46,84,1,86 38,88,1,120 46,88,1,120 46,92,1,79 36,96,1,120 46,96,1,120 36,98,1,120 36,100,1,120 46,100,1,82 38,104,1,120 46,104,1,120 46,108,1,79 46,112,1,120 36,116,1,120 46,116,1,78 38,120,1,120 46,120,1,120 46,124,1,82 38,124,1,120", @"name": @"major"}];
    
    int numberOfLoops = 20;
    
    for ( int i = 0; i < numberOfLoops; ++i ) {
        
        NSString* type = @"chor";
        NSString* style = @"";
        
    }
}

- (int) keyForTick:(int)tick {
    
    for ( int i = 0; i < _keys.count; ++i ) {
        
        NSDictionary * keyInfo = _keys[i];
        NSDictionary * nextKeyInfo = (i+1) < _keys.count ? _keys[i+1] : nil;
        
        if ( ! nextKeyInfo ) {
            return [_keys[i][@"k"] intValue];
        }
        
        if ( [keyInfo[@"o"] intValue] <= tick && tick < [nextKeyInfo[@"o"] intValue] ) {
            return [_keys[i][@"k"] intValue];
        }
    }
    
    return -1;
}

- (NSDictionary*)loopForInstrument:(NSString*)instrument
                             style:(NSString*)style
                              type:(NSString*)type {
    
    NSMutableArray * fetch = [[NSMutableArray alloc] init];
    
    for ( NSDictionary * loop in _loops ) {
        
        if ( [loop[@"instrument"] isEqualToString:instrument] && [loop[@"style"] isEqualToString:style] &&
            [loop[@"type"] isEqualToString:type] ) {
            [fetch addObject:loop];
        }
    }
    
    NSAssert(fetch.count == 0, @"All fetches should be possible");
    
    return fetch[arc4random()%fetch.count];
}

- (int)keyForX:(int)x y:(int)y offset:(int)offset {
    
    int yOffset = [@[@9, @7, @5, @0, @-5, @-7, @-9][y] intValue];
    int key = [@[@36, @38, @40, @41, @43, @45, @47][x] intValue];
    
    return key + yOffset + 12;
}

- (int)keyForTilt:(CGFloat)tilt {
    
    if ( tilt < -1 ) {
        tilt = -1;
    }
    
    if ( tilt > 1 ) {
        tilt = 1;
    }
    
    tilt += 1;
    tilt /= 2;
    
    NSArray * notes = @[@(C1), @(F1), @(G1), @(A1), @(plusOctave(D1)), @(plusOctave(F1)), @(plusOctave(G1)), @(plusOctave(A1))];
    
    int index = (int)floor(tilt * (notes.count));
    
    if ( index > notes.count -1 ) {
        index = notes.count - 1;
    }
    
    return [notes[index] intValue];
}

@end
