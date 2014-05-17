//
//  ColorAnalyzer.h
//  Jazz
//
//  Created by Nick on 26/09/2013.
//  Copyright (c) 2013 Tenere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol DynamicColorAnalyzerDelegate

- (void) mostPopularColorChanged:(UIColor *)color;

@end

@interface DynamicColorAnalyzer : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (assign, nonatomic) NSInteger numberOfColors;
@property (weak, nonatomic) id<DynamicColorAnalyzerDelegate> delegate;

- (void) start;
- (void) stop;
- (NSInteger) colorMatchesGroup:(UIColor*)color;

@end
