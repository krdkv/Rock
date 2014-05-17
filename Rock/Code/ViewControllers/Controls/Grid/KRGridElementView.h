//
//  KRGridView.h
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRGridElementView : UIView

@property (assign, nonatomic) NSInteger activityCount;
@property (assign) BOOL isActive;

@property (assign) NSInteger column;
@property (assign) NSInteger row;

@end
