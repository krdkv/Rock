//
//  DrumComposer.h
//  Rock
//
//  Created by Nick on 29/05/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrumComposer : NSObject



- (instancetype)initWithNumberOfBars:(NSInteger)numberOfBars;

@property (nonatomic, strong) NSMutableArray * notes;
@property (nonatomic, assign) NSInteger strongVelocity;
@property (nonatomic, assign) NSInteger weakVelocity;

- (void) addDrumWithMidiKeys:(NSArray*)keys
            withMainInterval:(NSInteger)interval
             playStrongNotes:(NSInteger)playStrongNotes
                  leftOffset:(NSInteger)leftOffset
                 rightOffset:(NSInteger)rightOffset
                   intensity:(CGFloat)intensity
                        dust:(CGFloat)dustLevel
                  dustOffset:(NSInteger)dustOffset;

- (void) reset;

@end
