//
//  KRGridView.m
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRGridElementView.h"

@implementation KRGridElementView

- (void) setActivityCount:(NSInteger)activityCount
{
	_activityCount = activityCount;
	CGFloat alpha = 0.2 + _activityCount * 0.2;
	alpha = MIN(alpha, 1.0);
	self.alpha = alpha;
}

@end
