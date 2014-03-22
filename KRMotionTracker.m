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

#define KRSlowMotionValue 40
#define KRNormalMotionValue 80

#define KRSlowSpeedValue 0.1
#define KRNormalSpeedValue 1.5

@interface KRMotionTracker () <CLLocationManagerDelegate>{
	CMMotionManager * _motionManager;
	CLLocationManager * _locationManager;
	NSMutableArray * _motionValues;
	NSMutableArray * _speedValues;
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
	_motionValues = [NSMutableArray new];
	_speedValues = [NSMutableArray new];
	
	[_locationManager startUpdatingLocation];
	
	NSOperationQueue * queue = [NSOperationQueue new];
	[queue setMaxConcurrentOperationCount:1];

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
    
    double accValue = sqrt(pow(motion.userAcceleration.x,2)+pow(motion.userAcceleration.y,2)+pow(motion.userAcceleration.z, 2));
	accValue = accValue * 100;
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
    
//	NSLog(@"value %f", accValue);
}

- (double) filterAccelerationValue:(double)newValue{
	double result = [self filterValue:newValue withOldValuesArray:_motionValues depth:KRMotionFilterDepth];
	return result;
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
#pragma mark Location Methods

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
	CLLocation * lastLocation = [locations lastObject];
	CLLocationSpeed speed = lastLocation.speed;
	KRSpeed value;
	if ( speed < KRSlowSpeedValue ) {
		value = kSlowSpeed;
	} else if ( speed <= KRNormalSpeedValue ) {
		value = kMediumSpeed;
	} else {
		value = kFastSpeed;
	}
	[self.delegate newSpeedValue:value];
}
@end
