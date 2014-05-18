//
//  TrackStructure.h
//  Rock
//
//  Created by Nick on 17/05/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackStructure : NSObject

- (void) generateWithIntensity:(CGFloat)intensity
                        colors:(NSArray*)colors
                      withTick:(int)tick;

- (NSDictionary*) keyForTick:(int)tick;

- (int)keyForX:(int)x y:(int)y offset:(int)offset;

- (int)keyForTilt:(CGFloat)tilt offset:(int)offset;

@property (nonatomic, readonly) NSMutableArray * keys;

@property (nonatomic, readonly) NSMutableArray * drumLoops;

@property (nonatomic, readonly) NSMutableArray * bassLoops;

@property (nonatomic, readonly) int tonica;

@end
