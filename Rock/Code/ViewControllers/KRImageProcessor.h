//
//  KRImageProcessor.h
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRImageProcessor : NSObject


+ (UIImage *) blur:(UIImage*)theImage width:(CGFloat)width height:(CGFloat)height;
@end
