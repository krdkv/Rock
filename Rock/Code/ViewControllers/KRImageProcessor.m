//
//  KRImageProcessor.m
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRImageProcessor.h"

@implementation KRImageProcessor

+ (UIImage *) blur:(UIImage*)theImage width:(CGFloat)width height:(CGFloat)height;
{
	CGFloat blurValue = 10.0;
	
    theImage = [self reOrientIfNeeded:theImage];
	
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
	
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:blurValue] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
		
	CGSize imageSize = theImage.size;
	CGRect rect = CGRectMake(imageSize.width/2.0 - width * (imageSize.height - 2*blurValue)/(2.0*height),
							 blurValue,
							 width * (imageSize.height - 2*blurValue)/height,
							 imageSize.height - 2 * blurValue);
	
    CGImageRef cgImage = [context createCGImage:result fromRect:rect];
	
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
	
    return returnImage;
}

+ (UIImage*) reOrientIfNeeded:(UIImage*)theImage
{
    if (theImage.imageOrientation != UIImageOrientationUp) {
        CGAffineTransform reOrient = CGAffineTransformIdentity;
        switch (theImage.imageOrientation) {
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, theImage.size.height);
                reOrient = CGAffineTransformRotate(reOrient, M_PI);
                break;
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, 0);
                reOrient = CGAffineTransformRotate(reOrient, M_PI_2);
                break;
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, 0, theImage.size.height);
                reOrient = CGAffineTransformRotate(reOrient, -M_PI_2);
                break;
            case UIImageOrientationUp:
            case UIImageOrientationUpMirrored:
                break;
        }
		
        switch (theImage.imageOrientation) {
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDownMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, 0);
                reOrient = CGAffineTransformScale(reOrient, -1, 1);
                break;
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.height, 0);
                reOrient = CGAffineTransformScale(reOrient, -1, 1);
                break;
            case UIImageOrientationUp:
            case UIImageOrientationDown:
            case UIImageOrientationLeft:
            case UIImageOrientationRight:
                break;
        }
		
        CGContextRef myContext = CGBitmapContextCreate(NULL, theImage.size.width, theImage.size.height, CGImageGetBitsPerComponent(theImage.CGImage), 0, CGImageGetColorSpace(theImage.CGImage), CGImageGetBitmapInfo(theImage.CGImage));
		
        CGContextConcatCTM(myContext, reOrient);
		
        switch (theImage.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                CGContextDrawImage(myContext, CGRectMake(0,0,theImage.size.height,theImage.size.width), theImage.CGImage);
                break;
				
            default:
                CGContextDrawImage(myContext, CGRectMake(0,0,theImage.size.width,theImage.size.height), theImage.CGImage);
                break;
        }
		
        CGImageRef CGImg = CGBitmapContextCreateImage(myContext);
        theImage = [UIImage imageWithCGImage:CGImg];
		
        CGImageRelease(CGImg);
        CGContextRelease(myContext);
    }
	
    return theImage;
}

@end
