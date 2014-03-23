//
//  KRMotionTrackerTests.m
//  Rock
//
//  Created by Anton Chebotov on 22/03/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KRMotionTracker.h"

@interface KRMotionTracker(){
	
}
- (double) filterValue:(double)value withOldValuesArray:(NSMutableArray *)oldValues depth:(int)depth;
@end

@interface KRMotionTrackerTests : XCTestCase

@end

@implementation KRMotionTrackerTests

- (void)setUp{
    [super setUp];
}

- (void)tearDown{
    [super tearDown];
}

- (void)testFilterResultWithNoOldValues{
	KRMotionTracker * tracker = [KRMotionTracker new];
	NSMutableArray * oldValues = [NSMutableArray new];
	double result = [tracker filterValue:1 withOldValuesArray:oldValues depth:4];
	XCTAssert(result == 1, @"Wrong filtering");
}

- (void) testFilterResultWithOldValue{
	KRMotionTracker * tracker = [KRMotionTracker new];
	NSMutableArray * oldValues = [@[@1] mutableCopy];
	
	double newValue = 2;
	
	double result = [tracker filterValue:newValue withOldValuesArray:oldValues depth:4];
	XCTAssert(result == (double)5/3, @"Wrong filtering");
	XCTAssert(oldValues.count == 2, @"Wrong old values saving");
	XCTAssert([oldValues[0] doubleValue] == newValue, @"Wrong old values saving");
}

- (void) testFilterResultWithOldValues{
	KRMotionTracker * tracker = [KRMotionTracker new];
	NSMutableArray * oldValues = [@[@2, @1] mutableCopy];
	
	double newValue = 4;
	
	double result = [tracker filterValue:newValue withOldValuesArray:oldValues depth:2];
	double expected = (double)32/11;
	XCTAssert(result == expected, @"Wrong filtering");
	XCTAssert(oldValues.count == 2, @"Wrong old values saving");
	XCTAssert([oldValues[0] doubleValue] == newValue, @"Wrong old values saving");
	
}

@end
