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
    kDistortion = kAudioUnitSubType_Distortion
};

#define kEffects @[  @[@(kReverb)], @[@(kReverb)], @[@(kDelay)] ]

/*
 @{@"property":@(kDistortionParam_Delay), @"onValue":@(0.1f), @"offValue":@(0.1f)},
 @{@"property":@(kDistortionParam_Decay), @"onValue":@(0.1f), @"offValue":@(0.f)},
 @{@"property":@(kDistortionParam_DelayMix), @"onValue":@(0.f), @"offValue":@(0.f)},
 @{@"property":@(kDistortionParam_RingModFreq1), @"onValue":@(44.f), @"offValue":@(100.f)},
 @{@"property":@(kDistortionParam_RingModFreq2), @"onValue":@(1147.f), @"offValue":@(100.f)},
 @{@"property":@(kDistortionParam_RingModBalance), @"onValue":@(12.1f), @"offValue":@(50.f)},
 @{@"property":@(kDistortionParam_RingModMix), @"onValue":@(0.f), @"offValue":@(0.f)},
 @{@"property":@(kDistortionParam_Decimation), @"onValue":@(10.f), @"offValue":@(0.f)},
 @{@"property":@(kDistortionParam_Rounding), @"onValue":@(0.f), @"offValue":@(0.f)},
 @{@"property":@(kDistortionParam_DecimationMix), @"onValue":@(0.7f), @"offValue":@(0.f)},
 @{@"property":@(kDistortionParam_LinearTerm), @"onValue":@(1.f), @"offValue":@(0.f)},
 @{@"property":@(kDistortionParam_SquaredTerm), @"onValue":@(18.07f), @"offValue":@(0.f)},
 @{@"property":@(kDistortionParam_CubicTerm), @"onValue":@(17.96f), @"offValue":@(0.f)},
 @{@"property":@(kDistortionParam_PolynomialMix), @"onValue":@(99.f), @"offValue":@(0.f)},
 @{@"property":@(kDistortionParam_SoftClipGain), @"onValue":@(6.6f), @"offValue":@(0.f)},
 @{@"property":@(kDistortionParam_FinalMix), @"onValue":@(34.5f), @"offValue":@(0.f)},
*/

#define kEffectSettings @[ @[@[@{@"p":@(kReverb2Param_DryWetMix), @"on":@60.f}, @{@"p":@(kReverb2Param_MaxDelayTime), @"on":@0.061f}, @{@"p":@(kReverb2Param_MinDelayTime), @"on":@0.0147f}]],                  @[@[@{@"p":@(kReverb2Param_DryWetMix), @"on":@50.f}, @{@"p":@(kReverb2Param_MaxDelayTime), @"on":@0.061f}, @{@"p":@(kReverb2Param_MinDelayTime), @"on":@0.0147f}]],                  @[@[@{@"p":@(kDelayParam_WetDryMix), @"on":@22.7}, @{@"p":@(kDelayParam_DelayTime), @"on":@0.5f}, @{@"p":@(kDelayParam_Feedback), @"on":@58.6f}, @{@"p":@(kDelayParam_LopassCutoff), @"on":@22050.f}]]]

#define kMapNames @[@"bass_solo", @"drums_full", @"guitar_solo"]

#define kNoteOnMidiMessage 0x9 << 4 | 0
#define kNoteOffMidiMessage 0x8 << 4 | 0

#define kPrefferedSampleRate 44100.f
#define kPrefferedMaximumFramesPerSlice 4096

#endif
