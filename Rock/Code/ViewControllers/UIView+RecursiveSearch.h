//
//  UIView+RecursiveSearch.h
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RecursiveSearch)

- (BOOL) shouldAvoidScrolling:(CGPoint)point event:(UIEvent *)event;

@end
