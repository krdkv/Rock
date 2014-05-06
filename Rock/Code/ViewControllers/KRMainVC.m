//
//  KRMainVC.m
//  Rock
//
//  Created by Anton Chebotov on 01/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRMainVC.h"
#import "KRSoloInstrumentVC.h"
#import "KRWalkingSpeedVC.h"

@interface KRMainVC ()
{
}
@property (weak) IBOutlet UIScrollView * contentScrollView;
@end

@implementation KRMainVC

- (void)viewDidLoad
{
    [super viewDidLoad];

	KRSoloInstrumentVC * soloVC = [[KRSoloInstrumentVC alloc] init];
	[self addChildViewController:soloVC];
	
	KRWalkingSpeedVC * speedVC = [[KRWalkingSpeedVC alloc] init];
	[self addChildViewController:speedVC];
}

- (void) addChildViewController:(UIViewController *)childController
{
	int count = self.childViewControllers.count;
	self.contentScrollView.contentSize = CGSizeMake(_contentScrollView.frame.size.width * (count + 1),
													_contentScrollView.frame.size.height);
	
	[super addChildViewController:childController];
	[self.contentScrollView addSubview:childController.view];
	[childController didMoveToParentViewController:self];
	
	CGRect frame = childController.view.frame;
	frame.origin = CGPointMake(_contentScrollView.frame.size.width * count, 0.0);
	childController.view.frame = frame;
}

@end
