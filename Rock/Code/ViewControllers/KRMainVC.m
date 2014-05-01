//
//  KRMainVC.m
//  Rock
//
//  Created by Anton Chebotov on 01/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRMainVC.h"

@interface KRMainVC ()
{
}
@property (weak) IBOutlet UIScrollView * contentScrollView;
@end

@implementation KRMainVC

- (void)viewDidLoad
{
    [super viewDidLoad];

	UIViewController * one = [[UIViewController alloc] init];
	one.view.backgroundColor = [UIColor orangeColor];
	[self addChildViewController:one];
	
	UIViewController * two = [[UIViewController alloc] init];
	two.view.backgroundColor = [UIColor greenColor];
	[self addChildViewController:two];
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
