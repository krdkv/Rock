//
//  KRGridView.h
//  Rock
//
//  Created by Anton Chebotov on 17/05/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KRSoloInstrumentDelegate
- (void) soloNoteOn:(int)x :(int)y;
- (void) soloNoteOff:(int)x :(int)y;
@end

@interface KRGridView : UIView
{
}
@property (weak) id <KRSoloInstrumentDelegate> delegate;
- (void) setupWithRows:(NSInteger)rows columns:(NSInteger)columns;

@end
