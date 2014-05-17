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

@interface KRGridView ()
{
	
}
@property (strong) NSMutableArray * elements;
@end

@implementation KRGridView

- (void) setupWithRows:(NSInteger)rows columns:(NSInteger)columns
{
	CGFloat width = (self.frame.size.width - (columns - 1)*GRID_OFFSET) / columns;
	CGFloat height = (self.frame.size.height - (rows - 1)*GRID_OFFSET) / rows;
	
	_elements = [NSMutableArray new];
	
	for (int i = 0; i < columns; i++){
		[_elements addObject:[NSMutableArray new]];
		for(int j = 0; j < rows; j++){
			
			CGRect frame = CGRectMake((width + GRID_OFFSET) * i, (height + GRID_OFFSET) * j, width, height);
			KRGridElementView * view = [[KRGridElementView alloc] initWithFrame:frame];
			view.column = i;
			view.row = j;
			view.backgroundColor = [UIColor whiteColor];
			view.alpha = 0.2;

			[_elements[i] addObject:view];
			[self addSubview:view];
		}
	}
}

#pragma mark -
#pragma mark Touches Handling

- (void) highlighElementColumn:(int)column row:(int)row step:(int)step
{
	if(column >= 0 && column < _elements.count && row >= 0 && [_elements[column] count] > row){
		KRGridElementView * element = _elements[column][row];
		element.activityCount += step;
	}
}

- (void) highlightNeighbours:(KRGridElementView *)element
{
	element.activityCount += 3;
	int row = element.row;
	int column = element.column;

	[self highlighElementColumn:column - 1 row:row - 1 step:1];
	[self highlighElementColumn:column - 1 row:row + 1 step:1];
	[self highlighElementColumn:column + 1 row:row - 1 step:1];
	[self highlighElementColumn:column + 1 row:row + 1 step:1];
	
	[self highlighElementColumn:column row:row + 1 step:2];
	[self highlighElementColumn:column row:row - 1 step:2];
	[self highlighElementColumn:column - 1 row:row step:2];
	[self highlighElementColumn:column + 1 row:row step:2];
}

- (void) redrawElements
{
	for(int i = 0; i < _elements.count; i++){
		for(int j = 0; j < [_elements[i] count]; j++){
			KRGridElementView * element = _elements[i][j];
			[element setActivityCount:0];
		}
	}
	
	for(int i = 0; i < _elements.count; i++){
		for(int j = 0; j < [_elements[i] count]; j++){
			KRGridElementView * element = _elements[i][j];
			if(element.isActive){
				[self highlightNeighbours:element];
			}
		}
	}
}

- (void) selectElement:(KRGridElementView *)elementView
{
	if([elementView isKindOfClass:[KRGridElementView class]]){
		elementView.isActive = YES;
		[_delegate soloNoteOn:elementView.column :elementView.row];
		[self redrawElements];
	}
}

- (void) deselectElement:(KRGridElementView *)elementView
{
	if([elementView isKindOfClass:[KRGridElementView class]]){
		elementView.isActive = NO;
		[_delegate soloNoteOff:elementView.column :elementView.row];
		[self redrawElements];
	}
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch * touch in touches){
		CGPoint point = [touch locationInView:self];
		KRGridElementView * elementView = (KRGridElementView *)[self hitTest:point withEvent:nil];
		[self selectElement:elementView];
	}

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch * touch in touches){
		CGPoint point = [touch locationInView:self];
		KRGridElementView * elementView = (KRGridElementView *)[self hitTest:point withEvent:nil];
		[self deselectElement:elementView];
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
			[self selectElement:elementView];
			[self deselectElement:previousElementView];
		}
	}
}

@end
