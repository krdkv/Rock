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
                        colors:(NSArray*)colors;

@property (nonatomic, readonly) NSArray * keys;

@property (nonatomic, readonly) NSArray * drumLoops;

@property (nonatomic, readonly) NSArray * bassLoops;

@end
