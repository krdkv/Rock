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
#define KRMotionTypeFilterDepth 3

#define KRSlowMotionValue 40
#define KRNormalMotionValue 80

#define KRShakeAccelerationTreshhold 400.0f

#define KRTiltAngleValue 0.3f

#define KRStationaryMaxSpeed 0.1f
#define KRWalkingMaxSpeed 1.5f
#define KRRunningMaxSpeed 8.0f

#define KRMotionUpdateFrequency 20 //Hz
#define KRTiltUpdateFrequency 50 //Hz

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
	_motionTypeValues = [NSMutableArray new];
	_currentMotionType = kMotionTypeUnknown;
	
	NSOperationQueue * queue = [NSOperationQueue new];
	[queue setMaxConcurrentOperationCount:1];
	
	[_motionManager startDeviceMotionUpdatesToQueue:queue
										withHandler:^(CMDeviceMotion *motion, NSError *error) {
											[self detectShake:motion];
										}];

	BOOL isLocationAvailable = [CLLocationManager locationServicesEnabled];
	if (isLocationAvailable){
		[_locationManager startUpdatingLocation];
		[self startSpeedControl];
	}
}

- (void) startTiltDetecting
{
	[_motionManager stopDeviceMotionUpdates];
	
	_motionManager.deviceMotionUpdateInterval = (CGFloat)1/KRTiltUpdateFrequency;
	NSOperationQueue * queue = [NSOperationQueue new];
	[queue setMaxConcurrentOperationCount:1];
	[_motionManager startDeviceMotionUpdatesToQueue:queue
										withHandler:^(CMDeviceMotion *motion, NSError *error) {
											[self detectTilt:motion];
										}];
}

- (void) startMotionDetecting
{
	[_motionManager stopDeviceMotionUpdates];
	
	_motionValues = [NSMutableArray new];
	for(int i = 0; i < 4; i++){
		[_motionValues addObject:[NSNumber numberWithFloat:0]];
	}
	
	CGFloat interval = (CGFloat)1/KRMotionUpdateFrequency;
	_motionManager.deviceMotionUpdateInterval = interval;
	NSOperationQueue * queue = [NSOperationQueue new];
	[queue setMaxConcurrentOperationCount:1];
	[_motionManager startDeviceMotionUpdatesToQueue:queue
										withHandler:^(CMDeviceMotion *motion, NSError *error) {
											[self detectMotion:motion];
										}];
}

- (void) stop
{
	[_motionManager stopDeviceMotionUpdates];
}

- (double) filterValue:(double)value withOldValuesArray:(NSMutableArray *)oldValues depth:(int)depth
{
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

- (void) detectMotion:(CMDeviceMotion *)motion
{
    double accValue = [self calculateAccelerationValue:motion];
	accValue = [self filterAccelerationValue:accValue];
    
	[self.delegate newMotionRawValue:accValue];
}


- (double) calculateAccelerationValue:(CMDeviceMotion *)motion
{
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
