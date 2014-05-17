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
	kMotionTypeUnknown = 10000,
} KRMotionType;

@protocol KRMotionTrackerDelegate
- (void) attitudeUpdatedWithPitch:(CGFloat)pitch roll:(CGFloat)roll yaw:(CGFloat)yaw;
- (void) motionUpdatedWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
- (void) xDistanceChanged:(CGFloat)distance;
- (void) newMotionValue:(KRSpeed)speed;
- (void) shakeDetected;
- (void) newMotionType:(KRMotionType)type;
- (void) noWayToGetLocationType;
- (void) logGPSSpeed:(CGFloat)speed;
- (void) tiltValue:(CGFloat)value;
@end

@interface KRMotionTracker : NSObject

@property (weak, nonatomic) id<KRMotionTrackerDelegate> delegate;
- (void) start;
- (void) startTiltDetecting;
- (void) stop;

@end



