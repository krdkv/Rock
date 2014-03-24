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

#define KRMotionFilterDepth 8
#define KRSpeedFilterDepth 5

#define KRSlowMotionValue 40
#define KRNormalMotionValue 100

#define KRShakeAccelerationTreshhold 400.0f

#define KRStationaryMaxSpeed 0.1f
#define KRWalkingMaxSpeed 1.5f
#define KRRunningMaxSpeed 8.0f

@interface KRMotionTracker () <CLLocationManagerDelegate> {
	CMMotionManager * _motionManager;
	CMMotionActivityManager * _activityManager;
	CLLocationManager * _locationManager;

	NSMutableArray * _motionValues;
	NSMutableArray * _locationValues;
	
	BOOL _triesToShake;
}

@end

@implementation KRMotionTracker

- (id) init{
	self = [super init];
	if(self){
		_motionManager = [CMMotionManager new];
		_activityManager = [CMMotionActivityManager new];
		_locationManager = [CLLocationManager new];
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		_locationManager.delegate = self;
	}
	return self;
}

- (void) start{
	_motionValues = [NSMutableArray new];
	_locationValues = [NSMutableArray new];
	
	NSOperationQueue * queue = [NSOperationQueue new];
	[queue setMaxConcurrentOperationCount:1];
	
	_motionManager.deviceMotionUpdateInterval = 1/KRDeviceMotionFrequency;
	
	[_motionManager startDeviceMotionUpdatesToQueue:queue
										withHandler:^(CMDeviceMotion *motion, NSError *error) {
											[self motionUpdated:motion];
											[self detectShake:motion];
											[self detectMovement:motion];
										}];

	BOOL isActivityAvailable = [CMMotionActivityManager isActivityAvailable];
	BOOL isLocationAvailable = [CLLocationManager locationServicesEnabled];
	if(isActivityAvailable){
		[_activityManager startActivityUpdatesToQueue:queue
										  withHandler:^(CMMotionActivity *activity) {
											  [self activityUpdated:activity];
										  }];
	}
	else if (isLocationAvailable){
		[_locationManager startUpdatingLocation];
	}
	else{
		[self.delegate noWayToGetLocationType];
	}
}

- (void) stop{
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

- (double) calculateAccelerationValue:(CMDeviceMotion *)motion{
	double accValue = sqrt(pow(motion.userAcceleration.x,2)+pow(motion.userAcceleration.y,2)+pow(motion.userAcceleration.z, 2));
	accValue = accValue * 100;
	return accValue;
}

- (void) motionUpdated:(CMDeviceMotion *)motion{
    
    double accValue = [self calculateAccelerationValue:motion];
	accValue = [self filterAccelerationValue:accValue];
//    NSLog(@"value: %.f", accValue);
	KRSpeed value;
	if ( accValue < KRSlowMotionValue ) {
		value = kSlowSpeed;
	} else if ( accValue <= KRNormalMotionValue ) {
		value = kMediumSpeed;
	} else {
		value = kFastSpeed;
	}
#warning Poor behavior when value is around boundary values
	dispatch_sync(dispatch_get_main_queue(), ^{
		[self.delegate newMotionValue:value];
	});
}

- (double) filterAccelerationValue:(double)newValue{
	return [self filterValue:newValue withOldValuesArray:_motionValues depth:KRMotionFilterDepth];
}

- (void) detectShake:(CMDeviceMotion *)motion{
	
#warning filter shake events
	double accValue = [self calculateAccelerationValue:motion];
	if(accValue > KRShakeAccelerationTreshhold){
//		NSLog(@"Acc: %.f", accValue);
		if(_triesToShake == YES){
			[self.delegate shakeDetected];
			_triesToShake = NO;
		} else {
			_triesToShake = YES;
		}
	}
}

#pragma mark -
#pragma mark Activity Methods

- (void) activityUpdated:(CMMotionActivity *)activity{
	KRMotionType type;
	if (activity.automotive){
		type = kAutomotive;
	}
	else if (activity.running){
		type = kRunning;
	}
	else if (activity.walking){
		type = kWalking;
	}
	else if(activity.stationary){
		type = kStationary;
	}
	[self.delegate newMotionType:type];
}

- (void) detectMovement:(CMDeviceMotion *)motion{
	
}
#pragma mark -
#pragma mark CLLocationManagerDelegate Methods

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
	CLLocation * location = [locations lastObject];
	CLLocationSpeed speed = location.speed;
	speed = [self filterSpeedValue:speed];
	KRMotionType type;
	if(speed < KRStationaryMaxSpeed){
		type = kStationary;
	}
	else if (speed < KRWalkingMaxSpeed){
		type = kWalking;
	}
	else if (speed < KRRunningMaxSpeed){
		type = kRunning;
	}
	else{
		type = kAutomotive;
	}
	[self.delegate newMotionType:type];
}

- (double) filterSpeedValue:(double)value{
	return [self filterValue:value withOldValuesArray:_locationValues depth:KRSpeedFilterDepth];
}
@end
