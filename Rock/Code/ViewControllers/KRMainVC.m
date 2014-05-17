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

#import "Player.h"

@interface KRMainVC () <KRSpinningWheelDelegate, KRSoloInstrumentDelegate>
{
	UIImage * _image;
}
@property (strong) Player * player;
@property (weak) IBOutlet UIScrollView * contentScrollView;
@property (weak) IBOutlet UIButton * playStopButton;

- (IBAction) playStopAction;
- (IBAction) rewindAction;
@end

@implementation KRMainVC

- (void)viewDidLoad
{
    [super viewDidLoad];

	KRSoloInstrumentVC * soloVC = [[KRSoloInstrumentVC alloc] init];
	soloVC.delegate = self;
	[self addChildViewController:soloVC];
	
	KRSpinningWheelVC * speedVC = [[KRSpinningWheelVC alloc] init];
	speedVC.delegate = self;
	[self addChildViewController:speedVC];
	
	_contentScrollView.delaysContentTouches = NO;
	
	KRColorAnalyzer * colorAnalyzer = [KRColorAnalyzer new];
	NSString * type = [colorAnalyzer getTypeForImage:_image];
	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Color is..."
													 message:type
													delegate:nil
										   cancelButtonTitle:@"Oh gosh"
										   otherButtonTitles:nil];
	[alert show];
	
	_player = [[Player alloc] init];
	[_player start];

}

- (void) addChildViewController:(UIViewController *)childController
{
	NSUInteger count = self.childViewControllers.count;
	CGSize size = CGSizeMake(_contentScrollView.frame.size.width * (count + 1),
							 _contentScrollView.frame.size.height);
	self.contentScrollView.contentSize = size;
	
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
- (IBAction) playStopAction
{
	if(_player.isPlaying){
		[_player stop];
		[_playStopButton setTitle:@"play" forState:UIControlStateNormal];
	}
	else{
		[_player start];
		[_playStopButton setTitle:@"stop" forState:UIControlStateNormal];
	}
}

- (IBAction) rewindAction
{
	
}

#pragma mark -
#pragma mark SoloInstrumentDelegate
- (void) soloNoteOn:(int)x :(int)y
{
	[_player soloNoteOn:x :y];
	NSLog(@"on! x:%i y:%i", x, y);
}

- (void) soloNoteOff:(int)x :(int)y
{
	[_player soloNoteOff:x :y];
	NSLog(@"off! x:%i y:%i", x, y);
}

- (void) playSoloWithTilt:(CGFloat)tilt
{
#warning not implemented!
}


#pragma mark -
#pragma mark SpinningWheelDelegate

- (void) tickWithInteger:(NSInteger)tick
{
	[_player tickWithNumber:(int)tick];
}


@end
