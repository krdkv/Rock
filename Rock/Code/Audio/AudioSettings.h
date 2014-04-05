//
//  AudioSettings.h
//  Rock
//
//  Created by Nick on 21/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#ifndef Rock_AudioSettings_h
#define Rock_AudioSettings_h

#import <AudioToolbox/AudioToolbox.h>

#define kDefaultTempo 120
#define kTimerCoefficient 1.875f * 4
#define kNumberOfTicksPerBar 32

enum {
    kBass = 0,
    kDrums
};

enum {
    kReverb = kAudioUnitSubType_Reverb2,
    kDelay = kAudioUnitSubType_Delay
};

#define kEffects @[@[@(kDelay)], @[@(kReverb)]]

#define kEffectSettings @[ @[@[]],                                                                                                                             @[@[@{@"p":@(kReverb2Param_DryWetMix), @"on":@70.f}, @{@"p":@(kReverb2Param_MaxDelayTime), @"on":@0.061f}, @{@"p":@(kReverb2Param_MinDelayTime), @"on":@0.0147f}]],  ]

#define kMapNames @[@"bass_solo", @"drums_full"]

#define kNoteOnMidiMessage 0x9 << 4 | 0
#define kNoteOffMidiMessage 0x8 << 4 | 0

#define kPrefferedSampleRate 44100.f
#define kPrefferedMaximumFramesPerSlice 4096

#endif
