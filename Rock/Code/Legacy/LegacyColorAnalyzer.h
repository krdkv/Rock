//
//  ColorAnalyzer.h
//  Jazz
//
//  Created by Nick on 26/09/2013.
//  Copyright (c) 2013 Tenere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol ColorAnalyzerDelegate

- (void) colorsDidChanged:(NSArray*)colorsArray;

@end

@interface LegacyColorAnalyzer : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (assign, nonatomic) NSInteger numberOfColors;
@property (weak, nonatomic) id<ColorAnalyzerDelegate> delegate;

- (void) start;
- (NSInteger) colorMatchesGroup:(UIColor*)color;

@end
