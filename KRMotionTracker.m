//
//  KRMotionTracker.m
//  Rock
//
//  Created by Anton Chebotov on 22/03/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRMotionTracker.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#define KRMotionFilterDepth 5
#define KRSpeedMotionDepth 5

@interface KRMotionTracker () <CLLocationManagerDelegate>{
	CMMotionManager * _motionManager;
	CLLocationManager * _locationManager;
}

@end

@implementation KRMotionTracker

- (id) init{
	self = [super init];
	if(self){
		_motionManager = [CMMotionManager new];
		_locationManager = [CLLocationManager new];
		_locationManager.delegate = self;
	}
	return self;
}

- (void) start{

	[_locationManager startUpdatingLocation];
	
	NSOperationQueue * queue = [NSOperationQueue new];
	[_motionManager startDeviceMotionUpdatesToQueue:queue
										withHandler:^(CMDeviceMotion *motion, NSError *error) {
											[self motionUpdated:motion];
										}];
}

- (void) stop{
	[_motionManager stopDeviceMotionUpdates];
}

#pragma mark -
#pragma mark Motion Methods

- (void) motionUpdated:(CMDeviceMotion *)motion{
	gravX = (acceleration.x * kFilteringFactor) + (gravX * (1.0 - kFilteringFactor));
    gravY = (acceleration.y * kFilteringFactor) + (gravY * (1.0 - kFilteringFactor));
    gravZ = (acceleration.z * kFilteringFactor) + (gravZ * (1.0 - kFilteringFactor));
    
    UIAccelerationValue accelX = acceleration.x - ( (acceleration.x * kFilteringFactor) + (gravX * (1.0 - kFilteringFactor)) );
    
    UIAccelerationValue accelY = acceleration.y - ( (acceleration.y * kFilteringFactor) + (gravY * (1.0 - kFilteringFactor)) );
    UIAccelerationValue accelZ = acceleration.z - ( (acceleration.z * kFilteringFactor) + (gravZ * (1.0 - kFilteringFactor)) );
    accelX *= 9.81f;
    accelY *= 9.81f;
    accelZ *= 9.81f;
    accelX = [self tendToZero:accelX];
    accelY = [self tendToZero:accelY];
    accelZ = [self tendToZero:accelZ];
    
    UIAccelerationValue vector = sqrt(pow(accelX,2)+pow(accelY,2)+pow(accelZ, 2));
    UIAccelerationValue acce = vector - prevVelocity;
    UIAccelerationValue velocity = (((acce - prevAcce)/2) * (1/kAccelerometerFrequency)) + prevVelocity;
    
    ++count;
    averageSpeed += velocity>0 ? velocity*10000 : 0;
    if ( count == kSpeedMeasuringFrequency ) {
        count = 0;
        averageSpeed = 0.f;
    }
    if ( count == kSpeedMeasuringFrequency - 1 ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            averageSpeed = averageSpeed / 10;
            Speed speed;
            if ( averageSpeed < 50 ) {
                speed = kSlowSpeed;
            } else if ( averageSpeed >= 50 && averageSpeed <= 300 ) {
                speed = kMediumSpeed;
            } else {
                speed = kFastSpeed;
            }
            
            if ( self.delegate ) {
                [self.delegate didChangedSpeed:speed];
            }
        });
    }
    
    //    NSLog(@"X %g Y %g Z %g, Vector %g, Velocity %g",accelX,accelY,accelZ,vector,velocity);
    
    prevAcce = acce;
    prevVelocity = velocity;
}

#pragma mark -
#pragma mark Location Methods
@end
