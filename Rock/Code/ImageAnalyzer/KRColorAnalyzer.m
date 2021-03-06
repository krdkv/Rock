//
//  ColorAnalyzer.m
//  Jazz
//
//  Created by Nick on 26/09/2013.
//  Copyright (c) 2013 Tenere. All rights reserved.
//

#import "KRColorAnalyzer.h"
#import "KRColorUnit.h"

@interface KRColorAnalyzer() {
    EAGLContext * _context;
    CIContext *coreImageContext;
    AVCaptureSession *session;
    GLuint renderBuffer;
	
	NSArray * _colorGroups;
}

@end

@implementation KRColorAnalyzer

- (id)init
{
    self = [super init];
    if (self) {
		_colorGroups = [self getColorsUnitsArray];
    }
    return self;
}

- (NSInteger) colorMatchesGroup:(UIColor*)color
{
    
    NSArray * colorGroups = @[[UIColor redColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor], [UIColor whiteColor], [UIColor blackColor]];
    
    CGFloat record = CGFLOAT_MAX;
    NSInteger recordIndex = 0;
    
    CGFloat groupColorRed, groupColorGreen, groupColorBlue,
        colorRed, colorGreen, colorBlue, alpha;
    
    [color getRed:&colorRed green:&colorGreen blue:&colorBlue alpha:&alpha];
    
    for ( int i = 0; i < colorGroups.count; ++i ) {
        
        UIColor * groupColor = colorGroups[i];
        [groupColor getRed:&groupColorRed green:&groupColorGreen blue:&groupColorBlue alpha:&alpha];
        
        CGFloat distance = sqrtf(powf((colorRed - groupColorRed), 2) + powf((colorGreen - groupColorGreen), 2) + powf((colorBlue - groupColorBlue), 2) );
        if ( distance < record ) {
            record = distance;
            recordIndex = i;
        }
    }
    return recordIndex;
}

#pragma mark -
#pragma mark Still Image Analyzing

- (NSArray *) getColorsUnitsArray
{
	return @[[[KRColorUnit alloc] initWithUIColor:[UIColor redColor] name:@"red"],
			 [[KRColorUnit alloc] initWithUIColor:[UIColor yellowColor] name:@"yellow"],
			 [[KRColorUnit alloc] initWithUIColor:[UIColor greenColor] name:@"green"],
			 [[KRColorUnit alloc] initWithUIColor:[UIColor blueColor] name:@"blue"],
			 [[KRColorUnit alloc] initWithUIColor:[UIColor whiteColor] name:@"white"],
			 [[KRColorUnit alloc] initWithRed:0 green:0 blue:0 name:@"black"],
			 [[KRColorUnit alloc] initWithRed:100.0/255.0 green:50.0/255.0 blue:0.0/255.0 name:@"brown"],
			 ];
}

- (CGFloat) distanceBetweenPixel:(const uint8_t *)pixel andColorUnit:(KRColorUnit *)colorUnit
{
	CGFloat distance = sqrtf(powf((pixel[0] - colorUnit.red), 2) + powf((pixel[1] - colorUnit.green), 2) + powf((pixel[2] - colorUnit.blue), 2) );
	return distance;
}

- (NSString *)typeWithFrequencies:(NSArray *)unitsArray pixelsCount:(NSInteger)pixelsCount
{
	NSInteger redFreq = ((KRColorUnit * )unitsArray[0]).frequency;
	NSInteger yellowFreq = ((KRColorUnit * )unitsArray[1]).frequency;
	NSInteger greenFreq = ((KRColorUnit * )unitsArray[2]).frequency;
	NSInteger blueFreq = ((KRColorUnit * )unitsArray[3]).frequency;
	
	int variousColors = 0;
	int treshhold = (int)pixelsCount/6;
	if (greenFreq > treshhold) {
		variousColors ++;
	}
	if(redFreq > treshhold){
		variousColors ++;
	}
	if(blueFreq > treshhold){
		variousColors ++;
	}
	if(yellowFreq > treshhold){
		variousColors ++;
	}
	if(variousColors > 2){
		return @"acid";
	}

	int maxFreq = 0;
	int index = 0;
	for(int i = 0; i < unitsArray.count; i++){
		NSInteger freq = ((KRColorUnit * )unitsArray[i]).frequency;
		if(freq > maxFreq){
			maxFreq = freq;
			index = i;
		}
	}
	
	return ((KRColorUnit * )unitsArray[index]).description;
}

- (NSArray *) getColorsWithFrequencies:(NSArray *)unitsArray pixelsCount:(NSInteger)pixelsCount
{
	NSMutableArray * result = [NSMutableArray new];
	for(int i = 0; i < unitsArray.count; i++){
		KRColorUnit * unit = unitsArray[i];
		NSInteger freq = unit.frequency;
		if(freq > pixelsCount / 10){
			[result addObject:unit.color];
		}
	}
	return result;
}

- (CGImageRef)scaleCGImage:(CGImageRef)image toWidth:(int)width andHeight:(int)height
{
	CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
	CGContextRef context = CGBitmapContextCreate(NULL,
												  width,
												  height,
												 CGImageGetBitsPerComponent(image),
												 CGImageGetBytesPerRow(image),
												 colorspace,
												 CGImageGetAlphaInfo(image));
	CGColorSpaceRelease(colorspace);
	
	if(context == NULL)
		return nil;
	
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
	
	CGImageRef imgRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	return imgRef;
}

- (NSArray *) getColorsForImage:(UIImage *)originalImage
{
	if(!originalImage){
		return @[];
	}

	CGImageRef cgimage = originalImage.CGImage;
	
	cgimage = [self scaleCGImage:cgimage toWidth:100 andHeight:100];
	
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
	
    
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    NSData * data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
    const uint8_t* bytes = [data bytes];
	
	
    for(size_t row = 0; row < height; row++)
    {
        for(size_t col = 0; col < width; col++)
        {
            const uint8_t * pixel = &bytes[row * bpr + col * bytes_per_pixel];
			KRColorUnit * unit = [self getColorUnitForPixel:pixel colorUnits:_colorGroups];
			unit.frequency ++;
        }
    }
	return [self getColorsWithFrequencies:_colorGroups pixelsCount:width * height];
}

- (KRColorUnit *) getColorUnitForPixel:(const uint8_t *)pixel colorUnits:(NSArray *)colorUnits
{
	CGFloat record = CGFLOAT_MAX;
	NSInteger recordIndex = 0;
	
	for (int i = 0; i < colorUnits.count ; i++) {
		KRColorUnit * unit = colorUnits[i];
		CGFloat distance = [self distanceBetweenPixel:pixel andColorUnit:unit];
		if ( distance < record ) {
			record = distance;
			recordIndex = i;
		}
	}
	KRColorUnit * result = colorUnits[recordIndex];
	return result;
}

@end
