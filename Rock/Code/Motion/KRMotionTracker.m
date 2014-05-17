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

#define KRDeviceMotionFrequency 50.0 //Hz

#define KRMotionFilterDepth 5
#define KRMotionTypeFilterDepth 3

#define KRSlowMotionValue 40
#define KRNormalMotionValue 80

#define KRShakeAccelerationTreshhold 400.0f

#define KRTiltAngleValue 0.3f

#define KRStationaryMaxSpeed 0.1f
#define KRWalkingMaxSpeed 1.5f
#define KRRunningMaxSpeed 8.0f

#define KRTiltUpdateFrequency 2 //Hz

@interface KRMotionTracker () <CLLocationManagerDelegate>
{
	CMMotionManager * _motionManager;
	CMMotionActivityManager * _activityManager;
	CLLocationManager * _locationManager;

	NSMutableArray * _motionValues;
	NSMutableArray * _motionTypeValues;
	
	
	BOOL _triesToShake;
	
	CGFloat _pitch;
	NSMutableArray * _xAccelerations;
}
@property KRMotionType currentMotionType;
@property CGFloat motionLastYaw;
@end

@implementation KRMotionTracker

- (id) init
{
	self = [super init];
	if(self){
		_motionManager = [CMMotionManager new];
		_activityManager = [CMMotionActivityManager new];
		_locationManager = [CLLocationManager new];
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		_xAccelerations = [NSMutableArray new];
	}
	return self;
}

- (void) start
{
	_motionValues = [NSMutableArray new];
	_motionTypeValues = [NSMutableArray new];
	_currentMotionType = kMotionTypeUnknown;
	
	NSOperationQueue * queue = [NSOperationQueue new];
	[queue setMaxConcurrentOperationCount:1];
	
//	_motionManager.deviceMotionUpdateInterval = 1/KRDeviceMotionFrequency;
	
	[_motionManager startDeviceMotionUpdatesToQueue:queue
										withHandler:^(CMDeviceMotion *motion, NSError *error) {
											[self motionUpdated:motion];
											[self detectShake:motion];
										}];

	BOOL isLocationAvailable = [CLLocationManager locationServicesEnabled];
	if (isLocationAvailable){
		[_locationManager startUpdatingLocation];
		[self startSpeedControl];
	}
	else{
		[self.delegate noWayToGetLocationType];
	}
}

- (void) startTiltDetecting
{
	[_motionManager stopDeviceMotionUpdates];
	
	_motionManager.deviceMotionUpdateInterval = 1/KRTiltUpdateFrequency;
	NSOperationQueue * queue = [NSOperationQueue new];
	[queue setMaxConcurrentOperationCount:1];
	[_motionManager startDeviceMotionUpdatesToQueue:queue
										withHandler:^(CMDeviceMotion *motion, NSError *error) {
											[self detectTilt:motion];
										}];

}

- (void) startMotionValueDetecting
{
	
}

- (void) stop
{
	[_motionManager stopDeviceMotionUpdates];
}

- (double) filterValue:(double)value withOldValuesArray:(NSMutableArray *)oldValues depth:(int)depth{
	double valuesSum = 0;
	double coeffSum = 0;
	[oldValues insertObject:[NSNumber numberWithDouble:value] atIndex:0];
	for (int i = 0; i < oldValues.count; i++) {
		double oldValue = [oldValues[i] doubleValue];
		double coeff = (double)1/(i+1);
		valuesSum += oldValue * coeff;
		coeffSum += coeff;
	}
	NSRange range;
	range.location = 0;
	range.length = MIN(KRMotionFilterDepth, oldValues.count);
	oldValues = [[oldValues subarrayWithRange:range] mutableCopy];
	return valuesSum/coeffSum;
}

#pragma mark -
#pragma mark Motion Methods

- (void) motionUpdated:(CMDeviceMotion *)motion
{
	dispatch_sync(dispatch_get_main_queue(), ^{
		[_delegate motionUpdatedWithX:motion.userAcceleration.x y:motion.userAcceleration.y z:motion.userAcceleration.z];
		
	});
	
	[self calculateDistancesWithMotion:motion];
	
    double accValue = [self calculateAccelerationValue:motion];
	accValue = [self filterAccelerationValue:accValue];
    
	KRSpeed value;
	if ( accValue < KRSlowMotionValue ) {
		value = kSlowSpeed;
	} else if ( accValue <= KRNormalMotionValue ) {
		value = kMediumSpeed;
	} else {
		value = kFastSpeed;
	}

	dispatch_sync(dispatch_get_main_queue(), ^{
		[self.delegate newMotionValue:value];
	});
}

- (void) calculateDistancesWithMotion:(CMDeviceMotion *)motion{
	CGFloat dx=0.0f;
	CGFloat vx=0.0f;
	CGFloat dt = 1 / KRDeviceMotionFrequency;
	[_xAccelerations addObject:[NSNumber numberWithFloat:motion.userAcceleration.x]];
	for (int i=1; i < _xAccelerations.count; i++)
	{
		vx+=([_xAccelerations[i-1] floatValue] + [_xAccelerations[i] floatValue])/2.0f*dt;
		dx+=vx*dt;
	}
	dispatch_sync(dispatch_get_main_queue(), ^{
		[_delegate xDistanceChanged:dx];
	});
}

- (double) calculateAccelerationValue:(CMDeviceMotion *)motion{
	double accValue = sqrt(pow(motion.userAcceleration.x,2)+pow(motion.userAcceleration.y,2)+pow(motion.userAcceleration.z, 2));
	accValue = accValue * 100;
	return accValue;
}

- (double) filterAccelerationValue:(double)newValue
{
	return [self filterValue:newValue withOldValuesArray:_motionValues depth:KRMotionFilterDepth];
}

- (void) detectShake:(CMDeviceMotion *)motion
{
#warning filter shake events
	double accValue = [self calculateAccelerationValue:motion];
	if(accValue > KRShakeAccelerationTreshhold){
		NSLog(@"Acc: %.f", accValue);
		if(_triesToShake == YES){
			[self.delegate shakeDetected];
			_triesToShake = NO;
		} else {
			_triesToShake = YES;
		}
	}
}


- (void) detectTilt:(CMDeviceMotion *)motion
{
	CMQuaternion quat = motion.attitude.quaternion;
    double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));
	
	if (self.motionLastYaw == 0) {
        self.motionLastYaw = yaw;
    }
	
    // kalman filtering
    static float q = 0.1;   // process noise
    static float r = 0.1;   // sensor noise
    static float p = 0.1;   // estimated error
    static float k = 0.5;   // kalman filter gain
	
    float x = self.motionLastYaw;
    p = p + q;
    k = p / (p + r);
    x = x + k*(yaw - x);
    p = (1 - k)*p;
	
    self.motionLastYaw = x;
	[self.delegate tiltValue:_motionLastYaw];
}


#pragma mark -
#pragma mark SpeedControl Methods

- (void) startSpeedControl
{
	[self performSelector:@selector(checkSpeedValue) withObject:nil afterDelay:0.5];
}

- (void) checkSpeedValue
{
	CLLocation * location = [_locationManager location];
	CLLocationSpeed speed = location.speed;
    
    if ( self.delegate ) {
        [self.delegate logGPSSpeed:speed];
    }
	KRMotionType type = [self getTypeWithSpeed:speed];
	[self notifyDelegateIfNeeded:type];
	
	[self performSelector:@selector(checkSpeedValue) withObject:nil afterDelay:0.5];
}

- (KRMotionType) getTypeWithSpeed:(CGFloat) speed
{
	if(speed < KRStationaryMaxSpeed){
		return kStationary;
	}
	else if (speed < KRWalkingMaxSpeed){
		return kWalking;
	}
	else if (speed < KRRunningMaxSpeed){
		return kRunning;
	}
	return kAutomotive;
}

- (void) notifyDelegateIfNeeded:(KRMotionType)type
{
	if([self isMotionTypeNew:type oldValues:_motionTypeValues])
	{
		[self.delegate newMotionType:type];
		_currentMotionType = type;
	}
}

- (BOOL) isMotionTypeNew:(KRMotionType)type oldValues:(NSMutableArray *)oldValues
{
	[oldValues addObject:[NSNumber numberWithInteger:type]];
	if(oldValues.count > KRMotionTypeFilterDepth){
		[oldValues removeObjectAtIndex:0];
	}
	
	for(int i = 0; i < oldValues.count - 1; i++){
		KRMotionType oldType = [oldValues[i] intValue];
		if(oldType != type){
			return NO;
		}
	}
	if(type != _currentMotionType){
		return YES;
	}
	return NO;
}

@end
