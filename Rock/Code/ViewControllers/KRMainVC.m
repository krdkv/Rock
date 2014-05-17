//
//  KRMainVC.m
//  Rock
//
//  Created by Anton Chebotov on 01/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRMainVC.h"
#import "KRMotionTracker.h"
#import "KRSoloInstrumentVC.h"
#import "KRSpinningWheelVC.h"
#import "KRColorAnalyzer.h"
#import "KREffectsVC.h"

#import "Player.h"

@interface KRMainVC () <KRSpinningWheelDelegate, KRSoloInstrumentDelegate, KREffectsVCDelegate, UIScrollViewDelegate, KRMotionTrackerDelegate>
{
	UIImage * _image;
	KRSpinningWheelVC * _spinningWheelVC;
	KRMotionTracker * _motionTracker;
	
	int _motionSum;
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
	
	_motionTracker = [KRMotionTracker new];
	_motionTracker.delegate = self;

	KRSoloInstrumentVC * soloVC = [[KRSoloInstrumentVC alloc] init];
	soloVC.delegate = self;
	[self addChildViewController:soloVC];
	
	_spinningWheelVC = [[KRSpinningWheelVC alloc] init];
	_spinningWheelVC.delegate = self;
	[self addChildViewController:_spinningWheelVC];
	
	KREffectsVC * effectsVC = [[KREffectsVC alloc] init];

	effectsVC.delegate = self;
	[self addChildViewController:effectsVC];
	
	_contentScrollView.delegate = self;
	
	KRColorAnalyzer * colorAnalyzer = [KRColorAnalyzer new];
	NSString * type = [colorAnalyzer getTypeForImage:_image];
		
	_player = [[Player alloc] init];
    [_player setOverheadVolume:150];
#warning get intensity and colors from image
	[_player setIntensity:1 andColorsArray:@[]];
	
	[_motionTracker startTiltDetecting];
}

- (void) addChildViewController:(UIViewController *)childController
{
	NSUInteger count = self.childViewControllers.count;
	CGSize size = CGSizeMake(_contentScrollView.frame.size.width * (count + 1),
							 _contentScrollView.frame.size.height);
	self.contentScrollView.contentSize = size;
	
	CGRect frame = childController.view.frame;
	frame.origin = CGPointMake(_contentScrollView.frame.size.width * count, 0.0);
	frame.size.height = size.height;
	childController.view.frame = frame;
	
	[super addChildViewController:childController];
	[self.contentScrollView addSubview:childController.view];
	[childController didMoveToParentViewController:self];
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
	
	_playStopButton.enabled = YES;
	if(x < 1){
		_motionSum = 0;
		[_motionTracker startTiltDetecting];
	}
	else if(x < wheelVCOffset + 1 && x > wheelVCOffset - 1){
		[self stopPlayer];
		_playStopButton.enabled = NO;
		[_motionTracker startMotionDetecting];
	}
	else{
		[_motionTracker stop];
	}
}

#pragma mark -
#pragma mark KRMotionTrackerDelegate Methods
- (void) newMotionValue:(KRSpeed)speed
{
	NSLog(@"Speed: %i", speed);
	if(speed == kSlowSpeed){
		_motionSum += 0;
	}
	else if (speed == kMediumSpeed){
		_motionSum += 4;
	}
	else{
		_motionSum += 10;
	}
	if(_motionSum > 10){
		[_player tickWithNumber:1];
		_motionSum = _motionSum % 10;
	}
}

- (void) newMotionRawValue:(CGFloat)rawValue
{
	_motionSum += rawValue;
	if(_motionSum > 100){
		[_player tickWithNumber:1];
		_motionSum = _motionSum % 100;
	}
}
- (void) tiltValue:(CGFloat)value
{
	CGFloat normalizedTilt = value / M_PI_2;
	[_player playSoloWithTilt:normalizedTilt];
}

#pragma mark -
#pragma mark KREffectsVCDelegate
- (void) guitarEffectColorSelected:(UIColor *)color
{
	[_player setEffectColorForInstrument:0 color:color];
}
- (void) bassEffectColorSelected:(UIColor *)color
{
	[_player setEffectColorForInstrument:1 color:color];
}
- (void) drumsEffectColorSelected:(UIColor *)color
{
	[_player setEffectColorForInstrument:2 color:color];
}


@end
