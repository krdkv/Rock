//
//  KRMotionTracker.h
//  Rock
//
//  Created by Anton Chebotov on 22/03/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSlowSpeed = 0,
    kMediumSpeed,
    kFastSpeed
} KRSpeed;

@protocol KRSpeedTrackerDelegate
- (void) didChangedSpeed:(KRSpeed)speed;
@end

@interface KRMotionTracker : NSObject

@property (weak, nonatomic) id<KRSpeedTrackerDelegate> delegate;
- (void) start;
- (void) stop;

@end



