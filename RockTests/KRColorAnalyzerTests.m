//
//  KRColorAnalyzerTests.m
//  Rock
//
//  Created by Anton Chebotov on 03/04/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KRColorAnalyzer.h"
#import "KRColorUnit.h"

@interface KRColorAnalyzer ()
{
	
}
@end

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

- (void)testGreen
{
	NSString * path = [[NSBundle mainBundle] pathForResource:@"green" ofType:@"png"];
	UIImage * image = [UIImage imageWithContentsOfFile:path];
	NSString * type = [colorAnalyzer getTypeForImage:image];
	XCTAssert([type isEqual:@"green"], @"Wrong image type from analyzer");
}

- (void) testRed
{
	NSString * path = [[NSBundle mainBundle] pathForResource:@"red" ofType:@"png"];
	UIImage * image = [UIImage imageWithContentsOfFile:path];
	NSString * type = [colorAnalyzer getTypeForImage:image];
	XCTAssert([type isEqual:@"red"], @"Wrong image type from analyzer");
}

- (void) testAcid
{
	NSString * path = [[NSBundle mainBundle] pathForResource:@"acid" ofType:@"png"];
	UIImage * image = [UIImage imageWithContentsOfFile:path];
	NSString * type = [colorAnalyzer getTypeForImage:image];
	XCTAssert([type isEqual:@"acid"], @"Wrong image type from analyzer");
}

- (void) testHugeImage
{
	NSString * path = [[NSBundle mainBundle] pathForResource:@"huge" ofType:@"jpg"];
	UIImage * image = [UIImage imageWithContentsOfFile:path];
	NSString * type = [colorAnalyzer getTypeForImage:image];
	XCTAssert([type isEqualToString:@"red"], @"Wrong image type from analyzer");
}


@end
