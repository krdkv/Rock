//
//  ViewController.m
//  Rock
//
//  Created by Nick on 20/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "DebugViewController.h"
#import "KRMotionTracker.h"
#import "Player.h"
#import "Knob.h"

#define kNumberOfColors 5
#define kScreenWidth   [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height

#define kColorViewStartTag 10

@interface DebugViewController () <KRMotionTrackerDelegate>{
    KRMotionTracker * _motionTracker;
    __block Player * _player;
	UIImage * _image;
    Knob * _knob;
}
@property (strong) KRColorAnalyzer *colorAnalyzer;
@property (weak) IBOutlet UILabel * motionQuantityLabel;
@property (weak) IBOutlet UILabel * motionTypeLabel;
@property (weak) IBOutlet UILabel * gpsSpeedLabel;
@property (weak) IBOutlet UILabel * xAcceleration;
@property (weak) IBOutlet UILabel * yAcceleration;
@property (weak) IBOutlet UILabel * zAcceleration;

@property (weak) IBOutlet UIImageView * scaledImageView;
@end

@implementation DebugViewController

static int tickNumber = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _knob = [[Knob alloc] initWithFrame:CGRectMake(-30.f, 50.f, 130.f*3, 130.f*3)];
    _knob.userInteractionEnabled = YES;
    
    tickNumber = 0;
    
    __block DebugViewController * me = self;
    
    _knob.onTick = ^{

        [me tickWithNumber:tickNumber];
        
        ++tickNumber;
        if ( tickNumber == 32 ) {
            tickNumber = 0;
        }
    };
    
    _player = [[Player alloc] init];
    [_player setOverheadVolume:100];
    [_player setIntensity:1.f andColorsArray:@[]];
//    [_player start];
    
#if !TARGET_IPHONE_SIMULATOR
    
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
	
	_colorAnalyzer = [KRColorAnalyzer new];
	_colorAnalyzer.numberOfColors = 10.0;
		
	NSString * type = [_colorAnalyzer getTypeForImage:_image];
    NSLog(@"Color is %@", type);
	
	_motionTracker = [KRMotionTracker new];
    _motionTracker.delegate = self;
    [_motionTracker startMotionDetecting];

}

- (void)tickWithNumber:(int)tick {
//    [_player tickWithNumber:tick];
}

- (IBAction)tempoChanged:(UISlider*)sender
{
    [_player setTempo:sender.value];
	

}

static CGPoint lastPoint;

- (void) changed:(CGPoint)point {
    
    if ( ABS(lastPoint.x - point.x) > 40 ) {
        lastPoint = point;
        [_player soloNoteOn:arc4random()%7 :arc4random()%7];
//        [_player playSolo:point];
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ( touches.count > 0 ) {
        UITouch * touch = [touches allObjects][0];
        CGPoint point = [touch locationInView:self.view];
        [self changed:point];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ( touches.count > 0 ) {
        UITouch * touch = [touches allObjects][0];
        CGPoint point = [touch locationInView:self.view];
        [self changed:point];
    }
}

- (void) setupWithImage:(UIImage *)image
{
	_image = image;
}

- (void) tiltAction
{
	AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

#pragma mark -
#pragma mark KRMotionTrackerDelegate Methods

- (void) logGPSSpeed:(CGFloat)speed
{
//    _gpsSpeedLabel.text = [NSString stringWithFormat:@"%f", speed];
}

- (void) newMotionValue:(KRSpeed)speed
{
    return;
    NSString * title = @"";
    switch (speed) {
        case kSlowSpeed:
            title = @"slow";
            [_player setTempo:120];
            break;
            
        case kMediumSpeed:
            title = @"normal";
            [_player setTempo:150];
            break;
            
        case kFastSpeed:
            title = @"fast";
            [_player setTempo:210];
            break;
    };
	_motionQuantityLabel.text = title;
}

- (void) shakeDetected
{
	NSLog(@"Shake!");
}

#pragma mark -
#pragma mark KRMotionTypeDelegate Methods

- (void) xDistanceChanged:(CGFloat)distance{
	_xAcceleration.text = [NSString stringWithFormat:@"%f", distance];
}

- (void) motionUpdatedWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{
	_xAcceleration.text = [NSString stringWithFormat:@"%f", x];
	_yAcceleration.text = [NSString stringWithFormat:@"%f", y];
	_zAcceleration.text = [NSString stringWithFormat:@"%f", z];
}

- (void) attitudeUpdatedWithPitch:(CGFloat)pitch roll:(CGFloat)roll yaw:(CGFloat)yaw
{
//	_xAcceleration.text = [NSString stringWithFormat:@"%f", pitch];
//	_yAcceleration.text = [NSString stringWithFormat:@"%f", roll];
//	_zAcceleration.text = [NSString stringWithFormat:@"%f", yaw];
}

- (void) newMotionRawValue:(CGFloat)rawValue
{
//	NSLog(@"lalala");
	dispatch_async(dispatch_get_main_queue(), ^{
		_gpsSpeedLabel.text = [NSString stringWithFormat:@"%.3f", rawValue];
	});
	
}
- (void) newMotionType:(KRMotionType)type
{
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

- (void) noWayToGetLocationType
{
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
