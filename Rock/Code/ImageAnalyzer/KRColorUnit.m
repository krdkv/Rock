//
//  KRColorUnit.m
//  Rock
//
//  Created by Anton Chebotov on 28/04/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRColorUnit.h"

@implementation KRColorUnit

- (id) initWithUIColor:(UIColor *)color name:(NSString *)name
{
	self = [super init];
	if(self){
		const CGFloat *components = CGColorGetComponents(color.CGColor);
		self.red = components[0] * 255;
		self.green = components[1] * 255;
		self.blue = components[2] * 255;
		self.frequency = 0;
		
		self.description = name;
	}
	return self;
}

- (id) initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue name:(NSString *)name
{
	UIColor * color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
	self = [self initWithUIColor:color name:name];
	return self;
}
@end
