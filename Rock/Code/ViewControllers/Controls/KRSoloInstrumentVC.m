//
//  KRSoloInstrumentVC.m
//  Rock
//
//  Created by Anton Chebotov on 01/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRSoloInstrumentVC.h"
#import "KRGridView.h"

#define GRID_ROWS 7
#define GRID_COLUMNS 7

#define GRID_OFFSET 1.0f

@interface KRSoloInstrumentVC ()

@property (weak) IBOutlet UIView * gridView;
@end

@implementation KRSoloInstrumentVC

- (void) viewDidLoad
{
	CGFloat width = (_gridView.frame.size.width - (GRID_COLUMNS - 1)*GRID_OFFSET) / GRID_COLUMNS;
	CGFloat height = (_gridView.frame.size.height - (GRID_ROWS - 1)*GRID_OFFSET) / GRID_ROWS;
	
	for (int i = 0; i < GRID_COLUMNS; i++){
		for(int j = 0; j < GRID_ROWS; j++){
			
			CGRect frame = CGRectMake((width + GRID_OFFSET) * i, (height + GRID_OFFSET) * j, width, height);
			KRGridView * view = [[KRGridView alloc] initWithFrame:frame];
			view.backgroundColor = [UIColor whiteColor];
			view.alpha = 0.2;

			[_gridView addSubview:view];
		}
	}
}

@end
