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

@property (nonatomic, readwrite) NSMutableArray * keys;
@property (nonatomic, readwrite) NSMutableArray * drumLoops;
@property (nonatomic, readwrite) NSMutableArray * bassLoops;

@end

@implementation TrackStructure

#define kPopularHarmonies @{ @0.273 : @[@5, @7, @0], @0.226 : @[@7, @5, @0], @0.113: @[@10, @5, @0], @0.09 : @[@9, @5, @0], @0.079: @[@10, @8, @0], @0.0512: @[@3, @8, @0], @0.048: @[@2, @7, @0], @0.046: @[@8, @10, @0], @0.032: @[@7, @9, @0], @0.03: @[@5, @10, @0] }

- (instancetype)init
{
    self = [super init];
    if (self) {
        _loops = [[NSMutableArray alloc] init];
        _drumLoops = [[NSMutableArray alloc] init];
        _bassLoops = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) generateWithIntensity:(CGFloat)intensity
                        colors:(NSArray*)colors {
    
    _loops = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Loops" ofType:@"plist"]];
    
    _keys = [NSMutableArray arrayWithArray:@[ @{@"o": @0, @"k": @(C1), @"s": @"min"}]];
    
    int numberOfLoops = 5;
    
    for ( int i = 0; i < numberOfLoops; ++i ) {
        
        NSString* type = @[@"chor", @"ver"][arc4random()%2];
        NSString* style = @"rock";
        
        NSDictionary * drumLoop = [self loopForInstrument:@"drums" style:style type:type intensity:1 scale:@"" subIntensity:4];
        [_drumLoops addObject:drumLoop];
        
        NSDictionary * bassLoop = [self loopForInstrument:@"bass" style:style type:type intensity:1 scale:@"maj" subIntensity:4];
        [_bassLoops addObject:bassLoop];
    }
}

- (NSDictionary*) keyForTick:(int)tick {
    
    for ( int i = 0; i < _keys.count; ++i ) {
        
        NSDictionary * keyInfo = _keys[i];
        NSDictionary * nextKeyInfo = (i+1) < _keys.count ? _keys[i+1] : nil;
        
        if ( ! nextKeyInfo ) {
            return _keys[i];
        }
        
        if ( [keyInfo[@"o"] intValue] <= tick && tick < [nextKeyInfo[@"o"] intValue] ) {
            return _keys[i];
        }
    }
    
    return nil;
}

- (NSDictionary*)loopForInstrument:(NSString*)instrument
                             style:(NSString*)style
                              type:(NSString*)type
                         intensity:(int)intensity
                             scale:(NSString*)scale
                      subIntensity:(int)subIntensity
{
    
    NSMutableArray * fetch = [[NSMutableArray alloc] init];
    
    for ( NSDictionary * loop in _loops ) {
        if ( [loop[@"instrument"] isEqualToString:instrument] && [loop[@"style"] isEqualToString:style] &&
            [loop[@"type"] isEqualToString:type] && intensity == [loop[@"intensity"] intValue] && ( [loop[@"scale"] isEqualToString:scale] )
            && subIntensity == [loop[@"subintensity"] intValue] ) {
            [fetch addObject:loop];
        }
    }
    
    NSAssert(fetch.count != 0, @"All fetches should be possible %@ %@ %@ %d %@ %d", instrument, style, type, intensity, scale, subIntensity);
    
    return fetch[arc4random()%fetch.count];
}

#define kMajorMask @[ @-5, @-3, @-1, @0, @2, @4, @5 ]
#define kMinorMask @[ @-5, @-4, @-2, @0, @2, @3, @5  ]

#define kOctaveMask @[ @36, @24, @12, @0, @-12, @-24, @-36 ]

#define kTiltMajorMask @[ @-12, @-8, @-1, @0, @7, @14, @16 ]
#define kTiltMinorMask @[ @-12, @-9, @-4, @0, @7, @14, @15 ]

- (int)keyForX:(int)x y:(int)y offset:(int)offset {
    
    NSDictionary * keyInfo = [self keyForTick:offset];
    int scale = [keyInfo[@"k"] intValue];
    bool isMajor = [keyInfo[@"s"] isEqualToString:@"maj"];
    
    scale +=  isMajor ? [kMajorMask[x] intValue] : [kMinorMask[x] intValue];
    scale += [kOctaveMask[y] intValue];
    
    return scale;
}

- (int)keyForTilt:(CGFloat)tilt offset:(int)offset{
    
    tilt += 1;
    tilt /= 2;
    
    NSDictionary * keyInfo = [self keyForTick:offset];
    int scale = [keyInfo[@"k"] intValue];
    bool isMajor = [keyInfo[@"s"] isEqualToString:@"maj"];
    
    int index = (int)floor(tilt * kTiltMajorMask.count);
    
    if ( index > kTiltMajorMask.count-1 ) {
        index = (int)kTiltMajorMask.count-1;
    }
    
    return scale + (isMajor ? [kTiltMajorMask[index] intValue] : [kTiltMinorMask[index] intValue]);
}

@end
