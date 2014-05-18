//
//  Knob.m
//  Rock
//
//  Created by Nick on 13/05/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "Knob.h"

#define kDefaultImageName @"knob"
#define kScale 55

@interface Knob() {
    UIImageView * _imageView;
    int _currentLeftBorder;
	BOOL _autospin;
}

@end

@implementation Knob

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    if (self) {
		[self initialize];
    }
    return self;
}

- (void) initialize
{
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height)];
	[_imageView setBackgroundColor:[UIColor clearColor]];
	[_imageView setImage:[UIImage imageNamed:kDefaultImageName]];
	[self addSubview:_imageView];
	
	_currentLeftBorder = -1;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self stopAutospin];
    CGPoint Location = [[touches anyObject] locationInView:self];
    
    int x = _imageView.center.x;
    int y = _imageView.center.y;
    
    float dx = Location.x - x;
    float dy = Location.y - y;
    
    CGFloat angle = atan2(-dx,dy);
    
    _imageView.layer.position = _imageView.center;
    _imageView.layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
        
    CGFloat angleAfter = atan2f(_imageView.transform.b, _imageView.transform.a) * (180 / M_PI);
    angleAfter += 180.f;
    
    CGFloat newBorder = floor(angleAfter / kScale) * kScale;
    
    if ( _currentLeftBorder != newBorder ) {
        _currentLeftBorder = newBorder;
        if ( self.onTick ) {
            self.onTick();
        }
    }
}

- (void) startAutospin
{
	_autospin = YES;
	[self autospin];
}

- (void) stopAutospin
{
	_autospin = NO;
}

- (void) autospin
{
	CGFloat ticksPerSecond = 8;
	CGFloat duration = 1.0/ticksPerSecond;
	CGFloat angle = M_PI/ (4*ticksPerSecond);
	
	[UIView animateWithDuration:duration
						  delay:0.0
						options:UIViewAnimationOptionCurveLinear
					 animations:^{
						 _imageView.layer.transform = CATransform3DRotate(_imageView.layer.transform, angle, 0, 0, 1);
					 }
					 completion:^(BOOL finished) {
						 if(_autospin){
							 [self autospin];
							 
							 if ( self.onTick ) {
								 self.onTick();
							 }
							 
						 }

					 }];
}

@end
