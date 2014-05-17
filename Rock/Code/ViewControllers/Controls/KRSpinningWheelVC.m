//
//  KRWalkingSpeedVC.m
//  Rock
//
//  Created by Anton Chebotov on 01/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRSpinningWheelVC.h"
#import "Knob.h"

@interface KRSpinningWheelVC ()

@property (weak) IBOutlet Knob * knob;
@end

@implementation KRSpinningWheelVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[_knob setOnTick:^{
		[self tick];
	}];
}

- (void) tick
{
	NSLog(@"tick");
}

@end
