//
//  KRGridView.m
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRGridView.h"

@implementation KRGridView

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.alpha += 0.2;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.alpha -= 0.2;
}

@end
