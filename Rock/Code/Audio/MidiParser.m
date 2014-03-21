//
//  MidiParser.m
//  Rock
//
//  Created by Nick on 21/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "MidiParser.h"
#import <AudioToolbox/MusicPlayer.h>

@implementation MidiParser

- (void) parseMidiFileWithFileName:(NSString*)fileName {
    
    MusicSequence s;
    NewMusicSequence(&s);
    
    NSString *midiFilePath = [[NSBundle mainBundle]
                              pathForResource:fileName
                              ofType:@"mid"];
    
    NSURL * midiFileURL = [NSURL fileURLWithPath:midiFilePath];
    
    MusicSequenceFileLoad(s, (__bridge CFURLRef)midiFileURL, 0, 0);
    
    MusicTrack track = NULL;
    
    UInt32 tracks;
    MusicSequenceGetTrackCount(s, &tracks);
    
    for (NSInteger i=0; i<tracks; i++) {
        
        NSLog(@"#### Track: %d", i);
        
        MusicSequenceGetIndTrack(s, i, &track);
        
        // Create an interator
        MusicEventIterator iterator = NULL;
        NewMusicEventIterator(track, &iterator);
        MusicTimeStamp timestamp = 0;
        MusicEventType eventType = 0;
        
        const void *eventData = NULL;
        UInt32 eventDataSize = 0;
        
        Boolean hasNext = YES;
        
        // A variable to store note messages
        MIDINoteMessage * midiNoteMessage;
        
        // Iterate over events
        while (hasNext) {
            
            // See if there are any more events
            MusicEventIteratorHasNextEvent(iterator, &hasNext);
            
            // Copy the event data into the variables we prepaired earlier
            MusicEventIteratorGetEventInfo(iterator, &timestamp, &eventType, &eventData, &eventDataSize);
            
            // Process Midi Note messages
            if(eventType==kMusicEventType_MIDINoteMessage) {
                // Cast the midi event data as a midi note message
                midiNoteMessage = (MIDINoteMessage*) eventData;
                
                NSLog(@"Midi note message: note: %d, velocity: %d, duration: %f ", midiNoteMessage->note, midiNoteMessage->velocity, midiNoteMessage->duration);
                
            }
            
            MusicEventIteratorNextEvent(iterator);
        }
    }
}

@end
