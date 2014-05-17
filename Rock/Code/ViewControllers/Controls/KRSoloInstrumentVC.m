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

@interface KRSoloInstrumentVC ()

@property (weak) IBOutlet KRGridView * gridView;
@end

@implementation KRSoloInstrumentVC

- (void) viewDidLoad
{
	[_gridView setupWithRows:GRID_ROWS columns:GRID_COLUMNS];
	_gridView.delegate = _delegate;
}

@end
