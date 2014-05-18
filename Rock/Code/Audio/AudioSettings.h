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

#define kDefaultTempo 130
#define kNumberOfTicksPerBar 32
#define kTimerCoefficient 1.875f * 4

enum {
    kBass = 0,
    kDrums,
    kGuitar
};

enum {
    kReverb = kAudioUnitSubType_Reverb2,
    kDelay = kAudioUnitSubType_Delay,
    kDistortion = kAudioUnitSubType_Distortion,
    kHighPass = kAudioUnitSubType_HighPassFilter,
    kLowPass = kAudioUnitSubType_LowPassFilter
};

enum {
    C1 = 24,
    C1d,
    D1,
    D1d,
    E1,
    F1,
    F1d,
    G1,
    G1d,
    A1,
    A1d,
    B2
};

#define plusOctave(x) x+12
#define minusOctave(x) x-12

#define kEffects @[  @[@(kDistortion)], @[@(kHighPass), @(kLowPass), @(kReverb)], @[@(kHighPass)] ]

#define kDrumHighPass @[ @{@"p":@(kHipassParam_CutoffFrequency), @"on":@482.8871f, @"off":@10.f}, @{@"p":@(kHipassParam_Resonance), @"on":@7.75f, @"off":@0.f} ]

#define kDrumLowPass @[ @{@"p":@(kLowPassParam_CutoffFrequency), @"on":@1540.5698f, @"off":@6900}, @{@"p":@(kLowPassParam_Resonance), @"on":@11.81f, @"off":@0.f}  ]

#define kDrumReverb @[ @{@"p":@(kReverb2Param_DryWetMix), @"on":@43, @"off":@0.f}, @{@"p":@(kReverb2Param_MaxDelayTime), @"on":@0.061f, @"off":@0.050f}, @{@"p":@(kReverb2Param_MinDelayTime), @"on":@0.0147f, @"off":@0.008f}  ]

#define kBassDistortion @[ @{@"p":@(0), @"on":@500.f, @"off":@0.1, }, @{@"p":@(1), @"on":@9.73f, @"off":@0, },@{@"p":@(2), @"on":@0, @"off":@0, },@{@"p":@(3), @"on":@0.4095, @"off":@0, },@{@"p":@(4), @"on":@81.8981, @"off":@0, },@{@"p":@(5), @"on":@4.5, @"off":@0, },@{@"p":@(6), @"on":@0.385, @"off":@0, },@{@"p":@(7), @"on":@20.f, @"off":@0, },@{@"p":@(8), @"on":@16.1, @"off":@0, },@{@"p":@(9), @"on":@19.5, @"off":@0, },@{@"p":@(10), @"on":@44.f, @"off":@100, },@{@"p":@(11), @"on":@1147, @"off":@100, },@{@"p":@(12), @"on":@50, @"off":@50, },@{@"p":@(13), @"on":@0.5, @"off":@0, },@{@"p":@(14), @"on":@-0.9f, @"off":@0, },@{@"p":@(15), @"on":@44.6, @"off":@0, }            ]

#define kGuitarHighPass @[ @{@"p":@(kHipassParam_CutoffFrequency), @"on":@100.f, @"off":@10.f}, @{@"p":@(kHipassParam_Resonance), @"on":@20.f, @"off":@0.f} ]

#define kReverbSettings @[@{@"p":@(kReverb2Param_DryWetMix), @"on":@60.f}, @{@"p":@(kReverb2Param_MaxDelayTime), @"on":@0.061f}, @{@"p":@(kReverb2Param_MinDelayTime), @"on":@0.0147f}]

#define kDelaySettings @[@{@"p":@(kDelayParam_WetDryMix), @"on":@22.7}, @{@"p":@(kDelayParam_DelayTime), @"on":@0.5f}, @{@"p":@(kDelayParam_Feedback), @"on":@58.6f}, @{@"p":@(kDelayParam_LopassCutoff), @"on":@22050.f}]

#define kEffectSettings @[ @[kBassDistortion], @[kDrumHighPass, kDrumLowPass, kDrumReverb], @[kGuitarHighPass]   ]

#define kMapNames @[@"bass_solo", @"drums_full", @"guitar_solo"]

#define kNoteOnMidiMessage 0x9 << 4 | 0
#define kNoteOffMidiMessage 0x8 << 4 | 0

#define kPrefferedSampleRate 44100.f
#define kPrefferedMaximumFramesPerSlice 4096

#endif
