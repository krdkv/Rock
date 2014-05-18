//
//  KRSpeedometerView.m
//  Rock
//
//  Created by Anton Chebotov on 18/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRSpeedometerView.h"

@interface KRSpeedometerView ()
{
	
}
@property (strong) UIImageView * scaleView;
@property (strong) UIImageView * arrowView;

@property (assign, nonatomic) CGFloat value;
@end

@implementation KRSpeedometerView

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
	if(self){
		[self initialize];
	}
	return self;
}

- (void) initialize
{
	_scaleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scale.png"]];
	_scaleView.center = CGPointMake(_scaleView.frame.size.width, _scaleView.frame.size.height);
	[self addSubview:_scaleView];
	
	_arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
	_arrowView.center = _scaleView.center;
	[self addSubview:_arrowView];
	
	self.value = - 1.5;
}

- (void) setValue:(CGFloat) value
{
	_value = value;
	_arrowView.transform = CGAffineTransformMakeRotation(value);
}

- (void) poke
{
	self.value += 0.1;
	[self performSelector:@selector(unpoke) withObject:nil afterDelay:1.0];
}

- (void) unpoke
{
	self.value -= 0.1;
}

@end
