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
#import "KRImageProcessor.h"
#import "KRSpeedometerView.h"

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
@property (weak) IBOutlet UIImageView * backgroundImageView;
@property (weak) IBOutlet KRSpeedometerView * speedometerView;

- (IBAction) playStopAction;

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
	
	
	UIImage * blurredImage = [KRImageProcessor blur:_image
											  width:self.view.frame.size.width
											 height:self.view.frame.size.height];
	_backgroundImageView.image = blurredImage;
	
	KRColorAnalyzer * colorAnalyzer = [KRColorAnalyzer new];
	NSArray * colors = [colorAnalyzer getColorsForImage:_image];
	CGFloat intensity = (CGFloat)colors.count / 7;
		
	_player = [[Player alloc] init];
    [_player setOverheadVolume:100];
	[_player setIntensity:intensity andColorsArray:colors];
	
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
	[_playStopButton setSelected:YES];
}
- (void) stopPlayer
{
	[_player stop];
	[_playStopButton setSelected:NO];
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
	[_speedometerView poke];
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

- (void) newMotionRawValue:(CGFloat)rawValue
{
	if(rawValue > 5){
		_motionSum += rawValue;
	}
	if(_motionSum > 70){
		[_player tickWithNumber:1];
		dispatch_async(dispatch_get_main_queue(), ^{
			[_speedometerView poke];
		});

		_motionSum = _motionSum % 70;
	}
}
- (void) tiltValue:(CGFloat)value
{
	CGFloat normalizedTilt = value / M_PI_2;
	[_player playSoloWithTilt:normalizedTilt];
	[_speedometerView setValue:normalizedTilt];
}

#pragma mark -
#pragma mark KREffectsVCDelegate
- (void) guitarEffectColorSelected:(UIColor *)color
{
	[_player setEffectColorForInstrument:2 color:color];
}
- (void) bassEffectColorSelected:(UIColor *)color
{
	[_player setEffectColorForInstrument:0 color:color];
}
- (void) drumsEffectColorSelected:(UIColor *)color
{
	[_player setEffectColorForInstrument:1 color:color];
}


@end
