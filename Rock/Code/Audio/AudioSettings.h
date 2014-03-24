//
//  AudioSettings.h
//  Rock
//
//  Created by Nick on 21/03/2014.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#ifndef Rock_AudioSettings_h
#define Rock_AudioSettings_h

#define kDefaultTempo 90
#define kTimerCoefficient 1.875f
#define kNumberOfTicksPerBar 32

enum {
    kBass = 0
};

#define kMapNames @[@"bass"]

#define kNoteOnMidiMessage 0x9 << 4 | 0
#define kNoteOffMidiMessage 0x8 << 4 | 0

#define kPrefferedSampleRate 44100.f
#define kPrefferedMaximumFramesPerSlice 4096

#endif
