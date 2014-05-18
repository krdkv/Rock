//
//  Knob.h
//  Rock
//
//  Created by Nick on 13/05/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Knob : UIControl

@property (nonatomic, strong) void(^onTick)(void);

- (void) startAutospin;
- (void) stopAutospin;
@end
