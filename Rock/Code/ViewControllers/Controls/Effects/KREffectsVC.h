//
//  KREffectsVC.h
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KREffectsVCDelegate

- (void) guitarEffectColorSelected:(UIColor *)color;
- (void) bassEffectColorSelected:(UIColor *)color;
- (void) drumsEffectColorSelected:(UIColor *)color;

@end

@interface KREffectsVC : UIViewController
@property (weak) id <KREffectsVCDelegate> delegate;
- (void) stopEffectsSelection;
@end
