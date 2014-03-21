//
//  AudioSampler.m
//  Rock
//
//  Created by Nick on 21/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "AudioSampler.h"
#import "AudioSettings.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioSampler() {
    AUGraph _graph;
    AudioUnit * _samplerUnits;
    AudioUnit _mixerUnit, _ioUnit;
    void(^_setupOnComplete)(void);
}

@end

@implementation AudioSampler

- (void) setupOnComplete:(void(^)(void))onComplete {
    [self setupAudioSession];
    [self initAUGraph];
    [self loadSampleMaps];
    
    if ( onComplete ) {
        onComplete();
    }
}

- (void) sendNoteOnToInstrument:(int)instrument
                        midiKey:(int)midiKey
                       velocity:(int)velocity {
    
	MusicDeviceMIDIEvent (_samplerUnits[instrument], kNoteOnMidiMessage, midiKey, velocity, 0);
}

- (void) sendNoteOffToInstrument:(int)instrument
                         midiKey:(int)midiKey {
    
    MusicDeviceMIDIEvent (_samplerUnits[instrument], kNoteOffMidiMessage, midiKey, 0, 0);
}

- (void) setupAudioSession {
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    NSError *audioSessionError = nil;
    
    [mySession setCategory:AVAudioSessionCategoryPlayback error: &audioSessionError];
    NSAssert(audioSessionError == nil, @"Can't set category to audio session");
    
    [mySession setPreferredSampleRate:kPrefferedSampleRate error:&audioSessionError];
    NSAssert(audioSessionError == nil, @"Can't set sample rate");
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void) initAUGraph {
    OSStatus result = noErr;
	AUNode *samplerNodes, mixerNode, ioNode;
    
    AudioComponentDescription cd = {};
	cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
	cd.componentFlags            = 0;
	cd.componentFlagsMask        = 0;
    
    // Creating graph
    
    result = NewAUGraph (&_graph);
    NSCAssert (result == noErr, @"Unable to create an AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Allocating memory for units and nodes
    
    samplerNodes = malloc(kMapNames.count * sizeof(AUNode));
    _samplerUnits = malloc(kMapNames.count * sizeof(AudioUnit));
    
    // Adding samplers
    
    cd.componentType = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_Sampler;
    
    for ( int i = 0; i < kMapNames.count; ++i ) {
        result = AUGraphAddNode (_graph, &cd, &samplerNodes[i]);
        NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    }
    
    // Adding mixer and io
    
    cd.componentType = kAudioUnitType_Mixer;
    cd.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    
    result = AUGraphAddNode(_graph, &cd, &mixerNode);
    
    cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_RemoteIO;
    
	result = AUGraphAddNode (_graph, &cd, &ioNode);
    NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Opening graph, making connections
    
    result = AUGraphOpen (_graph);
    NSCAssert (result == noErr, @"Unable to open the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    for ( int i = 0; i < kMapNames.count; ++i ) {
        result = AUGraphConnectNodeInput (_graph, samplerNodes[i], 0, mixerNode, i);
        NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    }
    
    result = AUGraphConnectNodeInput (_graph, mixerNode, 0, ioNode, 0);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Obtaining units
    
    for ( int i = 0; i < kMapNames.count; ++i ) {
        result = AUGraphNodeInfo (_graph, samplerNodes[i], 0, &_samplerUnits[i]);
        NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    }
    
    result = AUGraphNodeInfo (_graph, mixerNode, 0, &_mixerUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Mixer unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphNodeInfo (_graph, ioNode, 0, &_ioUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Setting maximum frame per slice
    
    UInt32 maximumFramesPerSlice = kPrefferedMaximumFramesPerSlice;
    
    AudioUnitSetProperty (_mixerUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maximumFramesPerSlice, sizeof (maximumFramesPerSlice));
    
    for ( int i = 0; i < kMapNames.count; ++i ) {
        AudioUnitSetProperty (_samplerUnits[i], kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maximumFramesPerSlice, sizeof (maximumFramesPerSlice));
    }
    
    // Setting sample rate
    
    result = AudioUnitInitialize (_ioUnit);
    NSCAssert (result == noErr, @"Unable to initialize the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    Float64 sampleRate = kPrefferedSampleRate;
    
    result = AudioUnitSetProperty (_ioUnit, kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, 0, &sampleRate, sizeof(sampleRate));
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    for ( int i = 0; i < kMapNames.count; ++i ) {
        result = AudioUnitSetProperty (_samplerUnits[i], kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, 0, &sampleRate, sizeof(sampleRate));
        NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    }
    
    // Starting graph
    
    result = AUGraphInitialize (_graph);
    NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Start the graph
    result = AUGraphStart (_graph);
    NSAssert (result == noErr, @"Unable to start audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Print out the graph to the console
    CAShow (_graph);
}

- (void) loadSampleMaps {

    for ( int i = 0; i < kMapNames.count; ++i ) {
        NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bass" ofType:@"aupreset"]];
        NSAssert(presetURL, @"Could not load preset: %@", kMapNames[i]);
        [self loadMapForUrl:presetURL andUnit:_samplerUnits[i]];
    }
}

- (void) loadMapForUrl:(NSURL*)url andUnit:(AudioUnit)unit {
    NSError * error;
	
	// Read from the URL and convert into a CFData chunk
    NSData * data = [NSData dataWithContentsOfURL:url
                                          options:0
                                            error:&error];
   	NSAssert(!error, @"Can't read data");
    
	CFPropertyListRef presetPropertyList = 0;
	CFPropertyListFormat dataFormat = 0;
	CFErrorRef errorRef = 0;
	presetPropertyList = CFPropertyListCreateWithData (kCFAllocatorDefault, (__bridge CFDataRef)(data), kCFPropertyListImmutable, &dataFormat, &errorRef);
    
	if (presetPropertyList != 0) {
        
		AudioUnitSetProperty(unit, kAudioUnitProperty_ClassInfo, kAudioUnitScope_Global, 0, &presetPropertyList, sizeof(CFPropertyListRef) );
        
		CFRelease(presetPropertyList);
	}
}

- (void) dealloc {
    
}

@end