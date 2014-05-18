//
//  KRWalkingSpeedVC.h
//  Rock
//
//  Created by Anton Chebotov on 01/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KRSpinningWheelDelegate
- (void)tick;
@end

@interface KRSpinningWheelVC : UIViewController
@property (weak) id <KRSpinningWheelDelegate> delegate;
- (void) startAutoSpin;
- (void) stopAutospin;
@end
