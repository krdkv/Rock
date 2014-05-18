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
    int _colorMode;
}

@property (nonatomic, readwrite) NSMutableArray * keys;
@property (nonatomic, readwrite) NSMutableArray * drumLoops;
@property (nonatomic, readwrite) NSMutableArray * bassLoops;
@property (nonatomic, readwrite) int tonica;

@end

@implementation TrackStructure

#define kPopularHarmonies @{ @0.273 : @[@5, @7, @0], @0.226 : @[@7, @5, @0], @0.113: @[@10, @5, @0], @0.09 : @[@9, @5, @0], @0.079: @[@10, @8, @0], @0.0512: @[@3, @8, @0], @0.048: @[@2, @7, @0], @0.046: @[@8, @10, @0], @0.032: @[@7, @9, @0], @0.03: @[@5, @10, @0] }

- (instancetype)init
{
    self = [super init];
    if (self) {
        _drumLoops = [[NSMutableArray alloc] init];
        _bassLoops = [[NSMutableArray alloc] init];
        _keys = [[NSMutableArray alloc] init];
        _loops = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Loops" ofType:@"plist"]];
        _colorMode = -1;
    }
    return self;
}

static bool firstPair = true;

enum {
    kFullMinor = 0,
    kMinor,
    kMajor,
    kFullMajor
};

- (void) generateWithIntensity:(CGFloat)intensity
                        colors:(NSArray*)colors
                      withTick:(int)tick
{
    [_drumLoops removeAllObjects];
    [_bassLoops removeAllObjects];
    
    if ( tick == 0 ) {
        _tonica = 24 + arc4random()%7;
        
        if ( colors.count < 2 ) {
            _colorMode = kMajor;
        } else {
            UIColor * firstColor = colors[1];
            CGFloat r, b, buf;
            [firstColor getRed:&r green:&buf blue:&b alpha:&buf];
            if ( r - b > 0.5f ) {
                _colorMode = kFullMajor;
            } else if ( r > b ) {
                _colorMode = kMajor;
            } else if ( b - r > 0.5f ) {
                _colorMode = kFullMinor;
            } else if ( b > r ) {
                _colorMode = kMinor;
            } else {
                _colorMode = kMajor;
            }
        }
    }
    
    int keyOffset = tick == 0 ? 0 : tick+128;
    
    NSArray * firstHarmony = [kPopularHarmonies allValues][arc4random()%kPopularHarmonies.count];
    NSArray * secondHarmony = [kPopularHarmonies allValues][arc4random()%kPopularHarmonies.count];
    
    int desiredIntensity = intensity > 0.5f ? 1 : 0;
    int subIntensitySecond = arc4random()%2 == 1  ? 3 : 4;
  
    NSString * scale;
    
    if ( _colorMode == kFullMajor ) {
        scale = @"maj";
    } else if ( _colorMode == kFullMinor ) {
        scale = @"min";
    } else if ( _colorMode == kMajor ) {
        scale = arc4random()%3 == 1 ? @"min" : @"maj";
    } else {
        scale = arc4random()%3 == 1 ? @"maj" : @"min";
    }
    
    if ( intensity > 0.5 ) {
        for ( int i = 0; i < 4; ++i ) {
            NSArray * harmony = arc4random()%64 == 32 ? secondHarmony : firstHarmony;
            [_keys addObject:@{@"o": @(keyOffset + 32*i + 0), @"s": scale, @"k": @(_tonica + [harmony[0] intValue])}];
            [_keys addObject:@{@"o": @(keyOffset + 32*i + 8), @"s": scale, @"k": @(_tonica + [harmony[1] intValue])}];
            [_keys addObject:@{@"o": @(keyOffset + 32*i + 8), @"s": scale, @"k": @(_tonica + [harmony[2] intValue])}];
        }
    } else {
        for ( int i = 0; i < 2; ++i ) {
            NSArray * harmony = i == 1 ? secondHarmony : firstHarmony;
            [_keys addObject:@{@"o": @(keyOffset + 32*i + 0), @"s": scale, @"k": @(_tonica + [harmony[0] intValue])}];
            [_keys addObject:@{@"o": @(keyOffset + 32*i + 16), @"s": scale, @"k": @(_tonica + [harmony[1] intValue])}];
            [_keys addObject:@{@"o": @(keyOffset + 32*i + 32), @"s": scale, @"k": @(_tonica + [harmony[2] intValue])}];
        }
    }
    
    int numberOfLoops = 2;
    
    for ( int i = 0; i < numberOfLoops; ++i ) {
        
        NSString* type;
        if ( intensity > 0.5 ) {
            type = i == 0 ? @"ver" : @"chor";
        } else {
            type = firstPair ? @"ver" : @"chor";
        }
        
        int subIntensity;
        if ( firstPair ) {
            subIntensity = i == 0 ? 1 : 2;
        } else {
            subIntensity = subIntensitySecond;
        }
        
        NSDictionary * drumLoop = [self loopForInstrument:@"drums" style:@"rock" type:type intensity:desiredIntensity scale:@"" subIntensity:4];
        [_drumLoops addObject:drumLoop];
        
        NSDictionary * bassLoop = [self loopForInstrument:@"bass" style:@"rock" type:type intensity:desiredIntensity scale:scale subIntensity:4];
        [_bassLoops addObject:bassLoop];
    }
    
    firstPair = !firstPair;
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
