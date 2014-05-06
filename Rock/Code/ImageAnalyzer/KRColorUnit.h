//
//  KRColorUnit.h
//  Rock
//
//  Created by Anton Chebotov on 28/04/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRColorUnit : NSObject 
{
	
}
@property (assign) CGFloat red;
@property (assign) CGFloat green;
@property (assign) CGFloat blue;
@property (assign) NSInteger frequency;

@property  (strong) NSString * description;

- (id) initWithUIColor:(UIColor *)color name:(NSString *)name;
- (id) initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue name:(NSString *)name;

@end
