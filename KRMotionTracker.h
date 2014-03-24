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

typedef enum {
	kStationary = 0,
	kWalking,
	kRunning,
	kAutomotive,
} KRMotionType;

@protocol KRMotionTrackerDelegate
- (void) newMotionValue:(KRSpeed)speed;
- (void) shakeDetected;
@end

@protocol KRMotionTypeDelegate
- (void) newMotionType:(KRMotionType)type;
- (void) noWayToGetLocationType;
- (void) logGPSSpeed:(CGFloat)speed;
@end

@interface KRMotionTracker : NSObject

@property (weak, nonatomic) id<KRMotionTrackerDelegate, KRMotionTypeDelegate> delegate;
- (void) start;
- (void) stop;

@end



