//
//  KRMotionTracker.h
//  Rock
//
//  Created by Anton Chebotov on 22/03/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSlowSpeed = 0,
    kMediumSpeed,
    kFastSpeed
} KRSpeed;

@protocol KRMotionTrackerDelegate
- (void) newMotionValue:(KRSpeed)speed;
@end

@protocol KRSpeedTrackerDelegate
- (void) newSpeedValue:(KRSpeed)speed;
@end

@interface KRMotionTracker : NSObject

@property (weak, nonatomic) id<KRSpeedTrackerDelegate, KRMotionTrackerDelegate> delegate;
- (void) start;
- (void) stop;

@end



