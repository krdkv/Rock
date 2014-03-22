//
//  SpeedTracker.m
//  Jazz
//
//  Created by Nick on 26/09/2013.
//  Copyright (c) 2013 Tenere. All rights reserved.
//

#import "LegacySpeedTracker.h"

#define kAccelerometerFrequency 50.0 //Hz
#define kSpeedMeasuringFrequency 10
#define kFilteringFactor 0.1

@interface LegacySpeedTracker() {
    UIAccelerationValue gravX;
    UIAccelerationValue gravY;
    UIAccelerationValue gravZ;
    UIAccelerationValue prevVelocity;
    UIAccelerationValue prevAcce;
    UILabel * speedLabel;
    NSInteger count;
    CGFloat averageSpeed;
    UIAccelerometer *accelerometer;
}

@end

@implementation LegacySpeedTracker

- (id)init
{
    self = [super init];
    if (self) {
        accelerometer = [UIAccelerometer sharedAccelerometer];
        accelerometer.updateInterval = 1 / kAccelerometerFrequency;
        
        gravX = gravY = gravZ = prevVelocity = prevAcce = 0.f;
        averageSpeed = count = 0;
    }
    return self;
}

- (void) start {
    accelerometer.delegate = self;
}

- (UIAccelerationValue)tendToZero:(UIAccelerationValue)value {
    if (value < 0) {
        return ceil(value);
    } else {
        return floor(value);
    }
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
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


@end
