//
//  ViewController.m
//  Rock
//
//  Created by Nick on 20/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "ViewController.h"
#import "AudioSampler.h"
#import "KRMotionTracker.h"

#define kNumberOfColors 5
#define kScreenWidth   [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height

#define kColorViewStartTag 10

@interface ViewController () <KRMotionTypeDelegate, KRMotionTrackerDelegate>{
    LegacyColorAnalyzer * _colorAnalyzer;
    KRMotionTracker * _motionTracker;
    AudioSampler * _sampler;
}
@property (weak) IBOutlet UILabel * motionQuantityLabel;
@property (weak) IBOutlet UILabel * motionTypeLabel;
@end

@implementation ViewController

- (void) tick {
    [_sampler sendNoteOnToInstrument:0 midiKey:28 + arc4random()%30 velocity:70];
    [NSTimer scheduledTimerWithTimeInterval:arc4random()%10 * 0.1f target:self selector:@selector(tick) userInfo:nil repeats:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	   
    _sampler = [[AudioSampler alloc] init];
    [_sampler setupOnComplete:^{
//        [self tick];
    }];
    
#if !TARGET_IPHONE_SIMULATOR    
    
    // To run it only on device
    
    _motionTracker = [KRMotionTracker new];
    _motionTracker.delegate = self;
    [_motionTracker start];
    
    _colorAnalyzer = [[LegacyColorAnalyzer alloc] init];
    _colorAnalyzer.delegate = self;
    _colorAnalyzer.numberOfColors = kNumberOfColors;
    [_colorAnalyzer start];

    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    CGFloat yOffset = 40.f;
    CGFloat height = 200.f;
    CGFloat width = kScreenWidth / kNumberOfColors;
    
    for ( int i = 0; i < kNumberOfColors; ++i ) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(i * width, yOffset, width, height)];
        view.tag = kColorViewStartTag + i;
        [self.view addSubview:view];
    }
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark KRMotionTrackerDelegate Methods

- (void) newMotionValue:(KRSpeed)speed{
    NSString * title = @"";
    switch (speed) {
        case kSlowSpeed:
            title = @"slow";
            break;
            
        case kMediumSpeed:
            title = @"normal";
            break;
            
        case kFastSpeed:
            title = @"fast";
            break;
    };
	_motionQuantityLabel.text = title;
}

- (void) shakeDetected{
	[_sampler sendNoteOnToInstrument:0 midiKey:28 + arc4random()%30 velocity:70];
	NSLog(@"Shake!");
}

#pragma mark -
#pragma mark KRMotionTypeDelegate Methods

- (void) newMotionType:(KRMotionType)type{
	NSString * title = @"";
	switch (type) {
		case kStationary:
			title = @"stationary";
			break;
		case kWalking:
			title = @"walking";
			break;
		case kRunning:
			title = @"running";
			break;
		case kAutomotive:
			title = @"automotive";
			break;
		default:
			title = @"Motion type unknown";
			break;
	}
	_motionTypeLabel.text = title;
}

- (void) noWayToGetLocationType{
// Propose we outta start some timer-based process to affect what motion types supposed to affect )
	NSLog(@"No way!");
}

#pragma mark Color analyzer

- (void) colorsDidChanged:(NSArray *)colorsArray {
    
    for ( int i = 0; i < kNumberOfColors; ++i ) {
        
        UIView * view = [self.view viewWithTag:kColorViewStartTag + i];
        
        if ( i < colorsArray.count ) {
            [view setBackgroundColor:colorsArray[i]];
        } else {
            [view setBackgroundColor:[UIColor lightGrayColor]];
        }
    }
    
}


@end
