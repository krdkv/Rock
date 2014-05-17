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

@interface KRMainVC () <KRSpinningWheelDelegate, KRSoloInstrumentDelegate, UIScrollViewDelegate>
{
	UIImage * _image;
	KRSpinningWheelVC * _spinningWheelVC;
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
	
	_spinningWheelVC = [[KRSpinningWheelVC alloc] init];
	_spinningWheelVC.delegate = self;
	[self addChildViewController:_spinningWheelVC];
	
	_contentScrollView.delegate = self;
	
	KRColorAnalyzer * colorAnalyzer = [KRColorAnalyzer new];
	NSString * type = [colorAnalyzer getTypeForImage:_image];
	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Color is..."
													 message:type
													delegate:nil
										   cancelButtonTitle:@"Oh gosh"
										   otherButtonTitles:nil];
	[alert show];
	
	_player = [[Player alloc] init];
#warning get intensity and colors from image
	[_player setIntensity:1 andColorsArray:@[]];
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

- (void) startPlayer
{
	[_player start];
	[_playStopButton setTitle:@"stop" forState:UIControlStateNormal];
}
- (void) stopPlayer
{
	[_player stop];
	[_playStopButton setTitle:@"play" forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark IBActions
- (IBAction) playStopAction
{
	if(_player.isPlaying){
		[self stopPlayer];
	}
	else{
		[self startPlayer];
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
}

- (void) soloNoteOff:(int)x :(int)y
{
	[_player soloNoteOff:x :y];
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

#pragma mark UIScrollViewDelegate Methods

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGFloat x = scrollView.contentOffset.x;
	CGFloat wheelVCOffset = _spinningWheelVC.view.frame.origin.x;
	
	if(x < wheelVCOffset + 1 && x > wheelVCOffset - 1){
		[self stopPlayer];
		_playStopButton.enabled = NO;
	}
	else{
		_playStopButton.enabled = YES;
	}
}


@end
