//
//  ColorAnalyzer.m
//  Jazz
//
//  Created by Nick on 26/09/2013.
//  Copyright (c) 2013 Tenere. All rights reserved.
//

#import "DynamicColorAnalyzer.h"

struct ColorUnit {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    unsigned int frequency;
};

@interface DynamicColorAnalyzer() {
    EAGLContext *context;
    CIContext *coreImageContext;
    AVCaptureSession *session;
    GLuint renderBuffer;
}

@end

@implementation DynamicColorAnalyzer

- (id)init
{
    self = [super init];
    if (self) {
		_numberOfColors = 1;
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return self;
}

- (void) start
{
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
    coreImageContext = [CIContext contextWithEAGLContext:context];
    
    NSError * error;
    session = [[AVCaptureSession alloc] init];
    
    [session beginConfiguration];
    [session setSessionPreset:AVCaptureSessionPreset640x480];
    
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    [session addInput:input];
    
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [session addOutput:dataOutput];
    [session commitConfiguration];
    [session startRunning];
}

- (void) stop
{
	[session stopRunning];
}

bool componentsAreClose(uint8_t a, uint8_t b) {
    return a - b < 30;
}

bool isDarkPixel(const uint8_t* color) {
    return color[0] < 15.f || color[1] < 15.f || color[2] < 15.f;
}

void quickSortR(struct ColorUnit a[], long N) {
    
    long i = 0, j = N;
    struct ColorUnit temp, p;
    
    p = a[ N>>1 ];
    
    do {
        while ( a[i].frequency < p.frequency ) i++;
        while ( a[j].frequency > p.frequency ) j--;
        
        if (i <= j) {
            temp = a[i]; a[i] = a[j]; a[j] = temp;
            i++; j--;
        }
    } while ( i<=j );
    
    if ( j > 0 ) quickSortR(a, j);
    if ( N > i ) quickSortR(a+i, N-i);
}

static int counter = 0;

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    ++counter;
    if ( counter == 10 ) {
        counter = 0;
    }
    if ( counter != 5 ) {
        return;
    }
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    image = [image imageByApplyingTransform:CGAffineTransformMakeScale(0.01f, 0.01f)];
    
    CGImageRef cgimage = [coreImageContext createCGImage:image fromRect:image.extent];
    
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
    const uint8_t* bytes = [data bytes];
    
    struct ColorUnit recordArray[width * height];
    
    int k = 0;
    for(size_t row = 0; row < height; row++)
    {
        for(size_t col = 0; col < width; col++)
        {
            const uint8_t* pixel = &bytes[row * bpr + col * bytes_per_pixel];
            
            if ( isDarkPixel(pixel) ) {
                continue;
            }
            
            bool needToUpdate = true;
            for ( int i = 0; i < k - 1; ++i ) {
                
                if ( componentsAreClose(pixel[0], recordArray[i].red) &&
                    componentsAreClose(pixel[1], recordArray[i].green) &&
                    componentsAreClose(pixel[2], recordArray[i].blue))
                {
                    needToUpdate = false;
                    recordArray[i].frequency++;
                    break;
                }
            }
            
            if ( needToUpdate ) {
                struct ColorUnit unit;
                unit.red = pixel[0];
                unit.green = pixel[1];
                unit.blue = pixel[2];
                unit.frequency = 1;
                recordArray[k++] = unit;
            }
        }
    }
    
    quickSortR(recordArray, k);
    
    NSMutableArray * colors = [[NSMutableArray alloc] init];
    
    for ( int i = 0; i < k; ++i ) {
        if ( i == self.numberOfColors ) {
            break;
        }
        int index = k - 1 - i;
        CGFloat red = ((CGFloat)recordArray[index].red)/255;
        CGFloat green = ((CGFloat)recordArray[index].green)/255;
        CGFloat blue = ((CGFloat)recordArray[index].blue)/255;
        [colors addObject:[UIColor colorWithRed:red green:green blue:blue alpha:1.f]];
    }
    
    if ( self.delegate ) {
        [self.delegate mostPopularColorChanged:colors[0]];
    }
}

- (NSInteger) colorMatchesGroup:(UIColor*)color {
    
    NSArray * colorGroups = @[[UIColor redColor], [UIColor yellowColor], [UIColor greenColor], [UIColor cyanColor], [UIColor blueColor], [UIColor magentaColor]];
    
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

@end
