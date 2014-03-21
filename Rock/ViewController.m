//
//  ViewController.m
//  Rock
//
//  Created by Nick on 20/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "ViewController.h"
#import "AudioSampler.h"

#define kNumberOfColors 5
#define kScreenWidth   [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height

#define kColorViewStartTag 10
#define kSpeedLabelTag 5

@interface ViewController () {
    LegacyColorAnalyzer * _colorAnalyzer;
    LegacySpeedTracker * _speedTracker;
    AudioSampler * _sampler;
}

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
        [self tick];
    }];
    
#if !TARGET_IPHONE_SIMULATOR    
    
    // To run it only on device
    
    _speedTracker = [[LegacySpeedTracker alloc] init];
    _speedTracker.delegate = self;
    [_speedTracker start];
    
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
    
    UILabel * speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 240.f, kScreenWidth, 72.f)];
    speedLabel.backgroundColor = [UIColor clearColor];
    [speedLabel setFont:[UIFont boldSystemFontOfSize:36.f]];
    [speedLabel setTextAlignment:NSTextAlignmentCenter];
    [speedLabel setTextColor:[UIColor blackColor]];
    [speedLabel setTag:kSpeedLabelTag];
    [self.view addSubview:speedLabel];
    
#endif
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Speed tracker

- (void) didChangedSpeed:(Speed)speed {
    
    UILabel * speedLabel = (UILabel*)[self.view viewWithTag:kSpeedLabelTag];
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
    }
    
    [speedLabel setText:title];
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
