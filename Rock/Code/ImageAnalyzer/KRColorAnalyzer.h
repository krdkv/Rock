//
//  ColorAnalyzer.h
//  Jazz
//
//  Created by Nick on 26/09/2013.
//  Copyright (c) 2013 Tenere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
	kRed = 0,
	kYellow,
	kGreen,
	kBlue,
	kWhite,
    kBlack,
	kBrown,
	kAcid,
	kMixed,
	kUnknown,
} KRImageType;

@protocol ColorAnalyzerDelegate
- (void) colorsDidChanged:(NSArray*)colorsArray;
@end

@interface KRColorAnalyzer : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (assign, nonatomic) NSInteger numberOfColors;
@property (weak, nonatomic) id<ColorAnalyzerDelegate> delegate;

- (NSInteger) colorMatchesGroup:(UIColor*)color;

- (NSString *) getTypeForImage:(UIImage *) image;
- (NSArray *) getColorsForImage:(UIImage *) image;

@end
