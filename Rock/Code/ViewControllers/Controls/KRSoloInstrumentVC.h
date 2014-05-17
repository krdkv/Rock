//
//  KRSoloInstrumentVC.h
//  Rock
//
//  Created by Anton Chebotov on 01/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KRSoloInstrumentDelegate
- (void) soloNoteOn:(int)x :(int)y;
- (void) soloNoteOff:(int)x :(int)y;
- (void) playSoloWithTilt:(CGFloat)tilt;
@end

@interface KRSoloInstrumentVC : UIViewController

@end
