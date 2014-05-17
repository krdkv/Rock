//
//  KRMainVC.m
//  Rock
//
//  Created by Anton Chebotov on 01/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRMainVC.h"
#import "KRSoloInstrumentVC.h"
#import "KRSpinningWheelVC.h"
#import "KRColorAnalyzer.h"

@interface KRMainVC ()
{
	UIImage * _image;
}
@property (weak) IBOutlet UIScrollView * contentScrollView;

- (IBAction) stopAction;
- (IBAction) rewindAction;
@end

@implementation KRMainVC

- (void)viewDidLoad
{
    [super viewDidLoad];

	KRSoloInstrumentVC * soloVC = [[KRSoloInstrumentVC alloc] init];
	[self addChildViewController:soloVC];
	
	KRSpinningWheelVC * speedVC = [[KRSpinningWheelVC alloc] init];
	[self addChildViewController:speedVC];
	
	KRColorAnalyzer * colorAnalyzer = [KRColorAnalyzer new];
	NSString * type = [colorAnalyzer getTypeForImage:_image];
	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Color is..."
													 message:type
													delegate:nil
										   cancelButtonTitle:@"Oh gosh"
										   otherButtonTitles:nil];
	[alert show];

}

- (void) addChildViewController:(UIViewController *)childController
{
	NSUInteger count = self.childViewControllers.count;
	self.contentScrollView.contentSize = CGSizeMake(_contentScrollView.frame.size.width * (count + 1),
													_contentScrollView.frame.size.height);
	
	[super addChildViewController:childController];
	[self.contentScrollView addSubview:childController.view];
	[childController didMoveToParentViewController:self];
	
	CGRect frame = childController.view.frame;
	frame.origin = CGPointMake(_contentScrollView.frame.size.width * count, 0.0);
	childController.view.frame = frame;
}

- (void) setupWithImage:(UIImage *)image
{
	_image = image;
}



#pragma mark -
#pragma mark IBActions

- (IBAction) stopAction
{
	
}
- (IBAction) rewindAction
{
	
}


@end
