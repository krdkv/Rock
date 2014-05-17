//
//  KREffectsVC.m
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KREffectsVC.h"
#import "DynamicColorAnalyzer.h"

@interface KREffectsVC () <DynamicColorAnalyzerDelegate>
{
	UIButton * _selectedButton;
	DynamicColorAnalyzer * _colorAnalyzer;
}
@property (weak) IBOutlet UIButton * guitarButton;
@property (weak) IBOutlet UIButton * bassButton;
@property (weak) IBOutlet UIButton * drumsButton;

- (IBAction)chooseColor:(UIButton *)sender;
@end

@implementation KREffectsVC


- (void)viewDidLoad
{
    [super viewDidLoad];
	_colorAnalyzer = [DynamicColorAnalyzer new];
	_colorAnalyzer.delegate = self;
}

- (IBAction)chooseColor:(UIButton *)sender
{
	if(sender == _selectedButton){
		[self stopColorDetecting];
	}
	else {
		[self stopColorDetecting];
		_selectedButton = sender;
		[self startColorDetecting];
	}
}

- (void) startColorDetecting
{
	[_colorAnalyzer start];
}

- (void) stopColorDetecting
{
	[_colorAnalyzer stop];
	if(_selectedButton == _guitarButton){
		[_delegate guitarEffectColorSelected:_guitarButton.backgroundColor];
	}
	else if (_selectedButton == _bassButton){
		[_delegate bassEffectColorSelected:_bassButton.backgroundColor];
	}
	else if (_selectedButton == _drumsButton){
		[_delegate drumsEffectColorSelected:_drumsButton.backgroundColor];
	}
	_selectedButton = nil;
}

#pragma mark -
#pragma mark DynamicColorAnalyzerDelegate Methods

- (void) mostPopularColorChanged:(UIColor *)color
{
	_selectedButton.backgroundColor = color;
}
@end
