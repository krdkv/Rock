//
//  KRSoloInstrumentVC.m
//  Rock
//
//  Created by Anton Chebotov on 01/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRSoloInstrumentVC.h"

@interface KRSoloInstrumentVC ()

@end

@implementation KRSoloInstrumentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = [touches anyObject];
	CGPoint point = [touch locationInView:self.view];
	NSString * message = [NSString stringWithFormat:@"x:%.1f y:%.1f", point.x, point.y];
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Tap-tap"
													 message:message
													delegate:nil
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
	[alert show];
}
@end
