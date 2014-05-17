//
//  KRScrollView.m
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRScrollView.h"
#import "KRGridView.h"
#import "UIView+RecursiveSearch.h"

@implementation KRScrollView


- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	if([self shouldAvoidScrolling:point event:event]){
		self.scrollEnabled = NO;
	}
	else{
		self.scrollEnabled = YES;
	}

	return [super pointInside:point withEvent:event];
}

@end
