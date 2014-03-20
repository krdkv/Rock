//
//  SpeedTracker.h
//  Jazz
//
//  Created by Nick on 26/09/2013.
//  Copyright (c) 2013 Tenere. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSlowSpeed = 0,
    kMediumSpeed,
    kFastSpeed
} Speed;

@protocol SpeedTrackerDelegate

- (void) didChangedSpeed:(Speed)speed;

@end

@interface LegacySpeedTracker : NSObject <UIAccelerometerDelegate>

@property (weak, nonatomic) id<SpeedTrackerDelegate> delegate;
- (void) start;

@end
