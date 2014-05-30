//
//  DrumComposer.m
//  Rock
//
//  Created by Nick on 29/05/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "DrumComposer.h"
#import "AudioSettings.h"

#define kDefaultStrongVelocity 125
#define kDefaultWeakVelocity 90

@interface DrumComposer() {
    NSInteger _numberOfBars;
}

@end

@implementation DrumComposer

- (instancetype)initWithNumberOfBars:(NSInteger)numberOfBars
{
    self = [super init];
    if (self) {
        _numberOfBars = numberOfBars;
        _notes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger) strongVelocityValue {
    return self.strongVelocity != 0 ? self.strongVelocity : kDefaultStrongVelocity;
}

- (NSInteger) weakVelocityValue {
    return self.weakVelocity != 0 ? self.weakVelocity : kDefaultWeakVelocity;
}

- (void) reset {
    [self.notes removeAllObjects];
}

- (void) addDrumWithMidiKeys:(NSArray*)keys
            withMainInterval:(NSInteger)interval
             playStrongNotes:(NSInteger)playStrongNotes
                  leftOffset:(NSInteger)leftOffset
                 rightOffset:(NSInteger)rightOffset
                   intensity:(CGFloat)intensity
                        dust:(CGFloat)dustLevel
                  dustOffset:(NSInteger)dustOffset
{
    
    if ( keys.count == 0 ) {
        return;
    }
    
    if ( intensity == 0 ) {
        return;
    }
    
    int currentDrumKey = 0;
    int strongNoteIndex = 0;
    
    if ( rightOffset == - 1 ) {
        rightOffset = INT_MAX;
    }
    
    if ( interval == - 1 ) {
        interval = 3 + arc4random()%13;
    }
    
    for ( int tickIndex = 0; tickIndex < _numberOfBars * kNumberOfTicksPerBar; ++tickIndex ) {
    
        if ( tickIndex < leftOffset ) {
            continue;
        }
        
        if ( tickIndex >= rightOffset ) {
            continue;
        }
        
        if ( tickIndex % interval != 0 ) {
            continue;
        }
        
        if ( (playStrongNotes == kStrongNotesOnly && strongNoteIndex == 0 )
            || ( playStrongNotes == kWeakNotesOnly && strongNoteIndex == 1 ) ) {
            
            strongNoteIndex = strongNoteIndex == 1 ? 0 : 1;
            
            continue;
        }
        
        if ( arc4random() % (int)( 1 / intensity) != 0 ) {
            continue;
            
            ++currentDrumKey;
            if ( currentDrumKey == keys.count ) {
                currentDrumKey = 0;
            }
        }
        
        NSInteger velocity = strongNoteIndex == 0 ? [self strongVelocityValue] : [self weakVelocityValue];
        
        [_notes addObject:@{@"k": @([keys[currentDrumKey] intValue]), @"o": @(tickIndex), @"d": @(100), @"v": @(velocity)}];
        
        if ( dustLevel != 0 ) {            
            if ( arc4random() % (int)(1 / dustLevel) == 0 ) {
                    NSInteger drum = [kDrumKeys[arc4random()%kDrumKeys.count] intValue];
                    NSInteger velocity = [self weakVelocityValue] + arc4random() % ( [self strongVelocityValue] - [self weakVelocityValue]);
                    
                    if ( tickIndex + dustOffset < _numberOfBars * kNumberOfTicksPerBar && tickIndex + dustOffset >= 0 ) {
                        [self.notes addObject:@{@"k": @(drum), @"o": @(tickIndex+dustOffset), @"d": @(100), @"v": @(velocity)}];
                    }
            }
        }
        
        strongNoteIndex = strongNoteIndex == 1 ? 0 : 1;
        
        ++currentDrumKey;
        if ( currentDrumKey == keys.count ) {
            currentDrumKey = 0;
        }
    }
}

@end
