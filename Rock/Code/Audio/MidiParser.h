//
//  MidiParser.h
//  Rock
//
//  Created by Nick on 21/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MidiParser : NSObject

- (void) parseMidiFileWithFileName:(NSString*)filName;

@end
