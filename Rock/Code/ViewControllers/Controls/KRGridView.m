//
//  KRGridView.m
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRGridView.h"
#import "KRGridElementView.h"

#define GRID_OFFSET 1.0f

@implementation KRGridView

- (void) setupWithRows:(NSInteger)rows columns:(NSInteger)columns
{
	CGFloat width = (self.frame.size.width - (columns - 1)*GRID_OFFSET) / columns;
	CGFloat height = (self.frame.size.height - (rows - 1)*GRID_OFFSET) / rows;
	
	for (int i = 0; i < columns; i++){
		for(int j = 0; j < rows; j++){
			
			CGRect frame = CGRectMake((width + GRID_OFFSET) * i, (height + GRID_OFFSET) * j, width, height);
			KRGridElementView * view = [[KRGridElementView alloc] initWithFrame:frame];
			view.backgroundColor = [UIColor whiteColor];
			view.alpha = 0.2;
			
			[self addSubview:view];
		}
	}
}

#pragma mark -
#pragma mark Touches Handling

- (void) redrawElements:(NSSet *) touches
{
	for(UITouch * touch in touches){
		CGPoint point = [touch locationInView:self];
		KRGridElementView * elementView = (KRGridElementView *)[self hitTest:point withEvent:nil];
		elementView.activityCount += 1;
	}
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch * touch in touches){
		CGPoint point = [touch locationInView:self];
		KRGridElementView * elementView = (KRGridElementView *)[self hitTest:point withEvent:nil];
		if([elementView isKindOfClass:[KRGridElementView class]])
		elementView.activityCount += 1;
	}

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch * touch in touches){
		CGPoint point = [touch locationInView:self];
		KRGridElementView * elementView = (KRGridElementView *)[self hitTest:point withEvent:nil];
		if([elementView isKindOfClass:[KRGridElementView class]])
			elementView.activityCount -= 1;
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch * touch in touches){
		
		CGPoint point = [touch locationInView:self];
		KRGridElementView * elementView = (KRGridElementView *)[self hitTest:point withEvent:nil];
		
		CGPoint previousPoint = [touch previousLocationInView:self];
		KRGridElementView * previousElementView = (KRGridElementView *)[self hitTest:previousPoint withEvent:nil];
		
		if(elementView != previousElementView){
			if([elementView isKindOfClass:[KRGridElementView class]]){
				elementView.activityCount += 1;
			}
			if([previousElementView isKindOfClass:[KRGridElementView class]]){
				previousElementView.activityCount -= 1;
			}
		}
	}
}

@end
