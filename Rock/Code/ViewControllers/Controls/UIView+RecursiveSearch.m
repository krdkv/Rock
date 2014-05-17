//
//  UIView+RecursiveSearch.m
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "UIView+RecursiveSearch.h"
#import "KRGridView.h"
#import "Knob.h"

@implementation UIView (RecursiveSearch)

- (BOOL) shouldAvoidScrolling:(CGPoint)point event:(UIEvent *)event
{
	if([self isKindOfClass:[KRGridView class]]){
		return [self pointInside:point withEvent:event];
	}
	if([self isKindOfClass:[Knob class]]){
		return [self pointInside:point withEvent:event];
	}
	
	for(UIView * subview in self.subviews){
		CGPoint convertedPoint = [self convertPoint:point toView:subview];
		if([subview shouldAvoidScrolling:convertedPoint event:event]){
			return YES;
		}
	}
	return NO;
}

@end
