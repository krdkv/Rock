//
//  KRColorAnalyzerTests.m
//  Rock
//
//  Created by Anton Chebotov on 03/04/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KRColorAnalyzer.h"

@interface KRColorAnalyzerTests : XCTestCase{
	KRColorAnalyzer * colorAnalyzer;
}

@end

@implementation KRColorAnalyzerTests

- (void)setUp{
    [super setUp];

	colorAnalyzer = [KRColorAnalyzer new];
	colorAnalyzer.numberOfColors = 10.0;
}

- (void)tearDown{
    [super tearDown];
}

- (void)testGreen{
	NSString * path = [[NSBundle mainBundle] pathForResource:@"green" ofType:@"png"];
	UIImage * image = [UIImage imageWithContentsOfFile:path];
	KRImageType type = [colorAnalyzer getTypeForImage:image];
	XCTAssert(type == kGreen, @"Wrong image type from analyzer");
}

- (void) testRed{
	NSString * path = [[NSBundle mainBundle] pathForResource:@"red" ofType:@"png"];
	UIImage * image = [UIImage imageWithContentsOfFile:path];
	KRImageType type = [colorAnalyzer getTypeForImage:image];
	XCTAssert(type == kRed, @"Wrong image type from analyzer");
}

- (void) testAcid{
	NSString * path = [[NSBundle mainBundle] pathForResource:@"acid" ofType:@"png"];
	UIImage * image = [UIImage imageWithContentsOfFile:path];
	KRImageType type = [colorAnalyzer getTypeForImage:image];
	XCTAssert(type == kAcid, @"Wrong image type from analyzer");
}


@end
